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

% =================== Cargas a analisar ===================
ZL_list = [25, 4 + 25.13j, -28.99j];

% =================== Valores MEDIDOS ===================
V1_med      = [227, 221, 218]; 
V2_NL_med   = [132, 128.3, 126.1];
V2L_med     = [127, 127, 127];
I2_med      = [4.83, 4.02, 4.48];
Regula_med  = [3.94, 1.02, 0.71];
PO_med      = [614, 67, 0];
Pin_med     = [652, 106, 38];
Pperdas_med = [38, 39, 38];
efic_med    = [94.17, 63.21, 0];

% =================== Loop de simulações ===================
for k = 1:length(ZL_list)
    ZL = ZL_list(k);

    % ---- Cálculos teóricos ---
    Z_eq = Z1 + Zm*(3*ZL+Z2p)/(Zm + 3*ZL + Z2p);
    
    V1 = 127*sqrt(3) * abs((Z1 + Z2p + 3*ZL) / (3*ZL));
    V2NL = V1*(1/sqrt(3)) * abs(Zm/(Zm+Z1));
    I2L = abs(127/ZL);
    Reg = abs((V2NL - V2L)/V2L) * 100;    % em %
    Po = V2L * (I2L)* cos(angle(ZL));
    Pin = (V1^2 / abs(Z_eq)) * cos(angle(Z_eq));
    Perdas = Pin - Po;
    Ef = (Po/Pin)*100;

    % ---- Erros percentuais ----
    erro_V1      = abs(V1 - V1_med(k)) / abs(V1) * 100;
    erro_V2      = abs(V2L - V2L_med(k)) / abs(V2L) * 100;
    erro_V2_NL   = abs(V2NL - V2_NL_med(k)) / abs(V2NL) * 100;
    erro_I2      = abs(abs(I2L) - I2_med(k)) / abs(I2L) * 100;
    erro_Regula  = abs(Reg - Regula_med(k)) / abs(Reg) * 100;
    erro_PO      = abs(Po - PO_med(k)) / abs(Po) * 100;
    erro_Pin     = abs(Pin - Pin_med(k)) / abs(Pin) * 100;
    erro_Pperdas = abs(Perdas - Pperdas_med(k)) / abs(Perdas) * 100;
    erro_Ef      = abs(Ef - efic_med(k)) / abs(Ef) * 100;

    % ---- Impressão ----
    fprintf('\n--- Para ZL = %.2f + %.2fi\n', real(ZL), imag(ZL));
    fprintf('V1: %.2f V | medido: %.2f V | erro: %.2f %%\n', V1, V1_med(k), erro_V1);
    fprintf('V2 (linha): %.2f V | medido: %.2f V | erro: %.2f %%\n', V2L, V2L_med(k), erro_V2);
    fprintf('V2 NL (linha): %.2f V | medido: %.2f V | erro: %.2f %%\n', V2NL, V2_NL_med(k), erro_V2_NL);
    fprintf('I2: %.2f A | medido: %.2f A | erro: %.2f %%\n', abs(I2L), I2_med(k), erro_I2);
    fprintf('Reg: %.2f %% | medido: %.2f %% | erro: %.2f %%\n', Reg, Regula_med(k), erro_Regula);
    fprintf('Pout: %.2f W | medido: %.2f W | erro: %.2f %%\n', Po, PO_med(k), erro_PO);
    fprintf('Pin: %.2f W | medido: %.2f W | erro: %.2f %%\n', Pin, Pin_med(k), erro_Pin);
    fprintf('Perdas: %.2f W | medido: %.2f W | erro: %.2f %%\n', Perdas, Pperdas_med(k), erro_Pperdas);
    fprintf('Eficiência: %.2f %% | medida: %.2f %% | erro: %.2f %%\n', Ef, efic_med(k), erro_Ef);
end