;+
; $Id: display.pro,v 1.2 2002/10/30 16:35:37 jpmorgen Exp $

; display puts up a window with an image in it.  reuse uses a window
; of the same size and title, if it exists.  Specifying a filename is
; OK: the filename will be used as the title.  zoom and rotate are
; pretty self explanatory (rotate is obselete), crx does a
; preliminary cosmic ray cleaning for display purposes only

;-
COMMON display_vars, wstack, wnull

; Remove any windows the user deleted
pro refresh_wstack
  COMMON display_vars
  if N_elements(wstack) eq 0 then begin
     wstack = bytarr(100)            ; Hopefully that is enough windows
     wnull = 0
  endif
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

pro display, im, hdr, title=title, REUSE=reuse, zoom=zoom, rotate=rotate, crx=crx
  COMMON display_vars

  ON_ERROR, 2
  if N_elements(im) eq 0 then message, 'ERROR: no filename or image supplied'
  if size(im, /TNAME) eq 'STRING' then im=readfits(im, hdr)

  if N_elements(size(im, /DIMENSIONS)) ne 2 then message, 'ERROR: specify a 2D array to display.  Try im=ssgread(<arg>, /TV)'

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

  ;; Allow window manager titles to change
  if w ne wnull then begin
     if keyword_set(title) then begin
        wdelete, w
        window,xsize=nx,ysize=ny,title=title,/free
     ;; Unless we aren't specifying a title
     endif else $
       wshow, w
  endif else begin
     window,xsize=nx,ysize=ny,title=title,/free
     push, !D.WINDOW, wstack, null=wnull
  endelse

  ;; Get rid of cosmic ray hits
  if keyword_set(crx) then begin
     badim = mark_cr(dim)
     badidx = where(badim gt 0, count)
     if count gt 0 then $
       dim[badidx] = !values.f_nan
  endif

  tvscl, dim, /NAN
  return
end

