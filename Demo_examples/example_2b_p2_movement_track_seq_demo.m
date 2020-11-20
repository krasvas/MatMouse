clear;
close all;

ImagesList='DemoExpMapSeq.txt';
Data_p2=movement_track_seq(ImagesList,1,'Data_p2.txt');
A=Data_p2;
T=importdata(ImagesList);
for i=1:length(A)
    InpImage=T{i};

    figure;
    Im=imread(InpImage);
    H=size(Im,1);
    W=size(Im,2);
    image(Im);
    axis image off;
    hold on;
    set(gca,'position',[0 0 1 1],'xlim',[0 W],'ylim',[0 H]);
    
    plot(A(i).x,A(i).y,'b+');
end

save Data_p2

