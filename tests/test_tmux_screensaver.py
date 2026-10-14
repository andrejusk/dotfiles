import os
import subprocess
from pathlib import Path

SCRIPT = Path(__file__).parents[1] / "home/.tmux/heartbeat.sh"


def write_executable(path, content):
    path.write_text(content)
    path.chmod(0o755)


def run_heartbeat(tmp_path, *, now, activity, copilot_state):
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir(exist_ok=True)
    tmux_log = tmp_path / "tmux.log"

    write_executable(
        bin_dir / "tmux",
        """#!/bin/sh
if [ "$1" = display-message ]; then
    printf '%s %s 0 123 \\$1 %s\n' \
        "$TMUX_TEST_ACTIVITY" "$TMUX_TEST_ACTIVITY" "$TMUX_TEST_COPILOT_STATE"
else
    printf '%s\n' "$*" >> "$TMUX_TEST_LOG"
fi
""",
    )
    write_executable(
        bin_dir / "date",
        """#!/bin/sh
printf '%s\n' "$TMUX_TEST_NOW"
""",
    )

    env = os.environ.copy()
    env.update(
        {
            "PATH": f"{bin_dir}:{env['PATH']}",
            "XDG_RUNTIME_DIR": str(tmp_path / "runtime"),
            "TMUX_TEST_ACTIVITY": str(activity),
            "TMUX_TEST_COPILOT_STATE": copilot_state,
            "TMUX_TEST_LOG": str(tmux_log),
            "TMUX_TEST_NOW": str(now),
        }
    )
    subprocess.run([str(SCRIPT)], env=env, check=True, capture_output=True, text=True)
    return tmux_log.read_text() if tmux_log.exists() else ""


def test_working_copilot_pauses_then_restarts_screensaver_timeout(tmp_path):
    assert run_heartbeat(
        tmp_path, now=1000, activity=1000, copilot_state="working"
    ) == ""
    assert run_heartbeat(
        tmp_path, now=1400, activity=1000, copilot_state="working"
    ) == ""

    assert run_heartbeat(
        tmp_path, now=1401, activity=1000, copilot_state="waiting"
    ) == ""
    assert run_heartbeat(
        tmp_path, now=1700, activity=1000, copilot_state="waiting"
    ) == ""
    assert "lock-session -t $1" in run_heartbeat(
        tmp_path, now=1701, activity=1000, copilot_state="waiting"
    )


def test_user_activity_resets_idle_screensaver_timeout(tmp_path):
    assert run_heartbeat(
        tmp_path, now=1000, activity=1000, copilot_state=""
    ) == ""
    assert run_heartbeat(
        tmp_path, now=1299, activity=1299, copilot_state=""
    ) == ""
    assert run_heartbeat(
        tmp_path, now=1598, activity=1299, copilot_state=""
    ) == ""
    assert "lock-session -t $1" in run_heartbeat(
        tmp_path, now=1599, activity=1299, copilot_state=""
    )
