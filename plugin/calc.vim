
function! DoCalc(n)
  let l:l=getline(a:n)
  let l:resw='calc:'
  let l:reswvar='var:'
  let l:reswvaralt='v:'
  let l:pos=match(l:l,l:resw)
  if l:pos > -1
    let l:pos+=len(l:resw)
    let l:cureq=match(l:l,'=',l:pos)
    while ((l:cureq > -1) && (strpart(l:l,l:cureq+1,1) == "="))
      let l:cureq=match(l:l,'=',l:cureq+2)
    endwhile
    if l:cureq > -1
      let l:varend=match(l:l,'\%([;_]\|$\)', l:cureq+1)
      if l:varend > - 1
        let l:calc=substitute(strpart(l:l,l:pos,l:cureq-l:pos),l:reswvar,'b:int','g')
        let l:calc=substitute(l:calc,l:reswvaralt,'b:int','g')
"        let l:calc=substitute(l:calc,'\d\+[.]\d\+','\="'."'".'".submatch(0)."'."'".'"','g')
        if l:calc=~'\d\+[.]\d\+'
          let l:calc="".l:calc
        endif
        let l:calc=eval(l:calc)
        if type(l:calc) == type(0.0)
          let l:calc=printf('%.2f',l:calc)
        endif
        let l:l=strpart(l:l,0,l:cureq+1).' '.l:calc.strpart(l:l,l:varend)
        call setline(a:n,l:l)
      endif
    endif
  else
    let l:pos=match(l:l,l:reswvar)
    if l:pos > -1
      let l:pos+=len(l:reswvar)
      " get the next space
      let l:cureq=match(l:l,'=',l:pos)
      if l:cureq > -1
        let l:varend=match(l:l,'\%([;%=|_]\|  \|$\)',l:cureq+1)
        while ((l:varend > -1) && (strpart(l:l,l:varend+1,1) == "="))
          let l:varend=match(l:l,'\%([;%=|_]\|  \|$\)',l:varend+2)
        endwhile
        if l:varend > - 1
          let l:var=strpart(l:l,l:pos,l:cureq-l:pos)
          let l:calc=substitute(strpart(l:l,l:cureq+1,l:varend-1-l:cureq),l:reswvar,'b:int','g')
          "          echo l:l
          let l:calc=substitute(l:calc,l:reswvaralt,'b:int','g')
          "          let l:calc=substitute(l:calc,'\d\+[.]\d\+','\="'."'".'".submatch(0)."'."'".'"','g')
          if l:calc=~'\d\+[.]\d\+'
            let l:calc="".l:calc
          endif
          let l:calc=eval(l:calc)
          if type(l:calc) == type(0.0)
            let l:calc=printf('%.2f',l:calc)
          endif
          exe "let b:int".l:var.'='.l:calc
          if strpart(l:l,l:varend,1)== "="
            let l:cureq=l:varend
            let l:varend=match(l:l,'\%([;_]\|$\)', l:cureq+1)
            let l:l=strpart(l:l,0,l:cureq+1).' '.l:calc.strpart(l:l,l:varend)
            call setline(a:n,l:l)
          endif
        endif
      endif
    endif
  endif
endfu
" var:a = (3.14359)
" var:b = 1+var:a
" var:b = 1+var:a = 4.14_
" calc:1+var:a= 4.14_
" calc:var:b*(1==1)= 4.14_
" var:c=v:b*(1==1)= 4.14_
" calc:2.5*3= 7.50_
function! CalcUpdate()
  for l:i in range(1,line('$'))
    call DoCalc(l:i)
  endfor
endfunction

command! CalcUpdate call CalcUpdate()
cabbr calc CalcUpdate

