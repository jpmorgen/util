; $Id: template_create.pro,v 1.3 2003/03/10 18:36:29 jpmorgen Exp $

; template_create

; Using a 0, two 1-D, or a 2D description, return an image of the same
; size and type as im.  x and y are labels for the  two 1-D case, but
; x ends up being a scaler or an image in the other cases

function template_create, im, description1, description2

  ON_ERROR, 2
  if N_params() eq 0 or N_params() gt 3 then $
    message,"ERROR: usage template_create, im, description1, description2"

  asize = size(im) & nx = asize(1) & ny = asize(2)

  if asize(0) ne 2 then $
    message,"ERROR: must pass a 2D image that will have the same dimensions as the template"
  template=im

  ;; No description means use average of image to calculate constant
  ;; template
  if N_params() eq 1 then begin
     template[*] = mean(im, /NAN)
     return, template
  endif     

  ;; handle single description cases
  if N_params() eq 2 then begin
     ;; Scaler description used as a constant template
     if N_elements(description1) eq 1 then begin
        template[*] = description1
        return, template
     endif

     ;; Image description is the template itself (we really didn't need to
     ;; be called for this case)
     if N_elements(description1) eq N_elements(im) then return, description1

     ;; x or y direction only.  NOTE, since we normlize the X
     ;; direction below, but not the Y direction, we have to
     ;; artificially inflate Y so that we get the correct template back
     if N_elements(description1) eq nx then begin
        for i=0,nx-1 do begin
           template[i,*] = description1[i]
        endfor
        return, template
     endif
     if N_elements(description1) eq ny then begin
        for i=0,ny-1 do begin
           template[*,i] = description1[i]
        endfor
        return, template
     endif else $
       message, "ERROR: template description must be the same size as on of the the image axes"
  endif ;; single description cases

  ;; handle two vector cases
  if N_elements(description1) gt 0 and N_elements(description2) gt 0 then begin
     x = description1
     y = description2
  endif

  ;; Y vector, X scaler
  if N_elements(x) eq 1 and $
       N_elements(y) eq ny then begin
     temp=x
     if temp eq 0 then temp = 1.
     x = fltarr(nx)
     x[*] = temp
  endif

  ;; X vector, Y scaler
  if N_elements(x) eq nx and $
       N_elements(y) eq 1 then begin
     temp=y
     if temp eq 0 then temp = 1.
     y = fltarr(ny)
     y[*] = temp
  endif

  ;; Make the 2-description template
  if N_elements(x) eq nx and N_elements(y) eq ny then begin
     x = x/mean(x, /NAN)
     ;; Doesn't seem to matter which way we go here, so normalize the
     ;; X direction, not in the y
     ;; lay the template down one column at a time
     for i=0,nx-1 do begin
        template[i,*] = x[i] * y[*]
     endfor
  endif else begin
     message, "ERROR: unknown template description type"
  endelse

  return, template
  

end

