; $Id: jpm_polyfit.pro,v 1.3 2002/12/16 18:26:57 jpmorgen Exp $

; jpm_Polyfit.  Does an interactive polynomail fitting in two variables


function jpm_polyfit, x, y, order, title=title, noninteractive=noninteractive, window=winnum, xtitle=xtitle, ytitle=ytitle, xtickunits=xtickunits, measure_errors=measure_errors

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

  window,winnum

  repeat begin
     good_idx = where(finite(y) eq 1 and finite(x) eq 1, count)
     if count eq 0 then begin
         message, /CONTINUE, 'All points deleted, returning 0'
         return, 0
     endif
     coefs = poly_fit(x[good_idx], y[good_idx], order, $
                      measure_errors=measure_errors)
     if keyword_set(noninteractive) then return, coefs
  

     refit = 1
     fity = fltarr(N_elements(y))
     wset, winnum

     for ci=0,order do begin
        fity = fity + coefs[ci]*(x)^ci
     endfor
     
     plot, x, y, $
           title=title, $
           xtickunits=xtickunits, $
           xrange=[min(x[good_idx], /NAN), $
                   max(x[good_idx], /NAN)], $
           yrange=[min(y[good_idx], /NAN), $
                   max(y[good_idx], /NAN)], $
           xstyle=2, ystyle=2, psym=plus, $
           xtitle=xtitle, $
           ytitle=ytitle
     oplot, x, fity
     if keyword_set(measure_errors) then $
       oploterr, x[good_idx], y[good_idx], measure_errors

     message, /CONTINUE, 'Fit coefficients'
     print, coefs

     ;; User selects a bad region which may or may not include any
     ;; points
     message, /CONTINUE, 'Select bad points with leftmost mouse button (drag works, but no box is drawn yet--sorry), middle button changes the polynomial order, rightmost button exits'
     cursor, x1, y1, /DOWN, /DATA
     cursor, x2, y2, /UP, /DATA
     ;; Get the corners straight
     if x1 gt x2 then begin
        temp = x1 & x1 = x2 & x2 = temp
     endif
     if y1 gt y2 then begin
        temp = y1 & y1 = y2 & y2 = temp
     endif
     if !MOUSE.button eq 1 then begin
        bad_idx = where(x1 lt x and x lt x2 and $
                        y1 lt y and y lt y2, $
                        count)
        if count eq 0 then begin
           dxs = x - x1
           dys = y - y1
           dists = dxs*dxs + dys*dys
           junk = min(dists, bad_idx, /NAN)
        endif
        y[bad_idx] = !values.f_nan
     endif ;; leftmost mouse button
     if !MOUSE.button eq 2 then begin
        order = order + 1
        repeat begin
           message, /CONTINUE, 'Enter new order [' + string(order) + ']'
           answer = get_kbrd(1)
        endrep until (byte(answer) ge 48 and byte(answer) le 57) $
          or  byte(answer) eq 10
        if byte(answer) ne 10 then order = fix(answer)
     endif
     if !MOUSE.button eq 4 then begin
        message, /CONTINUE, 'DONE'
        refit = 0
     endif
  endrep until refit eq 0


return, coefs

end
