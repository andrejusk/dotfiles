import re
import subprocess
from pathlib import Path

CONFIG = Path(__file__).parents[1] / "home/.tmux.conf"


def test_compact_status_preserves_copilot_indicators_in_both_themes(tmp_path):
    socket = str(tmp_path / "tmux.sock")

    def tmux(*args):
        return subprocess.run(
            ["tmux", "-S", socket, *args],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()

    formats = re.findall(
        r'^\s*set -g (status-right|window-status-format|window-status-current-format) "(.*)"$',
        CONFIG.read_text(),
        re.MULTILINE,
    )
    assert len(formats) == 6
    tmux(
        "-f", "/dev/null", "new-session", "-d", "-s", "dots-test",
        "-n", "test-window", "sleep 60",
    )
    try:
        tmux("set-option", "-g", "automatic-rename", "off")
        for option, value in formats:
            for width in (79, 80, 119, 120, 160):
                expanded = value.replace("#{client_width}", str(width))
                if option == "status-right":
                    expanded = expanded.replace("%a %d %b", "DATE")
                    for script in ("network", "battery", "heartbeat"):
                        expanded = expanded.replace(
                            f"#(~/.tmux/{script}.sh)", script.upper()
                        )
                    rendered = tmux("display-message", "-p", expanded)
                    assert ("NETWORK" in rendered) == (width >= 120)
                    assert ("BATTERY" in rendered) == (width >= 120)
                    assert ("DATE" in rendered) == (width >= 80)
                    assert "HEARTBEAT" in rendered
                    continue

                tmux("set-option", "-w", "@copilot_unread", "0")
                for state, symbol in (
                    ("idle", ""),
                    ("working", "\u25d0"),
                    ("waiting", "\u25cf"),
                    ("question", "?"),
                    ("error", "\u2717"),
                ):
                    tmux("set-option", "-w", "@copilot_state", state)
                    rendered = tmux("display-message", "-p", expanded)
                    assert ("test-window" in rendered) == (width >= 120)
                    if symbol:
                        assert symbol in rendered

                if option == "window-status-format":
                    tmux("set-option", "-w", "@copilot_unread", "1")
                    rendered = tmux("display-message", "-p", expanded)
                    assert "\u25cf" in rendered
                    assert ("test-window" in rendered) == (width >= 120)
                    assert "#[bg=#B46400]" in rendered or "#[bg=#F88C14]" in rendered
    finally:
        tmux("kill-server")
