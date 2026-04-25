"""Core feature-extraction and HMM modules.

The submodules use flat imports (``from framing import ...``) so they can be
read and run as standalone scripts. To make those imports resolve when this
package is imported normally (``import core``), we add the package directory
to ``sys.path`` here. This is the only place that magic lives.
"""
import sys
from pathlib import Path

_HERE = str(Path(__file__).resolve().parent)
if _HERE not in sys.path:
    sys.path.insert(0, _HERE)
