;+
; NAME:	fig_of_rot
;
; PURPOSE:
;	Makes a figure of rotation out of 1D vector f.  first point of
;	f is the center of the figure
;
; CATEGORY:
;	simple modeling
;
; CALLING SEQUENCE:
;	im = fig_of_rot(f)
;
; INPUTS:
;	f: The array to be transformed into a figure of rotation.
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;
; OPTIONAL OUTPUTS:
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
; Created Mon Apr 15 11:00:59 2002  jpmorgen
; Added keywords and generalized Fri Jul 29 11:47:45 2005  jpmorgen
;
; $Id: fig_of_rot.pro,v 1.2 2005/08/01 18:57:18 jpmorgen Exp $
;-
; 

function fig_of_rot, f, template=template, center=center

  ;; Check command line parameters
  CATCH, err
  if err ne 0 then begin
     CATCH, /CANCEL
     message, /NONAME, !error_state.msg, /CONTINUE
     message, 'USAGE: im = fig_of_rot(f, template=template, center=center)', /CONTINUE
     message, 'USAGE: where f is the vector you want to make into a figure of rotation of (assumes even pixel spacing), template is the image into which you want it placed and center is a vector containing the center point of the figure of rotation in the template image.  The default template is a square image twice the size (plus one) on each edge than f.  The default center is the center of that image.'
  endif

  if N_elements(f) eq 0 then $
     message, 'ERROR: you must specify the vector you want to make into a figure of rotation'

  ;; Get default template image
  if NOT keyword_set(template) then begin
     nx = 2 * N_elements(f) + 1
     ;; Make the template array the same type 
     template = make_array(nx, nx, value=f[0])
  endif
  tdims = size(template, /dimensions)
  if N_elements(tdims) ne 2 then $
    message, 'ERROR: this currently only works for 2D arrays'

  ;; Get center
  if NOT keyword_set(center) then begin
     center = [tdims[0]/2., tdims[1]/2.]
  endif
  if N_elements(center) ne 2 then $
    message, 'ERROR: the center keyword must contain 2 elements.'

  CATCH, /CANCEL
  ;; Done checking command line parameters

  xaxis = findgen(N_elements(f))
  ;; Now for the actual calculation.  Prepare return array and set all
  ;; elements to NAN, since we might not have enough input array to be
  ;; able to calculate all points
  a = template * !values.d_nan
  for ix = 0, tdims[0] - 1 do begin
     for iy = 0, tdims[1] - 1 do begin
        ;; Calculate the distance between each pixel in the image and
        ;; the center point.  use the centers of the pixels rather
        ;; than the vertexes
        r = sqrt(((ix + 0.5) - center[0])^2 + $
                 ((iy + 0.5) - center[1])^2)
        ;; Don't extend beyond end of f
        if r gt N_elements(f) then $
          CONTINUE

        ;; This is the heart of the code.  If you want to get fancier
        ;; with how to calculate pixel values from f, here is where
        ;; you would do it.
        a[ix,iy] = interpolate(f, r, missing=f[0])
;        a[ix,iy] = spline(xaxis, f, r)
     endfor ;; ix
  endfor ;; iy

  return, a
end
