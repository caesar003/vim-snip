" Vim-snip
" 
function! s:InsertSnippet(type, name)
    let l:plugin_root = expand('<script>:p:h:h')  " Get plugin directory
    let l:snippet_file = l:plugin_root . '/plugin/templates/' . a:type . '/' . a:name . '.txt'
    
    echo "Checking: " . l:snippet_file 
    if filereadable(l:snippet_file)
        " return join(readfile(l:snippet_file), "\n")
        execute 'read ' .l:snippet_file
    else
        echohl WarningMsg | echo "Snippet not found: " . l:snippet_file | echohl None
        return ""
    endif
endfunction



command! -nargs=+ Snip call s:InsertSnippet(<f-args>)
