FUNCTION BOUNDRY_FIND, y_in, threshold = threshold, contrast = contrast, Singlepoint=singlepoint, ClimbFrom = climbFrom

;Find the first peak, set a min value and max value and then start homing in
;on the point of increase Establish acceptable boundries around which to base
;subsequent guesses on

data = y_in
IF KEYWORD_SET(threshold) EQ 0 THEN threshold = .1
IF KEYWORD_SET(contrast) EQ 0 THEN contrast = .01
highPoint = MAX(data)
low=highPoint*contrast
high=highPoint*threshold
IF low LT MIN(data) THEN low = data[0]

;Type casting
xTen = 0.0
xOne = 0.0

;find the first x coordinate that corresponds with the high end guess
x_index = WHERE(data GT high)
x_index2 = WHERE(data LE low)
	xTen = x_index[0]-1

IF KEYWORD_SET(singlepoint) THEN BEGIN
	toReturn = xTen
ENDIF

IF N_elements(climbFrom) ne 0 THEN BEGIN
   xten = climbFrom
   WHILE data(xTen+1) GE data(xTen) and xTen lt N_elements(data) DO BEGIN
      xTen = xTen+1
   ENDWHILE
   if xTen eq N_elements(data)-1 then $
      message, 'WARNING: no higher points than data[climbFrom] found', /CONTINUE
   toReturn = xTen
ENDIF

IF (KEYWORD_SET(singlepoint) EQ 0) and N_elements(climbFrom) EQ 0 THEN BEGIN
;Work backwords from the high end guess to find the first low end guess
	IF data(xOne) NE low THEN BEGIN
		xOne = xTen
		WHILE data(xOne - 1) GE low DO BEGIN
			xOne = xOne-1
		ENDWHILE
	ENDIF
toReturn = [xOne, xTen]
ENDIF

RETURN, toReturn
END
