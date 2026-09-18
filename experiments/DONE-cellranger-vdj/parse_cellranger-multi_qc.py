#!/usr/bin/env python3

import argparse
import csv
import json
import logging
import re
import shlex
import shutil
import sys
from pathlib import Path


ALERT_FIELDS = [
    "Run", "Sample", "Scope", "Category", "Library Type", "Grouped By",
    "Group Name", "File", "Level", "Title", "Value", "Message",
]


def parse_args():
    parser = argparse.ArgumentParser(
        description="Create QC summary TSVs from Cell Ranger multi output directories."
    )
    parser.add_argument(
        "root",
        nargs="?",
        default=".",
        help="Directory to search recursively (default: current directory)",
    )
    parser.add_argument(
        "-o",
        "--output-dir",
        default=".",
        help="Directory for output TSV files (default: current directory)",
    )
    parser.add_argument(
        "--log-file",
        help="Log file (default: <output-dir>/cellranger-multi_qc.log)",
    )
    return parser.parse_args()


def sample_info(path):
    """Return (run, sample) for a per-sample Cell Ranger multi output file."""
    if path.parent.parent.name != "per_sample_outs":
        return None
    return path.parents[3].name, path.parent.name


def alert_info(path):
    """Return (run, sample) for per-sample or run-level web summaries."""
    info = sample_info(path)
    if info is not None:
        return info
    if path.parent.name == "outs":
        return path.parent.parent.name, ""
    return "", path.parent.name


def extract_alert_objects(text):
    """Yield JSON alert objects whose first field is level=ERROR or level=WARN."""
    decoder = json.JSONDecoder()
    pattern = re.compile(r'\{"level":"(?:ERROR|WARN)"')

    for match in pattern.finditer(text):
        try:
            alert, _ = decoder.raw_decode(text, match.start())
        except json.JSONDecodeError:
            continue
        if isinstance(alert, dict):
            yield alert


def read_metrics(root):
    wide_rows = []
    wide_columns = []
    metric_files = []
    metrics_by_sample = {}

    for path in sorted(root.rglob("metrics_summary.csv")):
        info = sample_info(path)
        if info is None:
            continue

        run, sample = info
        metric_files.append(path)

        with path.open(newline="", encoding="utf-8-sig") as handle:
            rows = list(csv.DictReader(handle))

        metrics_by_sample[(run, sample)] = rows

        sample_row = {"Run": run, "Sample": sample}
        for row in rows:
            if row.get("Category") == "Cells" and not row.get("Grouped By", "").strip():
                metric = row.get("Metric Name", "").strip()
                if not metric:
                    continue
                sample_row[metric] = row.get("Metric Value", "").strip()
                if metric not in wide_columns:
                    wide_columns.append(metric)

        wide_rows.append(sample_row)

    return metric_files, wide_rows, wide_columns, metrics_by_sample


def normalize_metric_name(value):
    return " ".join(re.findall(r"[a-z0-9]+", value.lower()))


def match_alert_metadata(alert, metric_rows):
    title = normalize_metric_name(str(alert.get("title", "")))
    value = str(alert.get("formatted_value", "")).strip()
    matches = []

    for row in metric_rows:
        metric_name = normalize_metric_name(row.get("Metric Name", ""))
        metric_value = row.get("Metric Value", "").strip()
        if metric_name and metric_name in title and metric_value == value:
            matches.append(row)

    if not matches:
        return {
            "Scope": "",
            "Category": "",
            "Library Type": "",
            "Grouped By": "",
            "Group Name": "",
        }

    metadata_fields = ["Category", "Library Type", "Grouped By", "Group Name"]
    unique_metadata = []
    for row in matches:
        metadata = tuple(row.get(field, "").strip() for field in metadata_fields)
        if metadata not in unique_metadata:
            unique_metadata.append(metadata)

    categories = [metadata[0] for metadata in unique_metadata]
    scopes = []
    for category in categories:
        scope = {"Library": "Library", "Cells": "Sample"}.get(category, category)
        if scope and scope not in scopes:
            scopes.append(scope)

    return {
        "Scope": " | ".join(scopes),
        **{
            field: " | ".join(dict.fromkeys(metadata[index] for metadata in unique_metadata))
            for index, field in enumerate(metadata_fields)
        },
    }


