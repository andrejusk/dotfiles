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


def _run_network(
    tmp_path,
    now,
    ping_succeeds,
    latency_ms=42.1,
    rx_bytes=1000,
    tx_bytes=1000,
):
    bin_dir = tmp_path / "bin"
    runtime_dir = tmp_path / "runtime"
    bin_dir.mkdir(exist_ok=True)
    runtime_dir.mkdir(exist_ok=True)
    _write_command(bin_dir, "date", 'printf "%s\\n" "$MOCK_NOW"')
    _write_command(bin_dir, "uname", 'printf "Darwin\\n"')
    _write_command(
        bin_dir,
        "route",
        'printf "   interface: en0\\n"',
    )
    _write_command(
        bin_dir,
        "networksetup",
        'printf "Hardware Port: Wi-Fi\\nDevice: en0\\n"',
    )
    _write_command(
        bin_dir,
        "ping",
        (
            f'printf "64 bytes from 1.1.1.1: time={latency_ms} ms\\n"'
            if ping_succeeds
            else "exit 1"
        ),
    )
    _write_command(
        bin_dir,
        "netstat",
        'printf "Name Mtu Network Address Ipkts Ierrs Ibytes Opkts Oerrs Obytes\\n'
        f'en0 1500 link x 0 0 {rx_bytes} 0 0 {tx_bytes}\\n"',
    )
    env = os.environ.copy()
    env.update(
        {
            "DOTS_THEME": "dark",
            "DOTS_WIFI_RSSI": "",
            "MOCK_NOW": str(now),
            "PATH": f"{bin_dir}:{env['PATH']}",
            "XDG_RUNTIME_DIR": str(runtime_dir),
        }
    )
    return subprocess.run(
        [str(NETWORK)],
        capture_output=True,
        text=True,
        check=True,
        env=env,
    ).stdout


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


def test_network_offline_warning_waits_for_sustained_failure(tmp_path):
    settling = _run_network(tmp_path, now=100, ping_succeeds=False)
    still_settling = _run_network(tmp_path, now=120, ping_succeeds=False)
    offline = _run_network(tmp_path, now=130, ping_succeeds=False)
    recovered = _run_network(tmp_path, now=140, ping_succeeds=True)

    assert "#[bg=#F88C14]" not in settling
    assert "#[bg=#F88C14]" not in still_settling
    assert "󰤭 --" in settling
    assert "#[bg=#F88C14]" in offline
    assert "#[bg=#F88C14]" not in recovered
    assert "󰤨 42ms" in recovered


def test_network_latency_waits_for_twelve_sample_warmup(tmp_path):
    for index in range(11):
        collecting = _run_network(
            tmp_path,
            now=100 + index * 10,
            ping_succeeds=True,
            latency_ms=40,
        )
        assert "󰤨 40ms" in collecting
        assert "#[bg=#F88C14]" not in collecting

    ready = _run_network(tmp_path, now=210, ping_succeeds=True, latency_ms=40)

    assert "40ms" in ready
    assert "#[bg=#F88C14]" not in ready


def test_network_icon_blinks_during_latency_warmup(tmp_path):
    visible = _run_network(tmp_path, now=100, ping_succeeds=True, latency_ms=40)
    hidden = _run_network(tmp_path, now=101, ping_succeeds=True, latency_ms=40)

    assert "󰤨 40ms" in visible
    assert "󰤨" not in hidden
    assert "  40ms" in hidden


def test_network_wifi_icon_reflects_cached_rssi(tmp_path):
    runtime_dir = tmp_path / "runtime"
    runtime_dir.mkdir()
    (runtime_dir / "network").write_text(
        "ping_time=100\nms=40\nlatency_samples=40\n"
        "offline_since=0\nwired=\niface=en0\nrssi=-80\n"
    )

    weak = _run_network(tmp_path, now=102, ping_succeeds=True, latency_ms=40)

    assert "󰤟 40ms" in weak


def test_network_latency_locks_after_warmup_despite_variance(tmp_path):
    for index in range(11):
        _run_network(
            tmp_path,
            now=100 + index * 10,
            ping_succeeds=True,
            latency_ms=40,
        )

    _run_network(tmp_path, now=210, ping_succeeds=True, latency_ms=200)
    locked = _run_network(tmp_path, now=211, ping_succeeds=True, latency_ms=200)

    assert "󰤨 53ms" in locked
    assert "#[bg=#F88C14]" not in locked


def test_network_latency_keeps_using_thirty_sample_rolling_mean(tmp_path):
    runtime_dir = tmp_path / "runtime"
    runtime_dir.mkdir()
    samples = (
        "16:36:16:22:22:24:19:43:17:16:20:16:46:15:31:"
        "18:16:19:32:22:27:30:38:51:16:17:16:17:16:19"
    )
    (runtime_dir / "network").write_text(
        f"ping_time=390\nms=19\nlatency_samples={samples}\n"
        "offline_since=0\nwired=\niface=en0\n"
    )

    stable = _run_network(tmp_path, now=391, ping_succeeds=True)

    assert "󰤨 24ms" in stable
    assert "#[bg=#F88C14]" not in stable


def test_network_latency_warns_only_after_warmup(tmp_path):
    for index in range(11):
        collecting = _run_network(
            tmp_path,
            now=100 + index * 10,
            ping_succeeds=True,
            latency_ms=200,
        )
        assert "󰤨 200ms" in collecting
        assert "#[bg=#F88C14]" not in collecting

    ready = _run_network(tmp_path, now=210, ping_succeeds=True, latency_ms=200)

    assert "200ms" in ready
    assert "#[bg=#F88C14]" in ready


def test_network_traffic_arrows_stay_visible_and_color_active_direction(tmp_path):
    idle = _run_network(tmp_path, now=100, ping_succeeds=True)
    receiving = _run_network(
        tmp_path,
        now=110,
        ping_succeeds=True,
        rx_bytes=601000,
        tx_bytes=1000,
    )
    sending = _run_network(
        tmp_path,
        now=120,
        ping_succeeds=True,
        rx_bytes=601000,
        tx_bytes=601000,
    )

    assert "#[bold]#[fg=#808080]⇃#[fg=#808080]↾#[nobold]" in idle
    assert "#[bold]#[fg=#2CB494]⇃#[fg=#808080]↾#[nobold]" in receiving
    assert "#[bold]#[fg=#808080]⇃#[fg=#7290B8]↾#[nobold]" in sending
    assert receiving.index("42ms") < receiving.index("⇃")
    assert "K" not in receiving


def test_network_indicator_is_hidden_in_codespaces(tmp_path):
    env = os.environ.copy()
    env.update(
        {
            "CODESPACES": "true",
            "DOTS_THEME": "dark",
            "XDG_RUNTIME_DIR": str(tmp_path),
        }
    )

    result = subprocess.run(
        [str(NETWORK)],
        capture_output=True,
        text=True,
        check=True,
        env=env,
    )

    assert result.stdout == ""
    assert not (tmp_path / "network").exists()


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


def test_network_pill_has_a_leading_cell_margin():
    status_right = re.findall(
        r'^\s*set -g status-right "(.*)"$',
        CONFIG.read_text(),
        re.MULTILINE,
    )

    assert len(status_right) == 2
    assert all(
        "#{?#{e|>=|:#{client_width},120}, #(~/.tmux/network.sh)"
        in value
        for value in status_right
    )


def test_window_overflow_markers_do_not_touch_pills():
    config = CONFIG.read_text()

    assert "list=left-marker fg=#808080,bg=default]‹ " in config
    assert "list=right-marker fg=#808080,bg=default] ›" in config


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
