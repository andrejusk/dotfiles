call plug#begin('~/.config/nvim/plugged')

" sensible defaults
Plug 'tpope/vim-sensible'

" colorscheme
Plug 'chriskempson/base16-vim'

" dev icons
Plug 'ryanoasis/vim-devicons'
Plug 'kyazdani42/nvim-web-devicons'
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

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'glepnir/lspsaga.nvim'
Plug 'hrsh7th/nvim-compe'
" {{{
    set completeopt=menuone,noselect

    let g:compe = {}
    let g:compe.enabled = v:true
    let g:compe.autocomplete = v:true
    let g:compe.debug = v:false
    let g:compe.min_length = 1
    let g:compe.preselect = 'enable'
    let g:compe.throttle_time = 80
    let g:compe.source_timeout = 200
    let g:compe.resolve_timeout = 800
    let g:compe.incomplete_delay = 400
    let g:compe.max_abbr_width = 100
    let g:compe.max_kind_width = 100
    let g:compe.max_menu_width = 100
    let g:compe.documentation = v:true

    let g:compe.source = {}
    let g:compe.source.path = v:true
    let g:compe.source.buffer = v:true
    let g:compe.source.calc = v:true
    let g:compe.source.nvim_lsp = v:true
    let g:compe.source.nvim_lua = v:true
    let g:compe.source.vsnip = v:true
    let g:compe.source.ultisnips = v:true
    let g:compe.source.luasnip = v:true
    let g:compe.source.emoji = v:true
    let g:compe.source.spell = v:true
    let g:compe.source.tags = v:true
    let g:compe.source.snippets_nvim = v:true
    let g:compe.source.treesitter = v:true

    highlight link CompeDocumentation NormalFloat
" }}}

" ts
Plug 'HerringtonDarkholme/yats.vim'
Plug 'maxmellon/vim-jsx-pretty'

" elm
Plug 'andys8/vim-elm-syntax'

" rust
Plug 'simrat39/rust-tools.nvim'


" debugger
Plug 'puremourning/vimspector'
" {{{
    let g:vimspector_enable_mappings = 'HUMAN'
" }}}

" Terminal
Plug 'kassio/neoterm'

call plug#end()
