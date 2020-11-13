" Tab and indentation width
set tabstop=4
set shiftwidth=4

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PLUGINS

" vim-plug installation (plugins will be installed on first Neovim startup)
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))

	silent !sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"
		\/nvim/site/autoload/plug.vim --create-dirs
		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

	autocmd VimEnter * PlugInstall --sync | source ~/.config/nvim/init.vim

endif


call plug#begin('~/.vim/plugged')

" Gruvbox theme
Plug 'morhetz/gruvbox'
" Comments
Plug 'tpope/vim-commentary'
" Automatically insert or delete brackets, parentheses, quotes, etc.
" Plug 'jiangmiao/auto-pairs'
Plug 'tmsvg/pear-tree'
" Additional text objects to operate
Plug 'wellle/targets.vim'
" Indent text object
Plug 'michaeljsmith/vim-indent-object'
" Improved syntax highlighting for multiple languages
Plug 'sheerun/vim-polyglot'
" Highlight color codes
Plug 'ap/vim-css-color'
" Coc completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Highlight yanked text
Plug 'machakann/vim-highlightedyank'

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" THEME

" True color support
set termguicolors

let g:gruvbox_bold = '0'
let g:gruvbox_italic = '1'

let g:gruvbox_contrast_dark = 'hard'

" Cursor background while search is highlighted
let g:gruvbox_hls_cursor = 'red'

colorscheme gruvbox

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Relative numbers, with current line absolute number
set number relativenumber

" Highlight current line
set cursorline

" Invisible characters
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣

" Use <Space> as <Leader>
map <Space> <Leader>

" Remap 'jk' to <Esc> in insert mode
inoremap jk <Esc>

" Yank to end of line with 'Y'
noremap Y y$

" Open terminal in currently open file directory
noremap <silent> <C-\> :lcd %:p:h<CR> :!konsole&<CR><CR> :lcd -<CR>

" " Stop search highlighting when entering insert mode
" autocmd InsertEnter * setlocal nohlsearch
" nnoremap n :set hlsearch<CR>n
" nnoremap N :set hlsearch<CR>N
" nnoremap / :set hlsearch<CR>/
" nnoremap ? :set hlsearch<CR>?

" Toggle search highlight with <Leader>h and <BS>
nnoremap <silent><expr> <Leader>h
	\ (&hls && v:hlsearch ? ':nohls' : ':set hls')."\n"
nnoremap <silent><expr> <BS>
	\ (&hls && v:hlsearch ? ':nohls' : ':set hls')."\n"

" Mouse support
set mouse=a

" Share system clipboard
set clipboard=unnamedplus

" Do not insert current comment leader when hitting 'o' in normal mode
autocmd FileType * set formatoptions-=o
" Insert current comment leader when hitting <Enter> in insert mode
autocmd FileType * set formatoptions+=r

" Disable auto pair repeat
let g:pear_tree_repeatable_expand = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COC

" Navigate through Coc completion with <Tab> and <S-Tab>
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Close preview with <Esc>
" inoremap <expr> <Esc> pumvisible() ? "\<C-d>" : "\<Esc>"
