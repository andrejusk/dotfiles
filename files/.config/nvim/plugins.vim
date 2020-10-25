call plug#begin('~/.config/nvim/plugged')

" sensible defaults
Plug 'tpope/vim-sensible'

" colorscheme
Plug 'chriskempson/base16-vim'

" dev icons
Plug 'ryanoasis/vim-devicons'
" {{{
    let g:webdevicons_enable_nerdtree = 1
    let g:webdevicons_conceal_nerdtree_brackets = 1

    let g:webdevicons_enable_airline_tabline = 1
    let g:webdevicons_enable_airline_statusline = 1

    let g:webdevicons_enable_startify = 1
" }}}

" explorer sidebar
Plug 'scrooloose/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
" {{{
    " Show hidden files/directories
    let g:NERDTreeShowHidden = 1

    " Remove bookmarks and help text from NERDTree
    let g:NERDTreeMinimalUI = 1
    let g:NERDTreeMinimalMenu = 1

    " Remove icons for expandable/expanded directories
    let g:NERDTreeDirArrowExpandable = ''
    let g:NERDTreeDirArrowCollapsible = ''

    " Hide certain files and directories from NERDTree
    let g:NERDTreeIgnore = ['\.git$[[dir]]']
" }}}

" status line
Plug 'vim-airline/vim-airline'
" {{{
    " Enable extensions
    let g:airline_extensions = ['branch', 'coc', 'hunks']

    " Do not draw separators for empty sections (only for the active window) >
    let g:airline_skip_empty_sections = 1

    " Smartly uniquify buffers names with similar filename, suppressing common parts of paths.
    let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

    " Custom setup that removes filetype/whitespace from default vim airline bar
    " let g:airline#extensions#default#layout = [['a', 'b', 'c'], ['x', 'z', 'warning', 'error']]

    " Customize vim airline per filetype
    " 'nerdtree'  - Hide nerdtree status line
    " 'list'      - Only show file type plus current line number out of total
    let g:airline_filetype_overrides = {
      \ 'coc-explorer':  [ 'CoC Explorer', '' ],
      \ 'fugitive': ['fugitive', '%{airline#util#wrap(airline#extensions#branch#get_head(),80)}'],
      \ 'help':  [ 'Help', '%f' ],
      \ 'startify': [ 'startify', '' ],
      \ 'vim-plug': [ 'Plugins', '' ],
      \ 'nerdtree': [ get(g:, 'NERDTreeStatusline', ''), '' ],
      \ 'list': [ '%y', '%l/%L'],
      \ }

    " Enable powerline fonts
    let g:airline_powerline_fonts = 1

    " Enable caching of syntax highlighting groups
    let g:airline_highlighting_cache = 1
" }}}

" Print function signatures in echo area
Plug 'Shougo/echodoc.vim'
" {{{
    " Enable echodoc on startup
    let g:echodoc#enable_at_startup = 1
" }}}

" start screen
Plug 'mhinz/vim-startify'

" distraction-free typing
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

" DOcumentation GEneraton
Plug 'kkoomen/vim-doge'

" auto-close plugins
Plug 'rstacruz/vim-closer'
Plug 'tpope/vim-endwise'

" better motion
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-surround'
Plug 'svermeulen/vim-subversive'
Plug 'godlygeek/tabular'
Plug 'tpope/vim-commentary'

" git tools
Plug 'mhinz/vim-signify'
" {{{
    let g:signify_sign_delete = '-'
" }}}
Plug 'tpope/vim-fugitive'

" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" {{{
    let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.9 } }
    let g:fzf_preview_window = ['right:66%', 'ctrl-/']

    let g:fzf_buffers_jump = 1
    let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

    let $FZF_DEFAULT_OPTS="--ansi --layout reverse --margin=1,4 --preview 'batcat --color=always --style=header,grid --line-range :300 {}'"
    let $FZF_DEFAULT_COMMAND = 'rg --files --ignore-case --hidden -g "!{.git,node_modules,vendor}/*"'
    command! -bang -nargs=? -complete=dir Files
            \ call fzf#vim#files(<q-args>, { 'options': $FZF_DEFAULT_OPTS}, <bang>0)
" }}}

" coc
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
" {{{
    " Keep in sync with below
    let g:coc_global_extensions = [
    \   'coc-css',
    \   'coc-eslint',
    \   'coc-git',
    \   'coc-html',
    \   'coc-json',
    \   'coc-prettier',
    \   'coc-python',
    \   'coc-tabnine',
    \   'coc-tsserver',
    \   'coc-yaml',
    \]
" }}}
Plug 'neoclide/coc-css', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-eslint', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-git', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-html', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-json', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-prettier', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-python', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-tabnine', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-yaml', {'do': 'yarn install --frozen-lockfile'}

call plug#end()
