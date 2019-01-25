" Name: Vim Configuration
" Author: Nicholas Truong
"===============================================================================

"===============================================================================
""" BASIC OPTION SETTING:
set encoding=utf-8          " Use UTF-8
set previewheight=20        " Preview window height
set textwidth=80            " Keep columns legible
set scrolloff=3             " Keep 3 lines above and below cursor
set wrap                    " Word wrap
set inccommand=nosplit      " Incremental commands
set expandtab               " Insert tabs as spaces
set tabstop=2               " Number of spaces a tab counts for
set shiftwidth=2            " Number of spaces a tab counts for
set nojoinspaces            " No double space when joining lines
set noswapfile              " No swapfile
"===============================================================================

"===============================================================================
""" KEYMAPS:
" Leader
let mapleader = "\<Space>"

" Escape
inoremap jk <Esc>

" Clear highlighting.
nnoremap <silent> <Esc> :nohlsearch<CR>:call clearmatches()<CR>

" Localize directory
nnoremap <silent> <Leader>cd :lcd %:p:h<CR>:echo "Localized directory."<CR>

" File opening: [open in window], [save], [exit], [close previews]
nnoremap <Leader>o :edit<Space>
nnoremap <Leader>s :write<CR>
nnoremap <Leader>q :quit!<CR>
nnoremap <Leader>z <C-w>z

" Tabbing
nnoremap <Leader>t :tabedit<CR>:edit<Space>

" Split window navigation: [left] [down] [up] [right]
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-j> <C-w>j
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-l> <C-w>l

" Make arrows resize splits
nnoremap <Left>  <C-w><
nnoremap <Down>  <C-w>-
nnoremap <Up>    <C-w>+
nnoremap <Right> <C-w>>

" Search and replace
nnoremap <Leader>r :%s//g<Left><Left>
vnoremap <Leader>r :s//g<Left><Left>

" Make.
nnoremap <silent> <Leader>mk :make!<CR>
"===============================================================================

"===============================================================================
""" TEXT FUNCTIONS:
" Autocomplete
function! TabToAutocomplete() abort
  if col(".") > 1 && strpart(getline("."), col(".") - 2, 3) =~ '^\w'
    return "\<C-n>"
    " return "\<C-x>\<C-o>"
  else
    return "\<Tab>"
  endif
endfunction
inoremap <expr> <Tab> TabToAutocomplete()

" Autoclose braces
function! Match_Close(open, close) abort
  let l:str = getline(".")
  let l:value = a:close
  if strpart(l:str, col(".") - 1, 1) == a:close
    let i = 0
    let len = strlen(str)
    let matches = 0
    while i < len
      let c = strpart(str, i, 1)
      if c == a:open
        let matches += 1
      elseif c == a:close
        let matches -= 1
      endif
      let i += 1
    endwhile
    if matches == 0
      let value = "\<Right>"
    endif
  endif
  return value
endfunction
inoremap { {}<Left>
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap <expr> } Match_Close("{", "}")
inoremap <expr> ) Match_Close("(", ")")
inoremap <expr> ] Match_Close("[", "]")

" Autoclose quotes
function! Match_Quote(ch) abort
  let line = getline(".")
  let value = ""
  let i = 0
  let len = strlen(line)
  let chcount = 0
  while i < len
    let c = strpart(line, i, 1)
    if c == a:ch
      let chcount += 1
    endif
    let i += 1
  endwhile
  if (chcount % 2 == 0)
    if strpart(line, col(".") - 1, 1) == a:ch
      let value = "\<Right>"
    else
      let value = a:ch.a:ch."\<Left>"
    endif
  else
    let value = a:ch
  endif
  return value
endfunction
inoremap <expr> " Match_Quote("\"")
inoremap <expr> ' Match_Quote("\'")

" Autoremove paired braces and quotes
function! Match_Remove() abort
  let pair_dict = {"{": "}", "(": ")", "[": "]", "\"": "\"", "\'": "\'"}
  let fst = strpart(getline("."), col(".") - 2, 1)
  let snd = strpart(getline("."), col(".") - 1, 1)
  if has_key(pair_dict, fst) && (pair_dict[fst] == strpart(getline("."), col(".") - 1, 1))
    return "\<Right>\<BS>\<BS>"
  endif
  return "\<BS>"
endfunction
inoremap <expr> <BS> Match_Remove()

" Autoindent and open braces
function! Brace_Opener() abort
  let fst = strpart(getline("."), col(".") - 2, 1)
  if (strpart(getline("."), col(".") - 2, 1) == "{") && (strpart(getline("."), col(".") - 1, 1) == "}")
    return "\<CR>\<CR>\<Up>\<Tab>"
  endif
  return "\<CR>"
endfunction
inoremap <expr> <CR> Brace_Opener()

" Autocommenting
function! Autocomment() abort
  if !exists("b:comment")
    return
  endif
  let l:line  = getline(".")
  let l:begin = strpart(l:line, match(l:line, '\S'), strlen(b:comment))
  let l:c     = col(".")
  let l:cmd   = ""
  if l:begin == b:comment
    let l:c -= strlen(b:comment) + 1
    let l:c = (l:c > 0) ? l:c : 0
    execute "normal! _dW"
  else
    let l:c += strlen(b:comment) + 1
    execute "normal! I" . b:comment . " "
  endif
  call cursor(".", l:c)
endfunction
nnoremap <silent> <C-_> :call Autocomment()<CR>

" Strip trailing whitespace
function! StripTrail() abort
  let search=@/
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  let @/=search
  call cursor(l, c)
endfunction
nnoremap <silent> <Leader><BS> :call StripTrail()<CR>

" Primitive surrounding capability
function! Surround()
  " Listen for updates to the command line.
  augroup Cmdline
    autocmd!
    autocmd CmdlineChanged * call s:SurroundPrompt(getcmdline())
  augroup END
  " Mark the current location.
  execute 'normal! m`'
  " Get the selected object and surround character(s).
  let l:cmd = input('surround ↯ ')[2:]
  " Clear the autogroup.
  augroup Cmdline
    autocmd!
  augroup END
  " Only continue if we are in visual mode.
  if mode() != 'v'
    return
  endif
  " Pairs to surround text with.
  let l:pairs = {
  \ '(' : '()',
  \ '[' : '[]',
  \ '{' : '{}',
  \ '<' : '<>'
  \ }
  " Surround the text.
  let l:txt = has_key(l:pairs, l:cmd) ? l:pairs[l:cmd] : l:cmd . l:cmd
  execute 'normal! c' . l:txt . "\<Esc>P``"
endfunction
function! s:SurroundPrompt(cmd)
  " If we are currently in visual mode, toggle visual mode again to prepare to
  " select more text.
  if mode() == 'v'
    execute 'normal! v'
  endif
  " Only select text if we have an appropriate query string.
  if a:cmd =~ '[ia].*'
    execute 'normal! v' . a:cmd[0:1] . 'o'
  endif
  " Update for changes.
  redraw
endfunction
nnoremap <silent> gs :call Surround()<CR>

" Highlight the current match when searching with n/N.
function! CurrentSearch(ch)
  call clearmatches()
  call matchadd("IncSearch", '\%#' . @/)
  return a:ch
endfunction
nnoremap <expr> <silent> n CurrentSearch("n")
nnoremap <expr> <silent> N CurrentSearch("N")
"===============================================================================

"===============================================================================
""" AESTHETICS:
" Colorscheme
set termguicolors
colorscheme transcendence
augroup au_display
  autocmd!
  " Trailing whitespace
  autocmd InsertEnter * setlocal nolist
  autocmd InsertLeave * setlocal list
