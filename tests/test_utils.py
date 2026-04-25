"""Tests for utils/utils.py."""
from __future__ import annotations

import json
import logging
import time
from pathlib import Path

import pytest

from utils import (
    ensure_dirs,
    load_config,
    load_pickle,
    save_json,
    save_pickle,
    setup_logging,
    timed,
)


class TestLoadConfig:
    def test_roundtrip(self, tmp_path):
        cfg = {"a": 1, "nested": {"b": [1, 2, 3]}}
        p = tmp_path / "cfg.json"
        p.write_text(json.dumps(cfg))
        loaded = load_config(p)
        assert loaded == cfg


class TestEnsureDirs:
    def test_creates_nested(self, tmp_path):
        a = tmp_path / "x" / "y" / "z"
        b = tmp_path / "another"
        ensure_dirs(a, b)
        assert a.is_dir()
        assert b.is_dir()

    def test_idempotent(self, tmp_path):
        d = tmp_path / "a"
        ensure_dirs(d)
        ensure_dirs(d)  # second call must not raise
        assert d.is_dir()


class TestSavePickle:
    def test_roundtrip(self, tmp_path):
        obj = {"x": [1, 2], "y": ("a", "b")}
        p = tmp_path / "deeper" / "obj.pkl"
        save_pickle(obj, p)
        assert p.exists()
        assert load_pickle(p) == obj


class TestSaveJson:
    def test_roundtrip(self, tmp_path):
        obj = {"acc": 0.83, "classes": ["a", "b"]}
        p = tmp_path / "sub" / "out.json"
        save_json(obj, p)
        assert p.exists()
        assert json.loads(p.read_text()) == obj

    def test_default_str_handles_unsupported(self, tmp_path):
        # Path objects are not JSON-serialisable; save_json uses default=str.
        obj = {"path": Path("/tmp/foo")}
        p = tmp_path / "out.json"
        save_json(obj, p)
        loaded = json.loads(p.read_text())
        assert loaded == {"path": "/tmp/foo"}


class TestTimed:
    def test_logs_when_logger_given(self, caplog):
        logger = logging.getLogger("timed_test")
        logger.setLevel(logging.INFO)
        with caplog.at_level(logging.INFO, logger="timed_test"):
            with timed("step", logger):
                time.sleep(0.001)
        assert any("step" in rec.message and "took" in rec.message for rec in caplog.records)

    def test_prints_when_no_logger(self, capsys):
        with timed("no logger"):
            pass
        out = capsys.readouterr().out
        assert "no logger" in out
        assert "took" in out

    def test_logs_on_exception(self, caplog):
        logger = logging.getLogger("timed_err")
        logger.setLevel(logging.INFO)
        with caplog.at_level(logging.INFO, logger="timed_err"):
            with pytest.raises(RuntimeError):
                with timed("bad", logger):
                    raise RuntimeError("boom")
        assert any("bad" in rec.message for rec in caplog.records)


class TestSetupLogging:
    def test_creates_log_file_and_returns_logger(self, tmp_path):
        logger = setup_logging(tmp_path, name="esr_test")
        try:
            assert logger.name == "esr_test"
            assert logger.handlers, "handlers should be attached"
            log_files = list(tmp_path.glob("esr_test_*.log"))
            assert len(log_files) == 1
            logger.info("hello")
            for h in logger.handlers:
                h.flush()
            assert "hello" in log_files[0].read_text()
        finally:
            for h in logger.handlers[:]:
                h.close()
                logger.removeHandler(h)
