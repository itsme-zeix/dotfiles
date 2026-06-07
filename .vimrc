" Turn on syntax highlighting
syntax on
" Make vim behaves less like vi
set nocompatible
" Keep a backup copy of the file being edited
" set backup
" The Location of the backup files.
" set backupdir=~/.backup
" Automatically indent the new line
set autoindent
" Indent the new line according to C-like syntax
set smartindent
" Make default indent at 2 spaces
set shiftwidth=2
" Set tab stop to 2
set tabstop=2
" Load the relevant plugins and indentation rules based on file types
filetype plugin indent on
"
" Replace all tab with spaces
set expandtab
" Display lines longer than the current window on the next line(s)
set wrap
" Prevent breaking a word into multiple lines when wrapping
set linebreak
" Display line and column number on the lower-right corner.
set ruler
" Enable 24-bit colors
" set termguicolors
" Use gruvbox as colourscheme
color gruvbox 
set background=dark
" To get around problem with seemingly random characters appear in certain
" teminals.
set t_RV=
set t_u7=

" uncomment to turn on line number
set number

set scrolloff=10
set belloff=all

" vim is optimized for keyboard-only, but if you insist on using mouse,
" uncomment the following
" set mouse+=a

" some advanced options requested by students.  Use them only if
" you know what you are doing (I don't know what they do!)
" set hidden 
" set wildmenu 
" set showcmd 
set hlsearch 
" set confirm 
" set visualbell 
" set ignorecase 
" set smartcase

set clipboard=unnamedplus
