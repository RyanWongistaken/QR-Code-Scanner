function str = code2str(A)
parsed = A(:)';

%use side bars to determine if its a qr code or not
if A(1,1) == 1 && A(1,11) == 1 && A(11,1) == 1 && A(11, 11) == 1
    parsed([1, 2, 10, 11, 12, 13, 21, 22, 65, 66, 76, 77, 87, 88, 98, 99, ...
         100:end]) = [];
    %remove zero stuffing
    parsed([81, 82, 83]) = [];
    %convert to 8bit ascii
    str = char(bin2dec(reshape(char(parsed+'0'), 8,[]).'));
else
    str = 'One non-QR code found!';
end
end

