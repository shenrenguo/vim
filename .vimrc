" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={{{,}}} foldlevel=0 foldmethod=marker spell:

" Environment {{{

    " Identify platform {{{
        silent function! OSX()
            return has('macunix')
        endfunction
        silent function! LINUX()
            return has('unix') && !has('macunix') && !has('win32unix')
        endfunction
        silent function! WINDOWS()
            return  (has('win16') || has('win32') || has('win64'))
        endfunction
    " }}}

    " Basics {{{
        set nocompatible        " Must be first line
        if !WINDOWS()
            set shell=/bin/sh
        endif
    " }}}

    " Windows Compatible {{{
        " On Windows, also use '.vim' instead of 'vimfiles'; this makes synchronization
        " across (heterogeneous) systems easier.
        if WINDOWS()
          set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
        endif
    " }}}

" }}}

" Use bundles config {{{
    if filereadable(expand("~/.vimrc.bundles"))
        source ~/.vimrc.bundles
    endif
" }}}

" General {{{

    set background=dark         " Assume a dark background

    " Allow to trigger background
    function! ToggleBG()
        let s:tbg = &background
        " Inversion
        if s:tbg == "dark"
            set background=light
        else
            set background=dark
        endif
    endfunction
    noremap <leader>bg :call ToggleBG()<CR>

    " if !has('gui')
        "set term=$TERM          " Make arrow and other keys work
    " endif
    filetype plugin indent on   " Automatically detect file types.
    syntax on                   " Syntax highlighting
    set mouse=a                 " Automatically enable mouse usage
    set mousehide               " Hide the mouse cursor while typing
    scriptencoding utf-8

    if has('clipboard')
        if has('unnamedplus')  " When possible use + register for copy-paste
            set clipboard=unnamed,unnamedplus
        else         " On mac and Windows, use * register for copy-paste
            set clipboard=unnamed
        endif
    endif

    " Most prefer to automatically switch to the current file directory when
    " a new buffer is opened; to prevent this behavior, add the following to
    " your .vimrc.before.local file:
    "   let g:spf13_no_autochdir = 1
    if !exists('g:spf13_no_autochdir')
        autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif
        " Always switch to the current file directory
    endif

    "set autowrite                       " Automatically write a file when leaving a modified buffer
    set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
    set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
    set virtualedit=onemore             " Allow for cursor beyond last character
    set history=1000                    " Store a ton of history (default is 20)
    set spell                           " Spell checking on
    set hidden                          " Allow buffer switching without saving
    set iskeyword-=.                    " '.' is an end of word designator
    set iskeyword-=#                    " '#' is an end of word designator
    set iskeyword-=-                    " '-' is an end of word designator

    " Instead of reverting the cursor to the last position in the buffer, we
    " set it to the first line when editing a git commit message
    au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

    " http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
    " Restore cursor to file position in previous editing session
    " To disable this, add the following to your .vimrc.before.local file:
    "   let g:spf13_no_restore_cursor = 1
    if !exists('g:spf13_no_restore_cursor')
        function! ResCur()
            if line("'\"") <= line("$")
                silent! normal! g`"
                return 1
            endif
        endfunction

        augroup resCur
            autocmd!
            autocmd BufWinEnter * call ResCur()
        augroup END
    endif

    " Setting up the directories {{{
        set backup                  " Backups are nice ...
        if has('persistent_undo')
            set undofile                " So is persistent undo ...
            set undolevels=1000         " Maximum number of changes that can be undone
            set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
        endif

        " To disable views add the following to your .vimrc.before.local file:
        "   let g:spf13_no_views = 1
        if !exists('g:spf13_no_views')
            " Add exclusions to mkview and loadview
            " eg: *.*, svn-commit.tmp
            let g:skipview_files = [
                \ '\[example pattern\]'
                \ ]
        endif
    " }}}

" }}}

" Vim UI {{{

    if filereadable(expand("~/.vim/bundle/vim-colors-solarized/colors/solarized.vim"))
        let g:solarized_termcolors=256
        let g:solarized_termtrans=1
        let g:solarized_contrast="normal"
        let g:solarized_visibility="normal"
        color solarized             " Load a colorscheme
    endif

    set tabpagemax=15               " Only show 15 tabs
    set showmode                    " Display the current mode

    set cursorline                  " Highlight current line

    highlight clear SignColumn      " SignColumn should match background
    highlight clear LineNr          " Current line number row will have same background color in relative mode
    "highlight clear CursorLineNr    " Remove highlight color from current line number

    if has('cmdline_info')
        set ruler                   " Show the ruler
        set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
        set showcmd                 " Show partial commands in status line and
                                    " Selected characters/lines in visual mode
    endif

    if has('statusline')
        set laststatus=2

        " Broken down into easily includeable segments
        set statusline=%<%f\                     " Filename
        set statusline+=%w%h%m%r                 " Options
        set statusline+=%{fugitive#statusline()} " Git Hotness
        set statusline+=\ [%{&ff}/%Y]            " Filetype
        set statusline+=\ [%{getcwd()}]          " Current dir
        set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
    endif

    set backspace=indent,eol,start  " Backspace for dummies
    set linespace=0                 " No extra spaces between rows
    set number                      " Line numbers on
    set showmatch                   " Show matching brackets/parenthesis
    set incsearch                   " Find as you type search
    set hlsearch                    " Highlight search terms
    set winminheight=0              " Windows can be 0 line high
    set ignorecase                  " Case insensitive search
    set smartcase                   " Case sensitive when uc present
    set wildmenu                    " Show list instead of just completing
    set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
    set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
    set scrolljump=5                " Lines to scroll when cursor leaves screen
    set scrolloff=3                 " Minimum lines to keep above and below cursor
    set foldenable                  " Auto fold code
    set list
    set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace

" }}}

" Formatting {{{

    set nowrap                      " Do not wrap long lines
    set autoindent                  " Indent at the same level of the previous line
    set shiftwidth=4                " Use indents of 4 spaces
    set expandtab                   " Tabs are spaces, not tabs
    set tabstop=4                   " An indentation every four columns
    set softtabstop=4               " Let backspace delete indent
    set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
    set splitright                  " Puts new vsplit windows to the right of the current
    set splitbelow                  " Puts new split windows to the bottom of the current
    "set matchpairs+=<:>             " Match, to be used with %
    set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
    "set comments=sl:/*,mb:*,elx:*/  " auto format comment blocks
    " Remove trailing whitespaces and ^M chars
    " To disable the stripping of whitespace, add the following to your
    " .vimrc.before.local file:
    "   let g:spf13_keep_trailing_whitespace = 1
    autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rust,twig,xml,yml,perl,sql autocmd BufWritePre <buffer> if !exists('g:spf13_keep_trailing_whitespace') | call StripTrailingWhitespace() | endif
    "autocmd FileType go autocmd BufWritePre <buffer> Fmt
    autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
    autocmd FileType haskell,puppet,ruby,yml setlocal expandtab shiftwidth=2 softtabstop=2
    " preceding line best in a plugin but here for now.

    autocmd BufNewFile,BufRead *.coffee set filetype=coffee

    " Workaround vim-commentary for Haskell
    autocmd FileType haskell setlocal commentstring=--\ %s
    " Workaround broken colour highlighting in Haskell
    autocmd FileType haskell,rust setlocal nospell

" }}}

" Key (re)Mappings {{{

    " The default leader is '\', but many people prefer ',' as it's in a standard
    " location. To override this behavior and set it back to '\' (or any other
    " character) add the following to your .vimrc.before.local file:
    "   let g:spf13_leader='\'
    if !exists('g:spf13_leader')
        let mapleader = ','
    else
        let mapleader=g:spf13_leader
    endif
    if !exists('g:spf13_localleader')
        let maplocalleader = '_'
    else
        let maplocalleader=g:spf13_localleader
    endif

    " The default mappings for editing and applying the spf13 configuration
    " are <leader>ev and <leader>sv respectively. Change them to your preference
    " by adding the following to your .vimrc.before.local file:
    "   let g:spf13_edit_config_mapping='<leader>ec'
    "   let g:spf13_apply_config_mapping='<leader>sc'
    if !exists('g:spf13_edit_config_mapping')
        let s:spf13_edit_config_mapping = '<leader>ev'
    else
        let s:spf13_edit_config_mapping = g:spf13_edit_config_mapping
    endif
    if !exists('g:spf13_apply_config_mapping')
        let s:spf13_apply_config_mapping = '<leader>sv'
    else
        let s:spf13_apply_config_mapping = g:spf13_apply_config_mapping
    endif

    " Code folding options
    nmap <leader>f0 :set foldlevel=0<CR>
    nmap <leader>f1 :set foldlevel=1<CR>
    nmap <leader>f2 :set foldlevel=2<CR>
    nmap <leader>f3 :set foldlevel=3<CR>
    nmap <leader>f4 :set foldlevel=4<CR>
    nmap <leader>f5 :set foldlevel=5<CR>
    nmap <leader>f6 :set foldlevel=6<CR>
    nmap <leader>f7 :set foldlevel=7<CR>
    nmap <leader>f8 :set foldlevel=8<CR>
    nmap <leader>f9 :set foldlevel=9<CR>

    " Most prefer to toggle search highlighting rather than clear the current
    " search results. To clear search highlighting rather than toggle it on
    " and off, add the following to your .vimrc.before.local file:
    "   let g:spf13_clear_search_highlight = 1
    if exists('g:spf13_clear_search_highlight')
        nmap <silent> <leader>/ :nohlsearch<CR>
    else
        nmap <silent> <leader>/ :set invhlsearch<CR>
    endif

    " Shortcuts
    " Change Working Directory to that of the current file
    cmap cwd lcd %:p:h
    cmap cd. lcd %:p:h

    " Visual shifting (does not exit Visual mode)
    vnoremap < <gv
    vnoremap > >gv

    " Allow using the repeat operator with a visual selection (!)
    " http://stackoverflow.com/a/8064607/127816
    vnoremap . :normal .<CR>

    " For when you forget to sudo.. Really Write the file.
    cmap w!! w !sudo tee % >/dev/null

    " Some helpers to edit mode
    " http://vimcasts.org/e/14
    cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>

    " Map <Leader>ff to display all lines with keyword under cursor
    " and ask which one to jump to
    nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

    " Easier horizontal scrolling
    map zl zL
    map zh zH

    " Easier formatting
    nnoremap <silent> <leader>q gwip

    " FIXME: Revert this f70be548
    " fullscreen mode for GVIM and Terminal, need 'wmctrl' in you PATH
    map <silent> <F11> :call system("wmctrl -ir " . v:windowid . " -b toggle,fullscreen")<CR>

" }}}

" Plugins {{{

    " ack.vim {{{
        if executable('ag')
            let g:ackprg = 'ag --nogroup --nocolor --column --smart-case'
        elseif executable('ack-grep')
            let g:ackprg="ack-grep -H --nocolor --nogroup --column"
        endif
    " }}}

    " vim-airline {{{
        if isdirectory(expand("~/.vim/bundle/vim-airline/"))
            let g:airline_theme = 'solarized'
            let g:airline#extensions#tabline#enabled = 1
            let g:airline_powerline_fonts = 1
        endif
    " }}}

    " ctrlp {{{
        if isdirectory(expand("~/.vim/bundle/ctrlp.vim/"))
            let g:ctrlp_working_path_mode = 'ra'
            nnoremap <silent> <D-t> :CtrlP<CR>
            nnoremap <silent> <D-r> :CtrlPMRU<CR>
            let g:ctrlp_custom_ignore = {
                \ 'dir':  '\.git$\|\.hg$\|\.svn$',
                \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$' }

            if executable('ag')
                let s:ctrlp_fallback = 'ag %s --nocolor -l -g ""'
            elseif executable('ack-grep')
                let s:ctrlp_fallback = 'ack-grep %s --nocolor -f'
            elseif executable('ack')
                let s:ctrlp_fallback = 'ack %s --nocolor -f'
            " On Windows use "dir" as fallback command.
            elseif WINDOWS()
                let s:ctrlp_fallback = 'dir %s /-n /b /s /a-d'
            else
                let s:ctrlp_fallback = 'find %s -type f'
            endif
            if exists("g:ctrlp_user_command")
                unlet g:ctrlp_user_command
            endif
            let g:ctrlp_user_command = {
                \ 'types': {
                    \ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others'],
                    \ 2: ['.hg', 'hg --cwd %s locate -I .'],
                \ },
                \ 'fallback': s:ctrlp_fallback
            \ }
        endif
    "}}}

    " NerdTree {{{
        if isdirectory(expand("~/.vim/bundle/nerdtree"))
            map <C-e> <plug>NERDTreeTabsToggle<CR>
            map <leader>e :NERDTreeFind<CR>
            nmap <leader>nt :NERDTreeFind<CR>

            let NERDTreeShowBookmarks=1
            let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
            let NERDTreeChDirMode=0
            let NERDTreeQuitOnOpen=1
            let NERDTreeMouseMode=2
            let NERDTreeShowHidden=1
            let NERDTreeKeepTreeInNewTab=1
            let g:NERDShutUp=1
            let g:nerdtree_tabs_open_on_gui_startup=0
        endif
    " }}}

    " UndoTree {{{
        if isdirectory(expand("~/.vim/bundle/undotree/"))
            nnoremap <Leader>u :UndotreeToggle<CR>
            " If undotree is opened, it is likely one wants to interact with it.
            let g:undotree_SetFocusWhenToggle=1
        endif
    " }}}

    " Matchit {{{
        if isdirectory(expand("~/.vim/bundle/matchit.zip"))
            let b:match_ignorecase = 1
        endif
    " }}}

    " indent_guides {{{
        if isdirectory(expand("~/.vim/bundle/vim-indent-guides/"))
            let g:indent_guides_start_level = 2
            let g:indent_guides_guide_size = 1
            let g:indent_guides_enable_on_vim_startup = 1
        endif
    " }}}

    " Ctags {{{
        set tags=./tags;/,~/.vimtags

        " Make tags placed in .git/tags file available in all levels of a repository
        let gitroot = substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
        if gitroot != ''
            let &tags = &tags . ',' . gitroot . '/.git/tags'
        endif
    " }}}

    " TagBar {{{
        if isdirectory(expand("~/.vim/bundle/tagbar/"))
            nnoremap <silent> <leader>tt :TagbarToggle<CR>

            " AsciiDoc {{{
                let g:tagbar_type_asciidoc = {
                    \ 'ctagstype' : 'asciidoc',
                    \ 'kinds' : [
                        \ 'h:table of contents',
                        \ 'a:anchors:1',
                        \ 't:titles:1',
                        \ 'n:includes:1',
                        \ 'i:images:1',
                        \ 'I:inline images:1'
                    \ ],
                    \ 'sort' : 0
                \ }
            "}}}

            " css {{{
                let g:tagbar_type_css = {
                    \ 'ctagstype' : 'Css',
                    \ 'kinds'     : [
                        \ 'c:classes',
                        \ 's:selectors',
                        \ 'i:identities'
                    \ ]
                \ }
            "}}}

            " elixir {{{
                let g:tagbar_type_elixir = {
                    \ 'ctagstype' : 'elixir',
                    \ 'kinds' : [
                        \ 'f:functions',
                        \ 'functions:functions',
                        \ 'c:callbacks',
                        \ 'd:delegates',
                        \ 'e:exceptions',
                        \ 'i:implementations',
                        \ 'a:macros',
                        \ 'o:operators',
                        \ 'm:modules',
                        \ 'p:protocols',
                        \ 'r:records'
                    \ ]
                \ }
            "}}}

            " go {{{
                let g:tagbar_type_go = {
                    \ 'ctagstype' : 'go',
                    \ 'kinds'     : [
                        \ 'p:package',
                        \ 'i:imports:1',
                        \ 'c:constants',
                        \ 'v:variables',
                        \ 't:types',
                        \ 'n:interfaces',
                        \ 'w:fields',
                        \ 'e:embedded',
                        \ 'm:methods',
                        \ 'r:constructor',
                        \ 'f:functions'
                    \ ],
                    \ 'sro' : '.',
                    \ 'kind2scope' : {
                        \ 't' : 'ctype',
                        \ 'n' : 'ntype'
                    \ },
                    \ 'scope2kind' : {
                        \ 'ctype' : 't',
                        \ 'ntype' : 'n'
                    \ },
                    \ 'ctagsbin'  : 'gotags',
                    \ 'ctagsargs' : '-sort -silent'
                \ }
            "}}}

            " Groovy {{{
                let g:tagbar_type_groovy = {
                    \ 'ctagstype' : 'groovy',
                    \ 'kinds'     : [
                        \ 'p:package',
                        \ 'c:class',
                        \ 'i:interface',
                        \ 'f:function',
                        \ 'v:variables',
                    \ ]
                \ }
            "}}}

            " Haskell {{{
                let g:tagbar_type_haskell = {
                    \ 'ctagsbin'  : 'hasktags',
                    \ 'ctagsargs' : '-x -c -o-',
                    \ 'kinds'     : [
                        \  'm:modules:0:1',
                        \  'd:data: 0:1',
                        \  'd_gadt: data gadt:0:1',
                        \  't:type names:0:1',
                        \  'nt:new types:0:1',
                        \  'c:classes:0:1',
                        \  'cons:constructors:1:1',
                        \  'c_gadt:constructor gadt:1:1',
                        \  'c_a:constructor accessors:1:1',
                        \  'ft:function types:1:1',
                        \  'fi:function implementations:0:1',
                        \  'o:others:0:1'
                    \ ],
                    \ 'sro'        : '.',
                    \ 'kind2scope' : {
                        \ 'm' : 'module',
                        \ 'c' : 'class',
                        \ 'd' : 'data',
                        \ 't' : 'type'
                    \ },
                    \ 'scope2kind' : {
                        \ 'module' : 'm',
                        \ 'class'  : 'c',
                        \ 'data'   : 'd',
                        \ 'type'   : 't'
                    \ }
                \ }
            "}}}

            " Markdown {{{
                let g:tagbar_type_markdown = {
                    \ 'ctagstype' : 'markdown',
                    \ 'kinds' : [
                        \ 'h:Heading_L1',
                        \ 'i:Heading_L2',
                        \ 'k:Heading_L3'
                    \ ]
                \ }
            "}}}

            " Object-C {{{
                let g:tagbar_type_objc = {
                    \ 'ctagstype' : 'ObjectiveC',
                    \ 'kinds'     : [
                        \ 'i:interface',
                        \ 'I:implementation',
                        \ 'p:Protocol',
                        \ 'm:Object_method',
                        \ 'c:Class_method',
                        \ 'v:Global_variable',
                        \ 'F:Object field',
                        \ 'f:function',
                        \ 'p:property',
                        \ 't:type_alias',
                        \ 's:type_structure',
                        \ 'e:enumeration',
                        \ 'M:preprocessor_macro',
                    \ ],
                    \ 'sro'        : ' ',
                    \ 'kind2scope' : {
                        \ 'i' : 'interface',
                        \ 'I' : 'implementation',
                        \ 'p' : 'Protocol',
                        \ 's' : 'type_structure',
                        \ 'e' : 'enumeration'
                    \ },
                    \ 'scope2kind' : {
                        \ 'interface'      : 'i',
                        \ 'implementation' : 'I',
                        \ 'Protocol'       : 'p',
                        \ 'type_structure' : 's',
                        \ 'enumeration'    : 'e'
                    \ }
                \ }
            "}}}

            "Puppet {{{
                let g:tagbar_type_puppet = {
                    \ 'ctagstype': 'puppet',
                    \ 'kinds': [
                        \'c:class',
                        \'s:site',
                        \'n:node',
                        \'d:definition'
                    \]
                \}
            "}}}

            "R {{{
                let g:tagbar_type_r = {
                    \ 'ctagstype' : 'r',
                    \ 'kinds'     : [
                        \ 'f:Functions',
                        \ 'g:GlobalVariables',
                        \ 'v:FunctionVariables',
                    \ ]
                \ }
            "}}}

            "Ruby {{{
                let g:tagbar_type_ruby = {
                    \ 'kinds' : [
                        \ 'm:modules',
                        \ 'c:classes',
                        \ 'd:describes',
                        \ 'C:contexts',
                        \ 'f:methods',
                        \ 'F:singleton methods'
                    \ ]
                \ }
            "}}}

            "Rust {{{
                let g:tagbar_type_rust = {
                    \ 'ctagstype' : 'rust',
                    \ 'kinds' : [
                        \'T:types,type definitions',
                        \'f:functions,function definitions',
                        \'g:enum,enumeration names',
                        \'s:structure names',
                        \'m:modules,module names',
                        \'c:consts,static constants',
                        \'t:traits,traits',
                        \'i:impls,trait implementations',
                    \]
                \}
            "}}}

            "Scala {{{
                let g:tagbar_type_scala = {
                    \ 'ctagstype' : 'scala',
                    \ 'sro'       : '.',
                    \ 'kinds'     : [
                      \ 'p:packages',
                      \ 'T:types:1',
                      \ 't:traits',
                      \ 'o:objects',
                      \ 'O:case objects',
                      \ 'c:classes',
                      \ 'C:case classes',
                      \ 'm:methods',
                      \ 'V:values:1',
                      \ 'v:variables:1'
                    \ ]
                \ }
            "}}}

            "TypeScript {{{
                let g:tagbar_type_typescript = {
                  \ 'ctagstype': 'typescript',
                  \ 'kinds': [
                    \ 'c:classes',
                    \ 'n:modules',
                    \ 'f:functions',
                    \ 'v:variables',
                    \ 'v:varlambdas',
                    \ 'm:members',
                    \ 'i:interfaces',
                    \ 'e:enums',
                  \ ]
                \ }
            "}}}

            "WSDL {{{
                let g:tagbar_type_xml = {
                    \ 'ctagstype' : 'WSDL',
                    \ 'kinds'     : [
                        \ 'n:namespaces',
                        \ 'm:messages',
                        \ 'p:portType',
                        \ 'o:operations',
                        \ 'b:bindings',
                        \ 's:service'
                    \ ]
                \ }
            "}}}

            "Xquery {{{
                let g:tagbar_type_xquery = {
                    \ 'ctagstype' : 'xquery',
                    \ 'kinds'     : [
                        \ 'f:function',
                        \ 'v:variable',
                        \ 'm:module',
                    \ ]
                \ }
            "}}}

            "XSD {{{
                let g:tagbar_type_xsd = {
                    \ 'ctagstype' : 'XSD',
                    \ 'kinds'     : [
                        \ 'e:elements',
                        \ 'c:complexTypes',
                        \ 's:simpleTypes'
                    \ ]
                \ }
            "}}}

            "XSLT {{{
                let g:tagbar_type_xslt = {
                  \ 'ctagstype' : 'xslt',
                  \ 'kinds' : [
                    \ 'v:variables',
                    \ 't:templates'
                  \ ]
                \}
            "}}}

        endif
    "}}}

    " Syntastic {{{
        if isdirectory(expand("~/.vim/bundle/syntastic/"))
            set statusline+=%#warningmsg#
            set statusline+=%{SyntasticStatuslineFlag()}
            set statusline+=%*
            let g:syntastic_always_populate_loc_list = 1
            let g:syntastic_auto_loc_list = 1
            let g:syntastic_check_on_open = 1
            let g:syntastic_check_on_wq = 0

            let g:syntastic_html_checkers = ['tidy']
            let g:syntastic_jade_checkers = ['jade_lint']
            let g:syntastic_javascript_checkers = ['eslint']
        endif
    " }}}

    " YouCompleteMe {{{
        if isdirectory(expand("~/.vim/bundle/YouCompleteMe/"))
            let g:acp_enableAtStartup = 0

            " enable completion from tags
            let g:ycm_collect_identifiers_from_tags_files = 1

            " remap Ultisnips for compatibility for YCM
            let g:UltiSnipsExpandTrigger = '<C-j>'
            let g:UltiSnipsJumpForwardTrigger = '<C-j>'
            let g:UltiSnipsJumpBackwardTrigger = '<C-k>'

            " Enable omni completion.
            autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
            autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
            autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
            autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
            autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
            autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
            autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

            " Haskell post write lint and check with ghcmod
            " $ `cabal install ghcmod` if missing and ensure
            " ~/.cabal/bin is in your $PATH.
            if !executable("ghcmod")
                autocmd BufWritePost *.hs GhcModCheckAndLintAsync
            endif

            " For snippet_complete marker.
            if !exists("g:spf13_no_conceal")
                if has('conceal')
                    set conceallevel=2 concealcursor=i
                endif
            endif

            " Disable the neosnippet preview candidate window
            " When enabled, there can be too much visual noise
            " especially when splits are used.
            set completeopt-=preview
        endif
    " }}}

    " Tabularize {{{
        if isdirectory(expand("~/.vim/bundle/tabular"))
            nmap <Leader>a& :Tabularize /&<CR>
            vmap <Leader>a& :Tabularize /&<CR>
            nmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
            vmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
            nmap <Leader>a=> :Tabularize /=><CR>
            vmap <Leader>a=> :Tabularize /=><CR>
            nmap <Leader>a: :Tabularize /:<CR>
            vmap <Leader>a: :Tabularize /:<CR>
            nmap <Leader>a:: :Tabularize /:\zs<CR>
            vmap <Leader>a:: :Tabularize /:\zs<CR>
            nmap <Leader>a, :Tabularize /,<CR>
            vmap <Leader>a, :Tabularize /,<CR>
            nmap <Leader>a,, :Tabularize /,\zs<CR>
            vmap <Leader>a,, :Tabularize /,\zs<CR>
            nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
            vmap <Leader>a<Bar> :Tabularize /<Bar><CR>
        endif
    " }}}

    " Fugitive {{{
        if isdirectory(expand("~/.vim/bundle/vim-fugitive/"))
            nnoremap <silent> <leader>gs :Gstatus<CR>
            nnoremap <silent> <leader>gd :Gdiff<CR>
            nnoremap <silent> <leader>gc :Gcommit<CR>
            nnoremap <silent> <leader>gb :Gblame<CR>
            nnoremap <silent> <leader>gl :Glog<CR>
            nnoremap <silent> <leader>gp :Git push<CR>
            nnoremap <silent> <leader>gr :Gread<CR>
            nnoremap <silent> <leader>gw :Gwrite<CR>
            nnoremap <silent> <leader>ge :Gedit<CR>
            " Mnemonic _i_nteractive
            nnoremap <silent> <leader>gi :Git add -p %<CR>
            nnoremap <silent> <leader>gg :SignifyToggle<CR>
        endif
    "}}}

    " PIV {{{
        if isdirectory(expand("~/.vim/bundle/PIV"))
            let g:DisableAutoPHPFolding = 0
            let g:PIVAutoClose = 0
        endif
    " }}}

    " AutoCloseTag {{{
        " Make it so AutoCloseTag works for xml and xhtml files as well
        au FileType xhtml,xml ru ftplugin/html/autoclosetag.vim
        nmap <Leader>ac <Plug>ToggleAutoCloseMappings
    " }}}

    " JSON {{{
        nmap <leader>jt <Esc>:%!python -m json.tool<CR><Esc>:set filetype=json<CR>
        let g:vim_json_syntax_conceal = 0
    " }}}

    " PyMode {{{
        " Disable if python support not present
        if !has('python') && !has('python3')
            let g:pymode = 0
        endif

        if isdirectory(expand("~/.vim/bundle/python-mode"))
            let g:pymode_lint_checkers = ['pyflakes']
            let g:pymode_trim_whitespaces = 0
            let g:pymode_options = 0
            let g:pymode_rope = 0
        endif
    " }}}

    " FIXME: Isn't this for Syntastic to handle?
    " Haskell post write lint and check with ghcmod
    " $ `cabal install ghcmod` if missing and ensure
    " ~/.cabal/bin is in your $PATH.
    if !executable("ghcmod")
        autocmd BufWritePost *.hs GhcModCheckAndLintAsync
    endif

" }}}

" GUI Settings {{{

    " GVIM- (here instead of .gvimrc)
    if has('gui_running')
        set guioptions-=T           " Remove the toolbar
        set lines=40                " 40 lines of text instead of 24
        if !exists("g:spf13_no_big_font")
            if LINUX() && has("gui_running")
                set guifont=Andale\ Mono\ Regular\ 12,Menlo\ Regular\ 11,Consolas\ Regular\ 12,Courier\ New\ Regular\ 14
            elseif OSX() && has("gui_running")
                set guifont=Andale\ Mono\ Regular:h12,Menlo\ Regular:h11,Consolas\ Regular:h12,Courier\ New\ Regular:h14
            elseif WINDOWS() && has("gui_running")
                set guifont=Andale_Mono:h10,Menlo:h10,Consolas:h10,Courier_New:h10
            endif
        endif
    else
        if &term == 'xterm' || &term == 'screen'
            set t_Co=256            " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
        endif
        "set term=builtin_ansi       " Make arrow and other keys work
    endif

" }}}

" Functions {{{

    " Initialize directories {{{
    function! InitializeDirectories()
        let parent = $HOME
        let prefix = 'vim'
        let dir_list = {
                    \ 'backup': 'backupdir',
                    \ 'views': 'viewdir',
                    \ 'swap': 'directory' }

        if has('persistent_undo')
            let dir_list['undo'] = 'undodir'
        endif

        " To specify a different directory in which to place the vimbackup,
        " vimviews, vimundo, and vimswap files/directories, add the following to
        " your .vimrc.before.local file:
        "   let g:spf13_consolidated_directory = <full path to desired directory>
        "   eg: let g:spf13_consolidated_directory = $HOME . '/.vim/'
        if exists('g:spf13_consolidated_directory')
            let common_dir = g:spf13_consolidated_directory . prefix
        else
            let common_dir = parent . '/.' . prefix
        endif

        for [dirname, settingname] in items(dir_list)
            let directory = common_dir . dirname . '/'
            if exists("*mkdir")
                if !isdirectory(directory)
                    call mkdir(directory)
                endif
            endif
            if !isdirectory(directory)
                echo "Warning: Unable to create backup directory: " . directory
                echo "Try: mkdir -p " . directory
            else
                let directory = substitute(directory, " ", "\\\\ ", "g")
                exec "set " . settingname . "=" . directory
            endif
        endfor
    endfunction
    call InitializeDirectories()
    " }}}

    " Initialize NERDTree as needed {{{
    function! NERDTreeInitAsNeeded()
        redir => bufoutput
        buffers!
        redir END
        let idx = stridx(bufoutput, "NERD_tree")
        if idx > -1
            NERDTreeMirror
            NERDTreeFind
            wincmd l
        endif
    endfunction
    " }}}

    " Strip whitespace {{{
    function! StripTrailingWhitespace()
        " Preparation: save last search, and cursor position.
        let _s=@/
        let l = line(".")
        let c = col(".")
        " do the business:
        %s/\s\+$//e
        " clean up: restore previous search history, and cursor position
        let @/=_s
        call cursor(l, c)
    endfunction
    " }}}

    " Shell command {{{
    function! s:RunShellCommand(cmdline)
        botright new

        setlocal buftype=nofile
        setlocal bufhidden=delete
        setlocal nobuflisted
        setlocal noswapfile
        setlocal nowrap
        setlocal filetype=shell
        setlocal syntax=shell

        call setline(1, a:cmdline)
        call setline(2, substitute(a:cmdline, '.', '=', 'g'))
        execute 'silent $read !' . escape(a:cmdline, '%#')
        setlocal nomodifiable
        1
    endfunction

    command! -complete=file -nargs=+ Shell call s:RunShellCommand(<q-args>)
    " e.g. Grep current file for <search_term>: Shell grep -Hn <search_term> %
    " }}}

    function! s:IsSpf13Fork()
        let s:is_fork = 0
        let s:fork_files = ["~/.vimrc.fork", "~/.vimrc.before.fork", "~/.vimrc.bundles.fork"]
        for fork_file in s:fork_files
            if filereadable(expand(fork_file, ":p"))
                let s:is_fork = 1
                break
            endif
        endfor
        return s:is_fork
    endfunction

    function! s:ExpandFilenameAndExecute(command, file)
        execute a:command . " " . expand(a:file, ":p")
    endfunction

    function! s:EditSpf13Config()
        call <SID>ExpandFilenameAndExecute("tabedit", "~/.vimrc")
        call <SID>ExpandFilenameAndExecute("vsplit", "~/.vimrc.before")
        call <SID>ExpandFilenameAndExecute("vsplit", "~/.vimrc.bundles")

        execute bufwinnr(".vimrc") . "wincmd w"
        call <SID>ExpandFilenameAndExecute("split", "~/.vimrc.local")
        wincmd l
        call <SID>ExpandFilenameAndExecute("split", "~/.vimrc.before.local")
        wincmd l
        call <SID>ExpandFilenameAndExecute("split", "~/.vimrc.bundles.local")

        if <SID>IsSpf13Fork()
            execute bufwinnr(".vimrc") . "wincmd w"
            call <SID>ExpandFilenameAndExecute("split", "~/.vimrc.fork")
            wincmd l
            call <SID>ExpandFilenameAndExecute("split", "~/.vimrc.before.fork")
            wincmd l
            call <SID>ExpandFilenameAndExecute("split", "~/.vimrc.bundles.fork")
        endif

        execute bufwinnr(".vimrc.local") . "wincmd w"
    endfunction

    execute "noremap " . s:spf13_edit_config_mapping " :call <SID>EditSpf13Config()<CR>"
    execute "noremap " . s:spf13_apply_config_mapping . " :source ~/.vimrc<CR>"
" }}}
