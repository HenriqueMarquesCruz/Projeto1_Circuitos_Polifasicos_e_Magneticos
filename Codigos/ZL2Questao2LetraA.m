clc; clear; close all;

% =================== Dados do Transformador ===================
f = 60;                 % Hz
w = 2*pi*f;

R1 = 0.95;
L1 = 1.53e-3;           % H
R2 = 0.23;
L2 = 0.37e-3;           % H
Rm = 1861.54;
Lm = 3.62;              % H

% Impedâncias
Z1 = R1 + 1j*w*L1;
Z2 = R2 + 1j*w*L2;
Zm = 1 / (1/Rm + 1/(1j*w*Lm));   % paralelo
Z2p = 3*Z2;

% =================== Tensões Nominais ===================
V2L = 127;       % tensão secundária nominal (linha)

% =================== Valores MEDIDOS (referência: ZL2) ===================
V1_med      = 221; 
V2_NL_med   = 128.3;
V2L_med     = 127;
I2_med      = 4.02;
Regula_med  = 1.02;
PO_med      = 67;
Pin_med     = 106;
Pperdas_med = 39;
efic_med    = 87.72;

% =================== Caso 1: variar módulo (15 a 30 Ω), fase fixa 80.96° ===================
theta_fix = deg2rad(80.96);        % fase em rad
mag_range = linspace(15,30,200);   % módulo variando

erros_mag = zeros(length(mag_range),9);

for n = 1:length(mag_range)
    ZL = mag_range(n) * exp(1j*theta_fix);

    % --- cálculos teóricos
    V1 = 127*sqrt(3) * abs((Z1 + Z2p + 3*ZL) / (3*ZL));
    V2NL = V1*(1/sqrt(3)) * abs(Zm/(Zm+Z1));
    I2L = abs(127/ZL);
    Reg = abs((V2NL - V2L)/V2L) * 100;    
    Po = V2L * (I2L)* cos(angle(ZL));
    Z_eq = Z1 + Z2p + 3*ZL;
    Pin = (V1^2 / abs(Z_eq)) * cos(angle(Z_eq));
    Perdas = Pin - Po;
    Ef = (Po/Pin)*100;

    % --- erros relativos
    erros_mag(n,:) = [
        abs(V1 - V1_med)/abs(V1)*100
        abs(V2L - V2L_med)/abs(V2L)*100
        abs(V2NL - V2_NL_med)/abs(V2NL)*100
        abs(I2L - I2_med)/abs(I2L)*100
        abs(Reg - Regula_med)/abs(Reg)*100
        abs(Po - PO_med)/abs(Po)*100
        abs(Pin - Pin_med)/abs(Pin)*100
        abs(Perdas - Pperdas_med)/abs(Perdas)*100
        abs(Ef - efic_med)/abs(Ef)*100
    ];
end

figure('Name','Erros vs |ZL| (fase fixa)','NumberTitle','off');
plot(mag_range, erros_mag,'LineWidth',1.5);
xlabel('|Z_L| [\Omega]');
ylabel('Erro [%]');
title('Erros relativos variando |Z_L| (fase fixa = 80.96°)');
legend({'V1','V2','V2 NL','I2','Regulação','Pout','Pin','Perdas','Eficiência'},...
       'Location','northeastoutside');
grid on;

% =================== Caso 2: variar fase (75° a 85°), módulo fixo 25.45 Ω ===================
mag_fix = 25.45;
theta_range = linspace(75,85,200);     % graus
theta_rad = deg2rad(theta_range);      % em rad

erros_phase = zeros(length(theta_range),9);

for n = 1:length(theta_range)
    ZL = mag_fix * exp(1j*theta_rad(n));

    % --- cálculos teóricos
    V1 = 127*sqrt(3) * abs((Z1 + Z2p + 3*ZL) / (3*ZL));
    V2NL = V1*(1/sqrt(3)) * abs(Zm/(Zm+Z1));
    I2L = abs(127/ZL);
    Reg = abs((V2NL - V2L)/V2L) * 100;    
    Po = V2L * (I2L)* cos(angle(ZL));
    Z_eq = Z1 + Z2p + 3*ZL;
    Pin = (V1^2 / abs(Z_eq)) * cos(angle(Z_eq));
    Perdas = Pin - Po;
    Ef = (Po/Pin)*100;

    % --- erros relativos
    erros_phase(n,:) = [
        abs(V1 - V1_med)/abs(V1)*100
        abs(V2L - V2L_med)/abs(V2L)*100
        abs(V2NL - V2_NL_med)/abs(V2NL)*100
        abs(I2L - I2_med)/abs(I2L)*100
        abs(Reg - Regula_med)/abs(Reg)*100
        abs(Po - PO_med)/abs(Po)*100
        abs(Pin - Pin_med)/abs(Pin)*100
        abs(Perdas - Pperdas_med)/abs(Perdas)*100
        abs(Ef - efic_med)/abs(Ef)*100
    ];
end

figure('Name','Erros vs fase de ZL (módulo fixo)','NumberTitle','off');
plot(theta_range, erros_phase,'LineWidth',1.5);
xlabel('Fase de Z_L [graus]');
ylabel('Erro [%]');
title('Erros relativos variando fase de Z_L (|ZL| = 25.45 Ω)');
legend({'V1','V2','V2 NL','I2','Regulação','Pout','Pin','Perdas','Eficiência'},...
       'Location','northeastoutside');
grid on;
