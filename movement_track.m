%     MatMouse toolbox 
%     Copyright (C) 2020 Vassilios Krassanakis, Anastasios Kesidis
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or (at
%     your option) any later version.
%
%     This program is distributed in the hope that it will be useful, but
%     WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%     For further information, please email Vassilios Krassanakis:
%     krasvas@uniwa.gr (University of West Attica)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function movement_track
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% --- Description ---
% Captures mouse movement data and provides the recorded mouse movements
% along with the corresponding time stamps.
% --- Syntax ---
% A=movement_track(InpImage,ScreenNum)
% --- Input parameters ---
% InpImage: The visual stimulus image file (e.g. 'map.png'). All the main
% image file formats are supported.
% ScreenNum: The monitor where the stimulus image will be shown. A value
% of 1 uses the current monitor while a value of 2 (or higher) uses the
% corresponding extended monitor. If omitted, the default value is 1.
% --- Output parameters ---
% A: An array that contains the tracked mouse movements. Array A is a
% structure with 3 fields:
%   A.t: time stamps (in seconds)
%   A.x: points x coordinates (in image pixels)
%   A.y: points y coordinates (in image pixels)
% --- Comments ---
% The origin of the coordinate system is on the top left corner of the
% input image.
% --- Example ---
% A=movement_track('map.png',1)

function A=movement_track(InpImage,ScreenNum,TxtFilename)

% check if an input image is provided
if ~exist('InpImage','var')
    error('Image filename not defined.');
    % check the selected output monitor. If omitted the default value is 1
elseif ~exist('ScreenNum','var')
    ScreenNum=1;
end
% check the validity of the selected otuput monitor
MonPos=get(0,'MonitorPositions');
if ScreenNum>size(MonPos,1)
    error('Wrong ScreenNum value. Only one monitor detected');
end

% create a new figure
hf=figure('windowstate','fullscreen');
set(hf,'Menubar','none','units','pixels','position',MonPos(ScreenNum,:));
drawnow;
% show the stimulus image
Im=imread(InpImage);
H=size(Im,1);
W=size(Im,2);

image(Im);
axis image off;
set(gca,'position',[0 0 1 1],'xlim',[0 W],'ylim',[0 H]);
hAxes=gca;
hold on;
% prepare the tracking movement loop
D=[];
MousePressed=0;
% start the tracking movement loop

set(hf,'WindowButtonDownFcn',@MouseClick);


FigPos=get(hf,'Position');
set(hAxes,'units','pixels');
AxesPos=get(hAxes,'Position');
AxesLimits = [get(hAxes, 'XLim')' get(hAxes,'YLim')'];

Offset = FigPos(1:2)+AxesPos(1:2);
AxesScale = diff(AxesLimits)./AxesPos(3:4);

drawnow;
drawnow;
tic;

while MousePressed==0
    p=get(0,'pointerlocation');
    x=p(1,1);
    y=p(1,2);
    
    Coords2 = ([x y]-Offset).*AxesScale+AxesLimits(1, :);
    
    AxesRatio=AxesPos(4)/AxesPos(3);
    ImRatio=H/W;
    
    xr=Coords2(1);
    yr=Coords2(2);
    
    Ratio=ImRatio/AxesRatio;
    
    if Ratio>1
        xr2=xr-W/2;
        xr3=xr2*Ratio;
        xrf=xr3+W/2;
        yrf=H-yr;
    else
        xrf=xr;
        yr2=yr-H/2;
        yr3=yr2/Ratio;
        yr4=yr3+H/2;
        yrf=H-yr4;
    end
    
    t=toc;
    D=[D;[t xrf yrf]];
    
    pause(0.00001);
end
% close the figure
close(hf);

A.t=D(:,1);
A.x=D(:,2);
A.y=D(:,3);

if exist('TxtFilename','var')
    fid=fopen(TxtFilename,'w');
    fprintf(fid,'%s\n',InpImage);
    fprintf(fid,'%d\n',length(A.t));
    fprintf(fid,'%0.4f %0.4f %0.4f\n',[A.t A.x A.y]');
    fclose(fid);
end

% Catch the mouse click that terminates the loop
    function MouseClick(~, ~)
        MousePressed=1;
    end

end