augroup END

" Buffer flags
function! Modifiers() abort
  let l:flags = ""
  let l:flags .= (&modified ? " [+] " : "")  " Modified flag
  let l:flags .= (&readonly ? " [-] " : "")  " Readonly flag
  let l:flags .= (&pvw ? " [preview] " : "") " Preview flag
  return l:flags
endfunction

" Statusline
set statusline=
set statusline+=\ %y\                    " File type
set statusline+=\ %.40f\                 " File path
set statusline+=%{Modifiers()}           " Flags
set statusline+=%=                       " Right side
set statusline+=\ [%3l                   " Current line
set statusline+=/%-3L]:                  " Total lines
set statusline+=[%2v]\                   " Virtual column number
set statusline+=\ %{&fileformat}         " File format
set statusline+=/%{&fileencoding?&fileencoding:&encoding}\  " File encoding

" Tabline
function! Tabline() abort
  let tl = ""
  for i in range(tabpagenr("$"))
    let tabnr   = i + 1
    let winnr   = tabpagewinnr(tabnr)
    let buflist = tabpagebuflist(tabnr)
    let bufnr   = buflist[winnr - 1]
    let file    = fnamemodify(bufname(bufnr), ":t")
    let tl .= " "
    let tl .= (tabnr == tabpagenr()) ? "%#TabLineSel#" : "%#TabLine#"
    let tl .= empty(file) ? "scratch" : file
    let tl .= "%* "
  endfor
  let tl .= "%#TabLineFill#"
  return tl
endfunction
set showtabline=2
if exists("+showtabline")
  set tabline=%!Tabline()
endif
"===============================================================================

"===============================================================================
""" TAGGING:
set tags=./tags;,tags;./.tags;,.tags;
command! MakeTags !ctags -Rf .tags *
nnoremap <silent> <Leader>[] :MakeTags<CR><CR>:echo "Made tags."<CR>
"===============================================================================

"===============================================================================
""" FILETYPE SPECIFIC:
augroup Commenting
  autocmd!
  autocmd filetype c,cpp   let b:comment = "//"
  autocmd filetype haskell let b:comment = "--"
  autocmd filetype java    let b:comment = "//"
  autocmd filetype tex     let b:comment = "%"
  autocmd filetype python  let b:comment = "#"
  autocmd filetype r       let b:comment = "#"
  autocmd filetype scala   let b:comment = "//"
  autocmd filetype vim     let b:comment = "\""
  let g:tex_flavor = "latex"
augroup END
"===============================================================================
