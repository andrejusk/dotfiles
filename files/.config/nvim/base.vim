set fileencoding=utf-8

set fileformat=unix
filetype on
filetype plugin on
syntax on


" ============================================================================ "
" ===                           EDITING OPTIONS                            === "
" ============================================================================ "

" Remap leader key to <SPACE>
let g:mapleader=' '

" Yank and paste with the system clipboard
set clipboard=

" Hides buffers instead of closing them
set hidden

set smartindent

set expandtab
set tabstop=4
set shiftwidth=4

set foldenable
set foldmethod=indent
set foldlevel=99

set cursorline
set cursorcolumn

set nonumber
set relativenumber

" do not wrap long lines by default
set nowrap

" two lines for command line
set cmdheight=2

" ============================================================================ "
" ===                                UI                                    === "
" ============================================================================ "

" Enable true color support
set termguicolors

" Change vertical split character to be a space (essentially hide it)
set fillchars+=vert:.

" Set preview window to appear at bottom
set splitbelow

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

" Automatically re-read file if a change was detected outside of vim
set autoread

" Enable line numbers
set number

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
