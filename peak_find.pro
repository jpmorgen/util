; $Id: peak_find.pro,v 1.1 2002/12/16 18:29:01 jpmorgen Exp $

; peak_find.pro  Returns the best position of the peak in the array
; given a variety of algorithms.  

function peak_find, y, xaxis=xaxis, N_continuum=N_continuum
  npts = N_elements(y)
  nterms = 3                    ; for gaussfit
  if keyword_set(N_continuum) then $
    nterms = nterms + N_continuum
  if NOT keyword_set(xaxis) then xaxis = indgen(npts)
  if N_elements(xaxis) ne npts then $
    message, 'ERROR: xaxis must have the same number of points as y'

  yfit = mpfitpeak(xaxis, y, params, nterms=nterms)
  if N_elements(yfit) gt 1 then begin
     return, params[1]
  endif
  ;; mpfitpeak seems to have failed.  Try a simple parabola
  if npts ge 3 then begin
     coefs = poly_fit(xaxis, y, 2)
     ;; I don't think poly_fit ever fails if it has enough points
     return, -1*coefs[1]/(2*coefs[2])
  endif
  ;; Well, this is simple
  maxy = max(y, max_idx)
  if N_elements(max_idx) gt 1 then $
    message, /CONTINUE, 'WARNING: peak_find found more than one peak'
  return, max_idx

end
