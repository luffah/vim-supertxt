
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
  let l:line_later = []
  let l:days = []
  let l:agendas = []
  let l:max = len(s:days)
  if bufname('%') =~ '\.agenda$'
    call add(l:agendas , [[],[],0])
    let l:closetag = 0
  else
    let l:closetag = 1
  endif
  let l:open = !l:closetag
  let l:i = 1 | while l:i <= line('$')
    let l:l = getline(l:i)
    if l:open
      if l:closetag && l:l =~ '^}$'
        let l:open = 0
      else
        " do calendar thing
        if ( !len(l:l) || l:l =~ '^\s\{2}') " jump over empty and tabbed lines
          " do nothing
        else
          if l:l =~ '^>' " unmark any line
            let l:l=l:l[1:]
            cal setline(l:i,l:l)
          endif
          for l:d in range(len(s:days))
            let l:day = s:days[l:d]
            if l:l =~ '^>\?'.l:day
              if match(l:agendas[-1][0], l:d) == -1
                call add(l:agendas[-1][0], l:d)
                call add(l:agendas[-1][1], [l:l, l:i, l:d])
              endif
              break
            endif
          endfor
        endif
      endif
    elseif l:closetag && l:l =~ '^agenda{$' "open tag
      let l:open = 1
      let l:founddays = []
      call add(l:agendas , [[],[],l:i])
    endif
    let i+=1
  endwhile
  let l:curday=0
  let l:dec=0
  for [l:founddays, l:agenda, l:ai]  in l:agendas
    if empty(l:founddays)
      for l:d in s:days " add all days
        call append(l:ai+l:dec, l:d . ' : ')
        let l:dec+=1
      endfor
    else
      let l:foundday=0
      for [l:l, l:i, l:day]  in l:agenda
        if l:day == 0
          " mark today
          let l:foundday+=1
          cal setline(l:i+l:dec,'>' . substitute(l:l, '{{{', '{ {{', ''))
        elseif l:foundday==l:day
          let l:foundday+=1
          " days had been founds in order
        else
          " today has not been found
          let l:idec = -1
          while (l:day + l:idec > 0) && (match(l:founddays,l:day + l:idec) == -1)
            let l:dec+=1
            call append(l:i-1, s:days[ l:day + l:idec ] . ' : {{{ }}}')
            let l:idec-=1
          endwhile
          if (l:day + l:idec == 0) && (match(l:founddays,l:day + l:idec) == -1)
            let l:dec+=1
            call append(l:i-1, '>'.s:days[ l:day + l:idec ] . ' : { {{ }}}')
            let l:idec-=1
          endif
          let l:foundday=l:day+1
        endif
        let l:idec = 1
        while (l:day + l:idec < len(s:days)) && (match(l:founddays,l:day + l:idec) == -1)
          let l:dec+=1
          call append(l:i+l:dec-1, s:days[ l:day + l:idec ] . ' : {{{ }}}')
          let l:idec+=1
          let l:foundday+=1
        endwhile
      endfor
    endif
  endfor
  exe "w"
endfu

"command! UpdateCal call <SID>UpdateCal()
let g:supertxt_filetypes=get(g:,'supertxt_filetypes',['zim','text','agenda'])
augroup SuperTxt
  for ft in g:supertxt_filetypes
    exe 'au Filetype '.ft.' silent! call <SID>UpdateCal()'
  endfor
augroup END

