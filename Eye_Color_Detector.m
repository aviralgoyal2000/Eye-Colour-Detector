I = imread('1.png');
I_cut = imread('1.png');

imshow(I);
I = rgb2gray(I);

[img_hist, img_bins] = hist(double(I(:)), 5);
T = img_bins(1);
b = I < T;

labeled = bwlabel(b, 8);
rgb = label2rgb(labeled, 'spring', [0 0 0]);
figure, imshow(rgb);
candidate_pupil = regionprops(labeled, 'Area','Eccentricity', 'Centroid', 'BoundingBox');
maxArea = 0;
for i = 1 : length(candidate_pupil)
    if (candidate_pupil(i).Area > maxArea) && ...
          (candidate_pupil(i).Eccentricity <= 0.7)
        maxArea = candidate_pupil(i).Area;
        m = i;
    end
end

Pupil.Cx = round(candidate_pupil(m).Centroid(1));
Pupil.Cy = round(candidate_pupil(m).Centroid(2));
Pupil.R = round(max(candidate_pupil(m).BoundingBox(3) / 2, candidate_pupil(m).BoundingBox(4) / 2));

Pupil.Rbig = Pupil.R * 2.7;
nPoints = 500;
theta = linspace(0, 2 * pi, nPoints);
rho = ones(1, nPoints) * Pupil.R;
[X, Y] = pol2cart(theta, rho);
X = X + Pupil.Cx;
Y = Y + Pupil.Cy;
hold on
plot(X,Y,'r','LineWidth',3);
imageSize = size(I_cut);
ci = [Pupil.Cy, Pupil.Cx, Pupil.R];
[xx, yy] = ndgrid((1:imageSize(1)) - ci(1), (1:imageSize(2)) - ci(2));
mask = uint8((xx .^ 2 + yy .^ 2) < ci(3) ^ 2);
cropPupil = uint8(zeros(size(I_cut)));
cropPupil(:, :, 1) = I_cut(:, :, 1) .* mask;
cropPupil(:, :, 2) = I_cut(:, :, 2) .* mask;
cropPupil(:, :, 3) = I_cut(:, :, 3) .* mask;

imageSize = size(I_cut);
ci = [Pupil.Cy, Pupil.Cx, Pupil.Rbig]; 
[xx, yy] = ndgrid((1:imageSize(1)) - ci(1), (1:imageSize(2)) - ci(2));
mask = uint8((xx .^ 2 + yy .^ 2) < ci(3) ^ 2);
cropBig = uint8(zeros(size(I_cut)));
cropBig(:, :, 1) = I_cut(:, :, 1) .* mask;
cropBig(:, :, 2) = I_cut(:, :, 2) .* mask;
cropBig(:, :, 3) = I_cut(:, :, 3) .* mask;

cropBig = cropBig - cropPupil;
figure, imshow(cropBig);

RValue = round(mean2(nonzeros(cropBig(:, :, 1))));
GValue = round(mean2(nonzeros(cropBig(:, :, 2))));
BValue = round(mean2(nonzeros(cropBig(:, :, 3))));
rgbImage(1, 1, :) = [RValue, GValue, BValue]; % r, g, b are uint8 values

r = RValue;
g = GValue;
b = BValue;
disp(r);
disp(g);
disp(b);

blueLowThreshold = 85;
blueHighThreshold = 200;
blueMask = (b > blueLowThreshold & b < blueHighThreshold);
y = (blueMask);
if y == 1
    disp("BLUE");
    return
end

redLowThreshold = 140;
redHighThreshold = 170;
redMask = (r >= redLowThreshold & r < redHighThreshold);
y = (redMask);
if y == 1
    disp("BROWN");
    return
end

greenLowThreshold = 130;
greenHighThreshold = 255;
greenMask = (g > greenLowThreshold & g < greenHighThreshold);
y = (greenMask);
if y == 1
    disp("GREEN");
    return
else
    disp("HAZEL");
    return
end

disp("Color Not Found!");