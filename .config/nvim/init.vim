" Vim-plug {{{
" ========

" auto-install
" ------------
if has('win32')
  if !filereadable(expand('~/AppData/Local/nvim/autoload/plug.vim'))
    silent call mkdir(expand('~/AppData/Local/nvim/autoload', 1), 'p')
    execute '!curl -fLo '.expand('~/AppData/Local/nvim/autoload/plug.vim', 1).' https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  endif
else
  if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
    silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  endif
endif

call plug#begin()

" Colors & Syntax
" ---------------
Plug 'PProvost/vim-ps1'
Plug 'lifepillar/vim-solarized8'
Plug 'junegunn/seoul256.vim'
Plug 'junegunn/rainbow_parentheses.vim'                             " :RainbowParentheses!!

" Completion
" ----------
Plug 'ervandew/supertab'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/neco-syntax'                                           " default languages syntax
Plug 'Shougo/neco-vim'                                              " vimL syntax
Plug 'fszymanski/deoplete-emoji'                                    " :smiley_face:
Plug 'wellle/tmux-complete.vim'                                     " cross panes word
Plug 'SirVer/ultisnips'                                             " <leader>s :UltiSnipsEdit
"Plug 'autozimu/LanguageClient-neovim', {
"    \ 'branch': 'next',
"    \ 'do': 'bash install.sh',
"    \ }

" FuzzyFinder
" -----------
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'                                             " <leader>cdnhb :Files :RgFZF

" Linter
" ------
Plug 'w0rp/ale'                                                     " :ALEInfo :ALEToggle :lopen :lnext

" Statusbar
" ---------
Plug 'itchyny/lightline.vim'

" Git
" ---
Plug 'airblade/vim-gitgutter'                                       " :GitGutterToggle :GitGutterPreviewHunk :GitGutter
Plug 'tpope/vim-fugitive'                                           " :Gedit :Gvsplit :Gdiff :Gstatus :Gcommit :Gblame :Gmove :Gdelete :Ggrep :Glog :Gread
Plug 'junegunn/gv.vim'                                              " :GV :GV! :GV?

" Editing
" -------
Plug 'junegunn/goyo.vim'                                            " :Goyo :Goyo!
Plug 'junegunn/limelight.vim'                                       " :Limelight
Plug 'godlygeek/tabular'                                            " :Tab /=
Plug 'jkramer/vim-checkbox'                                         " <leader>tt

" Misc
" ----
Plug 'sjl/gundo.vim'                                                " :GundoToggle
Plug 'christoomey/vim-tmux-navigator'                               " <ctrl>hjkl
Plug 'justinmk/vim-gtfo'                                            " gof got
Plug 'mhinz/vim-sayonara', { 'on': 'Sayonara' }                     " :Sayonara
Plug 'junegunn/vim-emoji'                                           " :Emojify
Plug 'jremmen/vim-ripgrep'                                          " :Rg :RgRoot

call plug#end()
" }}}
" General: colors {{{
" ===============

" settings
" --------
syntax on
filetype plugin indent on
set termguicolors
set background=dark

" nvim-qt
" -------
if has('win32')
  let g:seoul256_srgb              = 1            " for non iterm2 terminals when using seoul256
  let g:solarized_term_italics     = 1            " 1 to enable italics (0 default)
  let g:solarized_extra_hi_groups  = 1            " can break some stuff (0 default)
  colorscheme solarized8_flat
  highlight Normal  gui=NONE guibg=#00171d
  highlight NonTest gui=NONE guibg=#00171d
endif

" iTerm2 & WSL
" ------------
if has('mac') || isdirectory('/mnt/c/Windows')
  let g:solarized_term_italics     = 1            " 1 to enable italics (0 default)
  let g:solarized_extra_hi_groups  = 1            " can break some stuff (0 default)
  let g:solarized_termtrans        = 1            " because we use terminal background
  colorscheme solarized8_flat                     " solarized8(_low, _high, _flat) / seoul256(-light)
endif

" }}}
" General: statusline {{{
" ===================

