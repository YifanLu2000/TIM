%{
Title: Feature Matching via Topology-aware Graph Interaction Model
Authors: Yifan Lu, Jiayi Ma, Jun Huang, Xiao-Ping Zhang
Affiliation: Wuhan University
Contact: lyf048@whu.edu.cn

Paper Reference: Lu, Y., Ma, J., Mei, X., Huang, J., & Zhang, X. P. (2024). 
Feature Matching via Topology-Aware Graph Interaction Model. 
IEEE/CAA Journal of Automatica Sinica, 11(1), 113-130. doi:10.1109/jas.2023.123774 

Date: April 1, 2023

License: MIT License

Overview:
    This demo script demonstrates the application of TIM for feature matching with SIFT.

Dependencies:
    - MATLAB R2022a
    - VLFeat 0.9.20

Installation:
    Ensure MATLAB R2022a is installed and add the VLFeat Toolbox to your path

Acknowledgments:
    This work was supported by the National Natural Science Foundation of China (62276192).
%}

%% Initialization and load data
clc, clear all;
close all; warning off;
% initialization; % run for the first time
I1 = imread('./data/image_l.jpg');
I2 = imread('./data/image_r.jpg');
if size(I1,3)==1
    I1=repmat(I1,[1 1 3]);
end
if size(I2,3)==1
    I2=repmat(I2,[1 1 3]);
end
[X0, Y0] = sift_match(I1, I2, 1.5);
N = size(X0,1);
fontSize = 20;
%% Putative Matches
inliers = 1:N;
figure;
plot_matches_V(I1,I2,X0,Y0,inliers,inliers);
title('Putative')
set(gca,'fontsize',fontSize,'fontname','Arial','FontWeight','bold');
%% TIM
tic
[inliers] = TIM(X0, Y0, 'seedMask', 0, 'I1Size', size(I1), 'I2Size', size(I2));
toc
figure;
plot_matches_V(I1,I2,X0,Y0,inliers,inliers);
title('TIM')
set(gca,'fontsize',fontSize,'fontname','Arial','FontWeight','bold');









