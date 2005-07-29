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
;
; $Id: fig_of_rot.pro,v 1.1 2005/07/29 00:06:33 jpmorgen Exp $
;-
; Mon Apr 15 11:00:59 2002  jpmorgen

function fig_of_rot, f

  nx=2*N_elements(f) + 1
  ny=nx
  a=fltarr(nx,ny)
  xc=nx/2.
  yc=ny/2.

  ;; from Carey Woodward's radbin
  xx = areplicate(findgen(nx)-xc,ny,1)
  yy = areplicate(findgen(ny)-yc,nx)

  rr = sqrt(xx*xx + yy*yy)
  for x=0,nx-1 do begin
     for y=0,ny-1 do begin
        a[x,y] = interpolate(f, rr[x,y])
     endfor
  endfor


  return, a
end
