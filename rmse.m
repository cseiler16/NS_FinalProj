function rmsCalc = rmse(vector1, vector2)

v1Len = length(vector1);
v2Len = length(vector2);

%interpolate the smaller vector
if (v1Len < v2Len)
    vector1 = interp1(1:(v2Len/v1Len):v2Len, vector1, 1:v2Len, 'linear', 'extrap');
elseif (v2Len < v1Len)
    vector2 = interp1(1:(v1Len/v2Len):v1Len, vector2, 1:v1Len, 'linear', 'extrap');
end
% Root Mean Squared Error
rmsCalc = sqrt(mean((vector1 - vector2).^2));

end

