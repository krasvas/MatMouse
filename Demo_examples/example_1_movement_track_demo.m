clear;
close all;

ImageFilename='DemoExpMap1.png';
Data_DemoExpMap1=movement_track(ImageFilename,1,'Data_DemoExpMap1.txt');

figure;
Im=imread(ImageFilename);
H=size(Im,1);
W=size(Im,2);
image(Im);
axis image off;
hold on;
set(gca,'position',[0 0 1 1],'xlim',[0 W],'ylim',[0 H]);

plot(Data_DemoExpMap1.x,Data_DemoExpMap1.y,'b+');

save Data_DemoExpMap1


