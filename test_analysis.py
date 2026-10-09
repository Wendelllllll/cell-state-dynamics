"""Checks for trajectory mistakes that would change the interpretation of a plot."""
import unittest
import pandas as pd
from analyze import consecutive_steps, validate_observations


class TrajectoryChecks(unittest.TestCase):
    def example(self):
        return pd.DataFrame({"idx_glob": [1, 2, 1, 1, 2], "Frame": [4, 2, 1, 2, 1],
            "xumap": [99., 7., 0., 2., 7.], "yumap": [99., 3., 0., 1., 3.],
            "Movie": [1, 2, 1, 1, 2], "track": [1, 1, 1, 1, 1]})

    def test_no_connections_across_tracks_or_frame_gaps(self):
        steps = consecutive_steps(self.example())
        self.assertEqual(steps[["idx_glob", "Frame"]].values.tolist(), [[1, 1], [2, 1]])
        self.assertEqual(steps[["dx", "dy"]].values.tolist(), [[2., 1.], [0., 0.]])

    def test_duplicate_keys_rejected(self):
        data = self.example()
        with self.assertRaisesRegex(ValueError, "Duplicate"):
            validate_observations(pd.concat([data, data.iloc[[0]]]))

    def test_movie_collision_rejected(self):
        data = self.example()
        data.loc[0, "Movie"] = 9
        with self.assertRaisesRegex(ValueError, "multiple"):
            validate_observations(data)

    def test_nonfinite_coordinates_rejected(self):
        data = self.example()
        data.loc[0, "xumap"] = float("nan")
        with self.assertRaisesRegex(ValueError, "finite"):
            validate_observations(data)


if __name__ == "__main__":
    unittest.main()
