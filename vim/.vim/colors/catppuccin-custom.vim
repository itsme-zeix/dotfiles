" Vim color file
" Name: catppuccin-custom
" Base palette: Catppuccin Mocha
" Custom background: #212121

highlight clear

if exists("syntax_on")
  syntax reset
endif

set background=dark
let g:colors_name = "catppuccin-custom"

let s:bg = "#212121"
let s:bg_alt = "#2a2a2a"
let s:bg_highlight = "#343434"
let s:fg = "#cdd6f4"
let s:subtext1 = "#bac2de"
let s:subtext0 = "#a6adc8"
let s:overlay2 = "#9399b2"
let s:overlay1 = "#7f849c"
let s:overlay0 = "#6c7086"
let s:surface2 = "#585b70"
let s:surface1 = "#45475a"
let s:surface0 = "#313244"
let s:rosewater = "#f5e0dc"
let s:flamingo = "#f2cdcd"
let s:pink = "#f5c2e7"
let s:mauve = "#cba6f7"
let s:red = "#f38ba8"
let s:maroon = "#eba0ac"
let s:peach = "#fab387"
let s:yellow = "#f9e2af"
let s:green = "#a6e3a1"
let s:teal = "#94e2d5"
let s:sky = "#89dceb"
let s:sapphire = "#74c7ec"
let s:blue = "#89b4fa"
let s:lavender = "#b4befe"

function! s:h(group, fg, bg, attr, ctermfg, ctermbg) abort
  execute "highlight" a:group
        \ "guifg=" . a:fg
        \ "guibg=" . a:bg
        \ "gui=" . a:attr
        \ "ctermfg=" . a:ctermfg
        \ "ctermbg=" . a:ctermbg
        \ "cterm=" . a:attr
endfunction

" Editor
call s:h("Normal", s:fg, s:bg, "NONE", 189, 235)
call s:h("NormalNC", s:fg, s:bg, "NONE", 189, 235)
call s:h("ColorColumn", "NONE", s:bg_alt, "NONE", "NONE", 236)
call s:h("Conceal", s:overlay1, s:bg, "NONE", 103, 235)
call s:h("Cursor", s:bg, s:rosewater, "NONE", 235, 224)
call s:h("CursorColumn", "NONE", s:bg_alt, "NONE", "NONE", 236)
call s:h("CursorLine", "NONE", s:bg_alt, "NONE", "NONE", 236)
call s:h("Directory", s:blue, "NONE", "NONE", 111, "NONE")
call s:h("EndOfBuffer", s:bg, s:bg, "NONE", 235, 235)
call s:h("ErrorMsg", s:red, s:bg, "bold", 210, 235)
call s:h("FoldColumn", s:overlay0, s:bg, "NONE", 60, 235)
call s:h("Folded", s:blue, s:bg_alt, "NONE", 111, 236)
call s:h("LineNr", s:surface2, s:bg, "NONE", 59, 235)
call s:h("CursorLineNr", s:lavender, s:bg_alt, "bold", 147, 236)
call s:h("MatchParen", s:peach, s:surface1, "bold", 216, 238)
call s:h("ModeMsg", s:green, "NONE", "bold", 151, "NONE")
call s:h("MoreMsg", s:green, "NONE", "bold", 151, "NONE")
call s:h("NonText", s:surface2, "NONE", "NONE", 59, "NONE")
call s:h("Pmenu", s:fg, s:bg_alt, "NONE", 189, 236)
call s:h("PmenuSel", s:bg, s:blue, "bold", 235, 111)
call s:h("PmenuSbar", "NONE", s:surface0, "NONE", "NONE", 236)
call s:h("PmenuThumb", "NONE", s:overlay0, "NONE", "NONE", 60)
call s:h("Question", s:blue, "NONE", "bold", 111, "NONE")
call s:h("Search", s:bg, s:yellow, "NONE", 235, 222)
call s:h("IncSearch", s:bg, s:peach, "NONE", 235, 216)
call s:h("SignColumn", s:fg, s:bg, "NONE", 189, 235)
call s:h("SpecialKey", s:surface2, "NONE", "NONE", 59, "NONE")
call s:h("SpellBad", s:red, "NONE", "undercurl", 210, "NONE")
call s:h("SpellCap", s:yellow, "NONE", "undercurl", 222, "NONE")
call s:h("SpellLocal", s:blue, "NONE", "undercurl", 111, "NONE")
call s:h("SpellRare", s:mauve, "NONE", "undercurl", 183, "NONE")
call s:h("StatusLine", s:fg, s:bg_highlight, "NONE", 189, 237)
call s:h("StatusLineNC", s:overlay1, s:bg_alt, "NONE", 103, 236)
call s:h("TabLine", s:overlay1, s:bg_alt, "NONE", 103, 236)
call s:h("TabLineFill", "NONE", s:bg, "NONE", "NONE", 235)
call s:h("TabLineSel", s:green, s:bg_highlight, "bold", 151, 237)
call s:h("Title", s:blue, "NONE", "bold", 111, "NONE")
call s:h("VertSplit", s:surface1, s:bg, "NONE", 238, 235)
call s:h("Visual", "NONE", s:surface1, "NONE", "NONE", 238)
call s:h("WarningMsg", s:yellow, "NONE", "bold", 222, "NONE")
call s:h("WildMenu", s:bg, s:blue, "bold", 235, 111)

