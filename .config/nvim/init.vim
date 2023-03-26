"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PLUGINS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
" Improved syntax highlighting for multiple languages
Plug 'sheerun/vim-polyglot'
" Highlight color codes
Plug 'ap/vim-css-color'
" Highlight yanked text
Plug 'machakann/vim-highlightedyank'
" Comments
Plug 'tpope/vim-commentary'
" Automatically insert or delete brackets, parentheses, quotes, etc.
" Plug 'tmsvg/pear-tree'  " pear-tree conflicts with coc-rename
Plug 'Raimondi/delimitMate'
" Plug 'jiangmiao/auto-pairs'
" Additional text objects to operate with
Plug 'wellle/targets.vim'
" Indent text object
Plug 'michaeljsmith/vim-indent-object'
" Coc completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Latex 
Plug 'lervag/vimtex'
" fzf fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Change working directory to project root
Plug 'airblade/vim-rooter'
" Status line
Plug 'vim-airline/vim-airline'

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" GENERAL
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Tab and indentation width
set tabstop=4
set shiftwidth=4

" Relative numbers, with current line absolute number
set number relativenumber

" Highlight current line
autocmd VimEnter,WinEnter,BufWinEnter * set cursorline

" Minimum number of lines to keep above/below cursor
set scrolloff=1

" Command mode tab completion: first `<Tab>` completes partial match and
" displays menu, subsequent `<Tab>`s cycle through menu entries
set wildmode=longest:full,full

" New split location
set splitbelow
set splitright

" Share system clipboard
set clipboard=unnamedplus

" Mouse support
set mouse=a

" Invisible characters
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣

" Do not insert current comment leader when hitting `o` in normal mode
autocmd FileType * set formatoptions-=o
" Insert current comment leader when hitting `<Enter>` in insert mode
autocmd FileType * set formatoptions+=r

" Auto detect Octave .m files
autocmd BufNewFile,BufRead *.m set filetype=octave

" Auto detect Arduino .cpp files by looking for `#include <Arduino.h>` directive
function! s:DetectArduinoFile()
	let file_path = expand('%:p')
	let number_of_lines = system('wc -l ' . file_path)
	let i = 1
	while i <= number_of_lines
		let line = getline(i)
		if line =~ '^\s*$'
			let i += 1
		elseif line =~ '^\s*//'
			let i += 1
		elseif line =~ '^\s*/\*'
			while i <= number_of_lines
				let line = getline(i)
				if line =~ '\*/'
					let i += 1
					break
				else
					let i += 1
				endif
			endwhile
		elseif line =~ '^\s*#'
			if line =~ '^\s*#include <Arduino.h>'
				set filetype=arduino
				break
			else
				let i += 1
			endif
		else
			break
		endif
	endwhile
endfun
autocmd BufRead,BufWrite *.{c++,cc,cp,cpp,cxx,C,CPP,h,hh,hpp} call s:DetectArduinoFile()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" KEYBINDINGS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Use `<Space>` as `<Leader>`
map <Space> <Leader>

" Remap `jk` to `<Esc>` in insert mode
inoremap jk <Esc>

" Yank to end of line with `Y`
noremap Y y$

" Open terminal in currently open file directory with `<C-\>`
noremap <silent> <C-\> :lcd %:p:h<CR> :!konsole&<CR><CR> :lcd -<CR>

" Toggle search highlight with `<Leader>hl` and `<BS>`
nnoremap <silent><expr> <Leader>hl
	\ (&hls && v:hlsearch ? ':nohls' : ':set hls')."\n"
nnoremap <silent><expr> <BS>
	\ (&hls && v:hlsearch ? ':nohls' : ':set hls')."\n"

" " Disable search highlighting when entering insert mode
" autocmd InsertEnter * setlocal nohlsearch
" nnoremap n :set hlsearch<CR>n
" nnoremap N :set hlsearch<CR>N
" nnoremap / :set hlsearch<CR>/
" nnoremap ? :set hlsearch<CR>?

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PLUGIN SETUP
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" THEME

" True color support
set termguicolors

let g:gruvbox_bold = '0'
let g:gruvbox_italic = '1'

let g:gruvbox_contrast_light = 'hard'
let g:gruvbox_contrast_dark = 'hard'

let g:gruvbox_invert_selection= '0'

" Make signcolumn background the same as the number column
let g:gruvbox_sign_column = 'bg0'

" Cursor background while search is highlighted
let g:gruvbox_hls_cursor = 'red'

" Use the light theme when the terminal background is light
if $TERMINAL_BACKGROUND=='light'
  set background=light
endif

colorscheme gruvbox

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIM-POLYGLOT

" Don't highlight trailing spaces in Python
let g:python_highlight_space_errors = 0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIM-AIRLINE

" Disable default mode indicator, since we are using vim-airline
set noshowmode

" Current position information
" Item meanings:
" 	%p: percentage in file
" 	%%: percent sign
" 	%l: line number
" 	%L: number of lines in buffer
"	%c: column number
"	%v: virtual column number
"	%V: virtual column number as -{num}; not displayed if equal to %c
let g:airline_section_z = '%p%% %#__accent_bold#%{g:airline_symbols.linenr}%l%#__restore__#/%L%#__accent_bold#:%c%V%#__restore__#'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" AUTO PAIRS

" " Disable auto pair repeat
" let g:pear_tree_repeatable_expand = 0

" When <CR> is pressed inside an empty pair, an empty line is inserted
" between the opening and closing characters
let delimitMate_expand_cr = 1

" When <space> is pressed inside an empty pair, an additional space is
" inserted between the opening and closing characters
let delimitMate_expand_space = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FZF

" Redefine fzf `Rg` command to search only file content (excluding file names)
command! -bang -nargs=* Rg call fzf#vim#grep("rg --hidden --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

" Launch fzf default command with `<Ctrl>p`
nnoremap <silent> <C-p> :FZF<CR>

" Launch fzf `Rg` command with `<Ctrl>n`
nnoremap <silent> <C-n> :Rg<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COC

" TextEdit might fail if hidden is not set
set hidden

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Give more space for displaying messages
set cmdheight=2

" Having longer updatetime (default is 4000ms = 4s) leads to
" noticeable delays and poor user experience
set updatetime=300

" Don't pass messages to |ins-completion-menu|
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each
" time diagnostics appear/become resolved
if has("patch-8.1.1564")
	" Recently Vim can merge signcolumn and number column into one
	set signcolumn=number
else
	set signcolumn=yes
endif

" Navigate through Coc completion with `<Tab>` and `<S-Tab>`
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Use `<C-Space>` to trigger completion
if has('nvim')
	inoremap <silent><expr> <C-Space> coc#refresh()
else
	inoremap <silent><expr> <C-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in
" location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use `K` to show documentation in preview window
function! s:show_documentation()
	if (index(['vim','help'], &filetype) >= 0)
		execute 'h '.expand('<cword>')
	elseif (coc#rpc#ready())
		call CocActionAsync('doHover')
	else
		execute '!' . &keywordprg . " " . expand('<cword>')
	endif
endfunction
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Rename symbol with `<Leader>rn`
nmap <Leader>rn <Plug>(coc-rename)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the
" language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Mappings for CocList
" Show all diagnostics
nnoremap <silent><nowait> <Leader>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> <Leader>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <Leader>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> <Leader>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> <Leader>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item
nnoremap <silent><nowait> <Leader>j  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> <Leader>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent><nowait> <Leader>p  :<C-u>CocListResume<CR>
