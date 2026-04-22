let mapleader = " "

set number relativenumber
set ignorecase smartcase incsearch hlsearch
set autoindent expandtab tabstop=4 shiftwidth=4 softtabstop=4
set scrolloff=8 wildmenu showcmd laststatus=2
set mouse=a
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
set signcolumn=yes

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

if has('termguicolors') && ($COLORTERM ==# 'truecolor' || $COLORTERM ==# '24bit')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    let &t_AU = "\<Esc>[58:2::%lu:%lu:%lum"
    let &t_Cs = "\<Esc>[4:3m"
    let &t_Ce = "\<Esc>[4:0m"
    set termguicolors
endif

highlight clear
if exists("syntax_on")
    syntax reset
endif
syntax enable

if $DOTS_THEME ==# 'light'
    set background=light

    highlight Normal guifg=#3C4A50 guibg=NONE
    highlight LineNr guifg=#A0A0A0 guibg=NONE
    highlight CursorLineNr guifg=#B46400 guibg=NONE gui=bold
    highlight StatusLine guifg=#E8E0CC guibg=#1A8A72 gui=bold
    highlight StatusLineNC guifg=#808080 guibg=#D0C8B0 gui=NONE
    highlight VertSplit guifg=#C0B898 guibg=NONE
    highlight ColorColumn guibg=#F0E8D0

    highlight Comment guifg=#A0A0A0 gui=italic
    highlight Constant guifg=#B46400
    highlight String guifg=#1A8A72
    highlight Number guifg=#B46400
    highlight Identifier guifg=NONE
    highlight Function guifg=#506888 gui=bold
    highlight Statement guifg=#3254A8
    highlight Keyword guifg=#3254A8
    highlight Type guifg=#1A8A72
    highlight Special guifg=#78348C
    highlight PreProc guifg=#B46400
    highlight Error guifg=#B46400 guibg=NONE gui=bold,underline
    highlight Todo guifg=#986800 guibg=NONE gui=bold

    highlight Search guifg=#E8E0CC guibg=#B46400
    highlight IncSearch guifg=#E8E0CC guibg=#1A8A72

    highlight DiffAdd guifg=#1A8A72 guibg=#D8F0E4 gui=NONE
    highlight DiffDelete guifg=#B46400 guibg=#F8E8D0 gui=NONE
    highlight DiffChange guifg=#3254A8 guibg=#D8E4F4 gui=NONE
    highlight DiffText guifg=#3C4A50 guibg=#C8D8F0 gui=bold

    highlight diffAdded guifg=#1A8A72 gui=bold
    highlight diffRemoved guifg=#B46400 gui=bold
    highlight diffFile guifg=#506888 gui=bold
    highlight diffIndexLine guifg=#78348C
    highlight diffLine guifg=#00A0B8
    highlight diffSubname guifg=#B46400

    highlight SpellBad guifg=NONE guibg=#F8E8D0 gui=NONE cterm=NONE ctermfg=NONE ctermbg=NONE
    highlight SpellCap guifg=NONE guibg=#F8E8D0 gui=NONE cterm=NONE ctermfg=NONE ctermbg=NONE
    highlight SpellRare guifg=NONE guibg=#F8E8D0 gui=NONE cterm=NONE ctermfg=NONE ctermbg=NONE

    highlight Visual guibg=#D0E0D8

    highlight Pmenu guifg=#3C4A50 guibg=#E0D8C0
    highlight PmenuSel guifg=#E8E0CC guibg=#1A8A72 gui=bold

    highlight Folded guifg=#808080 guibg=#F0E8D0 gui=NONE
    highlight FoldColumn guifg=#A0A0A0 guibg=NONE

    highlight QuickFixLine guibg=#D0E0D8 gui=bold

    " UI Groups
    highlight Title guifg=#00A0B8 gui=bold
    highlight Underlined guifg=#3C4A50 gui=underline
    highlight Directory guifg=#506888
    highlight MatchParen guifg=#E8E0CC guibg=#1A8A72
    highlight NonText guifg=#C0B898
    highlight SpecialKey guifg=#C0B898
    highlight EndOfBuffer guifg=#C0B898
    highlight Conceal guifg=#A0A0A0
    highlight CursorLine guibg=#F0E8D0 gui=NONE
    highlight CursorColumn guibg=#F0E8D0
    highlight SignColumn guifg=#A0A0A0 guibg=NONE
    highlight GitGutterAdd guifg=#1A8A72 guibg=NONE
    highlight GitGutterChange guifg=#3254A8 guibg=NONE
    highlight GitGutterDelete guifg=#B46400 guibg=NONE
    highlight WarningMsg guifg=#986800
    highlight ErrorMsg guifg=#B46400 gui=bold
    highlight ModeMsg guifg=#3C4A50 gui=bold
    highlight MoreMsg guifg=#1A8A72
    highlight Question guifg=#1A8A72
    highlight WildMenu guifg=#E8E0CC guibg=#B46400
    highlight TabLine guifg=#808080 guibg=#E0D8C0 gui=NONE
    highlight TabLineFill guibg=#E0D8C0
    highlight TabLineSel guifg=#3C4A50 guibg=#E0D8C0 gui=bold
    highlight SpellLocal guifg=#00A0B8 gui=undercurl guisp=#00A0B8

    " Syntax Groups
    highlight Boolean guifg=#B46400
    highlight Float guifg=#B46400
    highlight Character guifg=#1A8A72
    highlight Conditional guifg=#3254A8
    highlight Repeat guifg=#3254A8
    highlight Label guifg=#78348C
    highlight Operator guifg=#3C4A50
    highlight Exception guifg=#B46400
    highlight Include guifg=#B46400
    highlight Define guifg=#B46400
    highlight Macro guifg=#B46400
    highlight PreCondit guifg=#B46400
    highlight StorageClass guifg=#3254A8
    highlight Structure guifg=#3254A8
    highlight Typedef guifg=#3254A8
    highlight Delimiter guifg=#3C4A50
    highlight SpecialChar guifg=#78348C
    highlight SpecialComment guifg=#986800
    highlight Debug guifg=#D020C0
    highlight Tag guifg=#506888
    highlight Ignore guifg=#C0B898

    " HTML/Markdown Groups
    highlight htmlBold guifg=#3C4A50 gui=bold
    highlight htmlItalic guifg=#3C4A50 gui=italic
    highlight htmlTagName guifg=#3254A8
    highlight htmlLink guifg=#3C4A50 gui=underline
    highlight htmlTag guifg=#A0A0A0
    highlight htmlEndTag guifg=#A0A0A0
    highlight markdownH1 guifg=#506888 gui=bold
    highlight markdownH2 guifg=#506888 gui=bold
    highlight markdownH3 guifg=#506888 gui=bold
    highlight markdownH4 guifg=#506888 gui=bold
    highlight markdownH5 guifg=#506888 gui=bold
    highlight markdownH6 guifg=#506888 gui=bold
    highlight markdownH1Delimiter guifg=#A0A0A0
    highlight markdownH2Delimiter guifg=#A0A0A0
    highlight markdownH3Delimiter guifg=#A0A0A0
    highlight markdownH4Delimiter guifg=#A0A0A0
    highlight markdownH5Delimiter guifg=#A0A0A0
    highlight markdownH6Delimiter guifg=#A0A0A0
    highlight markdownCode guifg=#B46400
    highlight markdownCodeBlock guifg=#B46400
    highlight markdownCodeDelimiter guifg=#A0A0A0
    highlight markdownUrl guifg=#3254A8 gui=underline
    highlight markdownLinkText guifg=#1A8A72
    highlight markdownListMarker guifg=#B46400
    highlight markdownRule guifg=#C0B898
    highlight markdownBold guifg=#3C4A50 gui=bold
    highlight markdownItalic guifg=#3C4A50 gui=italic
    highlight markdownBoldItalic guifg=#3C4A50 gui=bold,italic

    " YAML Groups
    highlight yamlKey guifg=#506888
    highlight yamlBlockMappingKey guifg=#506888
    highlight yamlFlowMappingKey guifg=#506888
    highlight yamlKeyValueDelimiter guifg=#A0A0A0
    highlight yamlBlockCollectionItemStart guifg=#A0A0A0
    highlight yamlBool guifg=#B46400
    highlight yamlNull guifg=#B46400
    highlight yamlInteger guifg=#B46400
    highlight yamlFloat guifg=#B46400
    highlight yamlAnchor guifg=#78348C
    highlight yamlAlias guifg=#78348C

    " Dockerfile Groups
    highlight dockerfileKeyword guifg=#3254A8
    highlight dockerfileFrom guifg=#3254A8 gui=bold

    " Language-specific Groups
    highlight pythonBuiltinObj guifg=#B46400
    highlight pythonBuiltinFunc guifg=#506888 gui=bold
    highlight pythonBuiltinType guifg=#1A8A72
    highlight pythonDottedName guifg=#3C4A50
    highlight pythonDecorator guifg=#78348C
    highlight pythonDecoratorName guifg=#78348C

    highlight goBuiltins guifg=#506888 gui=bold
    highlight goFormatSpecifier guifg=#78348C

    highlight javaScriptFunction guifg=#3254A8
    highlight javaScriptMember guifg=#506888
    highlight typescriptBraces guifg=#3C4A50
    highlight typescriptParens guifg=#3C4A50

    highlight shVariable guifg=#3C4A50
    highlight shDerefSimple guifg=#3C4A50
    highlight shCommandSub guifg=#506888

    highlight rubyInterpolation guifg=#78348C
    highlight rubyInterpolationDelimiter guifg=#78348C
    highlight rubyBlockParameter guifg=#3C4A50
    highlight rubyBlockArgument guifg=#3C4A50
    highlight jsxCloseString guifg=#3254A8

else

    highlight Normal guifg=#CCE0D0 guibg=NONE
    highlight LineNr guifg=#808080 guibg=NONE
    highlight CursorLineNr guifg=#FCFC38 guibg=NONE gui=bold
    highlight StatusLine guifg=#CCE0D0 guibg=#000080 gui=bold
    highlight StatusLineNC guifg=#808080 guibg=#000080 gui=NONE
    highlight VertSplit guifg=#808080 guibg=NONE
    highlight ColorColumn guibg=#2A1A0A

    highlight Comment guifg=#808080 gui=italic
    highlight Constant guifg=#F88C14
    highlight String guifg=#2CB494
    highlight Number guifg=#F88C14
    highlight Identifier guifg=NONE
    highlight Function guifg=#7290B8 gui=bold
    highlight Statement guifg=#4068D4
    highlight Keyword guifg=#4068D4
    highlight Type guifg=#2CB494
    highlight Special guifg=#88409C
    highlight PreProc guifg=#F88C14
    highlight Error guifg=#F88C14 guibg=NONE gui=bold,underline
    highlight Todo guifg=#FCFC38 guibg=NONE gui=bold

    highlight Search guifg=#3C3C3C guibg=#FCFC38
    highlight IncSearch guifg=#3C3C3C guibg=#F88C14

    highlight DiffAdd guifg=#2CB494 guibg=#0A2A1A gui=NONE
    highlight DiffDelete guifg=#F88C14 guibg=#2A1A0A gui=NONE
    highlight DiffChange guifg=#4068D4 guibg=#0A1A2A gui=NONE
    highlight DiffText guifg=#CCE0D0 guibg=#1A2A3A gui=bold

    highlight diffAdded guifg=#2CB494 gui=bold
    highlight diffRemoved guifg=#F88C14 gui=bold
    highlight diffFile guifg=#7290B8 gui=bold
    highlight diffIndexLine guifg=#88409C
    highlight diffLine guifg=#00E4FC
    highlight diffSubname guifg=#F88C14

    highlight SpellBad guifg=NONE guibg=#2A1A0A gui=NONE cterm=NONE ctermfg=NONE ctermbg=NONE
    highlight SpellCap guifg=NONE guibg=#2A1A0A gui=NONE cterm=NONE ctermfg=NONE ctermbg=NONE
    highlight SpellRare guifg=NONE guibg=#2A1A0A gui=NONE cterm=NONE ctermfg=NONE ctermbg=NONE

    highlight Visual guibg=#1A3050

    highlight Pmenu guifg=#CCE0D0 guibg=#000080
    highlight PmenuSel guifg=#3C3C3C guibg=#2CB494 gui=bold

    highlight Folded guifg=#808080 guibg=#1A1A1A gui=NONE
    highlight FoldColumn guifg=#808080 guibg=NONE

    highlight QuickFixLine guibg=#1A3050 gui=bold

    " UI Groups
    highlight Title guifg=#00E4FC gui=bold
    highlight Underlined guifg=#CCE0D0 gui=underline
    highlight Directory guifg=#7290B8
    highlight MatchParen guifg=#3C3C3C guibg=#2CB494
    highlight NonText guifg=#808080
    highlight SpecialKey guifg=#808080
    highlight EndOfBuffer guifg=#808080
    highlight Conceal guifg=#808080
    highlight CursorLine guibg=#0A2A1A gui=NONE
    highlight CursorColumn guibg=#0A2A1A
    highlight SignColumn guifg=#808080 guibg=NONE
    highlight GitGutterAdd guifg=#2CB494 guibg=NONE
    highlight GitGutterChange guifg=#4068D4 guibg=NONE
    highlight GitGutterDelete guifg=#F88C14 guibg=NONE
    highlight WarningMsg guifg=#FCFC38
    highlight ErrorMsg guifg=#F88C14 gui=bold
    highlight ModeMsg guifg=#CCE0D0 gui=bold
    highlight MoreMsg guifg=#2CB494
    highlight Question guifg=#2CB494
    highlight WildMenu guifg=#3C3C3C guibg=#FCFC38
    highlight TabLine guifg=#808080 guibg=#000080 gui=NONE
    highlight TabLineFill guibg=#000080
    highlight TabLineSel guifg=#CCE0D0 guibg=#000080 gui=bold
    highlight SpellLocal guifg=#00E4FC gui=undercurl guisp=#00E4FC

    " Syntax Groups
    highlight Boolean guifg=#F88C14
    highlight Float guifg=#F88C14
    highlight Character guifg=#2CB494
    highlight Conditional guifg=#4068D4
    highlight Repeat guifg=#4068D4
    highlight Label guifg=#88409C
    highlight Operator guifg=#CCE0D0
    highlight Exception guifg=#F88C14
    highlight Include guifg=#F88C14
    highlight Define guifg=#F88C14
    highlight Macro guifg=#F88C14
    highlight PreCondit guifg=#F88C14
    highlight StorageClass guifg=#4068D4
    highlight Structure guifg=#4068D4
    highlight Typedef guifg=#4068D4
    highlight Delimiter guifg=#CCE0D0
    highlight SpecialChar guifg=#88409C
    highlight SpecialComment guifg=#FCFC38
    highlight Debug guifg=#F032E6
    highlight Tag guifg=#7290B8
    highlight Ignore guifg=#808080

    " HTML/Markdown Groups
    highlight htmlBold guifg=#CCE0D0 gui=bold
    highlight htmlItalic guifg=#CCE0D0 gui=italic
    highlight htmlTagName guifg=#4068D4
    highlight htmlLink guifg=#CCE0D0 gui=underline
    highlight htmlTag guifg=#808080
    highlight htmlEndTag guifg=#808080
    highlight markdownH1 guifg=#7290B8 gui=bold
    highlight markdownH2 guifg=#7290B8 gui=bold
    highlight markdownH3 guifg=#7290B8 gui=bold
    highlight markdownH4 guifg=#7290B8 gui=bold
    highlight markdownH5 guifg=#7290B8 gui=bold
    highlight markdownH6 guifg=#7290B8 gui=bold
    highlight markdownH1Delimiter guifg=#808080
    highlight markdownH2Delimiter guifg=#808080
    highlight markdownH3Delimiter guifg=#808080
    highlight markdownH4Delimiter guifg=#808080
    highlight markdownH5Delimiter guifg=#808080
    highlight markdownH6Delimiter guifg=#808080
    highlight markdownCode guifg=#F88C14
    highlight markdownCodeBlock guifg=#F88C14
    highlight markdownCodeDelimiter guifg=#808080
    highlight markdownUrl guifg=#4068D4 gui=underline
    highlight markdownLinkText guifg=#2CB494
    highlight markdownListMarker guifg=#F88C14
    highlight markdownRule guifg=#808080
    highlight markdownBold guifg=#CCE0D0 gui=bold
    highlight markdownItalic guifg=#CCE0D0 gui=italic
    highlight markdownBoldItalic guifg=#CCE0D0 gui=bold,italic

    " YAML Groups
    highlight yamlKey guifg=#7290B8
    highlight yamlBlockMappingKey guifg=#7290B8
    highlight yamlFlowMappingKey guifg=#7290B8
    highlight yamlKeyValueDelimiter guifg=#808080
    highlight yamlBlockCollectionItemStart guifg=#808080
    highlight yamlBool guifg=#F88C14
    highlight yamlNull guifg=#F88C14
    highlight yamlInteger guifg=#F88C14
    highlight yamlFloat guifg=#F88C14
    highlight yamlAnchor guifg=#88409C
    highlight yamlAlias guifg=#88409C

    " Dockerfile Groups
    highlight dockerfileKeyword guifg=#4068D4
    highlight dockerfileFrom guifg=#4068D4 gui=bold

    " Language-specific Groups
    highlight pythonBuiltinObj guifg=#F88C14
    highlight pythonBuiltinFunc guifg=#7290B8 gui=bold
    highlight pythonBuiltinType guifg=#2CB494
    highlight pythonDottedName guifg=#CCE0D0
    highlight pythonDecorator guifg=#88409C
    highlight pythonDecoratorName guifg=#88409C

    highlight goBuiltins guifg=#7290B8 gui=bold
    highlight goFormatSpecifier guifg=#88409C

    highlight javaScriptFunction guifg=#4068D4
    highlight javaScriptMember guifg=#7290B8
    highlight typescriptBraces guifg=#CCE0D0
    highlight typescriptParens guifg=#CCE0D0

    highlight shVariable guifg=#CCE0D0
    highlight shDerefSimple guifg=#CCE0D0
    highlight shCommandSub guifg=#7290B8

    highlight rubyInterpolation guifg=#88409C
    highlight rubyInterpolationDelimiter guifg=#88409C
    highlight rubyBlockParameter guifg=#CCE0D0
    highlight rubyBlockArgument guifg=#CCE0D0
    highlight jsxCloseString guifg=#4068D4

endif

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