" Syntax
call s:h("Comment", s:overlay1, "NONE", "italic", 103, "NONE")
call s:h("Constant", s:peach, "NONE", "NONE", 216, "NONE")
call s:h("String", s:green, "NONE", "NONE", 151, "NONE")
call s:h("Character", s:teal, "NONE", "NONE", 115, "NONE")
call s:h("Number", s:peach, "NONE", "NONE", 216, "NONE")
call s:h("Boolean", s:peach, "NONE", "NONE", 216, "NONE")
call s:h("Float", s:peach, "NONE", "NONE", 216, "NONE")
call s:h("Identifier", s:flamingo, "NONE", "NONE", 224, "NONE")
call s:h("Function", s:blue, "NONE", "NONE", 111, "NONE")
call s:h("Statement", s:mauve, "NONE", "NONE", 183, "NONE")
call s:h("Conditional", s:mauve, "NONE", "NONE", 183, "NONE")
call s:h("Repeat", s:mauve, "NONE", "NONE", 183, "NONE")
call s:h("Label", s:mauve, "NONE", "NONE", 183, "NONE")
call s:h("Operator", s:sky, "NONE", "NONE", 117, "NONE")
call s:h("Keyword", s:mauve, "NONE", "NONE", 183, "NONE")
call s:h("Exception", s:mauve, "NONE", "NONE", 183, "NONE")
call s:h("PreProc", s:pink, "NONE", "NONE", 218, "NONE")
call s:h("Include", s:pink, "NONE", "NONE", 218, "NONE")
call s:h("Define", s:pink, "NONE", "NONE", 218, "NONE")
call s:h("Macro", s:pink, "NONE", "NONE", 218, "NONE")
call s:h("PreCondit", s:pink, "NONE", "NONE", 218, "NONE")
call s:h("Type", s:yellow, "NONE", "NONE", 222, "NONE")
call s:h("StorageClass", s:yellow, "NONE", "NONE", 222, "NONE")
call s:h("Structure", s:yellow, "NONE", "NONE", 222, "NONE")
call s:h("Typedef", s:yellow, "NONE", "NONE", 222, "NONE")
call s:h("Special", s:rosewater, "NONE", "NONE", 224, "NONE")
call s:h("SpecialChar", s:rosewater, "NONE", "NONE", 224, "NONE")
call s:h("Tag", s:mauve, "NONE", "NONE", 183, "NONE")
call s:h("Delimiter", s:subtext0, "NONE", "NONE", 146, "NONE")
call s:h("SpecialComment", s:overlay2, "NONE", "italic", 103, "NONE")
call s:h("Debug", s:red, "NONE", "NONE", 210, "NONE")
call s:h("Underlined", s:blue, "NONE", "underline", 111, "NONE")
call s:h("Ignore", s:overlay0, "NONE", "NONE", 60, "NONE")
call s:h("Error", s:red, s:bg_alt, "bold", 210, 236)
call s:h("Todo", s:bg, s:yellow, "bold", 235, 222)

" Diffs
call s:h("DiffAdd", s:green, s:bg_alt, "NONE", 151, 236)
call s:h("DiffChange", s:yellow, s:bg_alt, "NONE", 222, 236)
call s:h("DiffDelete", s:red, s:bg_alt, "NONE", 210, 236)
call s:h("DiffText", s:blue, s:bg_highlight, "bold", 111, 237)

" Common plugin groups
call s:h("GitGutterAdd", s:green, s:bg, "NONE", 151, 235)
call s:h("GitGutterChange", s:yellow, s:bg, "NONE", 222, 235)
call s:h("GitGutterDelete", s:red, s:bg, "NONE", 210, 235)
call s:h("airline_a", s:bg, s:blue, "bold", 235, 111)
call s:h("airline_b", s:fg, s:bg_highlight, "NONE", 189, 237)
call s:h("airline_c", s:overlay1, s:bg_alt, "NONE", 103, 236)

if has("nvim")
  let g:terminal_color_0 = s:bg
  let g:terminal_color_1 = s:red
  let g:terminal_color_2 = s:green
  let g:terminal_color_3 = s:yellow
  let g:terminal_color_4 = s:blue
  let g:terminal_color_5 = s:mauve
  let g:terminal_color_6 = s:teal
  let g:terminal_color_7 = s:subtext1
  let g:terminal_color_8 = s:surface2
  let g:terminal_color_9 = s:red
  let g:terminal_color_10 = s:green
  let g:terminal_color_11 = s:yellow
  let g:terminal_color_12 = s:blue
  let g:terminal_color_13 = s:mauve
  let g:terminal_color_14 = s:teal
  let g:terminal_color_15 = s:fg
else
  let g:terminal_ansi_colors = [
        \ s:bg, s:red, s:green, s:yellow,
        \ s:blue, s:mauve, s:teal, s:subtext1,
        \ s:surface2, s:red, s:green, s:yellow,
        \ s:blue, s:mauve, s:teal, s:fg
        \]
endif
