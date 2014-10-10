FUNCTION ESREVER, data_in, size_in

;This function will return a data set that has had its data reversed such that it will count the
;index backwards from the index end as opposed to starting at zero.
data = data_in
dataSize = N_ELEMENTS(data)
returnData = MAKE_ARRAY(dataSize)

FOR i=0, dataSize-1 DO BEGIN
	dummy = data[i]
	dummy = size_in-dummy
	returnData[i] = dummy
ENDFOR

RETURN, returnData
END
