clear;
close all;

ImageFilename='DemoExpMap1.png';

load Data_DemoExpMap1; 

HeatMap=show_heatmap(Data_DemoExpMap1,'DemoExpMap1.png',32,6,'heatmap.png','Heatmap2D','Heatmap3D',1,1);

