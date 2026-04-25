"""Tests for utils/dataset.py."""
from __future__ import annotations

import logging

import numpy as np
import pytest

# librosa is required at import time; skip the whole module if it's missing.
pytest.importorskip("librosa")

from dataset import (  # noqa: E402
    AudioItem,
    list_audio_files,
    parse_ravdess_filename,
    split_train_test,
)


class TestParseRavdessFilename:
    def test_parses_valid_name(self):
        meta = parse_ravdess_filename("/some/dir/03-01-06-01-02-01-12.wav")
        assert meta == {"emotion": "fearful", "actor": "12", "gender": "female"}

    def test_actor_parity_drives_gender(self):
        meta_male = parse_ravdess_filename("03-01-05-02-01-01-13.wav")
        assert meta_male["gender"] == "male"
        meta_female = parse_ravdess_filename("03-01-05-02-01-01-14.wav")
        assert meta_female["gender"] == "female"

    def test_unknown_emotion_code(self):
        meta = parse_ravdess_filename("03-01-99-01-02-01-12.wav")
        assert meta["emotion"] == "unknown"

    def test_invalid_filename_returns_none(self):
        assert parse_ravdess_filename("not-ravdess.wav") is None
        assert parse_ravdess_filename("03-01-aa-01-02-01-bad.wav") is None


class TestListAudioFiles:
    def test_finds_recursively(self, tmp_path):
        (tmp_path / "a").mkdir()
        (tmp_path / "a" / "x.wav").write_bytes(b"")
        (tmp_path / "b").mkdir()
        (tmp_path / "b" / "y.WAV").write_bytes(b"")
        (tmp_path / "c.flac").write_bytes(b"")
        (tmp_path / "ignore.txt").write_bytes(b"")
        files = list_audio_files(str(tmp_path))
        # WAV/wav patterns may double-count on case-insensitive filesystems; dedupe.
        names = sorted({p.split("/")[-1] for p in files})
        assert "x.wav" in names
        assert "y.WAV" in names
        assert "c.flac" in names
        assert "ignore.txt" not in names


def _items(label_speakers):
    """Helper: build AudioItems from a list of (label, speaker) pairs."""
    return [
        AudioItem(path=f"/fake/{i}.wav", label=lbl, speaker=spk)
        for i, (lbl, spk) in enumerate(label_speakers)
    ]


class TestSplitTrainTest:
    def test_speaker_independent_no_overlap(self):
        items = _items(
            [("happy", f"S{i}") for i in range(10)]
            + [("sad", f"T{i}") for i in range(10)]
        )
        train, test = split_train_test(
            items, test_size=0.3, speaker_independent=True, random_seed=0
        )
        assert len(train) + len(test) == len(items)
        train_spk = {it.speaker for it in train}
        test_spk = {it.speaker for it in test}
        assert train_spk.isdisjoint(test_spk)

    def test_random_split_keeps_all(self):
        items = _items([("happy", f"S{i}") for i in range(20)])
        train, test = split_train_test(
            items, test_size=0.25, speaker_independent=False, random_seed=0
        )
        assert len(train) + len(test) == 20
        assert len(test) >= 1

    def test_each_class_present_in_test(self):
        items = _items(
            [("happy", f"H{i}") for i in range(8)]
            + [("sad", f"S{i}") for i in range(8)]
        )
        train, test = split_train_test(
            items, test_size=0.25, speaker_independent=True, random_seed=0
        )
        test_labels = {it.label for it in test}
        assert test_labels == {"happy", "sad"}

    def test_logger_is_optional(self):
        items = _items([("happy", "A"), ("happy", "B"), ("sad", "C"), ("sad", "D")])
        # Should not raise without a logger
        split_train_test(items, test_size=0.5, speaker_independent=True, random_seed=0)
        # And accept a real logger
        split_train_test(
            items, test_size=0.5, speaker_independent=True,
            random_seed=0, logger=logging.getLogger("test"),
        )
