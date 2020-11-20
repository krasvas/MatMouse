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
% Function show_heatmap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Description ---
% Creates a grayscale heatmap that constitutes of an image where each
% pixel’s value represents the corresponding frequencies of the existing
% mouse points. The values of the frequencies are normalized in the range
% 0-255 (8 bit image). The production of grayscale heatmaps is based on the
% values of the selected parameters which include the standard deviation
% and the kernel size of the performed Gaussian filtering.
% --- Syntax ---
% HeatMap=show_heatmap(A, InpImage, GaussStdDev, GaussScale, HeatmapFilename, HeatmapFigName,Heatmap3DFigName)
% --- Input parameters ---
% A: An array A containing the tracked mouse movements of a trajectory. It
% can be given by functions movement_track or movement_track_seq.
% InpImage: The visual stimulus image file (e.g. 'map.png'). All the main
% image file formats are supported.
% GaussStdDev: Standard deviation of gaussian filter (in pixels).
% GaussScale: Positive integer which is multipled by GaussStdDev parameter
% in order to calculate the kernel size.
% HeatmapFilename: Image filename to save the (statistical) grasyscale heatmap
% HeatmapFigName: Filename used to save the heatmap's figure as
% .fig and .png files.
% Heatmap3DFigName: Filename used to save the 3D heatmap's figure as
% .fig and .png files.
% --- Example ---
% HeatMap=show_heatmap(A,'map1.png',32,6,'heatmap_demo_output.png', 'Heatmap_2D','Heatmap_3D');

function Heatmap=show_heatmap(A,InpImage,GaussStdDev,GaussScale,HeatmapFilename,HeatmapFigName,HeatIsolinesFigName,SaveToImage,SaveToFigure)

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

% Define kernel size as a function of s (gaussian)
kernel_size_gaussian=GaussStdDev*GaussScale;

% Bivariate histogram
r=A.y;
c=A.x;
[nRows,nCols,~]=size(Im);
W = histcounts2(r,c,0:nRows,0:nCols);

% Filter the 2d histogram
Filter=fspecial('gaussian',kernel_size_gaussian,GaussStdDev);
Heatmap=imfilter(W,Filter,'replicate');

% Adjust heatmap values to the range 0-255
HeatmapNorm=uint8((255/max(max(Heatmap)))*Heatmap);

% Save heatmap as one channel grayscale image
imwrite(Heatmap,HeatmapFilename);

% 2D heatmap
if ~isempty(HeatmapFigName)
    Fig2D=figure('Units','normalized','Position',[0 0 1 1],'name',HeatmapFigName,'NumberTitle','off');
    image(Im);
    axis image off;
    hold on;
    imshow(HeatmapNorm);
    alpha(0.7);
    cb=colorbar;
    title(InpImage,'fontsize',14);
    cb.Title.String='Density';
    cb.FontSize=14;
    if SaveToImage
        savefig(Fig2D,strcat(HeatmapFigName,'.fig'));
    end
    if SaveToFigure
        saveas(Fig2D,strcat(HeatmapFigName,'.png'));
    end
    
end

% 3D heatmap surface plot
if ~isempty(HeatIsolinesFigName)
    Fig3D=figure('Units','normalized','Position',[0 0 1 1],'name',HeatIsolinesFigName,'NumberTitle','off');
    image(Im);
    axis image off;
    hold on;
    [~,c]=contour(HeatmapNorm,'ShowText','on');
    c.LineWidth = 3;
    %     shading interp;
    title(InpImage,'fontsize',14);
    set(gca,'xtick',[],'ytick',[]);
    if SaveToImage
        savefig(Fig3D,strcat(HeatIsolinesFigName,'.fig'));
    end
    if SaveToFigure
        saveas(Fig3D,strcat(HeatIsolinesFigName,'.png'));
    end
end

end