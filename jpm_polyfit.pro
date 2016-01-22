; $Id: jpm_polyfit.pro,v 1.6 2003/06/19 21:48:16 jpmorgen Exp $

; jpm_Polyfit.  Does an interactive polynomail fitting in two
; variables.  BEWARE, y is set to NAN if a point is marked for not
; fitting.  Make sure you save the input y values in the calling
; routine if you need to.


function jpm_polyfit, x, y, order, bad_idx=bad_idx, title=title, noninteractive=noninteractive, window=winnum, xtitle=xtitle, ytitle=ytitle, xtickunits=xtickunits, measure_errors=measure_errors, MJD=MJD

  if NOT keyword_set(order) then order=0
  if NOT keyword_set(winnum) then winnum=7
  nx = N_elements(x)
  if nx ne N_elements(y) then $
    message, 'ERROR: X and Y must have the same number of elements'

  y_save = y
  bad_stack = intarr(nx)
  bad_stack[*] = -1

  ;; bad_idx is, for instance, the set of point not used in the last
  ;; fit.  See calling routines.
  if keyword_set(bad_idx) then begin
     if bad_idx[0] ne -1 then begin
        y[bad_idx] = !values.f_nan
        for i=0,N_elements(bad_idx)-1 do begin
           push, bad_idx[i], bad_stack, null=-1
        endfor
     endif
  endif

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


  if NOT keyword_set(noninteractive) then $
    window,winnum

  ;; Ndays are referenced to modified Julian day.  IDL plotting
  ;; routines are referenced to JD, so there needs to be an offset in
  ;; the displayed values, but not in the calulated values.
  plotx = x
  if keyword_set(MJD) then $
    plotx = x-0.5

  repeat begin
     good_idx = where(finite(y) eq 1 and finite(x) eq 1, count)
     if count eq 0 then begin
         message, /CONTINUE, 'All points deleted, returning 0'
         return, 0
     endif
     if keyword_set(measure_errors) then begin
        good_idx = where(finite(y) eq 1 and finite(x) eq 1 and $
                         finite(measure_errors) eq 1 and $
                         measure_errors ne 0, count)
        ;; Fitting a 0th order polynomial in the non-interactive case
        ;; amounts to taking the average.  Generally it is better to take
        ;; the median in this case
        if keyword_set(noninteractive) and order eq 0 then $
           return, median(y[good_idx]) 
       coefs = poly_fit(x[good_idx], y[good_idx], order, $
                        measure_errors=abs(measure_errors[good_idx]))
     endif else begin
        if keyword_set(noninteractive) and order eq 0 then $
           return, median(y[good_idx])
        coefs = poly_fit(x[good_idx], y[good_idx], order)
     endelse

     if keyword_set(noninteractive) then return, coefs
  
     refit = 1
     wset, winnum

     fity = fltarr(N_elements(y))
     for ci=0,order do begin
        fity = fity + coefs[ci]*(x)^ci
     endfor

     ;; Blank out bad measuremets.  This is a little complicated if
     ;; you don't have error bars, but this fakes it.
     bad_meas_count = 0
     good_meas_idx = indgen(N_elements(good_idx))
     if keyword_set(measure_errors) then begin
        bad_meas_idx = where(measure_errors[good_idx] le 0, bad_meas_count, $
                             complement=good_meas_idx)
     endif

     plot, plotx[good_idx[good_meas_idx]], y[good_idx[good_meas_idx]], $
           title=title, $
           xtickunits=xtickunits, $
           xrange=[min(plotx[good_idx], /NAN), $
                   max(plotx[good_idx], /NAN)], $
           yrange=[min(y[good_idx], /NAN), $
                   max(y[good_idx], /NAN)], $
           xstyle=2, ystyle=2, psym=psym_x, $
           xtitle=xtitle, $
           ytitle=ytitle
     if bad_meas_count gt 0 then begin
        oplot, plotx[good_idx[bad_meas_idx]], y[good_idx[bad_meas_idx]], $
               psym=square
        al_legend, ['Good measurement, not replaced by poly fit', 'Bad measurement, replaced by poly fit'], psym=[psym_x, square], pos=pos, /norm
     endif
     oplot, plotx, fity
     if keyword_set(measure_errors) then $
       oploterr, plotx[good_idx], y[good_idx], measure_errors[good_idx]



     message, /CONTINUE, 'Fit coefficients'
     print, coefs

     ;; User selects a bad region which may or may not include any
     ;; points
     message, /CONTINUE, 'Select bad points with leftmost mouse button (drag works, but no box is drawn yet--sorry), middle button brings up menu, rightmost button resurrects last deleted point'
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
        bad_idx = where(x1 lt plotx and plotx lt x2 and $
                        y1 lt y and y lt y2, $
                        count)
        if count eq 0 then begin
           dxs = plotx - x1
           dys = y - y1
           dists = dxs*dxs + dys*dys
           junk = min(dists, bad_idx, /NAN)
        endif
        y[bad_idx] = !values.f_nan
        for i=0,N_elements(bad_idx)-1 do begin
           push, bad_idx[i], bad_stack, null=-1
        endfor
     endif ;; leftmost mouse button
     if !MOUSE.button eq 2 then begin
        message, /CONTINUE, 'Menu:'
        print, 'Quit/eXit, saving polynomical fit (permanent write can be avoided later)'
        print, 'do nothing--return to Fitting'
        print, 'change Order'
        print, 'resurect All points'
        answer = ''
        for ki = 0,1000 do flush_input = get_kbrd(0)
        repeat begin
           message, /CONTINUE, '[Q/X], F, O, A?'
           answer = get_kbrd(1)
           if byte(answer) eq 10 then answer = 'Q'
           for ki = 0,1000 do flush_input = get_kbrd(0)
           answer = strupcase(answer)
        endrep until $
          answer eq 'Q' or $
          answer eq 'X' or $
          answer eq 'F' or $
          answer eq 'O' or $
          answer eq 'A'

        if answer eq 'O' then begin
           order = order + 1
           for ki = 0,1000 do flush_input = get_kbrd(0)
           repeat begin
              message, /CONTINUE, 'Enter new order [' + string(order) + ']'
              answer = get_kbrd(1)
           endrep until (byte(answer) ge 48 and byte(answer) le 57) $
             or  byte(answer) eq 10
           if byte(answer) ne 10 then order = fix(answer)
           for ki = 0,1000 do flush_input = get_kbrd(0)
        endif ;; O

        if answer eq 'A' then begin
           idx = pop(bad_stack, null=-1)
           while idx ne -1 do begin
             y[idx] = y_save[idx]
             idx = pop(bad_stack, null=-1)
          endwhile
        endif ;; A

        if answer eq 'Q' or answer eq 'X' then begin
           message, /CONTINUE, 'DONE'
           refit = 0
        endif ;; Q/X

     endif ;; Mouse button 2
     if !MOUSE.button eq 4 then begin
        idx = pop(bad_stack, null=-1)
        if idx eq -1 then begin
           message, /CONTINUE, 'ALL POINTS RESURRECTED'
        endif else begin
           y[idx] = y_save[idx]
        endelse
     endif ;; Mouse 4
  endrep until refit eq 0


return, coefs

end
