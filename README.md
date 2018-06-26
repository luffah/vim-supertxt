<a rel="license" href="https://creativecommons.org/licenses/by-sa/4.0/">
<img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png"></a>
<a rel="license" href="./LICENSE"><img src="https://www.gnu.org/graphics/gplv3-88x31.png" alt="License GPLv3"></a>

# Addons for your .txt notebooks
[![agenda](./agenda-clip.gif)
(Note: `__Highlight__` format is no longer used to highlight today.)

# Options
```vim
" default settings are made compatible with zimwiki format
let g:agenda_nbdays=15
let g:agenda_hi={'today': 'diffAdd', 'past': 'diffRemoved'}
let g:agenda_checkbox={
      \ 'today': '[>] ',
      \ 'past': '[x] ',
      \ 'future': '[ ] ',
      \ 'match_day_prefix' : '^\(\[.\] \)\?',
      \ 'content_sign': ' : '}
" let g:agenda_tag_delimiter=['^agenda{$','^}$']
let g:agenda_tag_delimiter=['^{{{agenda:$','^}}}$']
```

This addon add features in text and zimwiki files (See [zim](../vim-zim)) :
* Agenda 
* Pixel art samples (requires .pxlcolors syntax file. See [superpxl](../superpxl) )
