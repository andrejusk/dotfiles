" No arrow keys
noremap  <Up>    <NOP>
noremap  <Down>  <NOP>
noremap  <Left>  <NOP>
noremap  <Right> <NOP>
inoremap <Up>    <NOP>
inoremap <Down>  <NOP>
inoremap <Left>  <NOP>
inoremap <Right> <NOP>


" Quick window switching
"   Ctrl-[hjkl]
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-j> <C-w>j
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-l> <C-w>l


" Distraction free typing
"   <l>l - Toggle Goyo and Limelight
nnoremap <silent> <leader>l :Goyo<cr>
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!


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


" NERDTree
"   <l>e - Toggle NERDTree on/off
"   <l>E - Open current file location in NERDTree
nnoremap <silent> <leader>e :NERDTreeToggle<cr>
nnoremap <silent> <leader>E :NERDTreeFind<cr>


" coc.nvim
"   Ctrl-n - Go to previous diagnostic
"   Ctrl-p - Go to next diagnostic
"   <l>d - Jump to definition of current symbol
"   <l>r - Jump to references of current symbol
"   <l>j - Jump to implementation of current symbol
"   <l>s - Fuzzy search current project symbols
"   <l>n - Symbol renaming
"   <l>y - Format selected code
nnoremap <silent> <C-n> <Plug>(coc-diagnostic-prev)
nnoremap <silent> <C-p> <Plug>(coc-diagnostic-next)
nnoremap <silent> <leader>d <Plug>(coc-definition)
nnoremap <silent> <leader>r <Plug>(coc-references)
nnoremap <silent> <leader>j <Plug>(coc-implementation)
nnoremap <silent> <leader>s :<C-u>CocList -I -N --top symbols<cr>
nnoremap <silent> <leader>n <Plug>(coc-rename)
nnoremap <silent> <leader>y <Plug>(coc-format-selected)


" Search shorcuts
"   <l>h - Find and replace
"   <l>/ - Clear highlighted search terms while preserving history
nnoremap <leader>h :%s///<left><left>
nnoremap <silent> <leader>/ :nohlsearch<cr>


" Easy-motion shortcut
"   <l>w       - move to word bi-directionally
"   <l>W{char} - move to {char}
nnoremap <silent> <leader>w <Plug>(easymotion-bd-w)
nnoremap <silent> <leader>W <Plug>(easymotion-bd-f)



" use <tab> for trigger completion and navigate to next complete item
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use K to show documentation in preview window.
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


