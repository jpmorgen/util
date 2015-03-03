; +
; $Id: array_append.pro,v 1.2 2015/03/03 19:12:04 jpmorgen Exp $

;; --> NOTE that this is obselete.  It works fine for simple arrays,
;; but for structures you will want pfo_array_append

; array_append 

; Define or extend an array.  To reset a list, set orig_array to a
; scaler of different type from more_array:
;
; for i=0,10 do array=array_append(i, array) 
; print, array
; for i=0,10 do array=array_append(i, array) 
; print, array
; array = !values.d_nan
; for i=0,10 do array=array_append(i, array) 
; print, array

; Beware that this makes a copy of the original array, so if you are
; using this to build up a large array, you'd be better off operating
; with some other algorithm, e.g., pre-defining the array to its
; maximum length and handling things with counters, or null terminators.

; -

function array_append, more_array, orig_array, null_array=null_array

  ;; Any errors will probably make more sense in the calling code
  on_error, 2

  ;; Trivial case
  if N_elements(orig_array) eq 0 then $
    return, more_array

  ;; Next easiest case: we are up and running with an existing array.
  ;; Let IDL's error handling take care of type mismatches
  if N_elements(orig_array) gt 1 then $
    return, [orig_array, more_array] 


  ;; A one element original array is somewhat more ambiguous. 
  if N_elements(orig_array) eq 1 then begin
     ;; If the types don't match, we are starting over with more_array
     if size(orig_array, /type) ne size(more_array, /type) then $
       return, more_array
     ;; The types match.  See if orig_array is null_array.
     ;; Don't use keyword_set, since null is usually passed :-0
     if N_elements(null_array) ne 0 then $
       if orig_array eq null_array then $
         return, more_array
  endif ;; one element array

  ;; Having handled the special cases, let IDL do the rest
  return, [orig_array, more_array]

end
