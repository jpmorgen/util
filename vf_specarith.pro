; Wed Dec  5 00:11:08 2001  jpmorgen
;
; vf_specarith 
; 
; Add or subtract voigt fit spectra and optionally
; correct for comet motion from ephemeris contained in fitsname file.
; Writes three column spectral ascii file to outname.  Specify noquad
; to avoid adding the third columns in quadrature.  In this case, the
; third column of the first file is used.

; Unlike specarith, uses read_ascii and doesn't check pressure
; similarity or anything like that.  Assumes airmass correction is
; done elsewhere.

function vf_specarith, operation, fname1, fname2, title, noplot=noplot, fitsname=fitsname, outname=outname, noquad=noquad

if n_params() eq 0 then message, 'Usage vf_specarith [operation] base1 [base2]'
if n_params() eq 1 then begin
    fname1 = operation
endif
if n_params() eq 3 then begin
    title = ''
endif
deldot=0
if (N_elements(fitsname) ne 0) then begin
    im=readfits(fitsname,hdr)
    deldot = sxpar(hdr,'DELDOT')
    if (!ERR eq -1) then deldot=0
endif

restore,'~/pro/fitting/vf.template'
if file_test(fname1) eq 0 then return, -1
spec1=read_ascii(fname1,template=vf_template)
plot_spec=spec1
; column names are for [f]savefit.  In normal 3 column spectra, yfit
; are the real data values and y are the errors
if n_params() ge 3 then begin
    spec2=read_ascii(fname2,template=vf_template)
    if (strpos(operation, 'minus') ne -1) then begin
        plot_spec.yfit= spec1.yfit-spec2.yfit
        if (not keyword_set(noquad)) then begin
            plot_spec.y = sqrt(spec1.y^2+spec2.y^2)
        endif
    endif else begin
        if (strpos(operation, 'plus') ne -1) then begin
            plot_spec.yfit = spec1.yfit+spec2.yfit
            if (not keyword_set(noquad)) then begin
                plot_spec.y = sqrt(spec1.y^2+spec2.y^2)
            endif
        endif else begin
            msg = string('Operation, ', operation, ' is an unrecognized or unimplremented operation.')
            message, msg
        endelse
    endelse
    subtitle = string(format = '(a," ",a," ",a)',fname1, operation, fname2)
endif

plot_spec.X = plot_spec.X - deldot

if (not keyword_set(noplot)) then begin
    plot,plot_spec.X,plot_spec.yfit, xtitle = 'Velocity (km/s, zero arbitrary)', ytitle = 'Ringsum (ADU/s)', title = title, subtitle = subtitle
endif

if (keyword_set(outname)) then begin
    get_lun, lun
    openw, lun, outname
    for i=0,N_elements(plot_spec.X) - 1 do begin
        printf, lun, plot_spec.x[i], plot_spec.yfit[i], plot_spec.y[i]
    endfor
    close, lun
    free_lun, lun
endif

return, plot_spec
end
