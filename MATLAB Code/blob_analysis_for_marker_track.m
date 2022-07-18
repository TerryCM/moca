vidDevice = VideoReader('Horizontal Abduction Adduction - Yz Plane-1.mp4');
firstFrame = read(vidDevice,1117);
subplot(1,3,1)
imshow(firstFrame)