"" Plugin free statusline
"" ----------------------
"function! s:statusline_expr()
"  let mod  = "%{&modified ? '💋 ' : !&modifiable ? '[x] ' : ''}"
"  let ro   = "%{&readonly ? '🔒 ' : ''}"
"  let alew = " %{ALEWarnings()}"
"  let alee = " %{ALEErrors()}"
"  let fug  = "%{exists('g:loaded_fugitive') ? fugitive#head() : ''}"
"  let ggt  = " %{GitGutterStatus()}"
"  let sep  = '%= '
"  let ft   = "%{len(&filetype) ? ''.&filetype.' |' : ''} %{''.(&fenc!=''?&fenc:&enc).''} | %<%-10{&ff}"
"  let pos  = '%-12(%l : %c%V%)'
"  let pct  = '%P'
"  return '%F %<'.mod.ro.fug.ggt.alew.alee.sep.ft.pos.'%*'.pct
"endfunction
"
"" ALE integration
"" ---------------
"function! ALEWarnings() abort
"  let l:counts = ale#statusline#Count(bufnr(''))
"  let l:all_errors = l:counts.error + l:counts.style_error
"  let l:all_non_errors = l:counts.total - l:all_errors
"  return l:all_non_errors == 0 ? '' : printf('⚠ %d', all_non_errors)
"endfunction
"function! ALEErrors() abort
"  let l:counts = ale#statusline#Count(bufnr(''))
"  let l:all_errors = l:counts.error + l:counts.style_error
"  return l:all_errors == 0 ? '' : printf('✖ %d', all_errors)
"endfunction
"
"" gitgutter integration
"" ---------------------
"function! GitGutterStatus() abort
"  if ! exists('*GitGutterGetHunkSummary')
"        \ || ! get(g:, 'gitgutter_enabled', 0)
"        \ || winwidth('.') <= 90
"    return ''
"  endif
"  let g:gitgutter_sign_removed = '-'
"  let symbols = [
"        \ g:gitgutter_sign_added . '',
"        \ g:gitgutter_sign_modified . '',
"        \ g:gitgutter_sign_removed . ''
"        \ ]
"  let hunks = GitGutterGetHunkSummary()
"  let ret = []
"  for i in [0, 1, 2]
"    if hunks[i] > 0
"      call add(ret, symbols[i] . hunks[i])
"    endif
"  endfor
"  return join(ret, ' ')
"endfunction
"
"let &statusline = s:statusline_expr()

" }}}
" General: settings {{{
" =================

" Misc
" ----
set hidden                                " so I can switch between buffers even if I didn't save the file
set title                                 " titre fenêtre dans un terminal
set number                                " left rule
set splitright                            " split new window on the right
set showmatch                             " highlight matching [{()}]
set lazyredraw                            " screen in not redrawn everytime
set nolist
set foldmethod=marker
set noerrorbells visualbell t_vb=

" Mouse
" -----
set mouse=a
set mousemodel=popup

" Encodings
" ---------
set fileformat=unix
set fileformats=unix,mac,dos
scriptencoding utf-8
set fileencoding=utf-8
set fileencodings=utf-8

" Tabs & Spaces
" -------------
set tabstop=2                             " number of visual spaces per TAB
set softtabstop=2                         " number of spaces in tab when editing
set shiftwidth=2                          " indentation are 2 spaces
set expandtab                             " tabs are spaces

" Search
" ------
set ignorecase                            " no case sensitive
set smartcase                             " case-sensitive only if using a capital letter

" Completion
" ----------
"set omnifunc=syntaxcomplete#Complete
set completeopt=menuone,preview
set completeopt+=noinsert
set completeopt+=noselect
set wildmode=full                         " shows all the options

" Timeout
" -------
set notimeout
set ttimeout
set ttimeoutlen=100

" :h in vertical split 
cabbrev h vert h

" }}}
" General: bindings {{{
" =================

let g:mapleader = ','

" use <space> to fold/unfold
nnoremap <space> za

" Copy/Paste
" ----------
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>p "+p
vnoremap <leader>p "+p

" Buffer rotate
" -------------
noremap <S-h> :bprevious<CR>
noremap <S-l> :bnext<CR>

" }}}
" General: autocommands {{{
" =====================

augroup path
  autocmd!
  autocmd BufEnter * silent! lcd %:p:h                                           " current dir. same as the current file
augroup END

augroup filetype_help
  autocmd!
  autocmd FileType help wincmd L                                                 " help on the vertical right
  autocmd FileType help set nolist
augroup END

augroup filename_TODO
  autocmd!
  autocmd BufRead TODO.md :let markdown_folding=1
augroup END

augroup filetype_python
  autocmd!
  autocmd BufNewFile,BufRead *.py setlocal tabstop=4 softtabstop=4 shiftwidth=4
augroup END

augroup bell
  autocmd!
  autocmd GUIEnter * set visualbell t_vb=
augroup END

" }}}
" General: Python Support {{{
" =======================

" nvim-qt
if has('win64')
  let g:python_host_prog = 'C:\Python27\python.exe'
  let g:python3_host_prog = 'C:\Users\Max\AppData\Local\Programs\Python\Python36-32\python.exe'
endif

" macOS
if has('unix') && has('mac')
  "let g:python_host_prog = '/usr/bin/python'
  let g:python_host_prog = '/usr/local/opt/python@2/bin/python2'
  let g:python3_host_prog = '/usr/local/bin/python3'
" WSL
elseif has('unix')
  let g:python_host_prog = '/usr/bin/python'
  let g:python3_host_prog = '/usr/bin/python3'
endif

" }}}
" General: Netrw {{{
" ==============

map <C-t> :Lexplore<CR>

let g:netrw_browse_split = 4    " open in previous window
let g:netrw_banner       = 0    " pas de panneau en haut
let g:netrw_liststyle    = 3    " tree view
let g:netrw_winsize      = -28  " max width

" }}}
" Personal: Notes {{{
" ===============

" italic & bold style
"set conceallevel=2

" spell checking
command Spellcheck :setlocal spell spelllang=fr_fr<CR>

" create a note file with :NewNote <name>
command -nargs=1 NewNote :exec "e! " . fnameescape(expand("$NOTES_DIR/<args>.md"))

" converti les noms d'emoji en véritables emojis
silent! if emoji#available()
  command Emojify %s/:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/g
endif

augroup filetype_markdown
  autocmd!
  autocmd BufNewFile,BufRead,BufWrite *.txt,*.md,*.mkd,*.markdown,*.mdwn setlocal filetype=markdown
"  autocmd BufRead,BufWrite,InsertChange *.txt,*.md,*.mkd,*.markdown,*.mdwn syntax match ErrorMsg '\%>79v.\+'
  autocmd BufNewFile,BufReadPost *.txt,*.md,*.mkd,*.markdown,*.mdwn setlocal tabstop=3 shiftwidth=3 softtabstop=3
  autocmd BufNewFile,BufReadPost *.txt,*.md,*.mkd,*.markdown,*.mdwn setlocal list
"  autocmd BufNewFile,BufReadPost *.txt,*.md,*.mkd,*.markdown,*.mdwn setlocal listchars=tab:»\ ,nbsp:·,trail:·,eol:¬
augroup END

" }}}
" Plugin: goyo & limelight {{{
" ========================

let g:limelight_default_coefficient = 0.7                                 " default 0.5
let g:limelight_priority            = -1                                  " using -1 so it doesnt hide highlights

function! s:goyo_enter()
  colorscheme seoul256-light
  set conceallevel=2
  syntax off | syntax on                                                  " necessary to keep bold and italics
  if exists('$TMUX')
    silent !tmux set status off
    silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  endif
  Limelight
endfunction

function! s:goyo_leave()
  Limelight!
  set background=dark
  colorscheme solarized8_flat
  set conceallevel=0
  syntax off | syntax on
  if exists('$TMUX')
    silent !tmux set status on
    silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  endif
endfunction

augroup plugin_goyo
  autocmd!
  autocmd User GoyoEnter nested call <SID>goyo_enter()
  autocmd User GoyoLeave nested call <SID>goyo_leave()
augroup END

" }}}
" Plugin: fzf {{{
" ===========

" Using ripgrep for fzf
let $FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob ""'

" mappings
" --------
noremap <leader>b :Buffers<CR>
noremap <leader>c :Files $PROJECTS_DIR<CR>
noremap <leader>d :Files $DOTFILES_DIR<CR>
noremap <leader>n :Files $NOTES_DIR<CR>
noremap <leader>h :History<CR>
noremap <leader>s :Snippets<CR>

" rg+fzf word search
" ------------------
command -bang -nargs=* Rgfzf
  \ call fzf#vim#grep(
  \   'rg --no-heading --column --line-number --hidden --follow --ignore-case --no-ignore --color=always --glob "!.git" --glob "!Library" '.shellescape(<q-args>), 1, <bang>0)

