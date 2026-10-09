"""Rebuild the published extracts from the original project Data directory.

Usage: python prepare_data.py /path/to/original/Data
The originals are read only. Output is written to this repository's data directory.
"""
import argparse
import hashlib
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent
SOURCES = {
    "CropProperties_processed_masktexture_nowash_umap.csv":
        "eba3d4f6314a12edb792aab5774d45b252436db00e7ebdd5c510dba1a13e0dce",
    "nuclei_segmentation.csv":
        "9cec9283ec0cf4469366b64d95d9bdc378e32c60795c8c9e8911d38eddac2576",
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source_directory", type=Path)
    args = parser.parse_args()
    for name, expected in SOURCES.items():
        if hashlib.sha256((args.source_directory / name).read_bytes()).hexdigest() != expected:
            raise ValueError(f"Source fingerprint does not match the documented export: {name}")
    observations = pd.read_csv(args.source_directory / next(iter(SOURCES)))
    columns = [c for c in observations if c != "dirname" and not (
        len(c) > 1 and c[0] in "mt" and c[1:].isdigit())]
    nuclei = pd.read_csv(args.source_directory / "nuclei_segmentation.csv")
    summary = nuclei.groupby("Frame Number").agg(
        object_count=("Cell ID", "size"), median_area=("Area", "median"),
        median_perimeter=("Perimeter", "median"),
        median_intensity=("Mean Pixel Intensity", "median")
    ).reset_index().rename(columns={"Frame Number": "frame"})
    output = ROOT / "data"
    output.mkdir(exist_ok=True)
    observations[columns].to_csv(output / "cell_observations.csv", index=False)
    summary.to_csv(output / "segmentation_by_frame.csv", index=False)
    print(f"Wrote {len(observations):,} observation rows and {len(summary)} frame summaries.")


if __name__ == "__main__":
    main()
