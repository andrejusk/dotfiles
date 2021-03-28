" Disable arrow keys
noremap  <Up>    <NOP>
noremap  <Down>  <NOP>
noremap  <Left>  <NOP>
noremap  <Right> <NOP>
inoremap <Up>    <NOP>
inoremap <Down>  <NOP>
inoremap <Left>  <NOP>
inoremap <Right> <NOP>


" Disable manual and ex mode
nnoremap <F1> <nop>
nnoremap Q <nop>


" Quick escape
inoremap jk <Esc>
inoremap kj <Esc>


" Quick save
nnoremap <C-s> :w<CR>


" Better tabbing
"   When indenting, reselect previous selection
"   if in visual mode
vnoremap < <gv
vnoremap > >gv


" Quick window switching
"   Ctrl-[hjkl]
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-j> <C-w>j
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-l> <C-w>l


" Quick window resizing
"   Alt-[hjkl]
nnoremap <silent> <M-j> :resize -2<CR>
nnoremap <silent> <M-k> :resize +2<CR>
nnoremap <silent> <M-h> :vertical resize -2<CR>
nnoremap <silent> <M-l> :vertical resize +2<CR>


" Quicker omni complete nav
"   Ctrl-[jk]
inoremap <expr> <c-j> ("\<C-n>")
inoremap <expr> <c-k> ("\<C-p>")


" Distraction free typing
"   <l>l - Toggle Goyo and Limelight
nnoremap <silent> <leader>l :Goyo<cr>
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!


" Strip whitespace
"   <l>y - Remove all trailing whitespace
nnoremap <silent> <leader>y :StripWhitespace<cr>


" fzf
"   <l>p - Search files in current workdir
"   <l>P - Search files in $HOME
"   <l>g - Search commits for current buffer
"   <l>G - Search commits in current workdir
"   <l>f - Search source in current workdir
"   <l>; - Search buffers
nnoremap <silent> <leader>p :Files<cr>
nnoremap <silent> <leader>P :Files ~<cr>
nnoremap <silent> <leader>g :BCommits<cr>
nnoremap <silent> <leader>G :Commits<cr>
nnoremap <silent> <leader>f :Rg<cr>
nnoremap <silent> <leader>; :Buffers<cr>


" coc.nvim explorer
"   <l>e - Toggle explorer on/off
"   <l>E - Open current file location
nmap <silent> <leader>e :CocCommand explorer<cr>
nmap <silent> <leader>E :CocCommand explorer --reveal expand('<sfile>')<cr>


" coc.nvim
"   Ctrl-n - Go to next diagnostic
"   Ctrl-p - Go to previous diagnostic
"   <l>a - Open action list
"   <l>c - Open command list
"   <l>d - Jump to definition of current symbol
"   <l>r - Jump to references of current symbol
"   <l>j - Jump to implementation of current symbol
"   <l>s - Fuzzy search current project symbols
"   <l>n - Symbol renaming
"   <l>k - Symbol renaming
nmap <silent> <C-n> <Plug>(coc-diagnostic-next)
nmap <silent> <C-p> <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>a <Plug>(coc-codeaction-line)
nmap <silent> <leader>d <Plug>(coc-definition)
nmap <silent> <leader>r <Plug>(coc-references)
nmap <silent> <leader>j <Plug>(coc-implementation)
nmap <silent> <leader>s :<C-u>CocList -I -N --top symbols<cr>
nmap <silent> <leader>n <Plug>(coc-rename)
nmap <silent> <leader>c :CocCommand<cr>

" Search shorcuts
"   <l>h - Find and replace
"   <l>/ - Clear highlighted search terms while preserving history
nnoremap <leader>h :%s///<left><left>
nnoremap <silent> <leader>/ :nohlsearch<cr>


"   <c-@> - trigger completion
"   <tab> - trigger completion and navigate to next complete item
inoremap <silent><expr> <c-@> coc#refresh()
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"



function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

"   K - show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<cr>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
