function I = QReader(A)

% clean image
A = medfilt2(A, 'symmetric');
A = imsharpen(A);
A = imbinarize(A,'global');
A = A * 255;

% Remove surrounding white space starting with top left corner
A(1, :) = [];
A(:, 1) = [];
[m, n] = size(A);
count = 0;
for row = 1:m
    for col = 1:floor(n/7)
        if A(row, col) < 112
            if count == 0
                start_col = col;
                start_row = row;
                count = 1;
            end
        end
    end
end


A2 = A([start_row:end], [ start_col:end]);

A2(1, :) = [];
[m, n] = size(A2);

count = 0;

% remove surroudning white space with bottom right corner
for row = n:-1:1
    for col = m:-1:1
        if count == 0
            if A2(col, row) < 112
                count = 1;
                location1 = col;
                location2 = row;
            end         
        end
    end
end
if location2 > size(A2, 1)
    location2 = size(A2,1);
end

A2 = A2([1:location2], [1:location2]);

% clean the image 
for index = 1:10
    [m, n] = size(A2);
        if A2(m, 6) == 255
            A2(m, :) = [];
        end
end
for index = 1:10
    [m, n] = size(A2);
        if A2(6, n) == 255
            A2(:, n) = [];
        end
end


% Turn into nested matrix
a  = size(A2, 1);
b  = size(A2, 2);
% number of elements in the cell matrix
numParts = 11;
% create row slices 
c = floor(a/numParts);
d = rem(a, numParts);
partition_a = ones(1, numParts)*c;
partition_a(1:d) = partition_a(1:d)+1;
% create col slices 
e = floor(b/numParts);
f = rem(b, numParts);
partition_b = ones(1, numParts)*e;
partition_b(1:f) = partition_b(1:f)+1;

output = mat2cell(A2, partition_a, partition_b);

%if avg is bellow 100 it means it was a black square which is 1
for row = 1:11
    for col = 1:11
        if mean(mean(output{row,col})) < 100
           qr(row,col) = 1;
        else 
           qr(row, col) = 0;
        end
    end
end


I = qr;
end

