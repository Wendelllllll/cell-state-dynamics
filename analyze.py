"""Reproduce the repository figures from the included project-data extracts.

This review was added during repository preparation. It does not fit an embedding.
"""
from pathlib import Path
import json

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import Normalize
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parent
KEYS = ["idx_glob", "Frame"]


def validate_observations(data):
    required = KEYS + ["xumap", "yumap", "Movie", "track"]
    missing = set(required) - set(data.columns)
    if missing:
        raise ValueError(f"Missing columns: {sorted(missing)}")
    if data.empty or not np.isfinite(data[required].to_numpy(dtype=float)).all():
        raise ValueError("Required observations must be nonempty and finite")
    if data.duplicated(KEYS).any():
        raise ValueError("Duplicate track/frame observations")
    if (data[KEYS] % 1 != 0).any().any():
        raise ValueError("Track IDs and frames must be integers")
    if data.groupby("idx_glob")[["Movie", "track"]].nunique().gt(1).any().any():
        raise ValueError("A global track ID spans multiple movie/track pairs")
    return data.sort_values(KEYS, kind="stable").reset_index(drop=True)


def consecutive_steps(data):
    """Return forward displacements only for same-track, consecutive-frame pairs."""
    ordered = validate_observations(data)
    following = ordered.shift(-1)
    keep = (ordered.idx_glob == following.idx_glob) & (following.Frame - ordered.Frame == 1)
    steps = ordered.loc[keep, KEYS + ["xumap", "yumap"]].copy()
    steps["dx"] = (following.xumap - ordered.xumap).loc[keep]
    steps["dy"] = (following.yumap - ordered.yumap).loc[keep]
    return steps


def style_axis(ax):
    ax.spines[["top", "right"]].set_visible(False)
    ax.set_xlabel("UMAP 1")
    ax.set_ylabel("UMAP 2")


def main():
    data = validate_observations(pd.read_csv(ROOT / "data/cell_observations.csv"))
    steps = consecutive_steps(data)
    summary = pd.read_csv(ROOT / "data/segmentation_by_frame.csv")
    output = ROOT / "figures"
    output.mkdir(exist_ok=True)
    plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 10,
                         "axes.titlesize": 12, "figure.facecolor": "white"})
    norm = Normalize(data.Frame.min(), data.Frame.max())

    fig, axes = plt.subplots(1, 2, figsize=(11, 4.6), layout="constrained")
    color = axes[0].scatter(data.xumap, data.yumap, c=data.Frame, norm=norm,
                            cmap="viridis", s=7, alpha=.7, linewidths=0)
    fig.colorbar(color, ax=axes[0], label="Recorded frame")
    axes[0].set_title(f"{len(data):,} observations in the supplied embedding")
    positive = data.fluo1_mean_corr > 0
    color = axes[1].scatter(data.loc[positive, "xumap"], data.loc[positive, "yumap"],
                            c=np.log10(data.loc[positive, "fluo1_mean_corr"]),
                            cmap="magma", s=7, alpha=.7, linewidths=0)
    fig.colorbar(color, ax=axes[1], label="log10(fluo1_mean_corr)")
    axes[1].set_title(f"Fluorescence view ({(~positive).sum()} nonpositive values omitted)")
    for ax in axes:
        style_axis(ax)
    fig.savefig(output / "umap_overview.png", dpi=180)
    plt.close(fig)

    counts = data.groupby("idx_glob").size().rename("n").reset_index()
    identity = data.groupby("idx_glob")[["Movie", "track"]].first().reset_index()
    ranked = counts.merge(identity, on="idx_glob").sort_values(
        ["n", "idx_glob"], ascending=[False, True])
    selected = ranked.drop_duplicates(["Movie", "track"]).head(3).idx_glob
    fig, axes = plt.subplots(1, 3, figsize=(12, 4.8), layout="constrained")
    for ax, track_id in zip(axes, selected):
        part = data[data.idx_glob == track_id]
        vectors = steps[steps.idx_glob == track_id]
        ax.scatter(data.xumap, data.yumap, color="#d9dde2", s=3, alpha=.4, linewidths=0)
        ax.quiver(vectors.xumap, vectors.yumap, vectors.dx, vectors.dy,
                  color="#4b5563", angles="xy", scale_units="xy", scale=1,
                  width=.0025, alpha=.55)
        color = ax.scatter(part.xumap, part.yumap, c=part.Frame, norm=norm,
                           cmap="viridis", s=12, linewidths=0, zorder=3)
        ax.set_title(f"Track {track_id} / movie {int(part.Movie.iloc[0])}\n"
                     f"{len(part)} observations / {len(vectors)} steps", fontsize=10)
        style_axis(ax)
    fig.colorbar(color, ax=list(axes), label="Recorded frame", shrink=.8)
    fig.savefig(output / "track_examples.png", dpi=180)
    plt.close(fig)

    fig, axes = plt.subplots(1, 2, figsize=(10.5, 3.8), layout="constrained")
    axes[0].plot(summary.frame, summary.object_count, color="#167d8d", linewidth=1.5)
    axes[0].set_ylabel("Segmented objects per frame")
    axes[0].set_title("Object counts vary across the primary export")
    axes[1].plot(summary.frame, summary.median_area, color="#9261a8", linewidth=1.5)
    axes[1].set_ylabel("Median object area (pixels)")
    axes[1].set_title("Median segmented area")
    for ax in axes:
        ax.set_xlabel("Recorded frame")
        ax.spines[["top", "right"]].set_visible(False)
    fig.savefig(output / "segmentation_summary.png", dpi=180)
    plt.close(fig)
    print(json.dumps({"observations": len(data), "tracks": data.idx_glob.nunique(),
        "movies": data.Movie.nunique(),
        "movie_track_pairs": len(data[["Movie", "track"]].drop_duplicates()),
        "repeated_object_keys": int(data.duplicated(["Movie", "Frame", "CellID"]).sum()),
        "adjacent_frame_steps": len(steps),
        "nonconsecutive_pairs_excluded": len(data) - data.idx_glob.nunique() - len(steps),
        "segmented_object_observations": int(summary.object_count.sum()),
        "segmentation_frames": len(summary), "example_tracks": selected.tolist()}, indent=2))


if __name__ == "__main__":
    main()
