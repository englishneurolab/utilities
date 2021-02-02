function [newsignal] = minMaxNormalize(oldsignal)


newsignal = oldsignal-min(oldsignal) / max(oldsignal) - min(oldsignal);
end

