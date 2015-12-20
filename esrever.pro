;+
; NAME: ESREVER

; PURPOSE: flip indices into a 1-D array from the 0th element to the
; N-th minus 1 element.  Useful when working with an algorithm, such
; as marks_edge_find.pro, which is designed to work from one side of
; an array only (e.g. the left side) and just reverse() the array when
; working from the right side

; CATEGORY: fitting
;
; CALLING SEQUENCE:
;  IF KEYWORD_SET(Right) THEN BEGIN
;  	data = REVERSE(data)
;  	RETURN, ESREVER(MARKS_EDGE_FIND(data, Deviation=deviation, Value=value, Deriv1=deriv1, Deriv2=deriv2, Left=1, FirstDeriv = firstDeriv, SecondDeriv=secondDeriv), data)
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
; EXAMPLE: see calling sequence.  Note that passing data as
; size_or_data is efficient as long as data is a variable that can be
; passed by reference.  If it is an expression, it would be better to
; calculate the N_elements and pass that to esrever
;
; MODIFICATION HISTORY:
;
; $Id: esrever.pro,v 1.3 2015/03/02 21:53:29 jpmorgen Exp $
;
; $Log: esrever.pro,v $
; Revision 1.3  2015/03/02 21:53:29  jpmorgen
; Summary: Check in code changes, improve documentation
;
; Revision 1.2  2014/11/05 03:03:24  jpmorgen
; About to install new version
;
;-
FUNCTION ESREVER, idx, size_or_data;;, error=Error

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
  toReturn = dataSize-1 - idx

;; Handled this with an error keyword in marks_edge_find
;;;Account for possible elements that the user does not want un-reversed
;;	if KEYWORD_SET(error) then begin
;;		staticNumber = N_ELEMENTS(error)
;;		for i=0, staticNumber-1 DO BEGIN
;;			toReturn[error[i]] = idx[error[i]]
;;		ENDFOR
;;	ENDIF
return, toReturn
END
