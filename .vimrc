" colors {{{
syntax on
filetype plugin indent on
colorscheme elflord
highlight Comment cterm=italic
" }}}
" statusbar {{{
set statusline=
set statusline+=\ %<[%n]\                                    " buffer number
set statusline+=%F\                                          " full path
set statusline+=%y\                                          " file type
set statusline+=%m\                                          " modified flag
set statusline+=%r\                                          " read only flag
set statusline+=%=                                           " separation point left and right
set statusline+=%-14.(%l,%c%V\ %P%)                          " line, column, virtual column numbers
set statusline+=%{''.(&fenc!=''?&fenc:&enc).''}%<[%{&ff}]\   " file format & encoding

set laststatus=2  " always visible
" }}}
" settings {{{
set hidden                     " so I can switch between buffers even if I didn't save the file
set title                      " titre fenêtre dans un terminal
set number                     " left rule
set showcmd                    " show command in bottom bar
set splitright                 " split new window on the right
set showmatch                  " highlight matching [{()}]
set lazyredraw                 " screen in not redrawn everytime
set ttyfast                    " fast terminal connection with tmux
set sessionoptions-=options
set display+=lastline          " no @ on multiline that you can't see
set nolist

" Encodings
set fileformat=unix
set encoding=utf-8
scriptencoding utf-8
set fileencoding=utf-8
set fileencodings=utf-8

" Tabs & Spaces
" -------------
set backspace=indent,eol,start " normal backspacing
set tabstop=2                  " number of visual spaces per TAB
set softtabstop=2              " number of spaces in tab when editing
set shiftwidth=2               " indentation are 4 spaces
set expandtab                  " tabs are spaces
set autoindent                 " automatic indentation

" Search
" ------
set ignorecase " no case sensitive
set smartcase  " case-sensitive only if using a capital letter
set incsearch  " search as characters are entered
set hlsearch   " highlight matches

" Completion
" ----------
set omnifunc=syntaxcomplete#Complete
set complete-=i
set completeopt=menuone,preview

" Wildmenu
" --------
set wildmenu                        " visual autocomplete for command menu
set wildmode=full                   " shows all the option

" Misc
" ----
set autoread
set nrformats-=octal

if &history < 1000
  set history=1000
endif

if &tabpagemax < 50
  set tabpagemax=50
endif

if !empty(&viminfo)
  set viminfo^=!
endif

" Timeout
" -------
set notimeout
set ttimeout
set ttimeoutlen=100

" No bells
" --------
set noerrorbells visualbell t_vb=
augroup bell
  autocmd!
  autocmd GUIEnter * set visualbell t_vb=
augroup END

" Folding
set foldmethod=marker
" }}}
" bindings {{{
let g:mapleader = ','     " utilise ',' au lieu de '\' par défaut
nnoremap <space> za       " folder trigger

" Buffers
" -------
map <C-k> <C-w>k
map <C-j> <C-w>j
map <C-l> <C-w>l
map <C-h> <C-w>h
" }}}
" netrw {{{
" Pour Unix, définir la variable $CLOUD_DIR dans .zshenv
" Pour Windows, définir la variable $CLOUD_DIR comme suis :
" Clic droit sur Ordinateur -> Propriétés -> Paramètres système avancés -> Variables d'environnement...
"map <C-t> :Lexplore $CLOUD_DIR<CR>
map <C-t> :Lexplore<CR>
let g:netrw_browse_split = 4    " open in previous window
let g:netrw_banner = 0          " pas de panneau en haut
let g:netrw_liststyle = 3       " tree view
let g:netrw_winsize = -28       " max width
" }}}
" autocommands {{{
augroup misc
  autocmd!
  autocmd FileType help wincmd L        " help on the vertical right
  autocmd BufEnter * silent! lcd %:p:h  " current dir. same as the current file
augroup END

augroup filetype_markdown
  autocmd!
  autocmd BufNewFile,BufRead,BufWrite *.txt,*.md,*.mkd,*.markdown,*.mdwn setlocal filetype=markdown
  autocmd BufRead,BufWrite,InsertChange *.txt,*.md,*.mkd,*.markdown,*.mdwn syntax match ErrorMsg '\%>77v.\+'
  autocmd BufNewFile,BufReadPost *.txt,*.md,*.mkd,*.markdown,*.mdwn setlocal tabstop=3 shiftwidth=3 softtabstop=3
  autocmd BufNewFile,BufReadPost *.txt,*.md,*.mkd,*.markdown,*.mdwn setlocal list
  autocmd BufNewFile,BufReadPost *.txt,*.md,*.mkd,*.markdown,*.mdwn setlocal listchars=trail:․
augroup END

augroup filetype_help
  autocmd!
  autocmd FileType help wincmd L        " help on the vertical right
  autocmd FileType help set nolist
augroup END

augroup filetype_python
  autocmd!
  autocmd BufNewFile,BufRead *.py setlocal tabstop=4 softtabstop=4 shiftwidth=4
augroup END
" }}}
