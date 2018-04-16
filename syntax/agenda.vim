
syn match AgendaToday    /^>[a-z0-9 ]*\a : /   display
syn match AgendaDay      /^\a[a-z0-9 ]*\a :/  display
syn match AgendaDayInfo     /\(^\s\{2}.*\|{ {{.*\|{{{.*\)/  display
hi def link AgendaToday Todo
hi def link AgendaDay   Identifier
"hi def link AgendaDayInfo CursorColumn
hi def link AgendaDayInfo Comment
