; $Id: edge_find.pro,v 1.1 2002/12/16 18:28:00 jpmorgen Exp $

; edge_find.pro finds the first decent-sized edge in the 1D input
; array starting from the left or right side.  The threshold is a
; percent of the maximum derivative in the array

function edge_find, yin, side, contrast=contrast

  y = yin
  npts = N_elements(y)
  side = strlowcase(side)
  if side eq 'right' then begin
     y = reverse(y)
     edge = edge_find(y, 'left', contrast=contrast)
     edge = npts - edge
     return, edge
  endif else $
    if side ne 'left' then $
    message, 'ERROR: specify whether you are looking for an edge from the ''left'' or ''right'' side of the array'

  ;; If we got here, we are doing a standard edge finding from the
  ;; left side of the array.  We are looking for the first edge >
  ;; threshold
  dy = deriv(yin)
  return, first_peak_find(dy, 'left', contrast=contrast)
end
