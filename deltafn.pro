; Tue Apr 30 09:51:13 2002  jpmorgen

function deltafn, X, Y, Yaxis, Xaxis=Xaxis

npts=N_elements(Yaxis)
newYaxis=Yaxis
; Convert X to index value instead of X axis value
if keyword_set(Xaxis) then begin
    Xindex=indgen(npts)
    X=interpol(Xindex, Xaxis, X)
end

; Make the delta function
x1 = fix(X)
x2 = x1 + 1
y1 = (x2 - X) * Y
y2 = (X - x1) * Y
newYaxis(x1) = newYaxis(x1) + y1
newYaxis(x2) = newYaxis(x2) + y2

return, newYaxis
end
