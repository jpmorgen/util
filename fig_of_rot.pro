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
;	f: The 1D vector to be transformed into a figure of rotation.  
;
; OPTIONAL INPUTS:
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
;	missing: value used to fill image pixels beyond the end of f.
;	The default is !values.d_nan, which is converted to whatever
;	type f is.
;
; OUTPUTS:
;	image containing figure of rotation and any filled pixels with
;	the 'missing' value
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
; $Id: fig_of_rot.pro,v 1.4 2005/08/02 20:47:48 jpmorgen Exp $
;-
; 

function fig_of_rot, f, dims=dims, center=center, missing=missing

  ;; Check command line parameters
  CATCH, err
  if err ne 0 then begin
     CATCH, /CANCEL
     message, /NONAME, !error_state.msg, /CONTINUE
     message, 'USAGE: im = fig_of_rot(f, dims=dims, center=center, missing=missing)', /CONTINUE
     message, 'USAGE: see function documentation for details.  The procedure ''man'' from the ghrs library can help.'
  endif

  if N_elements(f) eq 0 then $
    message, 'ERROR: you must specify the vector you want to make into a figure of rotation'

  if N_elements(size(f, /dimensions)) ne 1 then $
    message, 'ERROR: f must be a 1D vector.'


  ;; Get default output image size
  if NOT keyword_set(dims) then begin
     nx = 2 * N_elements(f) + 1
  endif
  if N_elements(dims) ne 2 then $
    message, 'ERROR: this currently only works for 2D arrays'

  ;; Get center
  if NOT keyword_set(center) then begin
     center = [dims[0]/2., dims[1]/2.]
  endif
  if N_elements(center) ne 2 then $
    message, 'ERROR: the center keyword must contain 2 elements.'

  if N_elements(missing) eq 0 then $
    missing = !values.d_nan

  CATCH, /CANCEL
  ;; Done checking command line parameters

  ;; from Carey Woodward's radbin.  Quickly fill arrays with
  ;; delta x and delta y values from center
  xx = areplicate(findgen(dims[0])-center[0],dims[1],1)
  yy = areplicate(findgen(dims[1])-center[1],dims[0])
  rr = sqrt(xx^2 + yy^2)

  return, interpolate(f, rr, missing=missing)

end
