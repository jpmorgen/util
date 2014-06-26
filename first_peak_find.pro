;+
; NAME: first_peak_find
;

; PURPOSE: Finds the first decent-sized peak in the 1D input array
; starting from the left or right side

;
; CATEGORY: fitting
;
; CALLING SEQUENCE: 

; peak = first_peak_find(y, ['left' | 'right'], threshold=threshold, $
;   contrast=contrast, error=error, plot=plot, yerr=yerr, quiet=quiet, $
;   poly=poly
;
; DESCRIPTION: Uses threshold and contrast to spot the first value in
;   array y that is a decent-sized peak.  Then uses peak_find to
;   get the best center and error bars of that peak coordinate.
;   Assumes that the peak value is above zero.
;
; INPUTS:
;   y: 1D array in which it find the peak
;   side: 'left' or 'right'
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
;   threshold: fraction of maximum value of y that the peak
;   value of the first peak must exceed.  Default = 0.5
;
;   contrast: amount down from the candidate peak the algorithm
;   goes in order to set the left and right limits for the final
;   call to peak_find.  Default = 0.2*threshold
;
;   error: error estimate on peak index (from peak_find)
;
;   /plot: make a plot
;
;   yerr: error bars on yin
;
;   /quiet: don't print WARNING messages.  Passed to peak_find
;
;   /poly: force use of polynomial fitting in peak_find
;
; OUTPUTS:
;   return value is index of first peak
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
; $Id: first_peak_find.pro,v 1.6 2014/06/26 17:20:09 jpmorgen Exp $
;
; $Log: first_peak_find.pro,v $
; Revision 1.6  2014/06/26 17:20:09  jpmorgen
; Improved documentation
;
;-
; $Id: first_peak_find.pro,v 1.6 2014/06/26 17:20:09 jpmorgen Exp $

; first_peak_find.pro finds the first decent-sized peak in the 1D
; input array starting from the left or right side.  peak_thresh is
; the fraction of the max that the first peak needs to be above.
; Set it to 1 to find the max.  Default=0.1.  Contrast is in the same
; units and the amount down from the peak that you need to go to
; recognize it as a peak.  peak_find is used to get the best center.

function first_peak_find, yin, side, threshold=threshold_in, $
  contrast=contrast_in, error=error, plot=plot, yerr=yerr, quiet=quiet, $
  poly=poly

  y = yin
  npts = N_elements(y)
  if npts lt 2 then $
    return, 0
  side = strlowcase(side)
  ;; and from the left
  if side eq 'right' then begin
     y = reverse(y)
     peak = first_peak_find(y, 'left', threshold=threshold_in, $
                            contrast=contrast_in, yerr=yerr, error=error, $
                            plot=plot, quiet=quiet, poly=poly)
     peak = npts-1 - peak
     return, peak
  endif else $
    if side ne 'left' then $
    message, 'ERROR: specify whether you are looking for an peak from the ''left'' or ''right'' side of the array'

  ;; If we got here, we are doing a first peak finding from the left
  ;; side of the array.  Make sure that the array has some positive
  ;; elements.
  pos_idx = where(y gt 0, count)
  if count lt 3 then begin
     if NOT keyword_set(quiet) then $
       message, 'WARNING: input array has less than 3 positive elements.  Subtracting the minimum element from all points', /CONTINUE
     y = y - min(y, /NAN)
  endif

  ;; Set up default threshold and contrast.  This is really
  ;; application specific.  Check things out with the plot='title'
  ;; option to see what you need.
  if N_elements(threshold_in) eq 0 then begin
     threshold_in = 0.5
  endif
  threshold = threshold_in*max(y, /NAN)

  if N_elements(contrast_in) eq 0 then begin
     contrast_in = 0.2 * threshold_in
  endif
  contrast = contrast_in*max(y, /NAN)

  ;; Where handles NAN properly in this context
  peak_idx = where(y ge threshold, count)
  if count eq 0 then message, 'ERROR: Threshold of ' + string(threshold_in) + ' too high'

  ;; Start from the left side down low
  left_idx = peak_idx[0]

  ;; Now crawl over the function, recording the local maximum until
  ;; you fall down from it by the threshold 
  right_idx = left_idx + 1
  if right_idx ge npts then right_idx = npts-1
  max_idx = right_idx
  max_y = y[left_idx]
  while right_idx lt npts-1 and $
    (y[right_idx] gt max_y - contrast or finite(y[right_idx]) eq 0) do begin
     if y[right_idx] gt max_y then begin
        max_y = y[right_idx]
        max_idx = right_idx
     endif
     right_idx = right_idx + 1
  endwhile

  ;; Move the left_idx to a symetric position on the other side of
  ;; the peak
  left_idx = max_idx -1
  while left_idx gt 0 and $
    (y[left_idx] gt max_y - contrast or finite(y[left_idx]) eq 0) do begin
     left_idx = left_idx - 1
  endwhile

  local_max = max(y[left_idx:right_idx], tidx, /NAN)
  max_peak = tidx + left_idx
  symmetric_peak = (right_idx+left_idx)/2.
  symmetric_error = (right_idx-left_idx)/2.

  small_reg_fit_peak = peak_find(y[left_idx:right_idx], yerr=yerr, $
                                 error=small_reg_error, quiet=quiet, $
                                poly=poly) + left_idx

  ;; Don't bother with a large region if we have a narrow peak
  large_reg_fit_peak = !values.f_nan
  large_reg_error = !values.f_nan
  if symmetric_error gt 3 then begin
     ;; Now slide down until we hit the bottom of a valley.  We can
     ;; specify the contrast on the valley a little more finely
     min_y = y[left_idx]
     while left_idx gt 0 and $
       (y[left_idx] lt min_y + contrast or finite(y[left_idx]) eq 0) do begin
        if y[left_idx] lt min_y then min_y = y[left_idx]
        left_idx = left_idx - 1
     endwhile
     
     min_y = y[right_idx]
     while right_idx lt npts-1 and $
       (y[right_idx] lt min_y + contrast or finite(y[right_idx]) eq 0) do begin
        if y[right_idx] lt min_y then min_y = y[right_idx]
        right_idx = right_idx + 1
     endwhile
     
     large_reg_fit_peak = peak_find(y[left_idx:right_idx], $
                                    yerr=yerr, error=large_reg_error, $
                                    quiet=quiet, poly=poly) + left_idx
  endif ;; Large region needed
     
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
     error = symmetric_error
  endif
  
  ;; If we have a broad peak and the different fit regions don't agree
  ;; on a center to beter than 1 pixel, raise an error and print some
  ;; diagnostic info
  if symmetric_error gt 1 and $
    abs(small_reg_fit_peak - large_reg_fit_peak) gt 1 and $
    NOT keyword_set(quiet) then begin
     message, /CONTINUE, 'WARNING: functional fit values over two ranges disagree by more than 1 pixel.  Using ' + string(best_peak) + '+/-' + string(error)
     print, '      max_peak     symmetric_peak      small_reg_fit_peak  large_reg_fit_peak'
     print, string(format='(f8.3, " +/- NaN", f8.3, " +/- ", f8.3, f8.3, " +/- ", f8.3, f8.3, " +/- ", f8.3)', $
                   max_peak, symmetric_peak, symmetric_error, $
                   small_reg_fit_peak, small_reg_error, $
                   large_reg_fit_peak, large_reg_error)
  endif
  if keyword_set(plot) then begin
     plot, yin, title=plot
     if keyword_set(yerr) then $
       oploterr, yin, yerr
     print, '      max_peak     symmetric_peak      small_reg_fit_peak  large_reg_fit_peak'
     print, string(format='(f8.3, " +/- NaN", f8.3, " +/- ", f8.3, f8.3, " +/- ", f8.3, f8.3, " +/- ", f8.3)', $
                   max_peak, symmetric_peak, symmetric_error, $
                   small_reg_fit_peak, small_reg_error, $
                   large_reg_fit_peak, large_reg_error)
     print, string(format='("BEST PEAK: ", f8.3, " +/- ", f8.3)', $
                   best_peak, error)
     plots, [best_peak, best_peak], [-1E32,1E32]
     plots, [best_peak-error, best_peak-error], [-1E32,1E32], linestyle=2
     plots, [best_peak+error, best_peak+error], [-1E32,1E32], linestyle=2
  endif
  
  return, best_peak

end

