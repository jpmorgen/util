; $Id: normalize.pro,v 1.1 2002/12/16 20:06:34 jpmorgen Exp $

; Normalize an image, setting all pixels below cut to NAN

function normalize, input_im, cut
  ON_ERROR, 2
  if NOT keyword_set(cut) then cut = 0
  if cut lt 0 or cut ge 1 then $
    message, 'ERROR: cut must be between 0 and 1 (inclusive)'
  ;; Start with max pixel = 1
  imax = max(input_im, /NAN)
  if imax le 0 then $
    message, 'ERROR: don''t know how to normalize negative or zero arrays'
  im = input_im / imax

  good_idx = where(im gt cut, count)
  last_num = 0
  while last_num ne N_elements(good_idx) do begin
     if count eq 0 then message, 'ERROR: cut value of ' + string(cut) + ' resulted in no good pixels.  Choose something between 0 and 1'
     last_num = N_elements(good_idx)
     im = im/mean(im[good_idx], /NAN)
     good_idx = where(im gt cut, count)
  endwhile

  return, im
end
