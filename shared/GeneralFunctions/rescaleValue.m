% rescale the value x to the min value a and max value b

function y = rescaleValue(x,xmin,xmax,a,b)

    y = ((b-a) .* (x-xmin) / (xmax-xmin)) + a;
end