; $Id: peak_find.pro,v 1.4 2015/03/02 21:52:05 jpmorgen Exp $

; peak_find.pro  Returns the best position of the peak in the array
; given a variety of algorithms.  

function peak_find, y_in, xaxis=xaxis_in, N_continuum=N_continuum, $
                    yerr=yerr_in, error=error, lose_to_errors=lose_to_errors, $
                    plot=plot, quiet=quiet, poly=poly, _EXTRA=extra

  ;; The maximum fraction of points we are willing to lose before if
  ;; there are more NANs in the error column than in the others.  If
  ;; there are more than this fraction, then we just throw out the
  ;; error column.
  if NOT keyword_set(lose_to_errors) then lose_to_errors=0.85
  ;; Handle pathological cases first
  npts = N_elements(y_in)
  error = !values.d_nan
  if npts eq 0 then return, error

  if NOT keyword_set(xaxis_in) then xaxis_in = indgen(npts)
  if N_elements(xaxis_in) ne npts then $
    message, 'ERROR: xaxis must have the same number of points as y'

  ;; We need to rid the world of NANs so the fitting routines don't barf
  good_idx = where(finite(y_in) eq 1 and $
                   finite(xaxis_in) eq 1, count)
  ;; But make sure we don't have too many NANs in the error column
  if keyword_set(yerr_in) then begin
     junk = where(finite(yerr_in) eq 1, n_err)
     if n_err ge lose_to_errors*count then begin
        good_idx = where(finite(y_in) eq 1 and $
                         finite(yerr_in) eq 1 and $
                         finite(xaxis_in) eq 1, count)
        if count gt 0 then $
          yerr = yerr_in[good_idx]
     endif
  endif
  if count eq 0 then return, error

  y = y_in[good_idx]
  xaxis = xaxis_in[good_idx]
  
  if count eq 1 then return, xaxis[0]
  if count eq 2 then begin
     error = stdev(xaxis)
     maxy = max(y, max_idx)
     if N_elements(max_idx) gt 1 then begin
        return, mean(xaxis)
     endif
     return, xaxis(max_idx)
  endif
  
  if NOT keyword_set(poly) then begin

     ;; OK, we have at least 3 points to play with.  Run mpfitpeak,
     ;; which fails gracefully, letting us clean up with polyfitting a
     ;; parabola if necessary
     nterms = 3                 ; for [gauss/mp]fit
     if keyword_set(N_continuum) then $
       nterms = nterms + N_continuum
     
     ;; Intercept the case where we have more nterms than points so as
     ;; not to generate the word ERROR from mpfitpeak
     if n_elements(xaxis) LT nterms OR n_elements(y) LT nterms then begin
        if NOT keyword_set(quiet) then $
           message, /CONTINUE, 'WARNING: too little data to do mpfitpeak, defaulting to polynomial'
     endif else begin
        yfit = mpfitpeak(xaxis, y, params, nterms=nterms, error=yerr, $
                         perror=perror, status=status, _EXTRA=extra)

        if status gt 0 then begin
           if status ge 5 and NOT keyword_set(quiet) then $
              message, /CONTINUE, 'WARNING: mpfitpeak returned status ' + string(status)
           error = perror[1]
           if keyword_set(plot) then begin
              plot, y_in, title=plot
              plots, [params[1],params[1]], [-1E32,1E32]
           endif

           return, params[1]
        endif ;; sensible return from mpfit
     endelse ;; intercept too little data
  endif ;; doing mpfit

  ;; mpfitpeak seems to have failed or we don't want to bother with it.  Try a simple parabola
  coefs = poly_fit(xaxis, y, 2, sigma=sigma)
  ;; I don't think poly_fit ever fails if it has enough points
  error = 0.5*sqrt((sigma[1]/coefs[2]^2) + (coefs[1]*sigma[2]/coefs[2]^2)^2)
  val = -1*coefs[1]/(2*coefs[2])
  if keyword_set(plot) then begin
     plot, y_in, title=plot
     plots, [val,val], [-1E32,1E32]
  endif
  return, val

end
