" Colourscheme
set background=dark
colorscheme base16-seti

" Close preview window when completion is done.
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" Disable deprecated python2 provider
let g:loaded_python_provider = 0
set pyxversion=3

" Override start cowsay
let g:startify_custom_header =
        \ startify#pad(split(system('fortune | cowsay -f dragon-and-cow'), '\n'))

" LSP config
lua << EOF
local ok, _ = pcall(require, 'lspconfig')
if not ok then
  print('skipping lspconfig load')
else
  local lspconfig = require("lspconfig")
  lspconfig.bashls.setup{}
  lspconfig.dockerls.setup{}
  lspconfig.efm.setup{}
  lspconfig.elmls.setup{}
  lspconfig.gopls.setup{}
  lspconfig.graphql.setup{}
  lspconfig.html.setup{}
  lspconfig.jsonls.setup{}
  lspconfig.perlls.setup{}
  lspconfig.pyright.setup{
    settings = {
      python = {
        typeCheckingMode = "strict"
      }
    }
  }
  lspconfig.rust_analyzer.setup{}
  lspconfig.terraformls.setup{}
  lspconfig.tsserver.setup{}
  lspconfig.vimls.setup{}
end

EOF

