call plug#begin('~/.config/nvim/plugged')

" sensible defaults
Plug 'tpope/vim-sensible'

" colorscheme
Plug 'chriskempson/base16-vim'

" dev icons
Plug 'ryanoasis/vim-devicons'
" {{{
    let g:webdevicons_enable_airline_tabline = 1
    let g:webdevicons_enable_airline_statusline = 1

    let g:webdevicons_enable_startify = 1
" }}}

" status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" {{{
    " Theme
    let g:airline_theme = 'base16_seti'

    " Enable extensions
    let g:airline_extensions = ['branch', 'coc', 'hunks', 'tabline', 'whitespace', 'fzf']

    " Do not draw separators for empty sections (only for the active window) >
    let g:airline_skip_empty_sections = 0

    " Custom setup that removes filetype/whitespace from default vim airline bar
    let g:airline#extensions#default#layout = [['a', 'b', 'c'], ['x', 'z', 'warning', 'error']]

    " Customize vim airline per filetype
    " 'list'      - Only show file type plus current line number out of total
    let g:airline_filetype_overrides = {
      \ 'coc-explorer':  [ '  Explore', '' ],
      \ 'fugitive': ['fugitive', '%{airline#util#wrap(airline#extensions#branch#get_head(),80)}'],
      \ 'help':  [ 'Help', '%f' ],
      \ 'startify': [ 'startify', '' ],
      \ 'vim-plug': [ 'Plugins', '' ],
      \ 'list': [ '%y', '%l/%L'],
      \ }

    " Enable powerline fonts
    let g:airline_powerline_fonts = 1
    let g:airline_left_sep = ''
    let g:airline_right_sep = ''
    let g:airline_right_alt_sep = ''

    " Enable caching of syntax highlighting groups
    let g:airline_highlighting_cache = 1

    " Enable tabline
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#left_sep = ' '
    let g:airline#extensions#tabline#left_alt_sep = '|'
    let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
" }}}

" start screen
Plug 'mhinz/vim-startify'

" distraction-free typing
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

" DOcumentation GEneraton
Plug 'kkoomen/vim-doge', { 'do': { -> doge#install({ 'headless': 1 }) } }

" auto-close plugins
Plug 'tpope/vim-endwise'

" easier commentary
Plug 'tpope/vim-commentary'

" easier alignment
Plug 'godlygeek/tabular'

" extra visual feedback
Plug 'junegunn/rainbow_parentheses.vim'
" {{{
    let g:rainbow_active = 1
    let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]
    let g:rainbow_conf = {'guis': ['bold']}
" }}}
Plug 'unblevable/quick-scope'
Plug 'ntpeters/vim-better-whitespace'

" heuristic whitepsace
Plug 'tpope/vim-sleuth'

" better motion
Plug 'tpope/vim-surround'
Plug 'justinmk/vim-sneak'
" {{{
    let g:sneak#label = 1
    let g:sneak#prompt = ' '

    " case insensitive
    let g:sneak#use_ic_scs = 1

    " move to next search if cursor hasn't moved
    let g:sneak#s_next = 1
" }}}

" git tools
Plug 'mhinz/vim-signify'
" {{{
    let g:signify_sign_add = '+'
    let g:signify_sign_delete = '-'
    let g:signify_sign_change = '~'

    let g:signify_sign_show_count = 0
    let g:signify_sign_show_text = 1
" }}}
Plug 'tpope/vim-fugitive'

" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" {{{
    let g:fzf_layout = { 'down': '~40%' }
    let g:fzf_preview_window = ['right:50%', 'ctrl-/']
    let g:fzf_buffers_jump = 1
" }}}
Plug 'antoinemadec/coc-fzf'
Plug 'airblade/vim-rooter'

" coc
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
" {{{
    let g:coc_global_extensions = [
        \ 'coc-actions',
        \ 'coc-clangd',
        \ 'coc-css',
        \ 'coc-docker',
        \ 'coc-emmet',
        \ 'coc-emoji',
        \ 'coc-eslint',
        \ 'coc-explorer',
        \ 'coc-fish',
        \ 'coc-fzf-preview',
        \ 'coc-git',
        \ 'coc-go',
        \ 'coc-groovy',
        \ 'coc-highlight',
        \ 'coc-html',
        \ 'coc-json',
        \ 'coc-lists',
        \ 'coc-marketplace',
        \ 'coc-perl',
        \ 'coc-prettier',
        \ 'coc-python',
        \ 'coc-react-refactor',
        \ 'coc-rust-analyzer',
        \ 'coc-sh',
        \ 'coc-snippets',
        \ 'coc-styled-components',
        \ 'coc-svg',
        \ 'coc-swagger',
        \ 'coc-tabnine',
        \ 'coc-toml',
        \ 'coc-tslint',
        \ 'coc-tslint-plugin',
        \ 'coc-tsserver',
        \ 'coc-vimlsp',
        \ 'coc-xml',
        \ 'coc-yaml',
        \ ]
" }}}

" ts
Plug 'HerringtonDarkholme/yats.vim'
Plug 'maxmellon/vim-jsx-pretty'

" elm
Plug 'andys8/vim-elm-syntax'


" debugger
Plug 'puremourning/vimspector'
" {{{
    let g:vimspector_enable_mappings = 'HUMAN'
" }}}

" Terminal
Plug 'kassio/neoterm'

call plug#end()
