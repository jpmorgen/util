; $Id: display.pro,v 1.1 2002/09/05 17:20:09 jpmorgen Exp $

; display puts up a window with an image in it.

COMMON display_vars, wstack, wnull

; Remove any windows the user deleted
pro refresh_wstack
  COMMON display_vars
  tstack = wstack
  tstack[*] = wnull
  while wstack[0] ne wnull do begin
     CATCH, err
     if NOT err then begin
        wset, pop(wstack, null=wnull)
        push, !D.WINDOW, tstack, null=wnull
     endif
  endwhile
  while tstack[0] ne wnull do push, pop(tstack, null=wnull), wstack, null=wnull
  return
end

pro display, im, title, REUSE=reuse, zoom=zoom, rotate=rotate
  COMMON display_vars

  if NOT keyword_set(zoom) then zoom=1.
  
  asize = size(im) & nx = asize(1) & ny = asize(2)
  dim = congrid(im, nx*zoom, ny*zoom)
  if keyword_set(rotate) then dim = rotate(dim, rotate)
  asize = size(dim) & nx = asize(1) & ny = asize(2)

  refresh_wstack
  w = wnull
  if keyword_set(reuse) and (wstack[0] ne wnull) then begin
     tstack = wstack
     w = wnull
     REPEAT BEGIN 
        wset, pop(tstack, null=wnull)
        if (!D.X_SIZE eq nx) and (!D.Y_SIZE eq ny) then w = !D.WINDOW
     endrep UNTIL (tstack[0] eq wnull) OR (w ne wnull)
  endif
  if w ne wnull then wshow, w $
  else begin
     window,xsize=nx,ysize=ny,title=title,/free
     push, !D.WINDOW, wstack, null=wnull
  endelse

  tvscl, dim
  return
end

wstack = bytarr(100)            ; Hopefully that is enough windows
wnull = 0
end
