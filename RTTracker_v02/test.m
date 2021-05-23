clc;
close all;
clear all;

addpath(pwd);

%%=========================  Read data file ================================================
% Read reference image
info = dicominfo('./P01-0108.dcm');
Iref = dicomread(info);
%imshow(Iref,[]);
Iref = double(Iref);

% Read template image
info2 = dicominfo('./P01-0100.dcm');
I = dicomread(info2);
I = double(I);

% Read manual label
ml_oc = imread('C:/Users/Shuo/Desktop/Assignment3/RTTracker_v02/Data1/ManualLabel/P01-0100-ocontour-manual.png');
ml_ic = imread('C:/Users/Shuo/Desktop/Assignment3/RTTracker_v02/Data1/ManualLabel/P01-0100-icontour-manual.png');

%%========================= Configuration parameters for the motion estimation library =====

dimx = 1;
dimy = 1;
dimz = 1;

%% Normalize the reference image
%Iref = (Iref - min(Iref(:)))/(max(Iref(:)) - min(Iref(:)));

%% Normalize the template image
%I = (I - min(I(:))) / (max(I(:)) - min(I(:)));

%% Define registration method
%% 0: No motion estimation
%% 1: L2L2 optical flow algorithm
%% 2: L2L1 optical flow algorithm
id_registration_method = 1;

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
accelerationFactor = 0;

%% Number of iterative raffinement within each resolution level
nb_raffinement_level = 1;

%%========================= Adjustement of grey level intensities =========================


%%========================= Initialisation of the RealTItracker library =============

%% Define registration parameters
RTTrackerWrapper(dimx, dimy, dimz, ...
    id_registration_method, ...
    nb_raffinement_level, ...
    accelerationFactor, ...
    alpha);

%%========================= Registration loop over the dynamically acquired images ======

%% Estimate the motion between the reference and the current images
RTTrackerWrapper(Iref, I);

% Apply the estimated motion on the current image
[registered_image] = RTTrackerWrapper(I);

% Get the estimated motion field
[motion_field] = RTTrackerWrapper();

%% Display registered images & estimated motion field
display_result2D(Iref,I,registered_image,motion_field);

pause(0.01);

%%========================= Close the RealTItracker library ===========================

RTTrackerWrapper();
