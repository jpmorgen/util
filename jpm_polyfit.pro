; $Id: jpm_polyfit.pro,v 1.1 2002/11/22 19:46:22 jpmorgen Exp $

; jpm_Polyfit.  Does an interactive polynomail fitting in two variables


function jpm_polyfit, x, y, order, title=title, noninteractive=noninteractive, window=winnum, xtitle=xtitle, ytitle=ytitle, xtickunits=xtickunits

  if NOT keyword_set(order) then order=0
  if NOT keyword_set(winnum) then winnum=7

  plus = 1
  asterisk = 2
  dot = 3
  diamond = 4
  triangle = 5
  square = 6
  psym_x = 7

  solid=0
  dotted=1
  dashed=2
  dash_dot=3
  dash_3dot = 4
  long_dash=5


  repeat begin
     good_idx = where(finite(y) eq 1)
     coefs = poly_fit(x[good_idx], y[good_idx], order)
     if keyword_set(noninteractive) then return, coefs
  

     refit = 1
     fity = fltarr(N_elements(y))
     window,winnum

     for ci=0,order do begin
        fity = fity + coefs[ci]*(x)^ci
     endfor
     
     plot, x, y, $
           title=title, $
           xtickunits=xtickunits, $
           xrange=[min(x, /NAN), $
                   max(x, /NAN)], $
           yrange=[min(y, /NAN), $
                   max(y, /NAN)], $
           xstyle=2, ystyle=2, psym=plus, $
           xtitle=xtitle, $
           ytitle=ytitle
     oplot, x, fity

     ;; User selects a bad point
     message, /CONTINUE, 'Select bad points with leftmost mouse button, rightmost button exits'
     cursor, badx, bady, /DOWN, /DATA
     if !MOUSE.button eq 1 then begin
        dxs = x - badx
        dys = y - bady
        dists = dxs*dxs + dys*dys
        junk = min(dists, bad_idx, /NAN)
        y[bad_idx] = !values.f_nan
     endif ;; leftmost mouse button
     if !MOUSE.button eq 2 then begin
        message, /CONTINUE, 'HEY, I said left or right buttons, not middle!'
     endif
     if !MOUSE.button eq 4 then begin
        message, /CONTINUE, 'DONE'
        refit = 0
     endif
  endrep until refit eq 0


return, coefs

end
