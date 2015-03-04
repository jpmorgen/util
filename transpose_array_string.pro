; $Id: transpose_array_string.pro,v 1.1 2002/12/16 20:04:53 jpmorgen Exp $

; Transposes IDL/FITS array strings of the format [x:y] to [y:x]
function transpose_array_string, str
  str=strtrim(str)
  toks=strsplit(str,'[,]')
  if N_elements(toks) ne 2 then message, 'ERROR: unknown array string format'
  coords=strsplit(str,'[,]',/extract)
  return, string('[',coords[1], ',', coords[0], ']')
end

