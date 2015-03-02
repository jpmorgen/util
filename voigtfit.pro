; +

; $Id: voigtfit.pro,v 1.2 2015/03/02 21:55:16 jpmorgen Exp $

; Voigtfit.  Inspired by Carey Woordward's (woolrc@aya.yale.edu)
; program of the same name (aka VFudgit) that ran in Fudgit, a
; freely distrubuted function fitting package.  This uses Craig
; Markwardt's mpfit IDL package as its base

;; NOTE: this became the PFO package


;; Note, AUTODERIVATIVE must be used at the moment, since I don't
;; calculate derivatives analytically 
function voigtfit, X, Y, err_axis, params, parinfo=parinfo, $
                   _EXTRA=extra


  if keyword_set(parinfo) then $
    to_pass = {parinfo:parinfo}
  params = mpfitfun('voigtspec', X, Y, err_axis, $
                    params, FUNCTARGS=to_pass, AUTODERIVATIVE=1, $
                    PARINFO=parinfo, _EXTRA=extra)



return, params

end
