; WHAM_polar_transform.pro

; Tue Mar  9 09:35:26 1999  jpmorgen

; cd /usr/users/jpmorgen/analysis/OI_images
; loadct, 12

function polar_transform, fname, xc, yc, phi0=phi0

  image=readfits(fname,hdr) 
  asize = size(image)
  nx = asize(1)
  ny = asize(2)
  
  if NOT keyword_set(xc) then xc = nx/2.
  if NOT keyword_set(yc) then yc = ny/2.
  if NOT keyword_set(phi0) then phi0 = 0.


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
  angles=angles*180./!pi+phi0
  wrapidx = where(angles gt 360, count)
  if count gt 0 then angles[wrapidx] = angles[wrapidx] - 360
  wrapidx = where(angles lt 0, count)
  if count gt 0 then angles[wrapidx] = angles[wrapidx] + 360
  ;; Now make a rectangular array of radius vs. angle
  nr = 101
  na = 101
  polar=fltarr(na,nr)
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
;             polar(ia,ir)=polar(ia,ir)+total(image(x,y))
;             pixels(ia,ir)=pixels(ia,ir)+1
;         end
;     end
; end

  ;; This is the easy way to do the transformation, but it leaves a
  ;; lot of empty pixels
  for elemindex=long(0),(nx-1)*(ny-1) do begin
     r = floor(radii(elemindex)/r_step)
     a = floor((angles(elemindex))/a_step)
     x=imx(elemindex)
     y=imy(elemindex)
     if finite(image[x,y]) eq 1 then begin
        polar(a,r)=polar(a,r)+image(x,y)
        pixels(a,r)=pixels(a,r)+1
     endif
  endfor

  good_idx=where(pixels ne 0)
  polar(good_idx)=polar(good_idx)/pixels(good_idx)

  ;; Fill in blank pixels using average of nearest neighbors
;  for ir=0,nr-1 do begin
;     pixidx=where(pixels(*,ir) gt 0, n)
;     if (n eq 0) then begin
;        polar(*,r)=0
;        print, 'Empty row', ir
;     end else begin
;        if (n le 2) then begin  ; spline doesn't like so few elements
;           polar(*,r)=median(polar(pixidx,ir))
;        end else begin
;           new_row=spline(pixidx, polar(pixidx,ir), indgen(na))
;           polar(*,ir)=new_row(*)
;        endelse
;     endelse
;     
;  endfor

  return, polar

end

