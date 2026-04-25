"""dataset.py — load RAVDESS or a generic folder-of-WAVs dataset.

RAVDESS filename convention: 03-01-06-01-02-01-12.wav
positions 1..7 = modality, vocal_channel, emotion, intensity, statement,
repetition, actor (odd=male, even=female).

If the folder doesn't look like RAVDESS, we fall back to a generic loader
that treats every immediate sub-directory as a class (folder name = label).
This means it also works for the existing project dataset where files are
named e.g. femaleSad_1.wav: just rename/move them into per-emotion folders.
"""
from __future__ import annotations

import glob
import os
import random
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import librosa
import numpy as np


RAVDESS_EMOTION_MAP = {
    "01": "neutral",
    "02": "calm",
    "03": "happy",
    "04": "sad",
    "05": "angry",
    "06": "fearful",
    "07": "disgust",
    "08": "surprised",
}


@dataclass
class AudioItem:
    path: str
    label: str
    speaker: str
    audio: Optional[np.ndarray] = None
    sample_rate: Optional[int] = None


def parse_ravdess_filename(path: str) -> Optional[Dict[str, str]]:
    name = Path(path).stem
    parts = name.split("-")
    if len(parts) != 7:
        return None
    try:
        actor = int(parts[6])
    except ValueError:
        return None
    return {
        "emotion": RAVDESS_EMOTION_MAP.get(parts[2], "unknown"),
        "actor": str(actor),
        "gender": "female" if actor % 2 == 0 else "male",
    }


def list_audio_files(root: str) -> List[str]:
    pats = ("*.wav", "*.WAV", "*.flac", "*.mp3")
    files: List[str] = []
    for pat in pats:
        files.extend(glob.glob(os.path.join(root, "**", pat), recursive=True))
    return sorted(files)


def load_dataset(
    path: str,
    sample_rate: int = 16000,
    emotions: Optional[List[str]] = None,
    max_files_per_class: Optional[int] = None,
    trim_silence: bool = True,
    trim_top_db: float = 30.0,
    random_seed: int = 42,
    logger=None,
) -> List[AudioItem]:
    """Discover audio files and load them into memory as AudioItem objects."""
    files = list_audio_files(path)
    if not files:
        raise FileNotFoundError(
            f"No audio files found under {path}. Check `dataset.path` in config.json."
        )

    items: List[AudioItem] = []
    is_ravdess = parse_ravdess_filename(files[0]) is not None

    if logger:
        logger.info(
            "Found %d audio files under %s; format=%s",
            len(files),
            path,
            "RAVDESS" if is_ravdess else "folder-per-class",
        )

    for f in files:
        if is_ravdess:
            meta = parse_ravdess_filename(f)
            if meta is None:
                continue
            label = meta["emotion"]
            speaker = meta["actor"]
        else:
            # Folder-per-class: parent directory is the label
            label = Path(f).parent.name.lower()
            speaker = Path(f).stem  # treat each file as its own speaker by default

        if emotions is not None and label not in emotions:
            continue
        items.append(AudioItem(path=f, label=label, speaker=speaker))

    if max_files_per_class is not None:
        rng = random.Random(random_seed)
        by_class: Dict[str, List[AudioItem]] = {}
        for it in items:
            by_class.setdefault(it.label, []).append(it)
        kept: List[AudioItem] = []
        for c, lst in by_class.items():
            rng.shuffle(lst)
            kept.extend(lst[:max_files_per_class])
        items = kept

    # Load audio
    for it in items:
        y, sr = librosa.load(it.path, sr=sample_rate, mono=True)
        if trim_silence and len(y) > 0:
            y, _ = librosa.effects.trim(y, top_db=trim_top_db)
        it.audio = y.astype(np.float32)
        it.sample_rate = sr

    if logger:
        from collections import Counter

        ct = Counter(it.label for it in items)
        logger.info("Loaded %d items: %s", len(items), dict(ct))
    return items


def split_train_test(
    items: List[AudioItem],
    test_size: float = 0.2,
    speaker_independent: bool = True,
    random_seed: int = 42,
    logger=None,
) -> Tuple[List[AudioItem], List[AudioItem]]:
    """Stratified train/test split.

    If `speaker_independent` is True, no speaker appears in both splits.
    """
    rng = random.Random(random_seed)
    by_class: Dict[str, List[AudioItem]] = {}
    for it in items:
        by_class.setdefault(it.label, []).append(it)

    train: List[AudioItem] = []
    test: List[AudioItem] = []

    for label, lst in by_class.items():
        if speaker_independent:
            speakers = sorted({it.speaker for it in lst})
            rng.shuffle(speakers)
            n_test_spk = max(1, int(round(len(speakers) * test_size)))
            test_speakers = set(speakers[:n_test_spk])
            for it in lst:
                (test if it.speaker in test_speakers else train).append(it)
        else:
            shuffled = lst[:]
            rng.shuffle(shuffled)
            n_test = max(1, int(round(len(shuffled) * test_size)))
            test.extend(shuffled[:n_test])
            train.extend(shuffled[n_test:])

    if logger:
        from collections import Counter

        logger.info("Train classes: %s", dict(Counter(i.label for i in train)))
        logger.info("Test  classes: %s", dict(Counter(i.label for i in test)))
        if speaker_independent:
            tr_spk = {i.speaker for i in train}
            te_spk = {i.speaker for i in test}
            logger.info(
                "Speaker-independent: %d train spk, %d test spk, overlap=%d",
                len(tr_spk),
                len(te_spk),
                len(tr_spk & te_spk),
            )
    return train, test
