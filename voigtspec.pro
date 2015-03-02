; +

; $Id: voigtspec.pro,v 1.2 2015/03/02 21:49:45 jpmorgen Exp $

; voigspec.pro This extracts the continuum and Voigt parameters from a
; params/parinfo structure, makes the continuum and passes the rest of
; the parameters to the primitive routine voigtfn.  A Y axis with the
; continuum plus Voigts is returned.  This is suitable for use as a
; MYFUNCT for mpfitfun.  If the keyword Y=Y is specified, the
; Voigts will be added to that vector.

function voigtspec, X, params, parinfo=parinfo, $
                    Y=Yin, N_continuum=N_continuum

  if N_params() gt 3 then $
    message, 'ERROR: analytic derivatives not implemented yet.  Do you mean to say Y=Y?'
  
  ;; Check to see if we need to build a parinfo structure onto the one
  ;; contspec returns
  if NOT keyword_set(parinfo) then api=1
  ;; Make the continuum spectrum
  Y = contspec(X, params, parinfo=parinfo, Y=Yin, N_continuum=N_continuum)

  ;; Number of parameters per Voigt
  nppv = 4
  ;; The vfID number of the 0th component of the Voigt descriptor
  ;; (which happens to be the deviation from the line center in the
  ;; current implementation)

  ;; Make tokens for everything
  vfid_cont = 1
  vfid_center = 2
  vfid_area = 3
  vfid_ew = 3
  vfid_dop = 4
  vfid_lor = 5
  vfid_first = vfid_center
  vfid_last = vfid_area

  ssgid_disp = 1
  ssgid_dop = 2
  ssgid_cont = 3
  ssgid_voigt = 4


  if keyword_set(api) then begin
     if keyword_set(parinfo) then begin
        message, 'NOTE: extending parinfo structure', /INFORMATIONAL
     endif else begin
        ;; Actually, this should never be displayed.  The current way I
        ;; have things written, contspec will always return at least a
        ;; 0 continuum
        message, 'NOTE: creating parinfo structure', /INFORMATIONAL
     endelse
     nlpars = (N_elements(in_pararms) - N_continuum)
     if nlpars mod nppv ne 0 then $
       message, 'ERROR: you need to specify ' + string(nppv) + ' parameters per Voigt'
     num_lines = nlpars / nppv
     lparinfo = vfparinfo(num_lines)
     ;; Set up the tags for the parameters (e.g. delta line center,
     ;; widths, area)
     for ilp=0,nlpars-1 do begin
        ;; .vfID - 1=continuum parameter, 2-5 = voigt parameter
        lparinfo.vfID = vfid_first + ilp mod nppv
     endfor
     ;; In case parameters were specified in the old style of using
     ;; the actual line wavelength, stash that to .ssgowl and
     ;; make that params value = 0
     center_idx = where(parinfo.vfID eq vfid_center, nv)  
     for iv=0, nv-1 do begin
        message, 'WARNING: migrating to ssg observed wavelength structure, setting the linecenter parameter to 0'
        parinfo.ssgowl[iv] = params[iv]
        params[iv] = 0
     endfor
     
  endif ; add parinfo stuff

  ;; We are going to want to make a new parameter list for voigtfn
  ;; with just the Voigt parameters in it.  Since voigfn doesn't use
  ;; parinfo and doesn't accept continuum arguments, we can make this
  ;; very simple
  vparams=params
  voigt_idx = where(vfid_first le parinfo.vfid and $
                    parinfo.vfid le vfid_last, nv)

  ;; Return continuum if no Voigts
  if nv eq 0 then return, Y

  ;; Voigtfn takes the absolute wavelength, so we need to build that
  ;; from parinfo.ssgowl and the delta line center parameter
  dlc_idx = where(parinfo.vfID eq vfid_center, nv)  

  ;; This actually does not assume the user has set up the
  ;; parinifo.ssgowl structure, since it is initialized to 0 +
  ;; this would then just preserve whatever is in params
  for iv=0, nv-1 do begin
     idx = dlc_idx[iv]
     vparams[idx] = vparams[idx] + parinfo[idx].ssgowl
  endfor

  ;; voigtfn is a cumulative thing that adds onto the function Y.
  ;; Pass it just the voigt parameters + it should be happy
  Y = voigtfn(vparams[voigt_idx], X, Y)
  return, Y

end

