" this will override list markers highlighting from stock markdown.vim in
" /usr/local/Cellar/neovim/*/share/nvim/runtime/syntax/markdown.vim (brew macOS)
" /usr/share/nvim/runtime/syntax/markdown.vim (linux)

syn match markdownListMarker "\%(\t\| \{0,99\}\)[-*+]\%(\s\+\S\)\@=" contained
syn match markdownOrderedListMarker "\%(\t\| \{0,99}\)\<\d\+\.\%(\s\+\S\)\@=" contained
