"Examples:
"Pxl{0123456789ABCDEF} 
"agenda{
"lundi 26 févr. : 
"}
"gui color : [term color, char]
let s:cpo_save = &cpo
set cpo&vim

syn include @pxlIncl syntax/pxlcolors.vim
syn match PixelArtDelim "pxl{\|}" contained
hi def link PixelArtDelim		Ignore
syn region PxlTop start=+^pxl{+ end=+^}+ contains=PixelArtDelim,@pxlIncl keepend extend
syn region PxlTop start=+^{{{pxl:+ end=+^}}}+ contains=PixelArtDelim,@pxlIncl keepend extend

syn include @agendaIncl syntax/agenda.vim
syn match AgendaDelim "agenda{\|}" contained
hi def link AgendaDelim		Comment
syn region AgendaTop matchgroup=Todo start=+^agenda{+ end=+^}+ skip=+}}}+ contains=@agendaIncl keepend extend

let &cpo = s:cpo_save
unlet s:cpo_save