def read_alerts(root, metrics_by_sample):
    alert_rows = []
    web_summary_files = []

    for path in sorted(root.rglob("web_summary.html")):
        web_summary_files.append(path)
        run, sample = alert_info(path)
        text = path.read_text(errors="replace")
        seen = set()

        for alert in extract_alert_objects(text):
            key = (
                alert.get("level", ""),
                alert.get("title", ""),
                alert.get("formatted_value", ""),
                alert.get("message", ""),
            )
            if key in seen:
                continue
            seen.add(key)
            metadata = match_alert_metadata(alert, metrics_by_sample.get((run, sample), []))
            alert_rows.append({
                "Run": run,
                "Sample": sample,
                **metadata,
                "File": str(path),
                "Level": alert.get("level", ""),
                "Title": alert.get("title", ""),
                "Value": alert.get("formatted_value", ""),
                "Message": alert.get("message", ""),
            })

    level_order = {"ERROR": 0, "WARN": 1}
    category_order = {"Cells": 0, "Library": 1}
    alert_rows.sort(key=lambda row: (
        level_order.get(row["Level"], 2),
        category_order.get(row["Category"], 2),
        row["Run"],
        row["Sample"],
        row["Title"],
    ))

    return web_summary_files, alert_rows


def write_tsv(path, fieldnames, rows):
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=fieldnames,
            delimiter="\t",
            extrasaction="ignore",
        )
        writer.writeheader()
        writer.writerows(rows)


def configure_logging(log_file):
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s | %(levelname)s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        handlers=[
            logging.FileHandler(log_file, mode="w", encoding="utf-8"),
            logging.StreamHandler(),
        ],
    )
    return logging.getLogger(__name__)


def copy_sample_web_summaries(web_summary_files, output_dir, logger):
    web_summaries_dir = output_dir / "web_summaries"
    web_summaries_dir.mkdir(parents=True, exist_ok=True)
    copied = 0
    destinations = {}

    for source in web_summary_files:
        info = sample_info(source)
        if info is None:
            continue

        run, sample = info
        destination = web_summaries_dir / f"{sample}_web_summary.html"

        if destination in destinations and destinations[destination] != source:
            logger.error(
                "Duplicate sample name '%s' in runs '%s' and '%s'; both would copy to %s",
                sample,
                alert_info(destinations[destination])[0],
                run,
                destination,
            )
            raise SystemExit(1)

        shutil.copy2(source, destination)
        destinations[destination] = source
        copied += 1

    return web_summaries_dir, copied


def main():
    args = parse_args()
    root = Path(args.root).expanduser().resolve()
    output_dir = Path(args.output_dir).expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    log_file = (
        Path(args.log_file).expanduser().resolve()
        if args.log_file
        else output_dir / "cellranger-multi_qc.log"
    )
    log_file.parent.mkdir(parents=True, exist_ok=True)
    logger = configure_logging(log_file)

    logger.info("Command: %s", shlex.join(sys.argv))
    logger.info("Search root: %s", root)
    logger.info("Output directory: %s", output_dir)
    logger.info("Log file: %s", log_file)

    if not root.is_dir():
        logger.error("Search directory does not exist: %s", root)
        raise SystemExit(1)

    metric_files, wide_rows, wide_columns, metrics_by_sample = read_metrics(root)
    web_summary_files, alert_rows = read_alerts(root, metrics_by_sample)

    if not metric_files and not web_summary_files:
        logger.error(
            "No per-sample metrics_summary.csv or web_summary.html files found under %s",
            root,
        )
        raise SystemExit(1)

    wide_path = output_dir / "sample_metrics_summary.tsv"
    alerts_path = output_dir / "alerts_web_summary.tsv"

    write_tsv(wide_path, ["Run", "Sample"] + wide_columns, wide_rows)
    write_tsv(alerts_path, ALERT_FIELDS, alert_rows)
    web_summaries_dir, copied_web_summaries = copy_sample_web_summaries(
        web_summary_files,
        output_dir,
        logger,
    )

    logger.info("Processed %d per-sample metrics files", len(metric_files))
    logger.info("Processed %d web summaries", len(web_summary_files))
    logger.info("Extracted %d unique WARN/ERROR alerts", len(alert_rows))
    matched_alerts = sum(bool(row["Scope"]) for row in alert_rows)
    logger.info("Matched %d alerts to metrics_summary.csv metadata", matched_alerts)
    logger.info("Copied %d per-sample web summaries to %s", copied_web_summaries, web_summaries_dir)
    logger.info("Created: %s", wide_path)
    logger.info("Created: %s", alerts_path)
    logger.info("Finished successfully")


if __name__ == "__main__":
    main()
