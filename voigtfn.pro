; $Id: voigtfn.pro,v 1.1 2002/12/16 18:27:19 jpmorgen Exp $

;; Adds voigt profiles specified in params to Yaxis.

function voigtfn, params, Vaxis, Yaxis, plot=plot

  ;; This assumes that there are 4 parameters per Voigt. 

  ;; --> Would you rather look at 4 everywhere or nppv?

  if N_elements(params) mod 4 ne 0 then message, 'ERROR: wrong number of parameters.  Must have Voigt profile (center, dop width, Lorenzian width, area)'

  npts=N_elements(Vaxis)
  if NOT keyword_set(Yaxis) then Yaxis = dblarr(npts)
  newYaxis = Yaxis

  nlines = N_elements(params)/4

  ;; This is taken from Carey Woodward's V-Fudgit documentation
  for il=0, nlines-1 do begin
     v0 	= params[il*4 + 0]
     dopFWHM 	= params[il*4 + 1]
     lorFWHM 	= params[il*4 + 2]
     area	= params[il*4 + 3]
     rln2 = sqrt(alog(2d))      ; Make sure result is double precision
     x = 2d*rln2 * (Vaxis - v0)/dopFWHM
     y = rln2 * lorFWHM/dopFWHM
     ;; Use IDL's internal Voigt profile for now even though Carey
     ;; complains of a problem with it.  Well, first of all, I have to
     ;; get the sense of the axes right!
     P = 2d*rln2/sqrt(!pi) * area/dopFWHM * voigt(y,x) 
     newYaxis = newYaxis + P
  endfor

  if keyword_set(plot) then $
    plot, Vaxis, newYaxis

  return, newYaxis
end
