%     MatMouse toolbox
%     Copyright (C) 2020 Vassilios Krassanakis, Anastasios Kesidis
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%     For further information, please email Vassilios Krassanakis:
%     krasvas@uniwa.gr (University of West Attica)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function show_visualizations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Description ---
% Exports 2D plots of mouse movement trajectories that demonstrate the
% spatial dispersion of the individual visual search and the deviations of
% both horizontal and vertical mouse coordinates over time. Furthermore, it
% exports a 3D visualization that depicts the spatiotemporal distribution
% of the collected data.
% --- Syntax ---
% show_visualizations(A,InpImage,TrajectoryFigName,StimulusFigName,CoordsFigName,DurationFigName)
% --- Input parameters ---
% A: An array A containing the tracked mouse movements of a trajectory. It
% can be given by functions movement_track or movement_track_seq.
% InpImage: The visual stimulus image file (e.g. 'map.png'). All the main
% image file formats are supported.
% TrajectoryFigName: Filename used to save the mouse movement trajectories as
% .fig and .png files.
% StimulusFigName: Filename used to save the stimulus trajectories as
% .fig and .png files.
% CoordsFigName: Filename used to save the horizontal and vertical mouse
% coordinates over time as .fig and .png files.
% DurationFigName: Filename used to save the the spatiotemporal distribution
% of the collected data as .fig and .png files.
% --- Comments ---
% The figures are created if a valid filename is provided. In order to
% omit a particular figure use symbols [] instead of a filename.
% --- Example ---
% show_visualizations(A,'map1.png','TrajectoryFig','StimulusFig','CoordinatesFig','DurationFig');

function show_visualizations(A,InpImage,StimulusFigName,XYCoordsFigName,CurvatureFigName,DurationFigName,SaveToImage,SaveToFigure)

% check if SaveToImage is provided
if ~exist('SaveToImage','var')
    SaveToImage=0;
else
    SaveToImage=(SaveToImage==1);
end

% check if SaveToFigure is provided
if ~exist('SaveToFigure','var')
    SaveToFigure=0;
else
    SaveToFigure=(SaveToFigure==1);
end

% Read visual stimulus image
Im=imread(InpImage);
[H,W,~]=size(Im);

% 2D trajectory figure
if ~isempty(StimulusFigName)
    Fig1=figure('Units','normalized','Position',[0 0 1 1],'name',StimulusFigName,'NumberTitle','off');
    image(Im);
    axis image off;
    hold on;
    set(gca,'position',[0 0 1 1],'xlim',[0 W],'ylim',[0 H]);
    plot(A.x, A.y,'b-','linewidth',2);
    plot(A.x, A.y,'ro');
    legend ('Mouse trace', 'Captured mouse points',...
        'Location','northwest','fontsize',14);
    drawnow;
    if SaveToImage
        saveas(Fig1,strcat(StimulusFigName,'.png'));
    end
    if SaveToFigure
        savefig(Fig1,strcat(StimulusFigName,'.fig'));
    end
end

% Mouse coordinates over time figure
if ~isempty(XYCoordsFigName)
    Fig2=figure('Units','normalized','Position',[0 0 1 1],'name',XYCoordsFigName,'NumberTitle','off');
    line(A.t,A.x,'color','g','linewidth',2);
    hold on;
    line(A.t,A.y,'color','m','linewidth',2);
    grid on;
    title (InpImage,'fontsize',14);
    xlabel('Time stamp (sec)','fontsize',14);
    ylabel ('Mouse coordinates (pixels)','fontsize',14);
    legend('Horizontal coordinates','Vertical coordinates', 'Location', 'northwest','fontsize',14);
    drawnow;
    if SaveToImage
        saveas(Fig2,strcat(XYCoordsFigName,'.png'));
    end
    if SaveToFigure
        savefig(Fig2,strcat(XYCoordsFigName,'.fig'));
    end
end

% Curvature figure
if ~isempty(CurvatureFigName)
    Fig3=figure('Units','normalized','Position',[0 0 1 1],'name',CurvatureFigName,'NumberTitle','off');
    image(Im);
    axis image off;
    hold on;
    set(gca,'position',[0 0 1 1],'xlim',[0 W],'ylim',[0 H]);
    
    [~,~,uniq,~,~,~,curv]=calc_metrics(A);
    
    % Apply a gamma correction in curvature values
    % in order to enhance to visual result
    gamma_value=0.5;
    curv=curv/max(curv);
    curv=curv.^gamma_value;
    
    xx=[uniq.x';uniq.x'];
    yy=[uniq.y';uniq.y'];
    zz=zeros(size(xx));
    cc=[curv';curv'];
    
    surf(xx,yy,zz,cc,'EdgeColor','interp','linewidth',7) %// color binded to "y" values
    CMap=jet(256);
    CMap=(CMap(110:200,:));
    colormap(CMap);
    legend ({'  Curvature'},'Location','northwest','fontsize',14);
    colorbar('eastoutside','ticks',[0.08 0.5 0.92],'ticklabels',{'Low','Middle','High'});
    drawnow;
    if SaveToImage
        saveas(Fig3,strcat(CurvatureFigName,'.png'));
    end
    if SaveToFigure
        savefig(Fig3,strcat(CurvatureFigName,'.fig'));
    end
end

% Curvature figure
if ~isempty(DurationFigName)
    Fig4=figure('Units','normalized','Position',[0 0 1 1],'name',DurationFigName,'NumberTitle','off');
    image(Im);
    axis image off;
    hold on;
    set(gca,'position',[0 0 1 1],'xlim',[0 W],'ylim',[0 H]);
    
    dur=uniq.d/max(uniq.d);
    gamma_value=1.2;
    dur=dur.^gamma_value;
    
    plot(uniq.x,uniq.y,'r','linewidth',1);
    scatter(uniq.x,uniq.y,dur*1000,'filled',...
        'MarkerEdgeColor','r','MarkerFaceColor','r','linewidth',1);
    title (InpImage,'fontsize',14);
    legend ({'  Duration'},'Location','northwest','fontsize',14);
    
    [~,SortIdx]=sort(dur,'descend');
    text(uniq.x(SortIdx(1)),uniq.y(SortIdx(1))*0.9,...
        sprintf('%0.2f sec',uniq.d(SortIdx(1))),'horizontalalignment','center',...
        'verticalalignment','bottom','fontsize',14,...
        'edgecolor','k','backgroundcolor','w');
    drawnow;
    if SaveToImage
        saveas(Fig4,strcat(DurationFigName,'.png'));
    end
    if SaveToFigure
        savefig(Fig4,strcat(DurationFigName,'.fig'));
    end
end

end
