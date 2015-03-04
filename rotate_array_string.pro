; $Id: rotate_array_string.pro,v 1.1 2003/03/10 18:34:15 jpmorgen Exp $

; Rotates IDL/FITS array strings of the format [x1:y1,x2:y2] following
; the convention of IDL's rotate command

function rotate_array_string, sub_array, full_array, dir
  sub_array=strtrim(sub_array)
  full_array=strtrim(full_array)

  toks=strsplit(sub_array,'[,:]')
  if N_elements(toks) ne 4 then message, 'ERROR: unknown array subarray string format'
  toks=strsplit(full_array,'[,:]')
  if N_elements(toks) ne 4 then message, 'ERROR: unknown array full array string format'

  ;; The FITS array specifications start a 1, IDL starts at 0.  I
  ;; think in IDL, so lets just translate to that frame and back again.
  sub_coords  = fix(strsplit (sub_array,'[:,]',/extract))-1
  full_coords = fix(strsplit(full_array,'[:,]',/extract))-1
  new_coords = intarr(4)


  case dir of
     0: new_coords = sub_coords ;; Do nothing
     1: begin ;; 90 counterclockwise
        new_coords[0] = full_coords[3]-sub_coords[3]
        new_coords[1] = full_coords[3]-sub_coords[2]
        new_coords[2] = sub_coords[0]               
        new_coords[3] = sub_coords[1]               
     end                                            
     2: begin ;; 180 counterclockwise               
        new_coords[0] = full_coords[1]-sub_coords[1]
        new_coords[1] = full_coords[1]-sub_coords[0]
        new_coords[2] = full_coords[3]-sub_coords[3]
        new_coords[3] = full_coords[3]-sub_coords[2]
     end                                            
     3: begin ;; 270 counterclockwise               
        new_coords[0] = sub_coords[2]               
        new_coords[1] = full_coords[3]-sub_coords[3]
        new_coords[2] = full_coords[1]-sub_coords[1]
        new_coords[3] = full_coords[1]-sub_coords[0]
     end
     4: begin ;; Transpose only
        new_coords[0] = sub_coords[2]
        new_coords[1] = sub_coords[3]
        new_coords[2] = sub_coords[0]
        new_coords[3] = sub_coords[1]
     end
     5: begin ;; Rotate 90 clockwise and transpose
        temp = rotate_array_string(sub_array, full_array, 3)
        return, rotate_array_string(sub_array, full_array, 4)
     end
     6: begin ;; Rotate 180 clockwise and transpose
        temp = rotate_array_string(sub_array, full_array, 2)
        return, rotate_array_string(sub_array, full_array, 4)
     end
     7: begin ;; Rotate 270 clockwise and transpose 
        temp = rotate_array_string(sub_array, full_array, 1)
        return, rotate_array_string(sub_array, full_array, 4)
     end
     else: message, 'ERROR: usage is result = rotate_array_string(sub_array, full_array, dir), where dir is 0-7, as in IDL''s routine rotate'
  endcase

  ;; Translate back into FITS standard array reference, which starts
  ;; at 1
  new_coords = new_coords + 1
  return, string('[',strtrim(new_coords[0],2), ':', $
                 strtrim(new_coords[1],2), ',', $
                 strtrim(new_coords[2],2), ':', $
                 strtrim(new_coords[3],2), ']')

end

