; $Id: deltafn.pro,v 1.2 2002/12/16 18:29:33 jpmorgen Exp $

; Accepts X in pixels or real units (if Xaxis is specified) + puts a
; delta function of total "area" Y (really a weighting of two adjacent
; bins) at the position specified by X.  If you pass Y as an existing
; array, the delta functions will be scaled to match it.


function deltafn, Xin, Yin, Yaxis, Xaxis=Xaxis

  npts=N_elements(Yaxis)

  newYaxis=Yaxis
  X = Xin
  ;; Check to see if we beed to convert X to index value instead of X
  ;; axis value
  if keyword_set(Xaxis) then begin
     Xindex=indgen(npts)
     X=interpol(Xindex, Xaxis, Xin)
  end

  ;; Check bounds
  if N_elements(X) eq 1 then $
    if X lt 1 or X gt npts-2 then $
    return, newYaxis

  ;; Otherwise we have an array of values
  good_idx = where(X ge 0 and X le npts-1, count)
  if count eq 0 then return, newYaxis
  temp = X[good_idx]
  X = temp

  ;; Check to see if we need are just scaling the delta functions to
  ;; some existing Y axis
  Y = Yin
  if N_elements(Yin) eq npts then begin
     ref_Y = Yin
     Y = ref_Y[fix(X)]
  endif

  ;; Make the delta function
  x1 = fix(X)
  x2 = x1 + 1
  y1 = (x2 - X) * Y
  y2 = (X - x1) * Y

  newYaxis(x1) = newYaxis(x1) + y1
  newYaxis(x2) = newYaxis(x2) + y2

  return, newYaxis
end
