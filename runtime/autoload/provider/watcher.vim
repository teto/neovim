" TODO convert it to lua
if exists('g:loaded_watcher_provider')
  finish
endif

let g:loaded_watcher_provider = 1

function! s:watcher.start(filename) abort
endfunction

function! provider#watcher#Executable() abort
  if exists('g:watcher')
    if type({}) isnot# type(g:watcher)
          \ || type({}) isnot# type(get(g:watcher, 'watch', v:null))
          \ || type({}) isnot# type(get(g:watcher, 'stop', v:null))
      let s:err = 'watcher: invalid g:watcher'
      return ''
    endif
    let s:copy = get(g:watcher, 'watch', { '+': v:null, '*': v:null })
    let s:paste = get(g:watcher, 'paste', { '+': v:null, '*': v:null })
    return get(g:watcher, 'name', 'g:watcher')

endfunction

function! provider#watcher#Call(method, args) abort
  if get(s:, 'here', v:false)  " Clipboard provider must not recurse. #7184
    return 0
  endif
  let s:here = v:true
  try
    return call(s:clipboard[a:method],a:args,s:clipboard)
  finally
    let s:here = v:false
  endtry
endfunction

" eval_has_provider() decides based on this variable.
let g:loaded_clipboard_provider = empty(provider#clipboard#Executable()) ? 1 : 2

