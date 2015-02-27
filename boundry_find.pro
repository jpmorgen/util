FUNCTION BOUNDRY_FIND, y_in, threshold = threshold, contrast = contrast, Singlepoint=singlepoint

;Find the first peak, set a min value and max value and then start homing in
;on the point of increase Establish acceptable boundries around which to base
;subsequent guesses on

data = y_in
IF KEYWORD_SET(threshold) EQ 0 THEN threshold = .1
IF KEYWORD_SET(contrast) EQ 0 THEN contrast = .01
highPoint = MAX(data)
low=highPoint*contrast
high=highPoint*threshold
xTen = 0
xOne = 0

;find the first x coordinate that corresponds with the high end guess
x_index = WHERE(data GT high)
x_index2 = WHERE(data LE low)
	xTen = x_index[0]-1

IF KEYWORD_SET(singlepoint) THEN BEGIN
	toReturn = xTen
ENDIF ELSE BEGIN
;Work backwords from the high end guess to find the first low end guess
	IF data(xOne) NE low THEN BEGIN
		xOne = xTen
		WHILE data(xOne - 1) GE low DO BEGIN
			xOne = xOne-1
		ENDWHILE
	ENDIF
toReturn = [xOne, xTen]
ENDELSE

RETURN, toReturn
END
