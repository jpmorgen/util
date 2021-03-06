;+
; $Id: mark_bad_pix.pro,v 1.5 2003/06/19 21:47:38 jpmorgen Exp $

; mark_bad_pix Assuming Gaussian statistics, takes an image of sigma
; values and returns an image with the statistically unlikely pixels
; marked.  Statistically unlikely groups of pixels are searched for on
; all size scales up to the minimum dimension of the array.  The
; return value is an array of the same type as the input with the
; pixel values equal to the number of size scales on which a
; particular input pixel was found to be bad

; Intended calling sequence:
; template = template_create(im, description1, description2)
; sigma = template_statistic(im, template)
; badim = mark_bad_pix(abs(sigma))
; badidx = where(badim gt 0, count)
; if count gt 0 then im[badidx] = !values.f_nan

;-

function mark_bad_pix, sigma_im, cutval=cutval
  if N_elements(badval) eq 0 then badval = !values.f_nan
  if N_elements(cutval) eq 0 then cutval = 5
  im=sigma_im
  nan_idx = where(finite(sigma_im) eq 0, nan_count)
  badim=im
  badim[*]=0
  badidx=where(im gt cutval, count)
  ;; See if we find any bad pixels
  if count eq 0 then return, badim
  badim[badidx] = badim[badidx] + 1

  ;; Now look on different size scales.
  asize=size(im)
  nx=asize[1]
  ny=asize[2]
  for i=2,min([nx,ny]-1) do begin
     im=smooth(im, i, /NAN, /edge_truncate)
     ;; Don't let smoothing un-NAN anything
     if nan_count gt 0 then $
       im[nan_idx] = !values.f_nan
     badidx=where(im gt cutval, count)
     if count eq 0 then return, badim
     badim[badidx] = badim[badidx] + 1
     ;;im[badidx] = im[badidx] + 5 ; Exaggerate bad pixels
  endfor
  message, /CONTINUE, 'WARNING: bad pixels were found on all size scales'
  return, badim
end
