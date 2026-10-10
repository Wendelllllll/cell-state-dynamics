# Data and method notes

## Source and scope

This repository organizes materials from Sam's project in Nan Hao's lab. The source folder contains MATLAB scripts, two Live Scripts, three CSV exports, planning diagrams, and a copy of the older `ictrack` package. The package's own documentation identifies an earlier imaging-analysis workflow (HYK, 2016), with some routines dated 2011. It is an upstream tool, not a new implementation from this project, and is not redistributed here.

The planning diagrams describe additional work involving a variational autoencoder, morphology/texture features, Louvain clustering, and aging-mode assignment. They establish research context, not completed implementations. No training code, model weights, embedding configuration, validated mode labels, or definitive biological outcomes were recovered from this folder. The microscopy images themselves are also absent.

## Published data

| File | What one row means | Contents |
| --- | --- | --- |
| `data/cell_observations.csv` | One tracked-object observation at a recorded frame | 6,399 rows; 17 selected columns from `CropProperties_processed_masktexture_nowash_umap.csv` |
| `data/segmentation_by_frame.csv` | One frame in the primary nucleus export | 433 rows; object count and median area, perimeter, and intensity |

The embedding extract retains all source rows and their order. It omits only the `dirname` field and the 200 numeric feature columns `m0`–`m99` / `t0`–`t99`. Coordinates and measurements are not recomputed, rescaled, or imputed. CSV reserialization can change insignificant decimal formatting. There are no missing or nonfinite values in this extract.

The 48 global IDs map to only 41 distinct `(Movie, track)` pairs; seven pairs have two global IDs. There are also 1,043 rows beyond the first occurrence of `(Movie, Frame, CellID)` keys. For example, global IDs 55 and 60 share movie/track identity and measurements but have slightly different embedding coordinates. The export history does not explain this. Rows are retained as supplied, not silently deduplicated, and are not treated as independent biological samples. The trajectory examples use distinct movie/track pairs.

### Observation fields

| Fields | Interpretation |
| --- | --- |
| `idx_glob` | Global track identifier used by the supplied trajectory scripts; 48 distinct values |
| `Movie`, `track` | Source movie and within-movie track identifiers; each `idx_glob` maps to one pair |
| `Frame` | Recorded frame number, spanning 1–321; elapsed time and biological age are not supplied |
| `CellID` | Source object identifier; not substituted for `idx_glob` |
| `Centroid_X`, `Centroid_Y`, `Area`, `Perimeter` | Image-derived measurements retained with their original names; calibration is not supplied |
| `fluo1`, `fluo1_corr`, `fluo1_mean`, `fluo1_mean_corr`, `fluo2`, `fluo2_corr` | Source fluorescence measurements; channel identity and correction procedure are not reconstructed here |
| `xumap`, `yumap` | Precomputed embedding coordinates; not microscope positions |

For the segmentation summary, `object_count` counts rows per `Frame Number` in `nuclei_segmentation.csv`. The three medians are computed directly from `Area`, `Perimeter`, and `Mean Pixel Intensity`. The segmentation code measures area in pixels; no physical-size calibration is supplied. The source contains 389,233 object observations and 433 distinct frame payloads, with 614–1,136 objects per frame.

The secondary export, `nuclei_segmentation2.csv`, contains 342,936 rows (792 × 433), but its non-frame columns repeat identically in every frame. It is excluded. An annotation snippet in the archive reads a TIFF without a changing page index, which is consistent with this failure pattern, but the file's exact execution history is unknown. Repetition is the reason for exclusion; the cause is not established.

If the original exports are available, `python prepare_data.py /path/to/original/Data` verifies their SHA-256 fingerprints and rebuilds both published extracts. Running the figure review does not require the originals.

## Original MATLAB materials

The `matlab/` directory retains 16 working `.m` scripts and a plain-text extraction of `umap_scatter_plot_frame.mlx`. The original frame-colored figure is extracted from that Live Script's saved PNG output. No analysis logic in these scripts has been revised. Three embedding input paths were changed to `data/cell_observations.csv`, and the absolute personal path to the TIFF was replaced by its basename.

These are historical working scripts, with limitations worth keeping visible:

- The nucleus export assigns `Cell ID` separately in every frame. It segments objects but does not establish their identity across frames.
- `scatter_fluo1_fluo2.m` expects `Dataset2.0.csv`, which is absent. Its saved counterpart, `umap_scatter_plot.mlx`, uses the same missing input and has a different-looking embedding. Its figure is not used in this repository.
- Fluorescence transforms require positive values. Six values of `fluo1_mean_corr` in the included data are nonpositive; the Python fluorescence view excludes exactly these six rows.
- Some trajectory scripts connect adjacent rows within a track without checking frame gaps. Here 1,188 of 6,351 within-track neighboring pairs skip at least one frame.
- Direction normalization can divide by zero. Region-based variants filter before computing differences, which can also bridge gaps caused by leaving a region. Shared grid boundaries are inclusive and can count boundary observations twice.
- Random sampling is not seeded. `random100_2dynamic.m` actually samples five track IDs, while `random100_2dynamicquiver.m` samples 100 rows and can break temporal continuity.
- The `lifespan` calculation in `scatter_fluo1_fluo2.m` is frame divided by a track's maximum observed frame, not measured replicative lifespan. Concatenating values grouped by ID also assumes the original row order is grouped the same way.

Run historical scripts from the repository root with `addpath('matlab')`. The segmentation exporter needs the TIFF stack and its segmentation function on the MATLAB path. No MATLAB runtime was available for revalidation.

## Reproducing the review figures

`analyze.py` is a Python review added during repository preparation, separate from the original MATLAB work. It:

1. Checks finite coordinates, integer track/frame keys, duplicate keys, and consistency of movie/track identity.
2. Sorts by `idx_glob` and `Frame` and computes forward differences only when the next observation is the same track at frame + 1.
3. Keeps zero-length differences as zero, without direction normalization. There are 5,163 valid adjacent-frame pairs.
4. Ranks tracks by observation count, breaking ties by global ID, then takes the first three distinct movie/track pairs. It plots actual embedding displacement and uses a common frame color scale. No interpolation fills gaps.
5. Plots the supplied embedding by frame and by log fluorescence, plus the primary segmentation summary.

The unit tests specifically cover track boundaries, frame gaps, zero displacement, duplicate keys, nonfinite coordinates, and inconsistent movie identity. These checks validate table handling; they do not establish segmentation accuracy or biological validity.

The original UMAP fit cannot be reproduced from these materials: its model, settings, and training code are absent. For how embedding parameters influence visual structure, see the [UMAP parameter documentation](https://umap-learn.readthedocs.io/en/latest/parameters.html). Distances and arrows in these figures should not be interpreted as calibrated physical velocity or evidence of a causal transition.

## Source fingerprints

SHA-256 of the original CSV files, recorded before processing:

```text
CropProperties_processed_masktexture_nowash_umap.csv
eba3d4f6314a12edb792aab5774d45b252436db00e7ebdd5c510dba1a13e0dce

nuclei_segmentation.csv
9cec9283ec0cf4469366b64d95d9bdc378e32c60795c8c9e8911d38eddac2576

nuclei_segmentation2.csv (excluded)
d75e478edd090c1a82f2541c7c6ee5ef2cfde950037fea32649a72d0d9d92a5a
```
