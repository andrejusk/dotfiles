"  Colourscheme
set background=dark
colorscheme base16-seti

" Coc.nvim

" Close preview window when completion is done.
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" Disable deprecated python2 provider
let g:loaded_python_provider = 0

" Call method on window enter
augroup WindowManagement
  autocmd!
  autocmd WinEnter * call Handle_Win_Enter()
augroup END

" Change highlight group of preview window when open
function! Handle_Win_Enter()
  if &previewwindow
    setlocal winhighlight=Normal:MarkdownError
  endif
endfunction

" Reload icons after init source
if exists('g:loaded_webdevicons')
  call webdevicons#refresh()
endif
