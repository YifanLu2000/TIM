addpath('./src');

% Compile the mex file if the code can't work
% addpath(genpath('./src/graph_cut_src/'));
% mex ./src/graph_cut_src/gco-v3.0/myGC/myGraphCut.cpp;
% copyfile ./src/graph_cut_src/gco-v3.0/myGC/myGraphCut.mexw64 ./src/
% rmpath(genpath('./src/graph_cut_src/'));

% This is optional if you are using RANSAC
addpath('./src/RANSAC_ToolKit');     

% Add the path of the toolbox of vlfeat, you can download from:
% https://www.vlfeat.org/download/vlfeat-0.9.21-bin.tar.gz
addpath('./vlfeat-0.9.20/toolbox/'); 
run vl_setup;