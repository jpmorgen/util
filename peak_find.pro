; $Id: peak_find.pro,v 1.2 2003/03/10 18:35:22 jpmorgen Exp $

; peak_find.pro  Returns the best position of the peak in the array
; given a variety of algorithms.  

function peak_find, y, xaxis=xaxis, N_continuum=N_continuum, yerr=yerr, $
                    error=error
  ;; Handle pathological cases first
  npts = N_elements(y)
  error = !values.d_nan
  if npts eq 0 then return, error
  if NOT keyword_set(xaxis) then xaxis = indgen(npts)
  if npts eq 1 then return, xaxis[0]
  if npts eq 2 then begin
     error = stdev(xaxis)
     maxy = max(y, max_idx)
     if N_elements(max_idx) gt 1 then begin
        return, mean(xaxis)
     endif
     return, xaxis(max_idx)
  endif
  
  ;; OK, we have at least 3 points to play with.  Run mpfitpeak,
  ;; which fails gracefully, letting us clean up with polyfitting a
  ;; parabola if necessary
  nterms = 3                    ; for [gauss/mp]fit
  if keyword_set(N_continuum) then $
    nterms = nterms + N_continuum
  if N_elements(xaxis) ne npts then $
    message, 'ERROR: xaxis must have the same number of points as y'

  yfit = mpfitpeak(xaxis, y, params, nterms=nterms, error=yerr, perror=perror)
  if N_elements(yfit) gt 1 then begin
     error = perror[1]
     return, params[1]
  endif
  ;; mpfitpeak seems to have failed.  Try a simple parabola
  if npts ge 3 then begin
     coefs = poly_fit(xaxis, y, 2, sigma=sigma)
     ;; I don't think poly_fit ever fails if it has enough points
     error = 0.5*sqrt((sigma[1]/coefs[2]^2) + (coefs[1]*sigma[2]/coefs[2]^2)^2)
     return, -1*coefs[1]/(2*coefs[2])
  endif
end
