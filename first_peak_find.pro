; $Id: first_peak_find.pro,v 1.1 2002/12/16 18:28:31 jpmorgen Exp $

; peak_find.pro finds the first decent-sized peak in the 1D input
; array starting from the left or right side.  numerically, you need
; to specify a threshold, which by default is 10% of the max-min of
; the array.  Gausfit is used to get the best center, so if the peak
; is not vary Gaussian, use some other algorithm

function first_peak_find, yin, side, contrast=contrast, plot=plot

  ;; Work in positives 
  y = yin - min(yin, /NAN)
  npts = N_elements(y)
  side = strlowcase(side)
  ;; and from the left
  if side eq 'right' then begin
     y = reverse(y)
     peak = peak_find(y, 'left', contrast=contrast)
     peak = npts - peak
     return, peak
  endif else $
    if side ne 'left' then $
    message, 'ERROR: specify whether you are looking for an peak from the ''left'' or ''right'' side of the array'

  ;; If we got here, we are doing a standard positive peak finding
  ;; from the left side of the array and the minimum of the array is
  ;; 0.  We are looking for the first peak > threshold
  if N_elements(contrast) eq 0 then contrast = 0.1
  threshold = contrast*max(y, /NAN)
  peak_idx = where(y gt threshold, count)
  if count eq 0 then message, 'CODE ERROR: this should never happen'

  ;; Start from the left side down low
  left_idx = peak_idx[0]

  ;; Now crawl over the function, recording the local maximum until
  ;; you fall down from it by the threshold 
  right_idx = left_idx + 1
  max_idx = right_idx
  max_y = y[left_idx]
  while right_idx lt npts and y[right_idx] gt max_y - threshold do begin
     if y[right_idx] gt max_y then begin
        max_y = y[right_idx]
        max_idx = right_idx
     endif
     right_idx = right_idx + 1
  endwhile

  ;; Move the left_idx to a symetric position on the other side of
  ;; the peak
  left_idx = max_idx -1
  while left_idx gt 0 and y[left_idx] gt max_y - threshold do begin
     left_idx = left_idx - 1
  endwhile

  local_max = max(y[left_idx:right_idx], tidx)
  max_peak = tidx + left_idx
  symmetric_peak = (right_idx+left_idx)/2.
  small_reg_fit_peak = peak_find(y[left_idx:right_idx]) + left_idx

  ;; Now slide down until we hit the bottom of a valley.  We can
  ;; specify the contrast on the valley a little more finely
  min_y = y[left_idx]
  while left_idx gt 0 and $
    y[left_idx] lt min_y + contrast*threshold do begin
     if y[left_idx] lt min_y then min_y = y[left_idx]
     left_idx = left_idx - 1
  endwhile

  min_y = y[right_idx]
  while right_idx lt npts-1 and $
    y[right_idx] lt min_y + contrast*threshold do begin
     if y[right_idx] lt min_y then min_y = y[right_idx]
     right_idx = right_idx + 1
  endwhile

  large_reg_fit_peak = peak_find(y[left_idx:right_idx]) + left_idx

  best_peak = small_reg_fit_peak
  if abs(small_reg_fit_peak - large_reg_fit_peak) gt 1 then begin
     if abs(symmetric_peak - small_reg_fit_peak) gt $
       abs(symmetric_peak - large_reg_fit_peak) then begin
        best_peak = large_reg_fit_peak
     endif
     message, /CONTINUE, 'WARNING: functional fit values over two ranges disagree by more than 1 pixel.  Using ' + string(best_peak)
     print, max_peak, symmetric_peak, small_reg_fit_peak, large_reg_fit_peak
     if keyword_set(plot) then plot, yin
     ;; Hard to say exactly if this is the right thing to do, but
     ;; let's say that the small region peak is thrown off by a local
     ;; anomaly
  endif
  
  return, best_peak

end

