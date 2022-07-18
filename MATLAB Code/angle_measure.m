%% Credits
% Dihan Almamun, 2021

%% Code

angles = [];

for i = 1:length(green_x)
    % Finds length of sides using the distance formula
    side_green_TR = sqrt((green_x(i) - pink_TR_x(i))^2 + (green_y(i) - pink_TR_y(i))^2);
    side_green_BL = sqrt((green_x(i) - pink_BL_x(i))^2 + (green_y(i) - pink_BL_y(i))^2);
    side_TR_BL = sqrt((pink_TR_x(i) - pink_BL_x(i))^2 + (pink_TR_y(i) - pink_BL_y(i))^2);
    
    % Finds angle between markers using the law of cosines
    angles(end+1) = acosd(((side_green_TR)^2 + (side_green_BL)^2 - (side_TR_BL)^2) / (2*side_green_TR*side_green_BL));
end

angles = transpose(angles);