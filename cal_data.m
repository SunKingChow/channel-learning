%% Definition of parameters
N_Scatter = 40;
N_SBS = 5;
N_MS = 2000;    % MS number
M = 80; %MBS antenna number

SBS_locations = zeros(N_SBS,3);
Scatter_locations = zeros(N_Scatter,3);
MS_locations = zeros(N_MS,3);
gamma = 0.1;      % LOS factor, K_Rician = sqrt(gamma/(1-gamm))

frequency = 2.4e9;
lamda = 3e8/frequency;
D = lamda*0.5;  % distance between antenna elements of MBS

H_MBS = zeros(N_MS,M);  % channel impulse responses of MBS
H_SBS = zeros(N_MS,N_SBS);  % channel impulse responses of SBS

%% Generate SBS_location and scatter_locations
for i = 1:N_Scatter
    r_Scatter = 700*rand;
    phi_Scatter = rand*2*pi;
    Scatter_locations(i,1) = r_Scatter*cos(phi_Scatter);
    Scatter_locations(i,2) = r_Scatter*sin(phi_Scatter);
    Scatter_locations(i,3) = -20+40*rand;   
end
for i = 1:N_SBS
    r_SBS = 500*rand;
    phi_SBS = rand*2*pi;
    SBS_locations(i,1) = r_SBS*cos(phi_SBS);
    SBS_locations(i,2) = r_SBS*sin(phi_SBS);
    SBS_locations(i,3) = -15+30*rand;
end
%% Calulate channel responses for different MS
for i_MS = 1:N_MS
    % generate location of MS i
    r_MS = rand*600;
    phi_MS = rand*2*pi;
    MS_locations(i_MS,1) = r_MS*cos(phi_MS);
    MS_locations(i_MS,2) = r_MS*sin(phi_MS);
    MS_locations(i_MS,3) = -10+20*rand;
    % calculate responses of MBS antennas
    H1 = zeros(M,1);
    H2 = zeros(M,1);
    for m = 1:M
        [H1(m),H2(m)] = cal(MS_locations(i_MS,:),[(m-1)*D,0,0],N_Scatter,Scatter_locations);
    end
    power_H1 = mean(H1.*conj(H1));    % Power of LOS component
    power_H2 = mean(H2.*conj(H2));    % Power of NLOS component
    H_MBS(i_MS,:) = gamma*H1/sqrt(power_H1) + (1-gamma)*H2/sqrt(power_H2);
    % calculate responses of SBS antennas
    for i_SBS = 1:N_SBS
        [H1,H2] = cal(MS_locations(i_MS,:),SBS_locations(i_SBS,:),N_Scatter,Scatter_locations);
        H_SBS(i_MS,i_SBS) = gamma*H1/abs(H1) + (1-gamma)*H2/abs(H2);
    end
end
%% Figures
figure(1);
scatter3(Scatter_locations(:,1),Scatter_locations(:,2),Scatter_locations(:,3),'b.');
hold on;
scatter3(SBS_locations(:,1),SBS_locations(:,2),SBS_locations(:,3),'rs');
hold on;
%plot3(MS_locations(:,1),MS_locations(:,2),MS_locations(:,3),'rv');
plot3(0,0,0,'rs','MarkerFaceColor','r');
% show amplitudes and phases of H_MBS(1,:) and H_SBS(1,:)
figure(2);
subplot(1,2,1);plot(abs(H_MBS(1,:)));title('amplitude');
subplot(1,2,2);plot(angle(H_MBS(1,:)));title('phase');
figure(3);
subplot(1,2,1);plot(abs(H_SBS(1,:)));title('amplitude');
subplot(1,2,2);plot(angle(H_SBS(1,:)));title('phase');
%% Data saving
save(['data_with_',num2str(M),'antennas.mat'],'N_Scatter','N_SBS','N_MS','SBS_locations','Scatter_locations','MS_locations','H_MBS','H_SBS');