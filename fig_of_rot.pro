;+
; NAME:	fig_of_rot
;
; PURPOSE:
;	Makes a figure of rotation out of input array f.
;
; CATEGORY:
;	simple modeling
;
; CALLING SEQUENCE:
;       im = fig_of_rot(f, [x_or_r, y_or_ang, dims=dims, center=center, $
;	_EXTRA=extra])
;
; INPUTS:
;	f: The 1D vector to be transformed into a figure of rotation.  
;
; OPTIONAL INPUTS:
;	x_or_r: A vector specifying the coordinates along the X axis
;	(or in radius from center) of the points sampled by f.  Must
;	have the same number of elements as f
;
;	y_or_ang: A vector specifying the coordinates of the input
;	points of f along the Y axis or in angle
;
; KEYWORD PARAMETERS:
;	dims: vector containing dimensions of desired output image.
;	e.g. dims = size(template, /dimensions)
;
;	center: vector containing center coordinates of figure of
;	rot.  Does not have to be contained in image.  Distances are
;	assumed to be from the centers of square pixels.
;	E.g. center=[-0.5, -0.5] is how you would specify the very top
;	left hand of the image.
;
;	/rad: y_or_ang is an angle and specified in radians
;
;	/deg: y_or_ang is an angle and specified in degrees
;
;	_EXTRA: keyword parameters to pass on to interpolate
;
; OUTPUTS:
;	image containing figure of rotation
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
; $Id: fig_of_rot.pro,v 1.7 2015/03/03 19:07:16 jpmorgen Exp $
;-
; 

function fig_of_rot, f, x_or_r, y_or_ang, dims=dims, center=center, $
                     rad=rad, deg=deg, _EXTRA=extra

  ;; Check command line parameters
  CATCH, err
  if err ne 0 then begin
     CATCH, /CANCEL
     message, /NONAME, !error_state.msg, /CONTINUE
     message, 'USAGE: im = fig_of_rot(f, [x_or_r, y_or_ang, dims=dims, center=center])', /CONTINUE
     message, 'USAGE: see function documentation for details.  The procedure ''man'' from the ghrs library can help.'
  endif

  nf = N_elements(f)
  if nf eq 0 then $
    message, 'ERROR: you must specify the vector you want to make into a figure of rotation'

  if size(f, /N_dimensions) ne 1 then $
    message, 'ERROR: f must be a 1D vector.'

  nx = N_elements(x_or_r) 
  if nx gt 0 and nx ne nf then $
    message, 'ERROR: x_or_r must have the same number of elements as f'

  ny = N_elements(y_or_ang)
  if ny ne 0 and ny ne nf then $
    message, 'ERROR: y_or_ang must have the same number of elements as f'

  ;; Get default output image size
  if NOT keyword_set(dims) then begin
     dims = [2 * nf + 1, 2 * nf + 1]
  endif
  if N_elements(dims) ne 2 then $
    message, 'ERROR: this currently only works for 2D arrays'

  ;; Get center -- beware definition of pixel
  if NOT keyword_set(center) then begin
     center = [dims[0]/2. - 0.5, dims[1]/2. - 0.5]
  endif
  if N_elements(center) ne 2 then $
    message, 'ERROR: the center keyword must contain 2 elements.'

  if keyword_set(rad) and keyword_set(deg) then $
    message, 'ERROR: specify either rad or deg, not both!'

  CATCH, /CANCEL
  ;; Done checking command line parameters

  ;; Calculate the polar coordinates of each pixel of the output
  ;; array.  Code adapted from Craig Markwardt's mpfit2dpeak.
  xr = findgen(dims[0])-center[0]
  yc = findgen(dims[1])-center[1]
  ax = xr # (yc*0 + 1)
  ay = (xr*0 + 1) # yc
  ar = sqrt(ax^2 + ay^2)

  ;; Easy case: f has one element per X-axis pixel.  Use IDL's
  ;; interpolate function to return an array which is matched to the
  ;; dimensions of ar and has the values we want in each pixel.
  if nx eq 0 then $
    return, interpolate(f, ar, _EXTRA=extra)

  ;; Assume r_or_x is r
  r = r_or_x

  ;; If we have no Y-axis but we have positive and negative values on
  ;; our X-axis (e.g. converting a profile to a PSF) we will want to
  ;; do the full angle calculation.  Negative r are handled below for
  ;; the general case
  if ny eq 0 and min(r, /NAN) lt 0 and max(r, /NAN) gt 0 then begin
     ny = nf & rad = 1 & deg = 0
     ;; Make ang array and preserve any NAN values
     y_or_ang = r * 0.
     y_or_ang = !pi
  endif ;; Constructing ang axis for case of +/- X-axis

  ;; Handle the case of a second axis.
  if ny gt 0 then begin
     ;; Default to angle in radians
     ang = y_or_ang
     if keyword_set(deg) then $
       ang = temporary(ang) / !radeg
     ;; Convert rectangular coordinates to polar
     if NOT (keyword_set(rad) or keyword_set(deg)) then begin
        r = sqrt(r_or_x^2 + ang_or_y^2)
        ang = atan(ang_or_y, r_or_x)
     endif ;;
  endif ;; Set up the second axis 

  ;; Handle negative y values
  r_idx = where(r lt 0, count)
  if count gt 0 then $
    ang[r_idx] = (ang + !pi) mod (2. * !pi)
  r = abs(r)

  ;; Make our angles read 0 to 

  ;; Prepare to make a histogram of our angles.  Default to 10 degree
  ;; bins
  if NOT keyword_set(nbins) then $
    nbins = 36.
  ;; Center our first bin on 0 degrees
  ang_h = histogram(float(ang), nbins=nbins, max=2 * !pi + (!pi / nbins) , $
                    reverse_indices=ang_h_ridx)




  ;; We now have our function f(r, ang).  We calcualted the r values
  ;; of our output array pixels above (ar).  Calculate the angles:
  aang = atan(ay, ax)


  ;; Find the unique values of r and ang to help us make a good
  ;; binning for our histogram
  ur = uniq(r, sort(r))
  modang = ang mod !pi
  umodang = uniq(modang, sort(modang))


  ;; Pick a radius, set up a bunch of ables to sample, plop down into
  ;; array.  The radius maybe for the pixel in the output image you
  ;; are trying to estabilsh the value of

  ;; Since this is a figure of rotation we will want to spline
  r_idx = sort(ang)
  f = f[r_idx]
  r = r[r_idx]
  r_idx = sort(r)

end
