"""Utility helpers: I/O, logging, dataset loading, plotting.

The submodules use flat imports (``import utils``-style names won't work
inside this package because of the name clash with ``utils/utils.py``).
Adding the package directory to ``sys.path`` here lets callers do
``from utils import ensure_dirs`` etc. via the re-exports below, and lets
sibling submodules import each other without relative-import gymnastics.
"""
import sys
from pathlib import Path

_HERE = str(Path(__file__).resolve().parent)
if _HERE not in sys.path:
    sys.path.insert(0, _HERE)

# Re-export the small helpers from utils/utils.py so existing call-sites
# like `from utils import ensure_dirs` keep working. Relative form to avoid
# the package-vs-submodule name clash on the bare name `utils`.
from .utils import (  # noqa: E402  (import after sys.path tweak)
    ensure_dirs,
    load_config,
    load_pickle,
    save_json,
    save_pickle,
    setup_logging,
    timed,
)

__all__ = [
    "ensure_dirs",
    "load_config",
    "load_pickle",
    "save_json",
    "save_pickle",
    "setup_logging",
    "timed",
]
