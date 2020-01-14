function check(I)

I = rgb2gray(I); % change to black and white image

if size(I, 1) > 2500 && size(I, 2) > 2500
    I = I(1:5:end, 1:5:end); % reduce the power of the iphone
end
input_image = I; % store original for later use


I = imadjust(I); % Contrast boost to make blacks more distinct
I = imbinarize(I,'global'); % threshold image using golbal method
I = imcomplement(I); % invert binarized image so region props can work properly

% retuns the location of possible guid bars with details
details = regionprops('table', I, 'MajorAxisLength','MinoraxisLength', 'Orientation', 'Centroid');

% store location of potential
P_loc_V = [];% vertical bars of size 7
P_loc_H = [];% horizontal bars of size 5



% find possible vertical bars from regionprops
for row = 1:size(details,1)
    ratio = details.MajorAxisLength(row)/details.MinorAxisLength(row); 
    % ratio can be really strict as a result of the quality from IphoneTM 
    % vertical bar must be longer than 50 pixels
    if ratio > 6.5 && ratio < 7.5 && details.MajorAxisLength(row) > 50
        P_loc_V = [P_loc_V row];
    end    
end
% use refference vertical bar to find possible horrizontal guid bars
unit_size = details.MajorAxisLength(P_loc_V(1,1)) / 7;
for row = 1:size(details,1)
    ratio = details.MajorAxisLength(row)/unit_size;     
    if ratio > 4 && ratio < 6
        P_loc_H = [P_loc_H row];
    end  
end



% Check if guide bars are orthogonal to each other 
% number of vertical guide bars indicates number of qr codes
for V = 1:size(P_loc_V, 2)
    for H = 1:size(P_loc_H, 2)
        angle(V, H) = abs(details.Orientation(P_loc_H(1,H)) - details.Orientation(P_loc_V(1, V)));
    end 
end

% find the pair of side bars by checking for orthorganlity
for V = 1:size(P_loc_V, 2)
    n=90;
    [val(V),idx(V)]=min(abs(angle(V,:)-n));
end
temp = [];
for H = 1:size(idx, 2)
    temp = [temp P_loc_H(1, idx(1,H))];
end
P_loc_H = temp;








for col = 1:size(P_loc_V, 2)
    % rotate image to fix rotation of qr code
    alpha = -1 * details.Orientation(P_loc_H(1,col));
%     if details.Centroid(P_loc_H(1,col), 2) < details.Centroid(P_loc_V(1,col), 2) || ...
%        details.Centroid(P_loc_V(1,col), 1) < details.Centroid(P_loc_H(1,col), 1)
%         alpha = alpha + 180;    
%     end
    rotatedIm = imrotate(input_image, alpha);
    
        
     % find location of rotated points 
     V_y = round(details.Centroid(P_loc_V(1,col), 2));
     V_x = round(details.Centroid(P_loc_V(1,col), 1));
    canvas = zeros(size(input_image,1),size(input_image,2));
    canvas(V_y-1:V_y+1, V_x-1:V_x+1) = 1;
    canvas_rot = imrotate(canvas,alpha);
    [V_row, V_col] = find(canvas_rot);
    V_row = median(V_row);
    V_col = median(V_col);
    
    H_y = round(details.Centroid(P_loc_H(1,col), 2));
    H_x = round(details.Centroid(P_loc_H(1,col), 1));
    canvas = zeros(size(input_image,1),size(input_image,2));
    canvas(H_y-1:H_y+1, H_x-1:H_x+1) = 1;
    canvas_rot = imrotate(canvas,alpha);
    [H_row, H_col] = find(canvas_rot);
    H_row = median(H_row);
    H_col = median(H_col);
    
    % Fixes upside down QR code
    if H_row < V_row
        alpha = alpha + 180;
    end
    rotatedIm = imrotate(input_image, alpha ); 
    
    
    
     % find location of rotated points 
     V_y = round(details.Centroid(P_loc_V(1,col), 2));
     V_x = round(details.Centroid(P_loc_V(1,col), 1));
    canvas = zeros(size(input_image,1),size(input_image,2));
    canvas(V_y-1:V_y+1, V_x-1:V_x+1) = 1;
    canvas_rot = imrotate(canvas,alpha);
    [V_row, V_col] = find(canvas_rot);
    V_row = median(V_row);
    V_col = median(V_col);
    
    H_y = round(details.Centroid(P_loc_H(1,col), 2));
    H_x = round(details.Centroid(P_loc_H(1,col), 1));
    canvas = zeros(size(input_image,1),size(input_image,2));
    canvas(H_y-1:H_y+1, H_x-1:H_x+1) = 1;
    canvas_rot = imrotate(canvas,alpha);
    [H_row, H_col] = find(canvas_rot);
    H_row = median(H_row);
    H_col = median(H_col);

    
    % find location of qr code bounds
    unit_size = details.MajorAxisLength(P_loc_V(1, col)) / 7;
    start_col = round(V_col - (unit_size * 10)); 
    end_col = round(V_col   + unit_size); 
    start_row = round(H_row - (unit_size * 10));
    end_row = round(H_row + unit_size);    
    
    % prevents calculated bounds from being outside the image
    if start_col < 1 
        start_col = 1;
    end
    if start_row < 1
        start_row = 1;
    end
    if end_col > size(rotatedIm, 2)
        end_col = size(rotatedIm, 2);
    end
    if end_row > size(rotatedIm, 1)
        end_row = size(rotatedIm, 1);
    end
    
    % extract block containing qr code
    window = rotatedIm([start_row:end_row],[start_col:end_col]);
   
    % parse data
    qr = QReader(window);
    % convert data to 8bit ascii
    code2str(qr)
    
end
end

