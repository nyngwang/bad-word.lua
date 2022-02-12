if exists('g:loaded_bad_word') | finish | endif

let g:loaded_bad_word = 1

augroup BadWord
  autocmd!
  autocmd VimEnter,ColorScheme * lua require'bad-word'.highlight()
  autocmd CursorMoved,CursorMovedI * lua require'bad-word'.matchadd()
  autocmd WinLeave * lua require'bad-word'.matchdelete()
augroup END
