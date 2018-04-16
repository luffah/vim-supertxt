
fu! s:getrelday(a)
 return strftime("%A %d %b",localtime()+(86400 *a:a))
endfu

let s:days=[] " containing the next days
for i in range(0,8)
  call add(s:days, s:getrelday(i))
endfor

fu! ExtendCal(a)
  for i in range(len(s:days),a:a)
    call add(s:days, s:getrelday(i))
  endfor
  call s:UpdateCal()
endfu

fu! s:UpdateCal()
  let l:max = len(s:days)
  let l:open = (bufname('%') =~ '\.agenda$' ? 1 : 0)
  let l:closetag = !l:open
  let i = 1
  let l:foundday = 0
  let l:line_later = []
  let l:days = []
  let l:agendas = []
  " todo : viewed days in a store and after determine where to start instead
  " of starting at end
  while i <= line('$')
    let l:l = getline(i)
    if l:open
      if l:closetag && l:l =~ '^}$'
        if ! l:foundday
          for d in s:days " add all days
            call append(i-1, d . ' : ')
            let i=i+1
          endfor 
        endif
        let l:open = 0
      else
        " do calendar thing
        if l:l =~ '^>' " unmark any line
          let l:l=l:l[1:]
          cal setline(i,l:l)
        endif
        if ( !len(l:l) || l:l =~ '^\s\{2}') " jump over empty and tabbed lines
          " do nothing
        elseif !l:foundday && l:l =~ '^'.s:days[0] " mark today
          cal setline(i,'>' . substitute(l:l, '{{{', '{ {{', ''))
          let l:foundday=1
        elseif l:foundday && l:foundday < l:max
          if l:l =~ '^'.s:days[l:foundday]
            let l:foundday+=1
          else 
            call append(i-1, s:days[ l:foundday ] . ' : {{{ }}}')
            let l:foundday+=1
          endif
        endif
      endif
    elseif l:l =~ '^agenda{$' "open tag
      let l:open = 1
      let l:foundday = 0
      call add(l:agendas , [])
    endif
    let i+=1
  endwhile
  exe "w"
endfu

fu! UpdateCal()
  let l:max = len(s:days)
  let l:open = (bufname('%') =~ '\.agenda$' ? 1 : 0)
  let l:closetag = !l:open
  let i = 1
  let l:foundday = 0
  let l:line_later = []
  let l:days = []
  let l:agendas = []
  " todo : viewed days in a store and after determine where to start instead
  " of starting at end
  while i <= line('$')
    let l:l = getline(i)
    if l:open
      if l:closetag && l:l =~ '^}$'
        if ! l:foundday
          for d in s:days " add all days
            call append(i-1, d . ' : ')
            let i=i+1
          endfor 
        endif
        let l:open = 0
      else
        " do calendar thing
        if l:l =~ '^>' " unmark any line
          let l:l=l:l[1:]
          cal setline(i,l:l)
        endif
        if ( !len(l:l) || l:l =~ '^\s\{2}') " jump over empty and tabbed lines
          " do nothing
        elseif !l:foundday && l:l =~ '^'.s:days[0] " mark today
          cal setline(i,'>' . substitute(l:l, '{{{', '{ {{', ''))
          let l:foundday=1
        elseif l:foundday && l:foundday < l:max
          if l:l =~ '^'.s:days[l:foundday]
            let l:foundday+=1
          else 
            call append(i-1, s:days[ l:foundday ] . ' : {{{ }}}')
            let l:foundday+=1
          endif
        endif
      endif
    elseif l:l =~ '^agenda{$' "open tag
      let l:open = 1
      let l:foundday = 0
      call add(l:agendas , [])
    endif
    let i+=1
  endwhile
  exe "w"
endfu
let g:supertxt_filetypes=get(g:,'supertxt_filetypes',['zim','text','agenda'])
augroup SuperTxt
  for ft in g:supertxt_filetypes
    exe 'au Filetype '.ft.' silent! call <SID>UpdateCal()'
  endfor
augroup END

