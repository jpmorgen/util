; $Id: first_peak_find.pro,v 1.2 2003/03/10 18:35:10 jpmorgen Exp $

; first_peak_find.pro finds the first decent-sized peak in the 1D
; input array starting from the left or right side.  numerically, you
; need to specify a threshold, which by default is 10% of the max-min
; of the array.  Gausfit is used to get the best center, so if the
; peak is not vary Gaussian, use some other algorithm

function first_peak_find, yin, side, contrast=contrast, plot=plot, $
  yerr=yerr, error=error

  ;; Work in positives 
  y = yin - min(yin, /NAN)
  npts = N_elements(y)
  side = strlowcase(side)
  ;; and from the left
  if side eq 'right' then begin
     y = reverse(y)
     peak = first_peak_find(y, 'left', contrast=contrast, yerr=yerr, $
                            error=error)
     peak = npts - peak
     return, peak
  endif else $
    if side ne 'left' then $
    message, 'ERROR: specify whether you are looking for an peak from the ''left'' or ''right'' side of the array'

  ;; If we got here, we are doing a standard positive first peak
  ;; finding from the left side of the array and the minimum of the
  ;; array is 0.  We are looking for the first peak > threshold

  ;; Default contrast is wither 10% or 10 times the median error bar
  if N_elements(contrast) eq 0 then begin
     contrast = 0.1
     if keyword_set(yerr) then $
       contrast = 10.*median(yerr/y)
  endif

  threshold = contrast*max(y, /NAN)
  peak_idx = where(y gt threshold, count)
  if count eq 0 then message, 'CODE ERROR: this should never happen'

  ;; Start from the left side down low
  left_idx = peak_idx[0]

  ;; Now crawl over the function, recording the local maximum until
  ;; you fall down from it by the threshold 
  right_idx = left_idx + 1
  if right_idx ge npts then right_idx = npts-1
  max_idx = right_idx
  max_y = y[left_idx]
  while right_idx lt npts-1 and y[right_idx] gt max_y - threshold do begin
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
  symmetric_error = (right_idx-left_idx)/2.

  small_reg_fit_peak = peak_find(y[left_idx:right_idx], yerr=yerr, $
                                 error=small_reg_error) + left_idx

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

  large_reg_fit_peak = peak_find(y[left_idx:right_idx], $
                                 yerr=yerr, error=large_reg_error) + left_idx
  
  
  ;; Select best peak among our several choices.  There are two things
  ;; to consider here: sensibility of the answers and size of the
  ;; uncertainty in the answer
  best_peak = symmetric_peak
  error = symmetric_error

  if (best_peak - error) lt large_reg_fit_peak and $
    large_reg_fit_peak lt (best_peak + error) and $
    large_reg_error le error then begin
     best_peak = large_reg_fit_peak
     error = large_reg_error
  endif

  if (best_peak - error) lt small_reg_fit_peak and $
    small_reg_fit_peak lt (best_peak + error) and $
    small_reg_error le error then begin
     best_peak = small_reg_fit_peak
     error = small_reg_error
  endif

  ;; If our fancy fits were crummy, just go with the maximum point.
  ;; Use the range over which we looked as the error estimate.
  if best_peak eq symmetric_peak then begin
     best_peak = max_peak
     error = npts/2.
  endif
  
  ;; If we have a broad peak and the different fit regions don't agree
  ;; on a center to beter than 1 pixel, raise an error and print some
  ;; diagnostic info
  if symmetric_error gt 1  and $
    abs(small_reg_fit_peak - large_reg_fit_peak) gt 1 then begin
     message, /CONTINUE, 'WARNING: functional fit values over two ranges disagree by more than 1 pixel.  Using ' + string(best_peak) + '+/-' + string(error)
     print, '      max_peak     symmetric_peak      small_reg_fit_peak  large_reg_fit_peak'
     print, string(format='(f8.3, " +/- NaN", f8.3, " +/- ", f8.3, f8.3, " +/- ", f8.3, f8.3, " +/- ", f8.3)', $
                   max_peak, symmetric_peak, symmetric_error, $
                   small_reg_fit_peak, small_reg_error, $
                   large_reg_fit_peak, large_reg_error)
  endif
  if keyword_set(plot) then begin
     plot, yin
     if keyword_set(yerr) then $
       oploterr, yin, yerr
     print, '      max_peak     symmetric_peak      small_reg_fit_peak  large_reg_fit_peak'
     print, string(format='(f8.3, " +/- NaN", f8.3, " +/- ", f8.3, f8.3, " +/- ", f8.3, f8.3, " +/- ", f8.3)', $
                   max_peak, symmetric_peak, symmetric_error, $
                   small_reg_fit_peak, small_reg_error, $
                   large_reg_fit_peak, large_reg_error)
  endif
  
  return, best_peak

end

