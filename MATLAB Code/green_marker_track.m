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
    'MaximumBlobArea',5000,'MaximumCount',1);

% Output video player
videoPlayer = vision.VideoPlayer;

green_x = [];
green_y = [];

%% Run the algorithm in a loop
while hasFrame(vidDevice)
    vidFrame = readFrame(vidDevice);
    
    % Convert RGB image to chosen color space
    I = rgb2hsv(vidFrame);

    % Define thresholds for channel 1 based on histogram settings
    channel1Min = 0.249;
    channel1Max = 0.478;
    
    % Define thresholds for channel 2 based on histogram settings
    channel2Min = 0.215;
    channel2Max = 1.000;
    
    % Define thresholds for channel 3 based on histogram settings
    channel3Min = 0.379;
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
    
    if numel(centroidOut) == 2
        green_x(end+1) = centroidOut(1);
        green_y(end+1) = centroidOut(2) * -1;
    else
        green_x(end+1) = green_x(end);
        green_y(end+1) = green_y(end);
    end
    
    % Output video with drawn shape
    step(videoPlayer, Ishape);
end

%% Cleanup
green_x = transpose(green_x);
green_y = transpose(green_y);
release(hBlob)
release(videoPlayer)