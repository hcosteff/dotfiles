call plug#begin()

" Plug 'neoclide/coc.nvim', {'branch':'release'}

" On-demand loading
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'ellisonleao/gruvbox.nvim', {'branch':'main'}
Plug 'derekwyatt/vim-fswitch'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'RRethy/vim-illuminate'
Plug 'pocco81/auto-save.nvim'
"Plug 'ludovicchabant/vim-gutentags'

Plug 'itchyny/lightline.vim'
call plug#end()

let mapleader=" "

nnoremap <leader>plug :PlugInstall<CR>

" gruvbox settings
set background=dark " or light if you want light mode
colorscheme gruvbox


" highlight extra whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
au BufWinEnter * match ExtraWhitespace /\s\+$/
au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
au InsertLeave * match ExtraWhitespace /\s\+$/
au BufWinLeave * call clearmatches()

" Remove all trailing whitespaces
nnoremap <silent> <leader>rs :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>

" Reload init.vim
noremap <leader>rel :source ~/.config/nvim/init.vim<CR>

" Switch header and cpp
au BufEnter *.h  let b:fswitchdst = "c,cpp,cc,m"
au BufEnter *.cc let b:fswitchdst = "h,hpp"
nnoremap <silent> <C-o> :FSHere <CR>


set number
set mouse=a

set expandtab
set softtabstop=4
set shiftwidth=4
set autoindent
set smartindent
set clipboard=unnamedplus " Enables the clipboard between Vim/Neovim and other applications.
set completeopt=noinsert,menuone,noselect " Modifies the auto-complete menu to behave more like an IDE.
set cursorline " Highlights the current line in the editor
set title " Show file title
set wildmenu " Show a more advance menu
set cc=80 " Show at 80 column a border for good code style
filetype plugin indent on   " Allow auto-indenting depending on file type
syntax on
set ttyfast " Speed up scrolling in Vim

"Mac shortcut compatibility
inoremap  <Home>
nnoremap  <Home>
inoremap  <End>
nnoremap  g$
inoremap <C-E> <End>

nnoremap <M-b> b
inoremap <M-b> <C-O>b
nnoremap <M-f> w
inoremap <M-f> <C-O>w

" Modern-like selections (moving with shift)
nnoremap <S-Up> v<Up>
nnoremap <S-Down> v<Down>
nnoremap <S-Left> v<Left>
nnoremap <S-Right> v<Right>
nnoremap <S-> v<Home>
nnoremap <S-> v<End>
vnoremap <S-Up> <Up>
vnoremap <S-Down> <Down>
vnoremap <S-Left> <Left>
vnoremap <S-Right> <Right>
vnoremap <S-> <End>
vnoremap <S-> <Home>


inoremap  <del>
noremap <PageUp> <C-u>
noremap <PageDown> <C-d>

set virtualedit=onemore,block



nnoremap <leader>o :Files<CR>
nnoremap <leader>h :History:<CR>
nnoremap <leader>t :Tags<CR>

nnoremap q :q<CR>

" Nerdtree config
let g:NERDTreeWinSize=80
let g:NERDTreeShowHidden=0
let g:NERDTreeQuitOnOpen=1
let g:NERDTreeCustomOpenArgs =
      \ {'file': {'reuse': 'all', 'where': 'p', 'keepopen':0, 'stay':0}}

nnoremap <leader>nn :NERDTreeToggle<CR>
nnoremap <leader>nb :NERDTreeFromBookmark<Space>
nnoremap <leader>nf :NERDTreeFind<CR>

" Moving between tabs
nnoremap <leader>0 :tab split<CR>
nnoremap 0 :tabnext<CR>
nnoremap 9 :tabprevious<CR>


" search selected (ctrl-8 also works here)
nnoremap * *N

" jump to containing curly braces start (ctrl-5 also works here)
map <C-]> [{



