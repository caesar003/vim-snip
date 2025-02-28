" Vim-Snip Plugin
" Author: Caesar003
" Email: caesarmuksid@gmail.com
" Repo: https://github.com/caesar003/vim-snip
" Last Modified: Fri Feb 28 2025, 21:45
"
" Description:
" Vim-Snip is a lightweight, minimal snippet manager for Vim/Neovim. 
" Instead of relying on heavy snippet engines, it allows users to 
" quickly insert predefined templates stored as text files.
"
" Why use Vim-Snip?
" - Lightweight: No dependencies, just plain Vim script.
" - Simple and Transparent: Users can create and modify their own snippets easily.
" - Fully Customizable: Supports key mappings for fast snippet insertion.
"
" Usage:
" - Insert a snippet using:
"   `:Snip <language> <snippet-name>`
"   Example: `:Snip html boilerplate`
"
" - Define key mappings for quick usage in insert mode:
"   Example: `inoremap !<Tab> :Snip html boilerplate<CR>`
"
" - Snippet files should be stored in:
"   `<plugin-root>/templates/<language>/<snippet>.txt`
"   Feel free to add your own!
"
" ----------------------------------------------------------------------------

function! s:InsertSnippet(type, name)
    " Determine the plugin's root directory dynamically
    let l:plugin_root = expand('<script>:p:h:h') 
    let l:snippet_file = l:plugin_root . '/templates/' . a:type . '/' . a:name . '.txt'

    " Debugging output (optional)
    echo "Checking: " . l:snippet_file 

    " Check if the snippet file exists and insert its contents
    if filereadable(l:snippet_file)
        execute 'read ' . l:snippet_file
    else
        echohl WarningMsg | echo "Snippet not found: " . l:snippet_file | echohl None
    endif
endfunction

" Define a command to insert snippets
command! -nargs=+ Snip call s:InsertSnippet(<f-args>)
