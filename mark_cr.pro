;+
; $Id: mark_cr.pro,v 1.1 2002/12/16 20:06:20 jpmorgen Exp $

; mark_cr Uses a simple median filter subtraction algorithm to find
; really bright single pixels in an image


;-

function mark_cr, im, width=width, cutval=cutval

  if NOT keyword_set(width) then width = 3
  if NOT keyword_set(cutval) then cutval = 7
  filt_im = median(im, width)
  flatim = median(im-filt_im, width)
  template = template_create(im, flatim)  
  sigma = template_statistic(im, template)
  badim = mark_bad_pix(sigma, cutval=cutval)
  return, badim
end
