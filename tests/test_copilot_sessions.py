import importlib.machinery
import importlib.util
import json
from pathlib import Path

SCRIPT = Path(__file__).parents[1] / "home/.local/bin/copilot-sessions"


def load_module():
    loader = importlib.machinery.SourceFileLoader("copilot_sessions", str(SCRIPT))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


def write_session(root, sid, updated_at, event_timestamps):
    session = root / sid
    session.mkdir()
    (session / "workspace.yaml").write_text(
        f"updated_at: {updated_at}\n" f"cwd: /work/{sid}\n" f"summary: session {sid}\n"
    )
    events = [
        {
            "type": "user.message",
            "timestamp": event_timestamps[0],
            "data": {"content": f"message {sid}"},
        },
        *[
            {"type": "assistant.message", "timestamp": timestamp, "data": {}}
            for timestamp in event_timestamps[1:]
        ],
        {
            "type": "session.shutdown",
            "timestamp": "2026-08-30T12:00:00.000Z",
            "data": {},
        },
    ]
    (session / "events.jsonl").write_text(
        "".join(json.dumps(event) + "\n" for event in events)
    )


def test_build_ranks_by_latest_event_and_backfills_old_cache(tmp_path):
    module = load_module()
    module.SD = str(tmp_path / "sessions")
    module.CACHE_DIR = str(tmp_path / "cache")
    module.CACHE = str(Path(module.CACHE_DIR) / "index.tsv")
    root = Path(module.SD)
    root.mkdir()

    write_session(
        root,
        "recently-resumed",
        "2026-08-01T10:00:00.000Z",
        ["2026-08-01T10:00:00.000Z", "2026-08-24T11:13:15.773Z"],
    )
    write_session(
        root,
        "older",
        "2026-08-20T10:00:00.000Z",
        ["2026-08-20T10:00:00.000Z"],
    )

    Path(module.CACHE_DIR).mkdir()
    resumed_ws = root / "recently-resumed/workspace.yaml"
    resumed_events = root / "recently-resumed/events.jsonl"
    old_key = f"{resumed_ws.stat().st_mtime!r}:{resumed_events.stat().st_mtime!r}"
    Path(module.CACHE).write_text(
        f"{old_key}\trecently-resumed\t1\t2026-08-01T10:00\tstale\t/work/recently-resumed\n"
    )

    rows = module.build()

    assert [row[1] for row in rows] == ["recently-resumed", "older"]
    assert rows[0][0] == "2026-08-24T11:13"
    assert Path(module.CACHE).read_text().startswith(f"{module.CACHE_VERSION}:")
