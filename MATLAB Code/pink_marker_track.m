%% Credits
% Dihan Almamun, 2021
% inspired by code from Jung Hung Chien, PhD, UNMC

%% Setup
% Read video from directory
vidDevice = VideoReader('Horizontal Abduction_Adduction - YZ Plane (edited&compressed).mp4');

% Create structural element for morphological operations to remove disturbances
diskElem = strel('disk',3);

% Create a BlobAnanlysis object
hBlob = vision.BlobAnalysis('MinimumBlobArea',35,...
    'MaximumBlobArea',5000,'MaximumCount', 2);

% Output video player
videoPlayer = vision.VideoPlayer;

pink_TR_x = [];
pink_TR_y = [];
pink_BL_x = [];
pink_BL_y = [];

% Distinguishes between top/bottom ('vertical') and right/left ('horizontal') markers
marker_orientation = 'horizontal';

%% Run the algorithm in a loop
while hasFrame(vidDevice)
    vidFrame = readFrame(vidDevice);
    
    % Convert RGB image to chosen color space
    I = rgb2hsv(vidFrame);

    % Define thresholds for channel 1 based on histogram settings
    channel1Min = 0.871;
    channel1Max = 1.000;
    
    % Define thresholds for channel 2 based on histogram settings
    channel2Min = 0.354;
    channel2Max = 1.000;
    
    % Define thresholds for channel 3 based on histogram settings
    channel3Min = 0.646;
    channel3Max = 1.000;

    % Create mask based on chosen histogram thresholds
    sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
        (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
        (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
    Ibw = sliderBW;

    
    % Use morphological operations to remove disturbances
    Ibwopen = imopen(Ibw,diskElem);
    
    % Extract the blobs from the frame 
    [areaOut,centroidOut,bboxOut] = step(hBlob, Ibwopen);
    
    % Draw a box around the detected objects
    Ishape = insertShape(vidFrame,'Rectangle',bboxOut);
    
    if numel(centroidOut) == 4
        % Tracks top and bottom markers
        if strcmp(marker_orientation,'vertical')
            median_y = (centroidOut(1,2) + centroidOut(2,2)) / 2;

            if centroidOut(1,2) < median_y
                pink_TR_x(end+1) = centroidOut(1,1);
                pink_TR_y(end+1) = centroidOut(1,2) * -1;

                pink_BL_x(end+1) = centroidOut(2,1);
                pink_BL_y(end+1) = centroidOut(2,2) * -1;
            else
                pink_TR_x(end+1) = centroidOut(2,1);
                pink_TR_y(end+1) = centroidOut(2,2) * -1;

                pink_BL_x(end+1) = centroidOut(1,1);
                pink_BL_y(end+1) = centroidOut(1,2) * -1;
            end
        end

        % Tracks left and right markers
        if strcmp(marker_orientation,'horizontal')
            median_x = (centroidOut(1,1) + centroidOut(2,1)) / 2;

            if centroidOut(1,1) < median_x
                pink_BL_x(end+1) = centroidOut(1,1);
                pink_BL_y(end+1) = centroidOut(1,2) * -1;

                pink_TR_x(end+1) = centroidOut(2,1);
                pink_TR_y(end+1) = centroidOut(2,2) * -1;
            else
                pink_BL_x(end+1) = centroidOut(2,1);
                pink_BL_y(end+1) = centroidOut(2,2) * -1;

                pink_TR_x(end+1) = centroidOut(1,1);
                pink_TR_y(end+1) = centroidOut(1,2) * -1;
            end
        end
    else
        pink_TR_x(end+1) = pink_TR_x(end);
        pink_TR_y(end+1) = pink_TR_x(end);
        pink_BL_x(end+1) = pink_BL_y(end);
        pink_BL_y(end+1) = pink_BL_y(end);
    end
    
    % Output video stream
    step(videoPlayer, Ishape);
end

%% Cleanup
pink_TR_x = transpose(pink_TR_x);
pink_TR_y = transpose(pink_TR_y);
pink_BL_x = transpose(pink_BL_x);
pink_BL_y = transpose(pink_BL_y);
release(hBlob)
release(videoPlayer)