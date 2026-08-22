import unittest


class CurseForgeMetadataTests(unittest.TestCase):
    def test_build_metadata_includes_explicit_game_versions(self):
        # Given
        from scripts.build_curseforge_metadata import build_metadata

        version = "v12.022"
        changelog = "## v12.022\n\n- Fix release metadata."

        # When
        metadata = build_metadata(
            version=version,
            changelog=changelog,
            game_version_names=["Retail", "12.1.0"],
        )

        # Then
        self.assertEqual(metadata["displayName"], "MikScrollingBattleText v12.022")
        self.assertEqual(metadata["changelog"], changelog)
        self.assertEqual(metadata["changelogType"], "markdown")
        self.assertEqual(metadata["releaseType"], "release")
        self.assertEqual(metadata["gameVersionNames"], ["Retail", "12.1.0"])


if __name__ == "__main__":
    unittest.main()
