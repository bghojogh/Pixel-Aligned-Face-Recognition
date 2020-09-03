%% Aligned-Face Recognition Poject:

%% MATLAB initializations:
clc
clear all
close all

%% Add paths of functions:
addpath('functions_CLNF/demo');

%% Setting path of input images:
PathName='.\Datasets\yalefaces_dataset\';
dirname = fullfile(PathName,'*.jpg');
imglist = dir(dirname);
imgnum = length(imglist);
[~,order] = sort_nat({imglist.name});
imglist = imglist(order);  % imglist is now sorted

%% CLNF (Constrained Local Neural Fields) to find the landmarks:
PathName='.\Datasets\yalefaces_dataset\';
show_figures_CLNF = 1;
save_figures_CLNF = 1;
dataset = 1;

cd('./functions_CLNF/demo');
[shape_t, number_of_landmarks] = face_image_demo(imglist, PathName, show_figures_CLNF, save_figures_CLNF, dataset);
cd('..'); cd('..');

cd('saved_files');
save shape_t.mat shape_t
save number_of_landmarks.mat number_of_landmarks
cd('..');

