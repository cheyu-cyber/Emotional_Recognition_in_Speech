"""utils.py — shared helpers: logging, JSON I/O, timing, caching."""
from __future__ import annotations

import json
import logging
import os
import pickle
import time
from contextlib import contextmanager
from pathlib import Path
from typing import Any, Dict


def load_config(path: str | os.PathLike) -> Dict[str, Any]:
    with open(path, "r") as f:
        return json.load(f)


def setup_logging(log_dir: str | os.PathLike, name: str = "esr") -> logging.Logger:
    """Configure root logger to print to stdout and write to a timestamped file."""
    Path(log_dir).mkdir(parents=True, exist_ok=True)
    stamp = time.strftime("%Y%m%d_%H%M%S")
    log_path = Path(log_dir) / f"{name}_{stamp}.log"

    logger = logging.getLogger(name)
    logger.handlers.clear()
    logger.setLevel(logging.INFO)

    fmt = logging.Formatter(
        "%(asctime)s | %(levelname)-7s | %(name)s | %(message)s",
        datefmt="%H:%M:%S",
    )

    fh = logging.FileHandler(log_path)
    fh.setFormatter(fmt)
    logger.addHandler(fh)

    sh = logging.StreamHandler()
    sh.setFormatter(fmt)
    logger.addHandler(sh)

    logger.info("Logging to %s", log_path)
    return logger


@contextmanager
def timed(label: str, logger: logging.Logger | None = None):
    """Context manager that logs how long a block took."""
    t0 = time.time()
    try:
        yield
    finally:
        dt = time.time() - t0
        msg = f"[{label}] took {dt:.2f}s"
        if logger is not None:
            logger.info(msg)
        else:
            print(msg)


def ensure_dirs(*paths: str | os.PathLike) -> None:
    for p in paths:
        Path(p).mkdir(parents=True, exist_ok=True)


def save_pickle(obj: Any, path: str | os.PathLike) -> None:
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    with open(path, "wb") as f:
        pickle.dump(obj, f)


def load_pickle(path: str | os.PathLike) -> Any:
    with open(path, "rb") as f:
        return pickle.load(f)


def save_json(obj: Any, path: str | os.PathLike) -> None:
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w") as f:
        json.dump(obj, f, indent=2, default=str)
