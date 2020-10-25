" ============================================================================ "
" ===                           EDITING OPTIONS                            === "
" ============================================================================ "

" default encoding
set encoding=utf-8
set fileencoding=utf-8
set fileformat=unix
filetype on
filetype plugin on
syntax on

" Leader key <SPACE>
let g:mapleader=' '

" Yank and paste with the system clipboard
set clipboard=

" Hides buffers instead of closing them
set hidden

"   et  = expandtab (spaces instead of tabs)
"   ts  = tabstop (the number of spaces that a tab equates to)
"   sw  = shiftwidth (the number of spaces to use when indenting
"         -- or de-indenting -- a line)
"   sts = softtabstop (the number of spaces to use when expanding tabs)
set et sts=4 sw=4 ts=4

set foldenable
set foldmethod=indent
set foldlevel=99

set conceallevel=1

set number
set relativenumber

" do not wrap long lines by default
set nowrap

" two lines for command line
set cmdheight=2

set updatetime=300

" ============================================================================ "
" ===                                UI                                    === "
" ============================================================================ "

" Enable true color support
set termguicolors

" Set preview window to appear at bottom and right
set splitbelow
set splitright

" Don't dispay mode in command line (airilne already shows it)
set noshowmode

" Set floating window to be slightly transparent
set winbl=10

" ============================================================================ "
" ===                                 MISC.                                === "
" ============================================================================ "

" Automaticaly close nvim if NERDTree is only thing left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" === Search === "
" ignore case when searching
set ignorecase

" if the search string has an upper case letter in it, the search will be case sensitive
set smartcase

" Enable spellcheck for markdown files
autocmd BufRead,BufNewFile *.md setlocal spell

" Set backups
if has('persistent_undo')
  set undofile
  set undolevels=3000
  set undoreload=10000
endif
set backupdir=$XDG_DATA_HOME/nvim/backup " Don't put backups in current dir
set backup
set noswapfile

" Some servers have issues with backup files, see #649.
" set nobackup
" set nowritebackup
