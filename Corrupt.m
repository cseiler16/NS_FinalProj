function result_array = corrupt(x)
%BERCalc
%close all;
%BER = berOQPSK2450(10);
BER = 0.01;
len = length(x);
BER_losses = ceil(BER*len);
i = randperm(len,BER_losses);
for k=1:length(i)
    x(k) = [];
    end
result_array = x;
end