;+
; NAME: ESREVER
;
; PURPOSE: flip indices into a 1-D array from the 0th element to the
; N-th minus 1 element.  Useful when working with an algorithm which 
;
; CATEGORY:
;
; CALLING SEQUENCE:
;  IF KEYWORD_SET(Right) THEN BEGIN
;  	data = REVERSE(data)
;  	RETURN, ESREVER(MARKS_EDGE_FIND(data, Deviation=deviation, Value=value, Deriv1=deriv1, Deriv2=deriv2, Left=1, FirstDeriv = firstDeriv, SecondDeriv=secondDeriv), N_ELEMENTS(data))
;  ENDIF

;
; DESCRIPTION:
;
; INPUTS: 
;	idx: array of indices into data
; 	size_or_data: N_elements(data) or data itself, where data has
; 		      been reversed and fed into something like an
; 		      edge or peak-finding algorithm
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
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
; $Id: esrever.pro,v 1.2 2014/11/05 03:03:24 jpmorgen Exp $
;
; $Log: esrever.pro,v $
; Revision 1.2  2014/11/05 03:03:24  jpmorgen
; About to install new version
;
;-
FUNCTION ESREVER, idx, size_or_data

  ;; Make sure inputs are specified
  if N_elements(idx) + N_elements(size_or_data) eq 0 then $
     message, 'ERROR: usage: ESREVER, idx, size_or_data'

  ;; Figure out the size of our original data array.  Do it this way
  ;; so user can pass array (by reference) or N_elements(array)
  if N_elements(size_or_data) eq 1 then begin
     ;; assume this is the N_elements(data) case
     dataSize = size_or_data
  endif else begin
     dataSize = N_elements(size_or_data)
  endelse

  ;; Count the indices backward from the right-hand (last) index into
  ;; the array
  return, dataSize-1 - idx
END
