_dots_load_keybindings() {
    bindkey -e

    # Ctrl+D: delete char (suppress IGNORE_EOF logout warning)
    bindkey '^D' delete-char

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
    # Defaults to the current folder; ^g pulls out to the whole repo, ^l re-scopes
    # to the folder. Display paths are root-relative; field 3 is the absolute path.
    _dots_edit_widget() {
        local selection edit_log="${XDG_DATA_HOME:-$HOME/.local/share}/edit/log"
        local repo_root
        repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || repo_root="$PWD"
        [[ -z "$repo_root" ]] && repo_root="$PWD"
        selection="$(edit-list "$PWD" \
          | fzf --ansi --delimiter='\t' --with-nth=1,2 --nth=2 \
                --header 'enter=edit | ^v=preview | ^z=zen | ^y=copy | ^g=repo | ^l=folder' \
                --preview 'preview {3}' \
                --bind "ctrl-g:reload(edit-list ${(q)repo_root})" \
                --bind "ctrl-l:reload(edit-list ${(q)PWD})" \
                --expect='ctrl-v,ctrl-z,ctrl-y')" \
          || { zle reset-prompt; return; }
        local key=$(head -1 <<< "$selection")
        local file=$(printf '%s' "$(tail -1 <<< "$selection")" | cut -f3)
        [[ -z "$file" ]] && { zle reset-prompt; return; }
        case "$key" in
            ctrl-v)
                BUFFER="preview ${(q)file}"
                ;;
            ctrl-z)
                BUFFER="preview --zen ${(q)file}"
                ;;
            ctrl-y)
                BUFFER="clip ${(q)file}"
                ;;
            *)
                mkdir -p "${edit_log:h}"
                printf '%s\t%s\n' "$(date +%s)" "$file" >> "$edit_log"
                BUFFER="${EDITOR:-vim} ${(q)file}"
                ;;
        esac
        zle reset-prompt
        zle accept-line
    }
    zle -N _dots_edit_widget
    bindkey '^E' _dots_edit_widget

    # Ctrl+G: remote connect
    if [[ -z "${CODESPACES:-}" ]]; then
    _dots_ssh_hosts() {
        local ssh_log="${XDG_DATA_HOME:-$HOME/.local/share}/ssh/log"

        {
            if [[ -f "$ssh_log" ]]; then
                awk '{c[$2]++; t[$2]=$1} END {for(h in c) print c[h]*1000+t[h], h}' "$ssh_log" | sort -rn | awk '{print $2}'
            fi
            awk '/^Host / && !/\*/ {print $2}' ~/.ssh/config ~/.ssh/config.d/* 2>/dev/null
            awk '{print $1}' ~/.ssh/known_hosts 2>/dev/null | tr ',' '\n' | sed 's/\[//;s/\]:.*//'
            gh cs list --json name,repository,gitStatus \
                -q '.[] | "cs:\(.name)\t\(.repository)\t\(.gitStatus.ref // "")"' \
                2>/dev/null
        } | awk -F'\t' '
            BEGIN {
                teal  = "\033[38;2;44;180;148m"
                white = "\033[97m"
                amber = "\033[38;2;248;140;20m"
                rst   = "\033[0m"
            }
            {
                if ($1 ~ /^cs:/ && NF > 1) { repo[$1] = $2; br[$1] = $3 }
                if (!seen[$1]++) { order[++n] = $1 }
            }
            END {
                for (i = 1; i <= n; i++) {
                    k = order[i]
                    if (k ~ /^cs:/) {
                        name = substr(k, 4)
                        r = repo[k]; b = br[k]
                        printf "%scs:%s%s%s%s", white, rst, teal, name, rst
                        if (r != "") printf "  %s", r
                        if (b != "" && b != "main" && b != "master")
                            printf "  %s%s%s", amber, b, rst
                        printf "\n"
                    } else {
                        printf "%s%s%s\n", teal, k, rst
                    }
                }
            }
        '
    }
    _dots_ssh_widget() {
        local target
        target="$(_dots_ssh_hosts | fzf --ansi --no-preview)" || { zle reset-prompt; return; }
        target="$(printf '%s' "$target" | sed $'s/\033\\[[0-9;]*m//g' | awk '{print $1}')"
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

    # Ctrl+F: find in files (live grep). Searches as you type and streams
    # matches, so nothing scans the whole tree up front (the old version ran
    # `rg ''`, opening every file's content — brutal under Defender). Prefers the
    # repo's csearch trigram index (csearch opens only candidate files, far fewer
    # scanned open()s) and falls back to ripgrep. For an index-eligible repo
    # ($WORKSPACE/owner/repo) with no index yet, ripgrep serves the search while
    # the index builds once in the background; new keystrokes pick it up
    # automatically, or press ^T to switch the current query over when ready.
    _dots_find_in_files_widget() {
        local root
        root="$(git rev-parse --show-toplevel 2>/dev/null)" || root="$PWD"
        [[ -n "$root" ]] || root="$PWD"
        # One-time background index build if eligible + unindexed (no-op else).
        find-in-files --ensure-index "$root" 2>/dev/null

        local selection
        selection="$(fzf --ansi --disabled --delimiter=: \
            --prompt 'find> ' \
            --header "$(find-in-files --status "$root")" \
            --preview 'preview {1} {2}' \
            --preview-window='right:60%' \
            --bind "change:reload(sleep 0.2; find-in-files ${(q)root} {q})" \
            --bind "ctrl-t:reload(find-in-files ${(q)root} {q})" \
            --bind "result:transform-header(find-in-files --status ${(q)root})" \
            </dev/null)" || { zle reset-prompt; return; }
        local file="${selection%%:*}"
        local line="${${selection#*:}%%:*}"
        [[ -n "$file" ]] || { zle reset-prompt; return; }
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
                | fzf --bind 'ctrl-n:first+accept' \
                      --preview 'case {} in "+ new session") echo "Create a new tmux session";; *) tmux list-windows -t {} -F "  #{window_index}: #{window_name} #{pane_current_command}";; esac')" \
                || { zle reset-prompt; return; }
            if [[ "$session" == "+ new session" ]]; then
                BUFFER="tmux new-session -d && tmux switch-client -n"
            else
                BUFFER="tmux switch-client -t ${(q)session}"
            fi
        else
            local session
            session="$(echo "$sessions" \
                | fzf --bind 'ctrl-n:accept' \
                      --preview 'tmux list-windows -t {} -F "  #{window_index}: #{window_name} #{pane_current_command}"')" \
                || { zle reset-prompt; return; }
            BUFFER="tmux attach -t ${(q)session}"
        fi
        zle reset-prompt
        zle accept-line
    }
    zle -N _dots_tmux_widget
    bindkey '^N' _dots_tmux_widget

    # Ctrl+V: dev-container picker/creator (local devcontainers via podman).
    # Mirrors ^S: lists existing instances to resume; ^n creates a new one from
    # a git repo under $WORKSPACE. Auto-runs the chosen dev-container command.
    _dots_devcontainer_widget() {
        command -v dev-container >/dev/null || { zle reset-prompt; return; }
        local ws="${WORKSPACE:-$HOME/Workspace}"
        # Existing instances (fast: reads the cache, no VM). Rows: repo<TAB>instance
        local list; list="$(dev-container --list 2>/dev/null)"
        local sel key repo inst
        if [[ -n "$list" ]]; then
            sel="$(print -r -- "$list" | fzf --delimiter=$'\t' --with-nth=1,2 \
                      --header '^n=new  enter=resume  ^d=remove' \
                      --expect=ctrl-n,ctrl-d)" || { zle reset-prompt; return; }
            key="$(sed -n 1p <<< "$sel")"
            local line="$(sed -n 2p <<< "$sel")"
            repo="$(cut -f1 <<< "$line")"
            inst="$(cut -f2 <<< "$line")"
        else
            key=ctrl-n
        fi
        # ^n (or no instances yet) -> creator: pick a git repo under $WORKSPACE
        if [[ "$key" == "ctrl-n" ]]; then
            local picked
            picked="$(cd "$ws" 2>/dev/null && print -rl -- */*/.git(N:h) \
                | fzf --header 'pick a repo to spin up (owner/repo)')" \
                || { zle reset-prompt; return; }
            [[ -n "$picked" ]] || { zle reset-prompt; return; }
            BUFFER="dev-container ${(q)picked} --skip-setup --copilot"
        elif [[ "$key" == "ctrl-d" ]]; then
            BUFFER="dev-container --rm ${(q)repo}${inst:+ ${(q)inst}}"
        else
            BUFFER="dev-container ${(q)repo}${inst:+ --name ${(q)inst}} --skip-setup --copilot"
        fi
        zle reset-prompt
        zle accept-line
    }
    zle -N _dots_devcontainer_widget
    bindkey '^V' _dots_devcontainer_widget

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
        local colby_cmd="copilot --allow-all-tools --allow-all-paths"
        [[ -d "$session_dir" ]] || { BUFFER="$colby_cmd"; zle reset-prompt; zle accept-line; return; }
        local session
        # Session rows come from `copilot-sessions`, which keeps an incremental
        # cache (~/.cache/copilot-sessions) so only sessions whose files changed
        # are re-opened. This machine's Microsoft Defender scans every file
        # open(), so the old inline scan of ~500 sessions (events.jsonl up to
        # 32MB each) froze the prompt for seconds on the first ^S of each
        # terminal; piping the helper straight into fzf instead opens the picker
        # instantly and shows fzf's spinner while any rebuild streams in.
        #
        # Default to sessions in the current directory when the cache shows any
        # (checked instantly, no scan). The dir column is hidden in that view
        # since every row shares $PWD; ^g pulls out to the global list and shows
        # the dir column (before the message, so it stays readable), ^l re-scopes
        # to the current directory and hides it again.
        local cache="${XDG_CACHE_HOME:-$HOME/.cache}/copilot-sessions/index.tsv"
        local with_nth='1,4,3' scope=()
        if [[ "$PWD" != "$HOME" && -f "$cache" ]] && grep -qF -- "$PWD" "$cache"; then
            with_nth='1,3'
            scope=(--cwd "$PWD")
        fi
        session="$(copilot-sessions "${scope[@]}" | fzf --preview '
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
        ' --ansi --delimiter="|" --with-nth="$with_nth" \
           --header '^n=new ^s=latest enter=resume ^g=global ^l=cwd ^d=del ^r=restricted ⌥n=new restricted' \
           --bind "ctrl-l:reload(copilot-sessions --cwd ${(q)PWD})+change-with-nth(1,3)+first" \
           --bind "ctrl-g:reload(copilot-sessions)+change-with-nth(1,4,3)+first" \
           --expect=ctrl-r,ctrl-s,ctrl-n,ctrl-d,alt-n)"
        local fzf_rc=$?
        [[ $fzf_rc -ne 0 && "$session" != ctrl-s* && "$session" != ctrl-n* && "$session" != alt-n* ]] && { zle reset-prompt; return; }
        local key=$(echo "$session" | head -1)
        local line=$(echo "$session" | tail -1)
        # Ctrl+N — new session
        if [[ "$key" == "ctrl-n" ]]; then
            BUFFER="$colby_cmd"
            zle reset-prompt
            zle accept-line
            return
        fi
        # Alt+N — new restricted session
        if [[ "$key" == "alt-n" ]]; then
            BUFFER="gh copilot"
            zle reset-prompt
            zle accept-line
            return
        fi
        # Ctrl+S again — continue latest
        if [[ "$key" == "ctrl-s" ]]; then
            BUFFER="$colby_cmd --continue"
            zle reset-prompt
            zle accept-line
            return
        fi
        local id=$(echo "$line" | cut -d'|' -f2 | tr -d ' ')
        [[ -n "$id" ]] || { zle reset-prompt; return; }
        # Ctrl+D — delete session
        if [[ "$key" == "ctrl-d" ]]; then
            rm -rf "${session_dir:?}/$id" "${session_dir:?}/${id}.jsonl"
            zle reset-prompt
            return
        fi
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

    # Restore Tab after bindkey -e
    if (( ${+widgets[fzf-completion]} )); then
        bindkey '^I' fzf-completion
    elif (( ${+widgets[_dots_lazy_comp_widget]} )); then
        bindkey '^I' _dots_lazy_comp_widget
    fi

    # Enter: expand colby → full copilot invocation (visible in terminal history)
    _dots_enter_handler() {
        if [[ "$BUFFER" == "colby" || "$BUFFER" == "colby "* ]]; then
            BUFFER="${BUFFER/#colby/copilot --allow-all-tools --allow-all-paths}"
        fi
        zle accept-line
    }
    zle -N _dots_enter_handler
    bindkey '^M' _dots_enter_handler
}
_dots_load_keybindings
