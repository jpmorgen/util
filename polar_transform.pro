;+
; NAME: polar_transform
;
; PURPOSE: Take a polar transform of an image ... work in progress
;
; CATEGORY: Image processing
;
; CALLING SEQUENCE: 
;  polar_im = polar_transform(im, center=center, rscale=rscale, phi0=phi0, $
;                     pixels=pixels)
;
; INPUTS: im -- rectangular image to be transformed
;
; OPTIONAL INPUTS:
; polar_im-- input this as a template of how big to make output
;            polar_im.  Original array is not affected
; center -- point in input image corresponding to r=0, theta=0.
;           default is the center of the input image
; rscale -- not sure how this works
; phi0 -- phase to apply, in degrees
;
; KEYWORD PARAMETERS:
;
; OUTPUTS: polar_im -- the polar transform of im.  Defaults to be the
;                      same size as the imput image
;
; OPTIONAL OUTPUTS: pixels -- an image of the same dimensions of 
;
; COMMON BLOCKS:  
;   Common blocks are ugly.  Consider using package-specific system
;   variables.
;
; SIDE EFFECTS:
;
; RESTRICTIONS:
;
; PROCEDURE:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;
; $Id: polar_transform.pro,v 1.7 2015/03/03 18:22:33 jpmorgen Exp $
;-


function polar_transform, im, center=center, rscale=rscale, phi0=phi0, $
                     pixels=pixels, polar_im=polar_im

  if NOT keyword_set(phi0) then phi0 = 0.
  if NOT keyword_set(rscale) then rscale = 1.

  ;; Make arrays of radii and angles
  dims = size(im, /dimensions)
  if NOT keyword_set(center) then $
    center = dims/2
  xr = findgen(dims[0])-center[0]
  yc = findgen(dims[1])-center[1]
  xx = xr # (yc*0 + 1)
  yy = (xr*0 + 1) # yc

  radii = sqrt(xx^2 + yy^2)
  angles = atan(yy, xx)
  
  ;; Allow for phasing the angles to pretty up final array
  angles=angles*180./!pi-phi0
  wrapidx = where(angles gt 360, count)
  if count gt 0 then angles[wrapidx] = angles[wrapidx] - 360
  wrapidx = where(angles lt 0, count)
  if count gt 0 then angles[wrapidx] = angles[wrapidx] + 360

  ;; Now make a rectangular array of radius vs. angle.
  asize = size(polar_im)
  if asize[0] eq 0 then begin
     na = 360.
     nr = floor(max(radii)*rscale)
  endif
  if asize[0] eq 1 then begin
     na = asize(1)
     nr = floor(max(radii)*rscale)
  endif
  if asize[0] eq 2 then begin
     na = asize(1)
     nr = asize(2)
  endif

  polar_im = fltarr(na, nr)
  pixels=fltarr(na,nr)

  r_step=max(radii)/(nr-1)
  a_step=360./(na-1)

  ;; This is the easiest way to do the transformation, but it leaves a
  ;; lot of empty pixels.  Note that IDL can index a 2D array in a
  ;; serial way too (e.g. im[elemindex] saves us from defining x and y)
  for elemindex=long(0), N_elements(im)-1 do begin
     r = floor(radii(elemindex)/r_step)
     a = floor((angles(elemindex))/a_step)
     if finite(im[elemindex]) eq 1 then begin
        polar_im(a,r)=polar_im(a,r) + im[elemindex]
        pixels(a,r)=pixels(a,r)+1
     endif
  endfor

  good_idx = where(pixels ne 0, complement=zero_idx)
  polar_im(good_idx) = polar_im(good_idx)/pixels(good_idx)
  polar_im(zero_idx) = !values.f_nan
  
  ;; Fill in blank pixels left by transform at small radii.  Use a
  ;; spline fit through nearest neighbors.
  for ir=0,nr/2 do begin
     pixidx = where(finite(polar_im(*,ir)), count)
     if (count eq 0) then $
       CONTINUE
     if count le 2 then begin
        ;; spline doesn't like so few elements
        polar_im(*,r) = median(polar_im(pixidx,ir))
        CONTINUE
     endif
     new_row = spline(pixidx, polar_im(pixidx,ir), indgen(na))
           polar_im(*,ir) = new_row(*)

  endfor

  return, polar_im

end

