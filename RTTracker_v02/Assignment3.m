clc;
close all;
clear all;

addpath(pwd);

%%=========================  Read data file ================================================

% Read reference image
info = dicominfo('./P01-0108.dcm');
Iref = dicomread('./P01-0108.dcm');
% figure();
% imshow(Iref,[]);
Iref = im2double(Iref);



% Read template image
info2 = dicominfo('./P01-0100.dcm');
I = dicomread('./P01-0100.dcm');
% figure();
% imshow(I,[]);
I = im2double(I);

% Read manual label
ml_oc = imread('C:/Users/Shuo/Desktop/Assignment3/RTTracker_v02/Data1/ManualLabel/P01-0100-ocontour-manual.png');
ml_ic = imread('C:/Users/Shuo/Desktop/Assignment3/RTTracker_v02/Data1/ManualLabel/P01-0100-icontour-manual.png');

% Read evaluation label
gt_oc1 = imread('C:/Users/Shuo/Desktop/Assignment3/RTTracker_v02/Data1/GroundTruth/P01-0108-ocontour-manual.png');
gt_ic1 = imread('C:/Users/Shuo/Desktop/Assignment3/RTTracker_v02/Data1/GroundTruth/P01-0108-icontour-manual.png');
gt_oc1 = im2double(gt_oc1);
gt_ic1 = im2double(gt_ic1);

%%========================= Configuration parameters for the motion estimation library =====

[dimx dimy] = size(Iref);
dimz = 1;

%% Define registration method
%% 0: No motion estimation
%% 1: L2L2 optical flow algorithm
%% 2: L2L1 optical flow algorithm
id_registration_method = input('Please choose L2L2 (1) or L2L1 (2):\n');
if id_registration_method == 1
    id_registration_method = 1;
elseif id_registration_method == 2
    id_registration_method = 2;
else
    print('Please choose again');
end

% Dynamic image used as the reference position
reference_dynamic = 0;


%% Weighting factor (between 0 and 1) Close to 0: motion is highly sensitive to grey level intensity variation. Close to 1: the estimated motion is very regular along the space. See http://bsenneville.free.fr/RealTITracker/ for more informations
alpha = 0.3;
if (id_registration_method == 2)
    alpha = 0.6;
end

%% Computation of the highest resolution level to perform
%% (accelerationFactor=0 => computation is done on all resolution levels,
%%  accelerationFactor=1 => computation is done on all resolution levels except the highest one)
accelerationFactor = 1;

%% Number of iterative raffinement within each resolution level
nb_raffinement_level = 1;

%% Normalize the reference image
Iref = (Iref - min(Iref(:)))/(max(Iref(:)) - min(Iref(:)));

%% Normalize the template image
I = (I - min(I(:))) / (max(I(:)) - min(I(:)));

%% Normalize the icontour image
ml_ic = (ml_ic - min(ml_ic(:))) / (max(ml_ic(:)) - min(ml_ic(:)));

%% Normalize the ocontour image
ml_oc = (ml_oc - min(ml_oc(:))) / (max(ml_oc(:)) - min(ml_oc(:)));
%% Define registration parameters
RTTrackerWrapper(dimx, dimy, dimz, ...
    id_registration_method, ...
    nb_raffinement_level, ...
    accelerationFactor, ...
    alpha);

%%========================= Registration loop over the dynamically acquired images ======

%% Estimate the motion between the reference and the current images
% RTTrackerWrapper(Iref, I);
RTTrackerWrapper(ml_oc, I);
% RTTrackerWrapper(ml_ic, I);

% Apply the estimated motion on the current image
[registered_image] = RTTrackerWrapper(I);

% Get the estimated motion field
[motion_field] = RTTrackerWrapper();

%% Display registered images & estimated motion field
% display_result2D(Iref,I,registered_image,motion_field);
% display_result2D(ml_ic,I,registered_image,motion_field);
display_result2D(ml_oc,I,registered_image,motion_field);


%%========================= Close the RealTItracker library ===========================

RTTrackerWrapper();



%% Evaluation
r = im2double(registered_image);
BW = im2bw(registered_image,0.16);
BW = im2double(BW);

% Change to binary with ROI
evalu = r(30:160,50:150);
e = BW(30:160,50:150);
gt_ic = gt_ic1(30:160,50:150);
gt_oc = gt_oc1(30:160,50:150);

% Recall
for i = 1:131  
    if gt_oc(i,:) ==0
        Recall(i) = 0;
        continue
    else
        %Recall(i)=sum(evalu(i,:).*gt_ic(i,:))/sum(gt_ic(i,:));
        Recall(i)=sum(evalu(i,:).*gt_oc(i,:))/sum(gt_oc(i,:));
    end
end
recall = mean(Recall,'all');
    
    % Precision
for i = 1:131
     if gt_oc(i,:) ==0
        Prec(i) = 0;
        continue
     else
        %Prec(i)=sum(evalu(i,:).*gt_ic(i,:))/sum(evalu(i,:));
        Prec(i)=sum(evalu(i,:).*gt_oc(i,:))/sum(evalu(i,:));
     end
end
precision = mean(Prec,'all');

% Dice
d = dice(e,gt_oc);
% Hausdorff Distance
hd = hausdorff(evalu,gt_oc);
fprintf(' recall = %6.5f,\n precision = %6.5f,\n dice score = %6.5f,\n Hausdorff Distance = %6.5f,\n',recall,precision,d,hd);