; $Id: normalize.pro,v 1.2 2003/03/10 18:36:23 jpmorgen Exp $

; Normalize an array of arbitrary dimensions, ignoring all pixels
; below a cut value of cut.  Algorithm is iterative.  The first
; normalization factor is 1/median(im)

function normalize, $
   input_im, $
   cut, $
   first_mean=first_mean, $ ;; first normalization factor.  If not specified, median is used
   factor=factor ;; Return keyword is the factor by which the image was divided to normlize it
  ON_ERROR, 2
  if NOT keyword_set(cut) then cut = 0
  if cut lt 0 or cut ge 1 then $
    message, 'ERROR: cut must be between 0 and 1 (inclusive)'

  ;; By default, assume that the median is the best starting mean.
  ;; This avoids being biased by extreme values.  However, for arrays
  ;; with lots of small values and only a few high values that you
  ;; want to normalize, this doesn't work, so enable a keyword
  ;; to do the initialization
  if N_elements(first_mean) eq 0 then $
     mean_of_im = median(input_im) $
  else $
     mean_of_im = first_mean

  count = 0
  repeat begin
     last_num = count
     norm_im = input_im / mean_of_im
     good_idx = where(norm_im gt cut, count) ;; this excludes NANs too
     if count eq 0 then message, $
        'ERROR: cut value of ' + string(cut) + ' resulted in no good pixels.'
     mean_of_im = mean(input_im[good_idx], /NAN)
  endrep until last_num eq count
  factor = 1. / mean_of_im
  return, input_im / mean_of_im


  ;;;; Start with max pixel = 1
  ;;imax = max(input_im, /NAN)
  ;;if imax le 0 then $
  ;;  message, 'ERROR: don''t know how to normalize negative or zero arrays'
  ;;im = input_im / imax
  ;;
  ;;good_idx = where(im gt cut, count)
  ;;last_num = 0
  ;;while last_num ne N_elements(good_idx) do begin
  ;;   if count eq 0 then message, 'ERROR: cut value of ' + string(cut) + ' resulted in no good pixels.  Choose something between 0 and 1'
  ;;   last_num = N_elements(good_idx)
  ;;   im = im/mean(im[good_idx], /NAN)
  ;;   good_idx = where(im gt cut, count)
  ;;endwhile
  ;;
  ;;factor = median(im/input_im)
  ;;
  ;;return, im
end
