;+
; $Id: polar_transform.pro,v 1.6 2003/06/16 21:39:02 jpmorgen Exp $

; polar_transform  Takes the polar transform of an image.  The number
; of rectangular image pixels contributing to each transformed pixel
; image is contained in the optional parameter pixels

pro polar_transform, im, polar_im, xc, yc, rscale=rscale, phi0=phi0, $
                     pixels=pixels

  asize = size(im) 
  nx = asize(1)
  ny = asize(2)
  
  if NOT keyword_set(xc) then xc = nx/2.
  if NOT keyword_set(yc) then yc = ny/2.
  if NOT keyword_set(phi0) then phi0 = 0.
  if NOT keyword_set(rscale) then rscale = 1.

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
;print,imx,imy

; ; Try to fill in all the pixels in each row--didn't work
; for ir=0,nr-1 do begin
;     rl = (ir) * r_step
;     rh = (ir + 1) * r_step
;     ridx=where((radii ge rl) and (radii lt rh))
; ;    print,'ridx=',ridx
; ;    print,'radii(ridx)=',radii(ridx)
; ;    print,'angles(ridx)=',angles(ridx)
;     for ia=0,na-1 do begin
;         al = (ia) * a_step - 180.
;         ah = (ia + 1) * a_step - 180.
; ;        print,'ridx=',ridx
; ;        print,"al, ah",al, ah
; ;        print,"rl, rh",rl, rh
;         idx=where((angles(ridx) ge al) and (angles(ridx) lt ah),n)
;         if (n gt 0) then begin
;             x=imx(ridx(idx))
;             y=imy(ridx(idx))
; ;            print,'idx=', idx
; ;            print,'ridx(idx)=', ridx(idx)
; ;            print,'radii(ridx(idx))=',radii(ridx(idx))
; ;            print,"idx=",idx, "al, ah",al, ah
; ;            print,"rl, rh",rl, rh
; ;            print,"x,y",x,y
;             polar_im(ia,ir)=polar_im(ia,ir)+total(im(x,y))
;             pixels(ia,ir)=pixels(ia,ir)+1
;         end
;     end
; end

  ;; This is the easy way to do the transformation, but it leaves a
  ;; lot of empty pixels
  for elemindex=long(0),nx*ny-1 do begin
     r = floor(radii(elemindex)/r_step)
     a = floor((angles(elemindex))/a_step)
     x=imx(elemindex)
     y=imy(elemindex)
     if finite(im[x,y]) eq 1 then begin
        polar_im(a,r)=polar_im(a,r)+im(x,y)
        pixels(a,r)=pixels(a,r)+1
     endif
  endfor

  good_idx=where(pixels ne 0)
  polar_im(good_idx)=polar_im(good_idx)/pixels(good_idx)

  ;; Fill in blank pixels using average of nearest neighbors
;  for ir=0,nr-1 do begin
;     pixidx=where(pixels(*,ir) gt 0, n)
;     if (n eq 0) then begin
;        polar_im(*,r)=0
;        print, 'Empty row', ir
;     end else begin
;        if (n le 2) then begin  ; spline doesn't like so few elements
;           polar_im(*,r)=median(polar_im(pixidx,ir))
;        end else begin
;           new_row=spline(pixidx, polar_im(pixidx,ir), indgen(na))
;           polar_im(*,ir)=new_row(*)
;        endelse
;     endelse
;     
;  endfor

end

