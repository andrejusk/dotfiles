import os
import re
import subprocess
from pathlib import Path

CONFIG = Path(__file__).parents[1] / "home/.tmux.conf"
NETWORK = Path(__file__).parents[1] / "home/.tmux/network.sh"
BATTERY = Path(__file__).parents[1] / "home/.tmux/battery.sh"
THEME = Path(__file__).parents[1] / "home/.tmux/theme.sh"
PROFILE = Path(__file__).parents[1] / "home/.profile"
ZSHRC = Path(__file__).parents[1] / "home/.zshrc"


def _write_command(bin_dir, name, body):
    command = bin_dir / name
    command.write_text(f"#!/bin/sh\n{body}\n")
    command.chmod(0o755)


def _run_battery(
    tmp_path,
    now,
    pmset_output,
    system_power,
    all_power,
    voltage_mv=13000,
    current_ma=0,
):
    bin_dir = tmp_path / "battery-bin"
    runtime_dir = tmp_path / "battery-runtime"
    bin_dir.mkdir(parents=True, exist_ok=True)
    runtime_dir.mkdir(parents=True, exist_ok=True)
    _write_command(bin_dir, "date", 'printf "%s\\n" "$MOCK_NOW"')
    _write_command(bin_dir, "uname", 'printf "Darwin\\n"')
    _write_command(bin_dir, "pmset", 'printf "%s\\n" "$MOCK_PMSET"')
    _write_command(
        bin_dir,
        "curl",
        'printf "macmon_all_power_watts{chip=\\"Apple M5 Max\\"} %s\\n'
        'macmon_sys_power_watts{chip=\\"Apple M5 Max\\"} %s\\n" '
        '"$MOCK_ALL_POWER" "$MOCK_SYSTEM_POWER"',
    )
    _write_command(
        bin_dir,
        "ioreg",
        'printf "  |   \\"Voltage\\" = %s\\n'
        '  |   \\"InstantAmperage\\" = %s\\n" "$MOCK_VOLTAGE" "$MOCK_CURRENT"',
    )
    env = os.environ.copy()
    env.update(
        {
            "DOTS_THEME": "dark",
            "MOCK_ALL_POWER": str(all_power),
            "MOCK_CURRENT": str(current_ma),
            "MOCK_NOW": str(now),
            "MOCK_PMSET": pmset_output,
            "MOCK_SYSTEM_POWER": str(system_power),
            "MOCK_VOLTAGE": str(voltage_mv),
            "PATH": f"{bin_dir}:{env['PATH']}",
            "XDG_RUNTIME_DIR": str(runtime_dir),
        }
    )
    return subprocess.run(
        [str(BATTERY)],
        capture_output=True,
        text=True,
        check=True,
        env=env,
    ).stdout


def test_battery_charging_shows_percentage_and_adapter_output(tmp_path):
    output = _run_battery(
        tmp_path,
        now=100,
        pmset_output="Now drawing from 'AC Power'\nBattery 80%; charging;",
        system_power=5,
        all_power=3,
        current_ma=1000,
    )

    assert "󰂄 80% 18W" in output


def test_battery_full_shows_only_system_power(tmp_path):
    output = _run_battery(
        tmp_path,
        now=100,
        pmset_output="Now drawing from 'AC Power'\nBattery 100%; charged;",
        system_power=5,
        all_power=3,
    )

    assert "󰚥 5W" in output
    assert "100%" not in output


def test_battery_discharging_shows_percentage_and_system_power(tmp_path):
    output = _run_battery(
        tmp_path,
        now=100,
        pmset_output="Now drawing from 'Battery Power'\nBattery 70%; discharging;",
        system_power=5,
        all_power=3,
    )

    assert "󰂀 70% 5W" in output


def _run_theme(tmp_path, appearance, **env_overrides):
    bin_dir = tmp_path / "theme-bin"
    bin_dir.mkdir(exist_ok=True)
    _write_command(bin_dir, "uname", 'printf "Darwin\\n"')
    _write_command(
        bin_dir,
        "defaults",
        f'printf "%s\\n" "{appearance}"',
    )
    env = os.environ.copy()
    env.pop("DOTS_THEME_OVERRIDE", None)
    env.update(env_overrides)
    env["PATH"] = f"{bin_dir}:{env['PATH']}"
    return subprocess.run(
        [str(THEME)],
        capture_output=True,
        text=True,
        check=True,
        env=env,
    ).stdout.strip()


def test_theme_follows_macos_appearance_instead_of_cached_value(tmp_path):
    assert _run_theme(tmp_path, "Dark", DOTS_THEME="light") == "dark"


def test_theme_explicit_override_wins_over_macos_appearance(tmp_path):
    assert _run_theme(
        tmp_path,
        "Dark",
        DOTS_THEME="dark",
        DOTS_THEME_OVERRIDE="light",
    ) == "light"


def test_tmux_refreshes_theme_without_polling():
    config = CONFIG.read_text()
    sync_script = (THEME.parent / "sync-theme.sh").read_text()
    watch_script = (THEME.parent / "watch-theme.sh").read_text()
    watcher_source = (THEME.parent / "theme-watcher.swift").read_text()
    zshrc = ZSHRC.read_text()
    assert "client-focus-in 'run-shell -b \"~/.tmux/sync-theme.sh\"'" in config
    assert "client-attached 'run-shell -b \"~/.tmux/sync-theme.sh\"'" in config
    assert "run-shell -b '~/.tmux/watch-theme.sh'" in config
    assert '"$watcher"' in watch_script
    assert "notifyutil -w AppleInterfaceThemeChangedNotification" in watch_script
    assert 'sleep 0.1' in watch_script
    assert 'kill "$old_pid"' in watch_script
    assert "AppleInterfaceThemeChangedNotification" in watcher_source
    assert "DistributedNotificationCenter.default()" in watcher_source
    assert '"$script_dir/sync-theme.sh"' in watch_script
    assert "'#{pane_pid} #{@dots_theme_listener}'" in sync_script
    assert "kill -USR1 \"$pane_pid\"" in sync_script
    assert "TRAPUSR1()" in zshrc
    assert "tmux set-option -p @dots_theme_listener 1" in zshrc


def test_shell_theme_environment_can_switch_both_ways():
    command = f"""
        source {PROFILE!s}
        DOTS_THEME=light
        _dots_apply_theme_env
        [[ $BAT_THEME == dots-light ]]
        [[ $GLAMOUR_STYLE == light ]]
        [[ $DELTA_FEATURES == light ]]
        (( GIT_CONFIG_COUNT > 0 ))
        DOTS_THEME=dark
        _dots_apply_theme_env
        [[ $BAT_THEME == dots ]]
        [[ $GLAMOUR_STYLE == dark ]]
        [[ $DELTA_FEATURES == dark ]]
        [[ -z $GIT_CONFIG_COUNT ]]
    """
    subprocess.run(["zsh", "-dfc", command], check=True)


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
