%% ME568 Lab 3: Fluidic Actuators - Compact Analysis
clear; close all; clc;

% Constants
g = 9.81; kPa_to_Pa = 1000; cm_to_m = 0.01;
fprintf('=== ME568 Lab 3: Fluidic Actuators Analysis ===\n\n');

%% Quick Measurement Function
function len = quickMeasure()
    [file, path] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files'});
    if isequal(file, 0), error('No image selected.'); end
    
    img = imread(fullfile(path, file));
    if size(img, 3) == 3, img = rgb2gray(img); end
    
    figure('Position', [100, 100, 800, 600]);
    imshow(img); title('Click TWO points, then press Enter');
    [x, y] = ginput(2);
    
    pixel_dist = sqrt(diff(x).^2 + diff(y).^2);
    answer = inputdlg({'Ref length (cm):', 'Ref pixels:'}, 'Calibration', 1, {'10','100'});
    
    if ~isempty(answer)
        len = pixel_dist * (str2double(answer{1}) / str2double(answer{2}));
    else
        len = pixel_dist * 0.1;
    end
    
    hold on;
    plot(x, y, 'r-', 'LineWidth', 3);
    plot(x, y, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    text(mean(x), mean(y), sprintf('%.2f cm', len), 'Color', 'yellow', 'FontSize', 12);
    hold off;
    fprintf('Measured: %.2f cm\n', len);
end

%% Image Analysis (Optional)
disp('--- Image Analysis ---');
try
    actuators = {'A1', 'A2', 'A3'};
    init_lengths = [13.8, 13.9, 12.5];
    volumes_ml = [0, 10, 20, 30, 40, 50];
    measured_lengths = zeros(3, 6);
    
    for i = 1:3
        fprintf('\n%s - Initial: %.1f cm\n', actuators{i}, init_lengths(i));
        measured_lengths(i, 1) = init_lengths(i);
        for inc = 1:5
            fprintf('Add %d ml -> ', inc*10);
            len = quickMeasure();
            measured_lengths(i, inc+1) = len;
        end
    end
    
    % Plot results
    figure('Name', 'Length vs Volume');
    for i = 1:3
        plot(volumes_ml, measured_lengths(i, :), 'o-', 'LineWidth', 2, 'DisplayName', actuators{i});
        hold on;
    end
    xlabel('Volume (ml)'); ylabel('Length (cm)'); title('Actuator Length vs Volume');
    legend; grid on;
    
catch ME
    fprintf('Image analysis skipped. Using default data.\n');
    volumes_ml = [0, 10, 20, 30, 40, 50];
    measured_lengths = [13.8,13.2,12.8,12.1,11.5,10.9;
                        13.9,13.3,12.7,12.0,11.4,10.8;
                        12.5,12.0,11.6,11.1,10.7,10.2];
end

%% 1. PAM Analysis
disp('--- PAM Analysis ---');
P_A1 = [10,13.6,22.3,35.6,46.3,55.0];
Cont_A1 = [2.3,6.0,35.6,51.6,85.4,92.1];
L_A1 = [13.8,13.6,12.2,10.1,7.2,6.9];

figure('Name','PAM Characterization');
subplot(1,2,1);
plot(P_A1, Cont_A1, 'bo-', 'LineWidth',2); grid on;
xlabel('Pressure (kPa)'); ylabel('Contraction (%)'); title('Pressure vs Contraction');

subplot(1,2,2);
plot(P_A1, L_A1, 'rs-', 'LineWidth',2); grid on;
xlabel('Pressure (kPa)'); ylabel('Length (cm)'); title('Pressure vs Length');

%% Force Analysis
D0 = 2.0 * cm_to_m; b = 15.0 * cm_to_m;
Mass_g = [200,500,1000]; P_exp = [185.6,182.6,189.4]; L_exp = [13.2,13.2,13.0];

F_exp = (Mass_g/1000) * g;
F_theory = (pi*D0^2*(P_exp*kPa_to_Pa)/4) .* (3*(L_exp*cm_to_m/b).^2 - 1);
error_percent = abs(F_theory-F_exp)./F_exp*100;

fprintf('\n=== PAM FORCE RESULTS ===\n');
fprintf('Mass(g)\tF_exp(N)\tF_theory(N)\tError(%%)\n');
for i = 1:3
    fprintf('%d\t%.2f\t\t%.2f\t\t%.1f\n', Mass_g(i), F_exp(i), F_theory(i), error_percent(i));
end

figure('Name','Force Comparison');
plot(Mass_g, F_exp, 'bo-', Mass_g, F_theory, 'rs--', 'LineWidth',2);
xlabel('Mass (g)'); ylabel('Force (N)'); legend('Exp','Theory'); grid on;

%% 2. Bending Actuators
disp('--- Bending Characterization ---');
P_3B1 = [12,18,25,25,25]; Ang_3B1 = [30,45,60,75,90];
P_3B2 = [13,23,24,25,26]; Ang_3B2 = [30,45,60,75,90];
P_3C1 = [18,24,24,25,26]; Ang_3C1 = [30,45,60,75,90];
P_3C2 = [21,25,27,29,30]; Ang_3C2 = [30,45,60,75,90];

figure('Name','Bending Actuators');
subplot(1,2,1);
plot(P_3B1, Ang_3B1, 'b^-', P_3B2, Ang_3B2, 'bo--', 'LineWidth',2);
xlabel('Pressure (kPa)'); ylabel('Angle (°)'); title('Fiber-Reinforced'); legend('B1','B2'); grid on;

subplot(1,2,2);
plot(P_3C1, Ang_3C1, 'g^-', P_3C2, Ang_3C2, 'mo--', 'LineWidth',2);
xlabel('Pressure (kPa)'); ylabel('Angle (°)'); title('Pneu-Net'); legend('C1','C2'); grid on;

%% 3. Weight Lifting
disp('--- Weight Lifting ---');
Angles = [30,45,60,90];
P_3B_20 = [125,129,131,132]; P_3B_50 = [121,125,132,132];
P_3C_20 = [118,124,129,129]; P_3C_50 = [121,125,132,132];

figure('Name','Lifting Performance');
subplot(1,2,1);
plot(Angles, P_3B_20, 'c^-', Angles, P_3B_50, 'm*--', 'LineWidth',2);
xlabel('Angle (°)'); ylabel('Pressure (kPa)'); title('Fiber-Reinforced'); legend('20g','50g'); grid on;

subplot(1,2,2);
plot(Angles, P_3C_20, 'c^-', Angles, P_3C_50, 'm*--', 'LineWidth',2);
xlabel('Angle (°)'); ylabel('Pressure (kPa)'); title('Pneu-Net'); legend('20g','50g'); grid on;

%% Summary
fprintf('\n=== PERFORMANCE SUMMARY ===\n');
fprintf('Fiber-Reinforced - 90° @ %.0f kPa, 50g lift @ %.0f kPa\n', P_3B1(end), P_3B_50(end));
fprintf('Pneu-Net - 90° @ %.0f kPa, 50g lift @ %.0f kPa\n', P_3C2(end), P_3C_50(end));

%% Save Results
save('Lab3_Results.mat');
figHandles = findall(0, 'Type', 'figure');
for i = 1:length(figHandles)
    saveas(figHandles(i), sprintf('Lab3_Figure_%d.png', i));
end

fprintf('\n=== ANALYSIS COMPLETE ===\n');