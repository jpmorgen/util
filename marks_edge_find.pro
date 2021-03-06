FUNCTION MARKS_EDGE_FIND, data_in, Deviation=deviation, Value=value, Deriv1=deriv1, Deriv2=deriv2, Left = left, Right = right, Firstderiv=firstderiv, SecondDeriv=secondDeriv, climbFrom=climbFrom, error=error, quiet=quiet, _Extra = ex

IF KEYWORD_SET(left) EQ 0 AND KEYWORD_SET(Right) EQ 0 THEN BEGIN
	MESSAGE, 'Please specify left or right'
ENDIF


data=data_in

IF KEYWORD_SET(Right) THEN BEGIN
   ndata = N_ELEMENTS(data)
   data = REVERSE(data)
   if N_elements(climbFrom) ne 0 then begin
      rclimbFrom=ESREVER(climbFrom, ndata)
   endif
   RETURN, ESREVER(MARKS_EDGE_FIND(data, Deviation=deviation, Value=value, Deriv1=deriv1, Deriv2=deriv2, Left=1, FirstDeriv = firstDeriv, SecondDeriv=secondDeriv, climbFrom=rclimbFrom, error=error, quiet=quiet, _EXTRA=ex), ndata)
ENDIF


IF KEYWORD_SET(ex) THEN BEGIN
	IF KEYWORD_SET(Deriv1) and KEYWORD_SET(Deriv2) THEN BEGIN
		MESSAGE, 'extra keywords ambiguous, please recall methods with proper input'
	ENDIF
	IF KEYWORD_SET(Deviation) THEN BEGIN
		MESSAGE, 'extra keywords ambiguous, please recall methods with proper input'
	ENDIF
ENDIF


IF KEYWORD_SET(deviation) THEN BEGIN
	IF KEYWORD_SET(value) EQ 0 THEN value = MARKS_EDGE_FIND(data, Value=1, Left=1, quiet=quiet)
	IF KEYWORD_SET(deriv1) EQ 0 THEN deriv1 = MARKS_EDGE_FIND(data, left=1, deriv1=1, firstDeriv=firstderiv, quiet=quiet)
	IF KEYWORD_SET(deriv2) EQ 0 THEN deriv2 = MARKS_EDGE_FIND(data, left=1, deriv2=1, secondDeriv=secondderiv, quiet=quiet)
	
	deviation = value[1] - value[0]
	bounds = value[1]
	sum = 2
	
	IF deriv1 LE value[1] and deriv1 GE value[0] THEN BEGIN
		bounds=deriv1
		deviation=deviation+(deriv1-value[0])
		sum=sum+1
	ENDIF	
	IF deriv2 LE value[1] and deriv2 GE value[0] THEN BEGIN
		bounds=deriv2
		deviation = deviation+(deriv2-value[0])
		sum=sum+1
	ENDIF
error = (deviation/sum)
RETURN, bounds
ENDIF

IF KEYWORD_SET(value) THEN BEGIN
	RETURN, BOUNDRY_FIND(data, climbFrom=climbFrom, _EXTRA=ex)
ENDIF

IF KEYWORD_SET(deriv1) THEN BEGIN
	IF N_elements(firstDeriv) EQ 0 THEN BEGIN
		firstDeriv=DERIV(data)
	ENDIF
	RETURN, FIRST_PEAK_FIND(firstDeriv, 'left', quiet=quiet, _EXTRA=ex)
ENDIF

IF KEYWORD_SET(deriv2) THEN BEGIN
	IF KEYWORD_SET(secondDeriv) EQ 0 THEN BEGIN
		secondDeriv=DERIV(DERIV(data))
	ENDIF
	RETURN, FIRST_PEAK_FIND(secondDeriv, 'left', quiet=quiet, _EXTRA=ex)
ENDIF

MESSAGE, 'please specify a keyword to perform data operations.'
END


