_dots_load_keybindings() {
    bindkey -e
    stty -ixon 2>/dev/null

    # Ctrl+J: zoxide jump
    _dots_zoxide_widget() {
        local result
        result="$(zoxide query -i -- 2>&1)" || { zle reset-prompt; return; }
        BUFFER="cd ${(q)result}"
        zle reset-prompt
        zle accept-line
    }
    zle -N _dots_zoxide_widget
    bindkey '^J' _dots_zoxide_widget

    # Ctrl+B: git branch checkout
    _dots_git_branch_widget() {
        local branch
        branch="$(git branch --all --sort=-committerdate --format='%(refname:short)' 2>/dev/null \
            | fzf --preview 'git log --oneline --color -20 {}')" || { zle reset-prompt; return; }
        branch="${branch#origin/}"
        BUFFER="git checkout ${(q)branch}"
        zle reset-prompt
        zle accept-line
    }
    zle -N _dots_git_branch_widget
    bindkey '^B' _dots_git_branch_widget

    # Ctrl+E: edit file
    _dots_edit_widget() {
        local file
        file="$({ rg --files --hidden --glob '!.git' 2>/dev/null || find . -type f -not -path '*/.git/*'; } \
            | fzf --preview 'head -100 {}')" || { zle reset-prompt; return; }
        ${EDITOR:-vim} "$file" </dev/tty
        zle reset-prompt
    }
    zle -N _dots_edit_widget
    bindkey '^E' _dots_edit_widget

    # Ctrl+G: remote connect
    if [[ -z "${CODESPACES:-}" ]]; then
    _dots_ssh_hosts() {
        local ssh_log="${XDG_DATA_HOME:-$HOME/.local/share}/ssh/log"
        local cs_cache="$_dots_cache_dir/codespaces"

        # Refresh codespace cache in background if stale (>5 min)
        if [[ ! -f "$cs_cache" ]] || [[ -n "$(find "$cs_cache" -mmin +5 2>/dev/null)" ]]; then
            { gh cs list --json name -q '.[].name' 2>/dev/null | sed 's/^/cs:/' > "$cs_cache.tmp" && mv "$cs_cache.tmp" "$cs_cache"; } &!
        fi

        {
            if [[ -f "$ssh_log" ]]; then
                awk '{c[$2]++; t[$2]=$1} END {for(h in c) print c[h]*1000+t[h], h}' "$ssh_log" | sort -rn | awk '{print $2}'
            fi
            awk '/^Host / && !/\*/ {print $2}' ~/.ssh/config ~/.ssh/config.d/* 2>/dev/null
            awk '{print $1}' ~/.ssh/known_hosts 2>/dev/null | tr ',' '\n' | sed 's/\[//;s/\]:.*//'
            [[ -f "$cs_cache" ]] && cat "$cs_cache"
        } | awk '!seen[$0]++'
    }
    _dots_ssh_widget() {
        local target
        target="$(_dots_ssh_hosts | fzf)" || { zle reset-prompt; return; }
        if [[ "$target" == cs:* ]]; then
            BUFFER="cs ${target#cs:}"
        else
            BUFFER="ssh $target"
        fi
        zle reset-prompt
        zle accept-line
    }
    zle -N _dots_ssh_widget
    bindkey '^G' _dots_ssh_widget
    else
    bindkey -r '^G'
    fi

    # Ctrl+F: find in files
    _dots_find_in_files_widget() {
        local selection
        selection="$(rg --color=always --line-number --no-heading '' 2>/dev/null \
            | fzf --ansi --delimiter=: \
                  --preview 'head -n $((({2}+30))) {1} | tail -n 60' \
                  --preview-window='right:60%')" || { zle reset-prompt; return; }
        local file="${selection%%:*}"
        local line="${${selection#*:}%%:*}"
        ${EDITOR:-vim} "+$line" "$file" </dev/tty
        zle reset-prompt
    }
    zle -N _dots_find_in_files_widget
    bindkey '^F' _dots_find_in_files_widget

    # Ctrl+N: tmux session
    _dots_tmux_widget() {
        if [[ -z "$TMUX" ]]; then
            tmux new-session </dev/tty
        else
            local session
            session="$(tmux list-sessions -F '#{session_name}' 2>/dev/null \
                | fzf --preview 'tmux list-windows -t {} -F "  #{window_index}: #{window_name} #{pane_current_command}"')" \
                || { zle reset-prompt; return; }
            tmux switch-client -t "$session"
        fi
        zle reset-prompt
    }
    zle -N _dots_tmux_widget
    bindkey '^N' _dots_tmux_widget

    # Ctrl+O: open in browser
    _dots_open_widget() {
        local choice
        choice="$(printf 'repo\npr\nissues\nactions' | fzf)" || { zle reset-prompt; return; }
        case "$choice" in
            repo)    BUFFER="gh browse" ;;
            pr)      BUFFER="gh pr view --web" ;;
            issues)  BUFFER="gh browse --issues" ;;
            actions) BUFFER="gh browse --actions" ;;
        esac
        zle reset-prompt
        zle accept-line
    }
    zle -N _dots_open_widget
    bindkey '^O' _dots_open_widget

    # Ctrl+P: project switch
    _dots_project_widget() {
        local result
        result="$(zoxide query -l 2>/dev/null | grep "${WORKSPACE:-$HOME/Workspace}" \
            | fzf --preview 'ls -1 {}')" || { zle reset-prompt; return; }
        BUFFER="cd ${(q)result}"
        zle reset-prompt
        zle accept-line
    }
    zle -N _dots_project_widget
    bindkey '^P' _dots_project_widget

    # Ctrl+S: copilot sessions
    _dots_copilot_session_widget() {
        local session_dir="$HOME/.copilot/session-state"
        [[ -d "$session_dir" ]] || { zle reset-prompt; return; }
        local session
        session="$(python3 -c "
import os, json, glob
sd = os.path.expanduser('~/.copilot/session-state')
home = os.path.expanduser('~')
entries = []
for ws in glob.glob(os.path.join(sd, '*/workspace.yaml')):
    try:
        d = {}
        with open(ws) as f:
            for l in f:
                for k in ('updated_at:','cwd:','id:','summary:','repository:'):
                    if l.startswith(k): d[k[:-1]] = l.split(': ',1)[1].strip()
        sid = d.get('id','')
        if not sid: continue
        ts = d.get('updated_at','?')[:16]
        repo = d.get('repository','').split('/')[-1] if d.get('repository') else ''
        summary = d.get('summary','')
        msg = ''
        ev = os.path.join(os.path.dirname(ws), 'events.jsonl')
        if os.path.exists(ev):
            with open(ev) as f:
                for l in f:
                    if '\"user.message\"' in l:
                        try: msg = json.loads(l)['data']['content'].strip().split(chr(10))[0][:60]
                        except: pass
                        break
        if not msg: continue
        ctx = repo or d.get('cwd','?').replace(home,'~')
        label = f'{ctx} \u00b7 {summary}' if summary else f'{ctx} \u00b7 {msg}'
        entries.append((ts, sid, label))
    except: pass
for jf in glob.glob(os.path.join(sd, '*.jsonl')):
    try:
        sid = os.path.basename(jf).replace('.jsonl','')
        with open(jf) as f:
            ts = json.loads(f.readline())['data']['startTime'][:16]
        msg = ''
        with open(jf) as f:
            for l in f:
                if '\"user.message\"' in l:
                    try: msg = json.loads(l)['data']['content'].strip().split(chr(10))[0][:60]
                    except: pass
                    break
        if not msg: continue
        entries.append((ts, sid, msg))
    except: pass
entries.sort(key=lambda x: x[0], reverse=True)
for ts, sid, label in entries:
    print(f'{ts} | {sid} | {label}')
" 2>/dev/null | fzf --preview '
            id=$(echo {} | cut -d"|" -f2 | tr -d " ")
            sd="'"$session_dir"'"
            f="$sd/$id/events.jsonl"
            [[ -f "$f" ]] || f="$sd/${id}.jsonl"
            [[ -f "$f" ]] || exit 0
            grep "\"user.message\"" "$f" | python3 -c "
import sys,json
for line in sys.stdin:
    try:
        msg=json.loads(line)[\"data\"][\"content\"].strip().split(chr(10))[0][:100]
        print(\">\", msg)
    except: pass
" 2>/dev/null
        '  --header 'enter=colby | ctrl-r=restricted' \
           --expect=ctrl-r)" || { zle reset-prompt; return; }
        local key=$(echo "$session" | head -1)
        local line=$(echo "$session" | tail -1)
        local id=$(echo "$line" | cut -d'|' -f2 | tr -d ' ')
        if [[ "$key" == "ctrl-r" ]]; then
            BUFFER="gh copilot --resume $id"
        else
            BUFFER="copilot --allow-all-tools --allow-all-paths --resume $id"
        fi
        zle reset-prompt
        zle accept-line
    }
    zle -N _dots_copilot_session_widget
    bindkey '^S' _dots_copilot_session_widget

    # Ctrl+Y: git stash browser
    _dots_stash_widget() {
        local stash
        stash="$(git stash list --color=always 2>/dev/null \
            | fzf --ansi --no-sort \
                  --preview 'git stash show -p --color=always $(echo {} | cut -d: -f1)' \
                  --preview-window='right:60%')" || { zle reset-prompt; return; }
        local ref="${stash%%:*}"
        BUFFER="git stash apply $ref"
        zle reset-prompt
        zle accept-line
    }
    zle -N _dots_stash_widget
    bindkey '^Y' _dots_stash_widget
}
_dots_load_keybindings
