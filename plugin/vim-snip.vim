" Vim-Snip Plugin
" Author: Caesar003
" Email: caesarmuksid@gmail.com
" Repo: https://github.com/caesar003/vim-snip
" Last Modified: Sat Mar 01 2025, 09:30
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
"   :Snip <language> <snippet-name>
"   Example: :Snip html boilerplate
"
" - Define key mappings for quick usage in insert mode:
"   Example: inoremap !<Tab> :Snip html boilerplate<CR>
"
" - Snippet files should be stored in:
"   <plugin-root>/templates/<language>/<snippet>.txt
"   Feel free to add your own!
"
" - Special markers in snippets:
"   {cursor} - Where the cursor will be positioned after insertion
"   {placeholder:default} - Tab-navigable placeholders with optional default values
"
" ----------------------------------------------------------------------------

function! s:InsertSnippet(type, name)
    " Determine the plugin's root directory dynamically
    let l:plugin_root = expand('<script>:p:h:h') 
    let l:snippet_file = l:plugin_root . '/templates/' . a:type . '/' . a:name . '.txt'
    
    " Check if the snippet file exists and read its contents
    if filereadable(l:snippet_file)
        " Read the snippet content
        let l:content = readfile(l:snippet_file)
        let l:snippet = join(l:content, "\n")
        
        " Process placeholders and prepare for replacement
        let l:placeholders = []
        let l:pattern = '{placeholder:\([^}]*\)}'
        let l:index = 1
        
        " Find all placeholders in the snippet
        let l:placeholder_found = match(l:snippet, l:pattern)
        while l:placeholder_found != -1
            let l:match = matchstr(l:snippet, l:pattern, l:placeholder_found)
            let l:default = matchlist(l:match, l:pattern)[1]
            
            " Add placeholder to the list
            call add(l:placeholders, {'marker': l:match, 'default': l:default, 'index': l:index})
            
            " Replace in the snippet with a unique marker
            let l:snippet = substitute(l:snippet, l:match, '{ph'.l:index.'}', '')
            
            " Find next placeholder
            let l:index += 1
            let l:placeholder_found = match(l:snippet, l:pattern)
        endwhile
        
        " Check for cursor position
        let l:has_cursor = stridx(l:snippet, '{cursor}') != -1
        
        " Insert the snippet (temporarily replace {ph#} with actual defaults)
        for l:ph in l:placeholders
            let l:snippet = substitute(l:snippet, '{ph'.l:ph.index.'}', l:ph.default, 'g')
        endfor
        
        " Remove the current line if it's empty
        if getline('.') =~ '^\s*$'
            normal! dd
        endif
        
        " Insert the snippet
        let l:lines = split(l:snippet, "\n", 1)
        call append(line('.') - 1, l:lines)
        
        " Position the cursor if {cursor} is present, otherwise at the end of snippet
        if l:has_cursor
            " Find line with cursor marker
            let l:curr_line = line('.')
            for l:i in range(len(l:lines))
                let l:cursor_pos = stridx(l:lines[l:i], '{cursor}')
                if l:cursor_pos != -1
                    " Move to the line and column position
                    call cursor(l:curr_line + l:i, l:cursor_pos + 1)
                    " Remove the cursor marker
                    let l:line = getline('.')
                    call setline('.', substitute(l:line, '{cursor}', '', 'g'))
                    break
                endif
            endfor
        else
            " Move to end of snippet
            call cursor(line('.') + len(l:lines) - 1, 1)
        endif
        
        " Setup placeholders for navigation if there are any
        if len(l:placeholders) > 0
            " Create maps for navigating through placeholders
            let b:vim_snip_placeholders = l:placeholders
            let b:vim_snip_current_ph = 1
            let b:vim_snip_line_offset = line('.') - len(l:lines) + 1
            
            " Mark for clean-up when leaving the buffer
            augroup vim_snip_placeholder_cleanup
                autocmd!
                autocmd BufLeave <buffer> call s:CleanupPlaceholders()
            augroup END
            
            " Highlight the first placeholder
            call s:HighlightCurrentPlaceholder()
            
            " Enable tab navigation
            inoremap <buffer> <expr> <Tab> <SID>HandleTab()
            inoremap <buffer> <expr> <S-Tab> <SID>HandleShiftTab()
            
            " Enter normal mode to ensure we're ready for editing
            stopinsert
            echo "Use Tab/Shift-Tab to navigate placeholders"
        endif
        
    else
        echohl WarningMsg | echo "Snippet not found: " . l:snippet_file | echohl None
    endif
endfunction

function! s:HandleTab()
    " Go to next placeholder
    if exists('b:vim_snip_placeholders') && exists('b:vim_snip_current_ph')
        call s:ClearCurrentPlaceholder()
        let b:vim_snip_current_ph += 1
        if b:vim_snip_current_ph > len(b:vim_snip_placeholders)
            let b:vim_snip_current_ph = 1
        endif
        call s:HighlightCurrentPlaceholder()
        return "\<Esc>"
    endif
    return "\<Tab>"
endfunction

function! s:HandleShiftTab()
    " Go to previous placeholder
    if exists('b:vim_snip_placeholders') && exists('b:vim_snip_current_ph')
        call s:ClearCurrentPlaceholder()
        let b:vim_snip_current_ph -= 1
        if b:vim_snip_current_ph < 1
            let b:vim_snip_current_ph = len(b:vim_snip_placeholders)
        endif
        call s:HighlightCurrentPlaceholder()
        return "\<Esc>"
    endif
    return "\<S-Tab>"
endfunction

function! s:HighlightCurrentPlaceholder()
    " Highlight the current placeholder
    if exists('b:vim_snip_placeholders') && exists('b:vim_snip_current_ph')
        let l:ph = b:vim_snip_placeholders[b:vim_snip_current_ph - 1]
        
        " Find the placeholder in the buffer
        let l:pattern = l:ph.default
        let l:found = 0
        
        " Start searching from the beginning of the snippet
        let l:start_line = b:vim_snip_line_offset
        let l:end_line = line('$')
        
        for l:lnum in range(l:start_line, l:end_line)
            let l:line = getline(l:lnum)
            let l:col = stridx(l:line, l:pattern)
            if l:col != -1
                " Found the placeholder, move cursor and select it
                call cursor(l:lnum, l:col + 1)
                execute "normal! v" . (strlen(l:pattern) - 1) . "l"
                normal! o
                let l:found = 1
                break
            endif
        endfor
        
        if l:found
            " Start insert mode at the beginning of the placeholder
            startinsert
        else
            echo "Placeholder not found"
        endif
    endif
endfunction

function! s:ClearCurrentPlaceholder()
    " Clear the current visual selection if any
    if mode() =~# "[vV\<C-v>]"
        normal! u
    endif
endfunction

function! s:CleanupPlaceholders()
    " Clean up buffer variables and mappings when leaving the buffer
    if exists('b:vim_snip_placeholders')
        unlet b:vim_snip_placeholders
        unlet b:vim_snip_current_ph
        unlet b:vim_snip_line_offset
        
        silent! iunmap <buffer> <Tab>
        silent! iunmap <buffer> <S-Tab>
        
        autocmd! vim_snip_placeholder_cleanup
    endif
endfunction

" Define a command to insert snippets
command! -nargs=+ Snip call s:InsertSnippet(<f-args>)