" }}}
" Plugin: vim-ripgrep {{{
" ===================

" If not using this plugin, we can use this:
" Grepprg
" -------
" set grepprg=rg\ --vimgrep\ --hidden\ --follow\ --ignore-case\ --no-ignore\
" command -bar -nargs=1 Search silent grep <q-args> | redraw! | cwindow

" settings
" --------
let g:rg_binary      = 'rg'
let g:rg_command     = g:rg_binary . ' --vimgrep --hidden --follow --ignore-case --no-ignore --glob "!.git" --glob "!Library"'
let g:rg_highlight   = 1

" mappings
" --------
nnoremap <C-n> :cnext<cr>z.
nnoremap <C-p> :cprevious<cr>z.

" }}}
" Plugin: ale {{{
" ===========

" settings
" --------
"let g:ale_set_loclist          = 0                           " using quickfix instead location list
"let g:ale_set_quickfix         = 1
let g:ale_open_list            = 0                           " dont automatically open error lists
let g:ale_sign_column_always   = 1                           " always display sign column
let g:ale_completion_enabled   = 1
let g:ale_echo_msg_format      = '%severity% [%linter%] %s'  " :open format
let g:ale_sign_error           = '✖'
let g:ale_sign_warning         = '⚠'
let g:ale_echo_msg_error_str   = '✖'
let g:ale_echo_msg_warning_str = '⚠'
highlight ALEWarningSign guifg=#ffd005

