;+
; $Id: rect_transform.pro,v 1.2 2003/06/16 21:39:09 jpmorgen Exp $

; rect_transform  Converts a polar transform back into a rectangular image

pro rect_transform, polar_im, im, xc, yc, phi0=phi0, rscale=rscale, $
                    pixels=pixels

  if NOT keyword_set(phi0) then phi0 = 0.
  if NOT keyword_set(rscale) then rscale = 1.

  asize = size(polar_im)
  na = asize(1)
  nr = asize(2)

  asize = size(im)
  if asize[0] eq 0 then begin
     nx = nr*rscale
     ny = nx
  endif
  if asize[0] eq 1 then begin
     nx = asize(1)
     ny = nx
  endif
  if asize[0] eq 2 then begin
     nx = asize(1)
     ny = asize(2)
  endif

  im = fltarr(nx,ny)

  if NOT keyword_set(xc) then xc = nx/2.
  if NOT keyword_set(yc) then yc = ny/2.

  ;; Make arrays of radii and angles
  imx = lonarr(nx*ny)
  imy = lonarr(nx*ny)
  radii=fltarr(nx*ny)
  angles=fltarr(nx*ny)
  for x=0,nx-1 do begin
     for y=0,ny-1 do begin
        elemindex = y*nx + x
        imx(elemindex) = x
        imy(elemindex) = y
        radii(elemindex)=sqrt((x - xc)^2 + (y - yc)^2)
        if ((y eq yc) and (x eq xc)) $
          then angles(elemindex) = 0 $
        else angles(elemindex)=atan((y - yc), (x - xc))
     endfor
  endfor
  
  ;; Allow for phasing the angles to pretty up final array
  angles=angles*180./!pi-phi0
  wrapidx = where(angles gt 360, count)
  if count gt 0 then angles[wrapidx] = angles[wrapidx] - 360
  wrapidx = where(angles lt 0, count)
  if count gt 0 then angles[wrapidx] = angles[wrapidx] + 360
  ;; Now make a rectangular array of radius vs. angle

  pixels=fltarr(nx,ny)
  r_step=max(radii)/(nr-1)
  a_step=360./(na-1)

  for elemindex=long(0),nx*ny-1 do begin
     r = floor(radii(elemindex)/r_step)
     a = floor((angles(elemindex))/a_step)
     x=imx(elemindex)
     y=imy(elemindex)
     if finite(polar_im[a,r]) eq 1 then begin
        im[x,y] = im[x,y] + polar_im[a,r]
        pixels[x,y] = pixels[x,y] + 1
     endif 
  endfor

  good_idx=where(pixels ne 0)
  im[good_idx] = im[good_idx]/pixels[good_idx]

end
