# Choosing a `cellranger` pipeline #

If you are unsure, use this link from 10X Genomics cellranger website to decide: https://www.10xgenomics.com/support/software/cell-ranger/10.0/analysis/running-pipelines/cr-choosing-a-pipeline

----

| Pipeline | Use Case(s) | Link |
|---|---|---|
| `cellranger count` | Universal 3' GEX, Singleplex; Universal 5' GEX, Singleplex | [cellranger-count]() |
| `cellranger vdj` | Universal 5' VDJ | [cellranger-vdj]() |
| `cellranger atac` | Chromium Epi ATAC data | [cellranger-atac]() |
| `cellranger arc` | Single Cell Multiome ATAC + GEX | [cellranger-arc]() |
| `cellranger multi` | Single cell data not covered by `cellranger-count`, `cellranger-vdj`, `cellranger-arc`, or `cellranger-atac`<br>Examples: GEX + VDJ data, any multiplexed data (OCM, Hashtag, CellPlex/CMO), Flex v1/v2 data | [cellranger-multi](./cellranger-multi.md) |
