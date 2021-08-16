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


" Search shorcuts
"   <l>h - Find and replace
"   <l>/ - Clear highlighted search terms while preserving history
nnoremap <leader>h :%s///<left><left>
nnoremap <silent> <leader>/ :nohlsearch<cr>


" LSP config
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> <C-n> <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> <C-p> <cmd>lua vim.lsp.diagnostic.goto_next()<CR>

