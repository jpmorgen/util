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
; $Id: fig_of_rot.pro,v 1.3 2005/08/01 20:45:38 jpmorgen Exp $
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
     nx = 2 * (N_elements(f) - 1) + 1
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
  
  ;; Now for the actual calculation.  We have to do this in two steps,
  ;; since most of the functions we are interested in have an
  ;; exponential behavior that confuses interpolate and spline for
  ;; abscissa values less than 1.  So first start by laying down the
  ;; funtion on even pixel boundaries and then use ROT to move it back
  ;; to the true sub-pixel point.  Use a slightly bigger array so that
  ;; we don't get any edge effects with ROT.  Prepare the (overseized)
  ;; return array with all elements set to NAN, since we might not
  ;; have enough input array to be able to calculate all points.  Make
  ;; sure its type matches the template image.
  a = make_array(tdims[0] + 2, tdims[1] + 2, $
                 value=template[0] * !values.d_nan)
  acenter = round(center) + 1
  ;; NOTE array bounds are 2 more than normal
  for ix = 0, tdims[0] + 1 do begin
     for iy = 0, tdims[1] + 1 do begin
        ;; Calculate the distance between each pixel in the image and
        ;; the center point.  use the centers of the pixels rather
        ;; than the vertexes
        r = sqrt((ix - acenter[0])^2 + $
                 (iy - acenter[1])^2)
;        ;; Don't extend beyond end of f
;        if r gt N_elements(f) then $
;          CONTINUE

        ;; This is the heart of the code.  If you want to get fancier
        ;; with how to calculate pixel values from f, here is where
        ;; you would do it.
        if r lt 1. then begin
           a[ix,iy] = f[0]
        endif else begin
           a[ix,iy] = interpolate(f, r, missing=!values.d_nan)
        endelse
     endfor ;; ix
  endfor ;; iy

  ;; Now use IDL's ROT command to translate the array to the sub-pixel
  ;; level.  ROT is a little inconvenient to use, since it takes
  ;; whatever X and Y you give it and, without the /PIVOT keywords,
  ;; translates the image to make that [nx/2, ny/2].
  dcenter = acenter - (center + 1)
;  a = rot(a, 0, 1, $
;          (tdims[0] + 2) / 2. - dcenter[0], $
;          (tdims[1] + 2) / 2. - dcenter[1], $
;          cubic=-0.5)
  return, a[1:tdims[0]-1, 1:tdims[1]-1]
end
