import os
import subprocess
import time
from pathlib import Path

SCRIPT = Path(__file__).parents[1] / "home/.tmux/copilot-state.sh"


def write_executable(path, content):
    path.write_text(content)
    path.chmod(0o755)


def run_state(tmp_path, active):
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    tmux_log = tmp_path / "tmux.log"
    sound_log = tmp_path / "sound.log"
    sound_file = tmp_path / "ding.aiff"
    sound_file.touch()

    write_executable(
        bin_dir / "tmux",
        """#!/bin/sh
printf '%s\n' "$*" >> "$TMUX_TEST_LOG"
[ "$1" = display-message ] && printf '%s\n' "$TMUX_TEST_ACTIVE"
""",
    )
    write_executable(
        bin_dir / "afplay",
        """#!/bin/sh
printf '%s\n' "$*" >> "$COPILOT_SOUND_TEST_LOG"
""",
    )

    env = os.environ.copy()
    env.update(
        {
            "PATH": f"{bin_dir}:{env['PATH']}",
            "TMUX": "/tmp/tmux-test/default,1,0",
            "TMUX_PANE": "%1",
            "TMUX_TEST_LOG": str(tmux_log),
            "TMUX_TEST_ACTIVE": active,
            "COPILOT_SOUND_FILE": str(sound_file),
            "COPILOT_SOUND_TEST_LOG": str(sound_log),
        }
    )
    subprocess.run([str(SCRIPT), "waiting"], env=env, check=True)

    for _ in range(20):
        if sound_log.exists():
            break
        time.sleep(0.01)
    return tmux_log.read_text(), sound_log.read_text() if sound_log.exists() else ""


def test_inactive_handover_marks_unread_and_plays_sound(tmp_path):
    tmux_log, sound_log = run_state(tmp_path, "0")

    assert "@copilot_unread 1" in tmux_log
    assert "-v 0.5" in sound_log


def test_active_handover_does_not_mark_unread_or_play_sound(tmp_path):
    tmux_log, sound_log = run_state(tmp_path, "1")

    assert "@copilot_unread 1" not in tmux_log
    assert sound_log == ""
