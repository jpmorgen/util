; $Id: template_statistic.pro,v 1.1 2002/12/16 20:06:55 jpmorgen Exp $

; template_statistic

; Using a 0, two 1-D, or a 2D template as a model, calculates the
; standard deviation of the data (a 2D image) from that model,
; returning it in an array.

function template_statistic, im, model, poisson=poisson

  deviation = im - model

  if NOT keyword_set(poisson) then begin
     ;; We are not sure of the statistics of the image.  Just subtract
     ;; and send back the deviations normalized to the stdev
     sigma = deviation/stddev(deviation, /NAN)
     return, sigma
  endif

  ;; Poisson statistics.  Let's do it by assuming the model is the
  ;; true parent population, so define errors in terms of that
  err_im = sqrt(model)
  sigma = deviation/err_im

  return, sigma
end

