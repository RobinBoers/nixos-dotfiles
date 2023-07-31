{ config, pkgs, lib, ... }:

{
  ## Neovim

  # I split this into a seperate file because my neovim config is literally giant, and it was taking way to long to scroll up and down my home.nix file while it was still in there.

  programs.neovim = {
    enable = true; 

    defaultEditor = true;
    vimAlias = true;
    extraConfig = ''
      " ===  Appearance  === "

      " Font
      "set guifont=monospace\ 16

      " Use terminal color scheme
      colorscheme dim
      set notermguicolors

      set number          " Show line numbers
      syntax on           " Turn syntax highlighting on
      set ruler           " Show where cursor is
      set showmatch       " Show brackets when text indicator is over them
      set background=dark

      " Hide stupid window seperators
      set fillchars-=vert:\|
      hi VertSplit ctermfg=0 ctermbg=NONE guifg=0 guibg=NONE
      hi StatusLine ctermfg=0 ctermbg=NONE guifg=0 guibg=NONE
      hi StatusLineNC ctermfg=0 ctermbg=NONE guifg=0 guibg=NONE
      hi TabLineFill ctermfg=black ctermbg=NONE

      hi TabLine ctermfg=darkgray ctermbg=black
      hi TabLineSel ctermfg=gray ctermbg=black

      " No annoying sound on errors
      set noerrorbells
      set novisualbell
      set t_vb=
      set tm=500

      " Tabs
      "set showtabline=2
      nnoremap <C-n> :tabnew<cr>
      vnoremap <C-n> :tabnew<cr>
      inoremap <C-n> <C-o>:tabnew<cr>

      nnoremap <C-w> :tabclose<cr>
      vnoremap <C-w> :tabclose<cr>
      inoremap <C-w> <C-o>:tabclose<cr>

      " ===  Integrations  === "

      " Git integration
      call v:lua.require'gitsigns'.setup()

      " Integrated terminal
      "call v:lua.require'toggleterm'.setup()
      "nnoremap <C-`> :ToggleTerm dir=git_dir direction=float<cr>
      "nnoremap <C-S-G> :ToggleTerm dir=git_dir direction=float go_back=0<cr>

      " Better UI

      call v:lua.require'noice'.setup()

      " Project integration

      lua << EOF
        require'project_nvim'.setup {
          detection_methods = { "lsp" }
        }
      EOF

      call v:lua.require'telescope'.load_extension('projects')

      nnoremap <C-p> :Telescope find_files<cr>
      vnoremap <C-p> :Telescope find_files<cr>
      inoremap <C-p> <C-o>:Telescope find_files<cr>

      nnoremap <C-r> :Telescope projects<cr>
      vnoremap <C-r> :Telescope projects<cr>
      inoremap <C-r> <C-o>:Telescope projects<cr>

      noremap <C-K>T :Telescope colorscheme<cr>

      " Command applet

      " Activate command mode with CTRL+Shift+P
      nnoremap <C-S-p> :
      vnoremap <C-S-p> :
      inoremap <C-S-p> <C-o> :

      " Treesitter

      lua << EOF
        require'nvim-treesitter.configs'.setup {
          auto_install = false,
          highlight = {
            enable = true
          },
          indent = {
            enable = true
          }
        }
      EOF

      " File tree

      " Map CTRL-B to toggle
      nnoremap <C-b> :NvimTreeToggle<cr>
      vnoremap <C-b> :NvimTreeToggle<cr>

      " Map CTRL-Shift-B to focus
      nnoremap <C-S-b> :NvimTreeFocus<cr>
      vnoremap <C-S-b> :NvimTreeFocus<cr>

      " Homemade statusline
      " See: https://shapeshed.com/vim-statuslines/

      set cmdheight=1     " Height of the command area
      set noshowmode      " Since I'll be displaying the current mode in the status line, I disable the native way vim does this.

      function! StatuslineModeColor()
          let l:mode=mode()
          if l:mode==?"v"
              return "Search"
          elseif l:mode==#"i"
              return "Directory"
          elseif l:mode==#"R"
              return "DiffDelete"
          else
              return "PmenuThumb"
          endif
      endfunction

      function! StatuslineMode()
        let l:mode=mode()
        if l:mode==#"n"
          return "NORMAL"
        elseif l:mode==?"v"
          return "VISUAL"
        elseif l:mode==#"i"
          return "INSERT"
        elseif l:mode==#"R"
          return "REPLACE"
        elseif l:mode==?"s"
          return "SELECT"
        elseif l:mode==#"t"
          return "TERMINAL"
        elseif l:mode==#"c"
          return "COMMAND"
        elseif l:mode==#"!"
          return "SHELL"
        endif
      endfunction

      function! StatuslineGit()
        let l:branchname = fugitive#Head()
        return strlen(l:branchname) > 0?' git '.l:branchname.' ':'\'
      endfunction

      set statusline=
      set statusline+=%#StatusLine#
      set statusline+=\ %#{StatuslineModeColor()}#
      set statusline+=\ \ %{StatuslineMode()}\ \ 
      set statusline+=%#WinBar#
      set statusline+=\ %{StatuslineGit()}    " Git branch
      set statusline+=%#StatusLine#
      set statusline+=\ %f                    " Current file
      set statusline+=\ %#WarningMsg#
      set statusline+=\ %m                    " Dirty buffer state
      set statusline+=%#StatusLine#
      set statusline+=%=                      " Left/right seperator
      set statusline+=\=\=\=
      set statusline+=\ %l:%c/%L             
      set statusline+=\ %y
      set statusline+=\ \=\=\=

      " ===  Editor  === "

      set mouse=a                     " Enable mouse
      set backspace=indent,eol,start  " Use backspace to delete automatic indent, end of lines and characters outside of insert mode.
      set hidden                      " Don't discard unsaved buffers (and terminals)
      "set so=15                      " Set the minimal number of lines below the cursor

      " Use only insert mode (I know, I know...)
      "set insertmode                 " Disable normal mode, only works in Vim, not in Neovim
      "set iminsert=1                  " Keep insert mode when switching buffers
      "startinsert                     " Start in insert mode

      " NO ESCAPE FOR YOU
      "inoremap <esc>   <NOP>

      " Indentation settings
      set tabstop=2     " Use two spaces for identation
      set shiftwidth=2
      set autoindent    " Enable auto indentation
      set expandtab     " Replace tabs with spaces

      " Use the best encoding
      set encoding=UTF-8

      " Intergrate system clipboard (needs xclip, wl-copy or similar)
      set clipboard+=unnamedplus

      " Show new content when editted from outside
      set autoread        
      au FocusGained,BufEnter * checktime " When you open a buffer or if VIM gains focus

      " Turn off swap files (cause I use git)
      set noswapfile
      set nobackup
      set nowb

      " ===  Search  === "

      set incsearch             " Show search results while searching
      set hlsearch              " Highlight search results

      nnoremap <C-f> /

      "set lazyredraw            " Improve scrolling performance when navigating through large result
      set regexpengine=1        " Use old regexp engine
      set ignorecase smartcase  " Ignore case only when the pattern contains no capital letters

      " Shortcut for far.vim find
      "nnoremap <silent> <C-f>  :Farf<cr>
      "vnoremap <silent> <C-f>  :Farf<cr>

      " Shortcut for far.vim replace
      "nnoremap <silent> <C-h>  :Farr<cr>
      "vnoremap <silent> <C-h>  :Farr<cr>

      " ===  CHEATS  === "

      " Map Ctrl+C to copy
      nnoremap <C-c> "+y
      vnoremap <C-c> "+y
      inoremap <C-c> <C-o>"+y

      " Map Ctrl+X to cut
      nnoremap <C-x> "+d
      vnoremap <C-x> "+d
      inoremap <C-x> <C-o>"+d

      " Map Ctrl+V to paste
      nnoremap <C-v> "+p
      vnoremap <C-v> "+p
      inoremap <C-v> <C-o>"+p

      " Map Ctrl+Z to undo
      nnoremap <C-z> u
      vnoremap <C-z> u
      inoremap <C-z> <C-o>u

      " Map Ctrl+Y to redo
      nnoremap <C-y> <C-r>
      vnoremap <C-y> <C-r>
      inoremap <C-y> <C-o><C-r>

      " Map Ctrl+S to save
      nnoremap <C-s> :w<CR>
      vnoremap <C-s> <C-c>:w<CR>
      inoremap <C-s> <C-o>:w<CR>

      " ===  Autocomplete  === "

      set wildmenu        " Add autocompletion for commands

      " Ignore these files in command autocompletion
      set wildignore=*.o,*~,*.pyc,*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store,*/_build/*,*/dist/*,*/target/*,*/npm_modules/*

    '';
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      vim-dim
      vim-fugitive
      nvim-treesitter
      nvim-treesitter-textobjects
      nvim-treesitter-parsers.yaml
      nvim-treesitter-parsers.vim
      nvim-treesitter-parsers.typescript
      nvim-treesitter-parsers.toml
      nvim-treesitter-parsers.rust
      nvim-treesitter-parsers.rasi
      nvim-treesitter-parsers.python
      nvim-treesitter-parsers.php
      nvim-treesitter-parsers.nix
      nvim-treesitter-parsers.markdown
      nvim-treesitter-parsers.markdown_inline
      nvim-treesitter-parsers.make
      nvim-treesitter-parsers.lua
      nvim-treesitter-parsers.json
      nvim-treesitter-parsers.javascript
      nvim-treesitter-parsers.ini
      nvim-treesitter-parsers.html
      nvim-treesitter-parsers.heex
      nvim-treesitter-parsers.gitignore
      nvim-treesitter-parsers.gitcommit
      nvim-treesitter-parsers.fish
      nvim-treesitter-parsers.erlang
      nvim-treesitter-parsers.elixir
      nvim-treesitter-parsers.eex
      nvim-treesitter-parsers.dockerfile
      nvim-treesitter-parsers.diff
      nvim-treesitter-parsers.css
      nvim-treesitter-parsers.cmake
      nvim-treesitter-parsers.bash
      trouble-nvim
      todo-comments-nvim
      noice-nvim
      gitsigns-nvim
      plenary-nvim
      telescope-nvim
      project-nvim
      dressing-nvim
      nui-nvim
    ];
  };
}