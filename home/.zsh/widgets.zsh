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

    # Ctrl+E: edit file (frecency + git status boost)
    _dots_edit_widget() {
        local file edit_log="${XDG_DATA_HOME:-$HOME/.local/share}/edit/log"
        file="$({
            awk -v logfile="$edit_log" '
            BEGIN {
                while ((getline line < logfile) > 0) {
                    idx = index(line, "\t")
                    if (idx) { f = substr(line, idx+1); cnt[f]++; ts[f] = substr(line, 1, idx-1)+0 }
                }
                close(logfile)
                cmd = "git status --porcelain 2>/dev/null"
                while ((cmd | getline line) > 0) {
                    st = substr(line, 1, 2); f = substr(line, 4)
                    if ((i = index(f, " -> ")) > 0) f = substr(f, i+4)
                    gsub(/^"|"$/, "", f)
                    if (st !~ /D/) git[f] = st
                }
                close(cmd)
                for (f in cnt) {
                    s = cnt[f] * 1000 + ts[f]
                    if (f in git) { s += 100000; printf "%d\t%s\t%s\n", s, clr(git[f]), f; delete git[f] }
                    else printf "%d\t \t%s\n", s, f
                }
                for (f in git) printf "100000\t%s\t%s\n", clr(git[f]), f
            }
            function clr(st) {
                if (st ~ /^\?\?/) return "\033[33m?\033[0m"
                if (st ~ /^R/)    return "\033[36mR\033[0m"
                if (st ~ /^A/)    return "\033[32mA\033[0m"
                if (st ~ /M/)     return "\033[38;5;103mM\033[0m"
                return "\033[90m~\033[0m"
            }' /dev/null 2>/dev/null | sort -rn | cut -f2-
            rg --files --hidden --glob '!.git' 2>/dev/null | awk '{print " \t" $0}'
        } | awk -F'\t' '!seen[$2]++' \
          | fzf --ansi --delimiter='\t' --nth=2 \
                --preview 'bat --color=always --style=numbers --line-range=:100 {2} 2>/dev/null || head -100 {2}')" \
          || { zle reset-prompt; return; }
        file="$(printf '%s' "$file" | cut -f2)"
        [[ -z "$file" ]] && { zle reset-prompt; return; }
        mkdir -p "${edit_log:h}"
        printf '%s\t%s\n' "$(date +%s)" "$file" >> "$edit_log"
        BUFFER="${EDITOR:-vim} ${(q)file}"
        zle reset-prompt
        zle accept-line
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
        selection="$(rg --color=always --line-number --no-heading --hidden --glob '!.git' '' 2>/dev/null \
            | fzf --ansi --delimiter=: \
                  --preview 'n={2}; n=${n:-1}; bat --color=always --style=numbers --highlight-line=$n --line-range=$((n>30?n-30:1)):$((n+30)) {1} 2>/dev/null || head -n $(( n + 30 )) {1} 2>/dev/null | tail -n 60' \
                  --preview-window='right:60%')" || { zle -I; zle reset-prompt; return; }
        local file="${selection%%:*}"
        local line="${${selection#*:}%%:*}"
        BUFFER="${EDITOR:-vim} +${line} ${(q)file}"
        zle reset-prompt
        zle accept-line
    }
    zle -N _dots_find_in_files_widget
    bindkey '^F' _dots_find_in_files_widget

    # Ctrl+Q: git log browser
    _dots_git_log_widget() {
        local commit
        commit="$(git log --oneline --color --decorate -50 2>/dev/null \
            | fzf --ansi --no-sort \
                  --preview 'git show --color=always {1}' \
                  --preview-window='right:60%')" || { zle reset-prompt; return; }
        BUFFER="git show ${commit%% *}"
        zle reset-prompt
        zle accept-line
    }
    zle -N _dots_git_log_widget
    bindkey '^Q' _dots_git_log_widget

    # Ctrl+K: command help lookup
    _dots_help_widget() {
        local cmd
        cmd="$(print -l ${(ko)commands} | fzf --preview 'tldr {1} 2>/dev/null || man -P cat {1} 2>/dev/null | head -80')" \
            || { zle reset-prompt; return; }
        if command -v tldr &>/dev/null; then
            BUFFER="tldr ${(q)cmd}"
        else
            BUFFER="man ${(q)cmd}"
        fi
        zle reset-prompt
        zle accept-line
    }
    zle -N _dots_help_widget
    bindkey '^K' _dots_help_widget

    # Ctrl+N: tmux session
    _dots_tmux_widget() {
        [[ -n "${CODESPACES:-}" ]] && { zle reset-prompt; return; }
        local sessions
        sessions="$(tmux list-sessions -F '#{session_name}' 2>/dev/null)"
        if [[ -z "$sessions" ]]; then
            BUFFER="tmux new-session"
        elif [[ -n "$TMUX" ]]; then
            local session
            session="$({ echo '+ new session'; echo "$sessions"; } \
                | fzf --preview 'case {} in "+ new session") echo "Create a new tmux session";; *) tmux list-windows -t {} -F "  #{window_index}: #{window_name} #{pane_current_command}";; esac')" \
                || { zle reset-prompt; return; }
            if [[ "$session" == "+ new session" ]]; then
                BUFFER="tmux new-session -d && tmux switch-client -n"
            else
                BUFFER="tmux switch-client -t ${(q)session}"
            fi
        else
            local session
            session="$(echo "$sessions" \
                | fzf --preview 'tmux list-windows -t {} -F "  #{window_index}: #{window_name} #{pane_current_command}"')" \
                || { zle reset-prompt; return; }
            BUFFER="tmux attach -t ${(q)session}"
        fi
        zle reset-prompt
        zle accept-line
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
        [[ -d "$session_dir" ]] || { BUFFER="colby --continue"; zle reset-prompt; zle accept-line; return; }
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
        ' --delimiter="|" --with-nth=1,3 \
           --header 'enter=resume | ^r=restricted | ^s=latest | ^n=new' \
           --expect=ctrl-r,ctrl-s,ctrl-n)"
        local fzf_rc=$?
        [[ $fzf_rc -ne 0 && "$session" != ctrl-s* && "$session" != ctrl-n* ]] && { zle reset-prompt; return; }
        local key=$(echo "$session" | head -1)
        local line=$(echo "$session" | tail -1)
        # Ctrl+N — new session
        if [[ "$key" == "ctrl-n" ]]; then
            BUFFER="colby"
            zle reset-prompt
            zle accept-line
            return
        fi
        # Ctrl+S again — continue latest
        if [[ "$key" == "ctrl-s" ]]; then
            BUFFER="colby --continue"
            zle reset-prompt
            zle accept-line
            return
        fi
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

    # Ctrl+X: process manager
    _dots_process_widget() {
        local proc
        proc="$(ps -eo pid,user,%cpu,%mem,command 2>/dev/null \
            | fzf --header-lines=1 --preview 'ps -p {1} -o pid,ppid,stat,start,time,command 2>/dev/null' \
                  --preview-window='down:4:wrap')" || { zle reset-prompt; return; }
        local pid="${${proc## #}%% *}"
        BUFFER="kill $pid"
        zle reset-prompt
        zle accept-line
    }
    zle -N _dots_process_widget
    bindkey '^X' _dots_process_widget

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
