" ============================================================================ "
" ===                           EDITING OPTIONS                            === "
" ============================================================================ "
"
" Leader key <SPACE>
let g:mapleader=' '

" Use posix-compliant shell
set shell=sh

" Enable syntax highlighting
syntax enable
filetype on
filetype plugin on

" do not wrap long lines by default
set nowrap

" default encoding
set encoding=utf-8
set fileencoding=utf-8
set fileformat=unix

" Yank and paste with the system clipboard
set clipboard=unnamedplus

"   et  = expandtab (spaces instead of tabs)
"   ts  = tabstop (the number of spaces that a tab equates to)
"   sw  = shiftwidth (the number of spaces to use when indenting
"         -- or de-indenting -- a line)
"   sts = softtabstop (the number of spaces to use when expanding tabs)
set et sts=4 sw=4 ts=4
set showtabline=4

set foldenable
set foldmethod=indent
set foldlevel=99

set conceallevel=0

set scrolloff=10

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=100
set timeoutlen=300

" Don't pass messages to |ins-completion-menu|.
set shortmess=atT

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" coc.nvim recommendations
set nobackup
set nowritebackup

" ============================================================================ "
" ===                                UI                                    === "
" ============================================================================ "

" Cursor/scroll support in normal/visual modes
set mouse=nv

" Support italics
hi Comment cterm=italic

" Enable true color support
if (has("termguicolors"))
    set termguicolors
    hi LineNr ctermbg=NONE guibg=NONE
endif

" Set preview window to appear at bottom and right
set splitbelow
set splitright

" Don't dispay mode in command line (airline already shows it)
set noshowmode

" Set floating window to be slightly transparent
set winbl=10

" Enable ruler
set ruler
set number
set relativenumber

" Pop-up menu
set pumheight=10

" two lines for command line
set cmdheight=2

" no visual bell
set visualbell t_vb=

" if the search string has an upper case letter in it, the search will be case sensitive
set smartcase

" Redraw on resize
autocmd VimResized * redraw!

" Redraw on writing buffer
autocmd BufWritePost * redraw!
