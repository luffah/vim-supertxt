let g:agenda_nbdays=get(g:,'agenda_nbdays',15)
let g:agenda_hi=get(g:,'agenda_hi',{'today': 'diffAdd', 'past': 'diffRemoved'})
let g:agenda_checkbox=get(g:,'agenda_checkbox',{
      \ 'today': '[>] ',
      \ 'past': '[x] ',
      \ 'future': '[ ] ',
      \ 'match_day_prefix' : '^\(\[.\] \)\?',
      \ 'content_sign': ' : '})
let g:agenda_tag_delimiter=get(g:,'agenda_tag_delimiter', ['^{{{agenda:$','^}}}$'])

fu! s:getrelday(a)
 return strftime("%A %d %b",localtime()+(86400 *a:a))
endfu

let s:days=[] " containing the next days
for s:i in range(g:agenda_nbdays)
  call add(s:days, s:getrelday(s:i))
endfor

" add days as if the day_idx is today
fu! s:auto_extend_from(day_idx)
  call clearmatches()
  if g:agenda_nbdays > len(s:days)
    for i in range(len(s:days),g:agenda_nbdays)
      call add(s:days, s:getrelday(i))
    endfor
  endif
  for l:i in reverse(range(a:day_idx)) 
    call add(s:days, s:getrelday(g:agenda_nbdays-l:i))
  endfor
  call matchadd(g:agenda_hi['today'],s:getrelday(0).'\c')
  for s:i in range(1,g:agenda_nbdays)
    call matchadd(g:agenda_hi['past'],s:getrelday(-s:i).'\c')
  endfor
endfu

" return index in s:days for today
fu! s:get_today_idx()
  let l:today=s:getrelday(0)
  let l:ret=index(s:days,l:today)
  return l:ret
endfu

" return a list of [founddays, agenda, firstline, lastlinenumber]
" (a text can contain many agendas)
" founddays contains index of days founds in text
" agenda contains a a list of [line, linenumber,dayindex]
" firstlineidx is the first line of the agenda
fu! s:find_agendas_in_lines()  
  let l:agendas = []
  if bufname('%') =~ '\.agenda$'
    call add(l:agendas , [[],[],0,line('$')])
    let l:embedded = 0
  else
    let l:embedded = 1
  endif
  let l:open = !l:embedded
  let l:prefix_re=g:agenda_checkbox['match_day_prefix']
  let l:day_idxs=range(len(s:days))
  for l:i in range(1,line('$'))
    let l:l = getline(l:i)
    if l:open
      if l:embedded && l:l =~ g:agenda_tag_delimiter[1] " close tag
        let l:open = 0
      else
        " do calendar thing
        if ( !len(l:l) || l:l =~ '^\(\s\{2}\|}}}\)' ) " jump over empty and tabbed lines
          " do nothing
          if l:i == l:agendas[-1][3]
            let l:agendas[-1][3]=l:i
          endif
        else
          for l:d in l:day_idxs
            let l:day = s:days[l:d]
            if l:l =~ l:prefix_re.l:day
              if index(l:agendas[-1][0], l:d) == -1
                call add(l:agendas[-1][0], l:d)
                call add(l:agendas[-1][1], [l:l, l:i, l:d])
                let l:agendas[-1][3]=l:i
              endif
              break
            endif
          endfor
        endif
      endif
    elseif l:embedded && l:l =~ g:agenda_tag_delimiter[0] "open tag
      let l:open = 1
      let l:founddays = []
      call add(l:agendas , [[],[],l:i,l:i])
    endif
  endfor
  return l:agendas
endfu

fu! s:UpdateCal()
  let l:today_idx=s:get_today_idx()
  call s:auto_extend_from(l:today_idx)
  let l:line_later = []
  let l:days = []
  let l:agendas = s:find_agendas_in_lines()
  let l:future_cb=g:agenda_checkbox['future']
  let l:future_re='^'.escape(g:agenda_checkbox['future'],'[]^\/')
  let l:today_cb=g:agenda_checkbox['today']
  let l:past_cb=g:agenda_checkbox['past']
  let l:content_sign=g:agenda_checkbox['content_sign']
  let l:dec=0 " the line offset of added days
  for [l:founddays, l:agenda, l:firstline, l:lastline]  in l:agendas
    if empty(l:founddays)
      for l:d in s:days " add all days
        call append(l:lastline+l:dec,
              \ (l:d>l:today_idx? l:future_cb : l:past_cb) . l:d . l:content_sign)
        let l:dec+=1
      endfor
    else
      let l:foundday=0
      let l:nbagenda = len(l:agenda) 
      for l:agendaidx in range(l:nbagenda)
        let [l:l, l:i, l:day] = l:agenda[l:agendaidx]
        if l:day <= l:today_idx
          " mark today
          cal setline(l:i+l:dec, substitute(l:l,l:future_re,l:today_cb,''))
        elseif l:foundday==l:day
          " another expected day is found
        else
          " day is not been found in expected order
          let l:newday = l:day-1
          while (l:newday > 0) && (index(l:founddays, l:newday) == -1)
            let l:dec+=1
            call append(l:i-1, l:past_cb . s:days[ l:newday ] . l:content_sign)
            let l:newday-=1
          endwhile
          if (l:newday == l:today_idx) && (index(l:founddays, l:newday) == -1)
            let l:dec+=1
            call append(l:i-1, l:today_cb . s:days[ l:newday ] . l:content_sign)
          endif
          let l:foundday=l:day
        endif
        let l:newday = l:day + 1
        let l:ilast = ( (l:agendaidx == l:nbagenda - 1) ? 
              \ l:lastline : ( l:agenda[l:agendaidx+1][1] - 1 ) ) 
        while (l:newday < len(s:days))
              \ && (index(l:founddays,l:newday) == -1)
          let l:dec+=1
          call append(l:ilast+l:dec-1, l:future_cb . s:days[ l:newday ] . l:content_sign)
          let l:newday+=1
          let l:foundday+=1
        endwhile
        let l:foundday+=1
      endfor
    endif
  endfor
  exe "w"
endfu

command! UpdateCal call <SID>UpdateCal()
let g:supertxt_filetypes=get(g:,'supertxt_filetypes',['zim','text','agenda'])
augroup SuperTxt
  au!
  for ft in g:supertxt_filetypes
    exe 'au Filetype '.ft.' silent! call <SID>UpdateCal()'
  endfor
augroup END

