; $Id: center_of_gravity.pro,v 1.1 2002/12/16 20:20:30 jpmorgen Exp $

function center_of_gravity, image

asize = size(image)
nx = asize(1)
ny = asize(2)
ixmdx = 0
iymdy = 0

for x = 0,nx-1 do begin
    ixmdx = ixmdx + x*total(image(x,*))
end
for y = 0,ny-1 do begin
    iymdy = iymdy + y*total(image(*,y))
end

cog=[ixmdx,iymdy]/total(image)
;print, 'center of gravity: ', cog

return, cog

end

