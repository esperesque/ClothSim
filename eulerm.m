function [y_next] = eulerm(y,dy,h)
%EULER Summary of this function goes here
%   Detailed explanation goes here
y_next = y + h*dy;
end