" linters (all linters are activated by default)
" ----------------------------------------------
let g:ale_linters = {
\   'sh': ['shellcheck'],
\}

" }}}
" Plugin: deoplete {{{
" ================

" settings
" --------
let g:deoplete#enable_at_startup    = 1
let g:tmuxcomplete#trigger          = ''  " tmux-complete
let g:necosyntax#min_keyword_length = 2   " neco-syntax

" }}}
" Plugin: ultisnips {{{
" =================

" settings
" --------
let g:UltiSnipsSnippetDirectories  = [$DOTFILES_DIR.'/.config/nvim/ultisnippets']
let g:UltiSnipsSnippetsDir         = $DOTFILES_DIR.'/.config/nvim/ultisnippets'
let g:UltiSnipsJumpForwardTrigger  = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
"let g:UltiSnipsListSnippets        = '<leader>s'                                  " only works in insert mode (commented out because we're using fzf mapping instead)
let g:UltiSnipsEditSplit           = 'vertical'

" type Enter to activate snippet in the completion list
" -----------------------------------------------------
let g:UltiSnipsExpandTrigger='<NUL>'
function! <SID>ExpandSnippetOrReturn()
  let l:snippet = UltiSnips#ExpandSnippetOrJump()
  if g:ulti_expand_or_jump_res > 0
    return l:snippet
  else
    return "\<CR>"
  endif
endfunction

inoremap <expr> <CR> pumvisible() ? "<C-R>=<SID>ExpandSnippetOrReturn()<CR>" : "\<CR>"

" }}}
" Plugin: gtfo {{{
" ============

" settings
" --------
let g:gtfo#terminals = { 'mac' : 'iterm' }
let g:gtfo#terminals = { 'win' : 'powershell -NoLogo -NoExit -Command' }

" }}}
" Plugin: gitgutter {{{
" =================

" settings
" --------
set updatetime=100
let g:gitgutter_map_keys = 0

if exists('&signcolumn')                  " Vim 7.4.2201
  set signcolumn=yes
else
  let g:gitgutter_sign_column_always = 1
endif

" }}}
" Plugin: rainbow parentheses {{{
" ===========================

" settings
" --------
let g:rainbow#pairs     = [['(', ')'], ['[', ']'], ['{', '}']]
let g:rainbow#blacklist = [2, 246]

augroup rainbow_parentheses
  autocmd!
  autocmd VimEnter * RainbowParentheses
augroup END

" }}}
" Plugin: LSP {{{
" ===========

"let g:LanguageClient_serverCommands = {
"  \ 'sh': ['bash-language-server', 'start'],
"  \ }
"
"set formatexpr=LanguageClient_textDocument_rangeFormatting()

"nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
"nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
"nnoremap <silent> <F3> :call LanguageClient#testDocument_rename()<CR>

" }}}
" Plugin: supertab {{{
" ================

let g:SuperTabLongestEnhanced  = 1
let g:SuperTabLongestHighlight = 1

" }}}
" Plugin: vim-checkbox {{{
" ===================

let g:checkbox_states = [' ', 'x', 'v', 'i', '?', '!']

" }}}
" Plugin: lightline {{{
" =================

" vim built-in options
" --------------------
function! MyAttributes() abort
  let l:filename = expand('%:p') !=# '' ? expand('%:p') : 'No Name'
  let l:readonly = &readonly ? ' 🔒' : ''
  let l:modified = &modified ? ' 💋' : ''
  return l:filename . l:readonly . l:modified
endfunction

" gitgutter
" ---------
function! MyGitGutter() abort
  if ! exists('*GitGutterGetHunkSummary')
        \ || ! get(g:, 'gitgutter_enabled', 0)
        \ || winwidth('.') <= 90
    return ''
  endif
  let g:gitgutter_sign_removed = '-'
  let l:symbols = [
        \ g:gitgutter_sign_added . '',
        \ g:gitgutter_sign_modified . '',
        \ g:gitgutter_sign_removed . ''
        \ ]
  let l:hunks = GitGutterGetHunkSummary()
  let l:ret = []
  for l:i in [0, 1, 2]
    if l:hunks[l:i] > 0
      call add(l:ret, l:symbols[l:i] . l:hunks[l:i])
    endif
  endfor
  return join(l:ret, ' ')
endfunction

" ALE
" ---
function! MyALEWarnings() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors
  return l:all_non_errors == 0 ? '' : printf('⚠ %d', l:all_non_errors)
endfunction
function! MyALEErrors() abort
  let l:counts = ale#statusline#Count(bufnr(''))
  let l:all_errors = l:counts.error + l:counts.style_error
  return l:all_errors == 0 ? '' : printf('✖ %d', l:all_errors)
endfunction

" main lightline settings
" -----------------------
let g:lightline = {}
let g:lightline.component_function = {
  \  'fileattributes'  : 'MyAttributes',
  \  'fugitive'        : 'MyFugitive',
  \  'gitgutter'       : 'MyGitGutter',
  \  'ale_warnings'    : 'MyALEWarnings',
  \  'ale_errors'      : 'MyALEErrors',
  \ }
let g:lightline.component_expand = {
  \  'fugitive'        : 'fugitive#head',
  \ }
let g:lightline.active = { 'left': [ [ 'mode', 'paste' ], [ 'fileattributes' ], [ 'fugitive', 'gitgutter', 'ale_errors', 'ale_warnings' ] ] }
let g:lightline.colorscheme = 'solarized'

" }}}
" Plugin: Gundo {{{
" =============

let g:gundo_width = 60
let g:gundo_preview_height = 25
let g:gundo_preview_bottom = 1

" }}}
