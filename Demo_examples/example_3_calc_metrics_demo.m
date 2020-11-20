clear;
close all;

disp('-----');

ImageFilename='DemoExpMap1.png';

load Data_DemoExpMap1;

[react,len,uniq,lineq,dstat,charea,curv]=calc_metrics(Data_DemoExpMap1)

figure;
Im=imread(ImageFilename);
H=size(Im,1);
W=size(Im,2);
image(Im);
axis image off;
hold on;
set(gca,'position',[0 0 1 1],'xlim',[0 W],'ylim',[0 H]);

plot(Data_DemoExpMap1.x,Data_DemoExpMap1.y,'bo');
hold on
plot(Data_DemoExpMap1.x,Data_DemoExpMap1.y,'b-');


x1=Data_DemoExpMap1.x(1);
x2=Data_DemoExpMap1.x(end);

y1=-(lineq.a*x1+lineq.c)/lineq.b;
y2=-(lineq.a*x2+lineq.c)/lineq.b;

line([x1 x2],[y1 y2],'color','r','linewidth',2);