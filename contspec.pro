; +

; $Id: contspec.pro,v 1.1 2002/12/16 18:26:10 jpmorgen Exp $

; contspec.pro Make a polynomial continuuum spectrum spectrum for an X
; axis, picking out the continuum polynomial from a params/parinfo
; structure or from the first N_params elements of params.  The
; continuum polynomial parameters must be in units of the X axis.
; This is suitable for use as a MYFUNCT for mpfitfun.

function contspec, X, params, dparams, parinfo=parinfo, $
                   Y=Yin, N_continuum=N_continuum, refX = refX

  if N_params() gt 3 then $
    message, 'ERROR: analytic derivatives not implemented yet.  Do you mean to say Y=Y?'

  vfid_cont = 1
  vfid_center = 2
  vfid_dop = 3
  vfid_lor = 4
  vfid_area = 5

  ;; --> Consider taking ssg stuff out at this level?
  ssgid_disp = 1
  ssgid_dop = 2
  ssgid_cont = 3
  ssgid_voigt = 4

  if keyword_set(Yin) then $
    Y = Yin $
  else $
    Y = dblarr(N_elements(X))   ; 0th order continuum = 0

  if NOT keyword_set(N_continuum) then N_continuum = 1
  if NOT keyword_set(parinfo) then begin
     message, 'NOTE: creating parinfo structure', /INFORMATIONAL
     parinfo = ssg_init_parinfo(N_continuum)
     parinfo.vfID[0:N_continuum-1] = vfid_cont
     parinfo.ssgID[0:N_continuum-1] = ssgid_cont
  endif ;; creating parinfo
  ;; The reference X value for the continuum polynomial
  if NOT keyword_set(refX) then begin
     disp_idx = where(parinfo.ssgID eq ssgid_disp, count)
     if count eq 0 then begin
        refX = mean(X)  ;;  Either this or 0
     endif else begin ;; Get refX from dispersion
        refX = params[disp_idx[0]]
     endelse
  endif ;; reference X

  cont_idx = where(parinfo.vfid eq 1, N_continuum)
  if N_elements(params) lt N_continuum then begin
     message, 'WARNING: not enough elements in params for ' + string(N_continuum) + ' continuum polynomial coefficients.  Extending params with 0s', /INFORMATIONAL
     params = [params, replicate(0, N_elements(params) - N_continuum)]
  endif

  ;; IDL is nice and not nice.  This code gets skipped if nv
  ;; N_continuum is 0.  One might think that it could go backwarnds,
  ;; but that would require a 3rd argument to for (increment)
  for n=0,N_continuum-1 do begin
     Y = Y + params[cont_idx[n]]*(X-refX)^n
  endfor

return, Y
end

