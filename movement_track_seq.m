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
% Function movement_track_seq
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Description  ---
% Captures mouse movement data in a set of stimuli images. For each image
% it provides the recorded mouse movements along with the corresponding
% time stamps.
% --- Syntax ---
% A=movement_track_seq(ImagesList,ScreenNum)
% --- Input parameters ---
% ImagesList: A text file containing the filenames of the stimuli images.
% For instance,
% map1.png
% map2.png
% map3.png
% All the main image file formats are supported.
% ScreenNum: The monitor where the stimulus image will be shown. A value
% of 1 uses the current monitor while a value of 2 (or higher) uses the
% corresponding extended monitor. If omitted, the default value is 1.
% --- Output parameters ---
% A: An array that contains the tracked mouse movements for all the stimuli
% images. Array A(i) is a structure with 3 fields containing the tracked
% movements for the i-th stimulus image, with 1<=i<=N where N denotes the
% number of images in the ImageList text file.
%   A(i).t: time stamp (in seconds) for the i-th image
%   A(i).x: point's x coordinate (in image pixels) for the i-th image
%   A(i).y: point's y coordinate (in image pixels) for the i-th image
% --- Comments ---
% The origin of the coordinate system is on the top left corner of the input images.
% --- Example ---
% A=movement_track('images_list.txt',1)

function A=movement_track_seq(ImagesList,ScreenNum,TxtFilename)

% check if an images list is provided
if ~exist('ImagesList','var')
    error('Images list not defined.');
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

% get the list of stimuli images
T=importdata(ImagesList);

set(hf,'WindowButtonDownFcn',@MouseClick);

% for each image
for i=1:length(T)
    InpImage=T{i};
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
    
    FigPos=get(hf,'Position');
    set(hAxes,'units','pixels');
    AxesPos=get(hAxes,'Position');
    AxesLimits = [get(hAxes, 'XLim')' get(hAxes,'YLim')'];
    
    Offset = FigPos(1:2)+AxesPos(1:2);
    AxesScale = diff(AxesLimits)./AxesPos(3:4);
    
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
        
        pause(0.0001);
    end
    % close the figure
    clf;
    
    A(i).t=D(:,1);
    A(i).x=D(:,2);
    A(i).y=D(:,3);
end
close(hf);

if exist('TxtFilename','var')    
    fid=fopen(TxtFilename,'w');
    for i=1:length(A)
        ImageFilename=T{i};
        fprintf(fid,'%s\n',ImageFilename);
        fprintf(fid,'%d\n',length(A(i).t));
        fprintf(fid,'%0.4f %0.4f %0.4f\n',[A(i).t A(i).x A(i).y]');
    end
    fclose(fid);
end

% Catch the mouse click that terminates the loop
    function MouseClick(~, ~)
        MousePressed=1;
    end

end

