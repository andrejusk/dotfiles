let mapleader = " "

set number relativenumber
set ignorecase smartcase incsearch hlsearch
set autoindent expandtab tabstop=4 shiftwidth=4 softtabstop=4
set scrolloff=8 wildmenu showcmd laststatus=2
set hidden
set noswapfile nobackup undofile
let s:undo_dir = expand('~/.vim/undodir')
if !isdirectory(s:undo_dir)
    call mkdir(s:undo_dir, 'p')
endif
set undodir=~/.vim/undodir
set undolevels=1000
set undoreload=10000
set belloff=all
set noerrorbells

set lazyredraw
set synmaxcol=500
set redrawtime=500
set maxmempattern=5000
set nomodeline
set noshowmatch
silent! set diffopt+=vertical,algorithm:histogram,indent-heuristic,iwhite,foldcolumn:0

if executable('rg')
    set grepprg=rg\ --vimgrep\ --smart-case\ --hidden\ -g\ '!.git'
    set grepformat=%f:%l:%c:%m
endif
set path+=**
set wildignore+=**/node_modules/**,**/.git/**,**/vendor/**
set wildignore+=**/tmp/**,**/dist/**,**/build/**,**/__pycache__/**,**/*.pyc

augroup filetypes
    autocmd!
    autocmd FileType gitcommit setlocal spell spelllang=en_gb textwidth=72 colorcolumn=50,72
    autocmd FileType go setlocal noexpandtab softtabstop=0
    autocmd FileType markdown,text setlocal spell spelllang=en_gb wrap
    autocmd FileType python setlocal textwidth=88 colorcolumn=88
    autocmd FileType typescript,typescriptreact setlocal syntax=javascript
    autocmd FileType qf nnoremap <buffer> q :cclose<CR>
augroup END

augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow
augroup END

let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4

set background=dark

if $COLORTERM ==# 'truecolor' || $COLORTERM ==# '24bit'
    set termguicolors
endif

highlight clear
if exists("syntax_on")
    syntax reset
endif

highlight Normal guifg=#CCE0D0 guibg=NONE
highlight LineNr guifg=#808080 guibg=NONE
highlight CursorLineNr guifg=#FCFC38 guibg=NONE gui=bold
highlight StatusLine guifg=#CCE0D0 guibg=#000080 gui=bold
highlight StatusLineNC guifg=#808080 guibg=#000080 gui=NONE
highlight VertSplit guifg=#808080 guibg=NONE
highlight ColorColumn guibg=#703014

highlight Comment guifg=#808080 gui=italic
highlight Constant guifg=#F88C14
highlight String guifg=#2CB494
highlight Number guifg=#F88C14
highlight Identifier guifg=NONE
highlight Function guifg=#0C48CC gui=bold
highlight Statement guifg=#4068D4
highlight Keyword guifg=#4068D4
highlight Type guifg=#2CB494
highlight Special guifg=#88409C
highlight PreProc guifg=#F88C14
highlight Error guifg=#F40404 guibg=NONE gui=bold,underline
highlight Todo guifg=#FCFC38 guibg=NONE gui=bold

highlight Search guifg=#3C3C3C guibg=#FCFC38
highlight IncSearch guifg=#3C3C3C guibg=#F88C14

highlight DiffAdd guifg=NONE guibg=#2CB494
highlight DiffDelete guifg=NONE guibg=#F40404
highlight DiffChange guifg=NONE guibg=#0C48CC
highlight DiffText guifg=NONE guibg=#88409C gui=bold

highlight diffAdded guifg=#2CB494 gui=bold
highlight diffRemoved guifg=#F40404 gui=bold
highlight diffFile guifg=#0C48CC gui=bold
highlight diffIndexLine guifg=#88409C
highlight diffLine guifg=#00E4FC
highlight diffSubname guifg=#F88C14

highlight SpellBad guifg=#F40404 gui=undercurl guisp=#F40404
highlight SpellCap guifg=#FCFC38 gui=undercurl guisp=#FCFC38
highlight SpellRare guifg=#88409C gui=undercurl guisp=#88409C

highlight Visual guibg=#4068D4

highlight Pmenu guifg=#CCE0D0 guibg=#000080
highlight PmenuSel guifg=#3C3C3C guibg=#2CB494 gui=bold

highlight QuickFixLine guibg=#4068D4 gui=bold

function! GitRoot()
  let l:root = systemlist('git rev-parse --show-toplevel')[0]
  if v:shell_error == 0 && isdirectory(l:root)
    execute 'silent cd' fnameescape(l:root)
    echo 'Project Root: ' . l:root
  else
    echo 'Not in a git repository'
  endif
endfunction

function! OpenScratch()
    split | noswapfile hide enew
    setlocal buftype=nofile bufhidden=hide localindentkeys=
    nnoremap <buffer> q :q<CR>
endfunction

nnoremap <leader>gr :call GitRoot()<CR>
nnoremap <leader>s :call OpenScratch()<CR>
nnoremap <leader>t :!ctags -R .<CR>
nnoremap <Esc><Esc> :nohlsearch<CR>
nnoremap <leader>dw :set diffopt+=iwhite<CR>
nnoremap <leader>dW :set diffopt-=iwhite<CR>

nnoremap ]c ]czz
nnoremap [c [czz
nnoremap ]q :cnext<CR>zz
nnoremap [q :cprev<CR>zz
nnoremap <C-j> :cnext<CR>
nnoremap <C-k> :cprev<CR>

nnoremap <leader>g :silent grep! <cword><CR>
vnoremap <leader>g "zy:silent grep! "<C-R>z""<CR>
nnoremap <leader>/ :grep<Space>

