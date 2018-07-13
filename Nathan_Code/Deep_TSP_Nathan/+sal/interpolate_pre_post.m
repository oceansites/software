function [ dft ] = interpolate_pre_post( precal, postcal )
adj_interp = zeros(1,length(precal))';
for i=1:length(precal)
    adj_interp(i) = ((i-1)/(length(precal)-1)) * (postcal(i)-precal(i));
end
% adj_interp is a ratio of the distance between the pre and post cal data.
dft = precal + adj_interp; 
end

