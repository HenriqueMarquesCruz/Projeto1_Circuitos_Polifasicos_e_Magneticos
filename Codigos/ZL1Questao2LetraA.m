clc; clear; close all;

% =================== Dados do Transformador ===================
f = 60;                 
w = 2*pi*f;

% Valores conhecidos
R1 = 0.95;
L1 = 1.53e-3;   % fixo em 1.53 mH

% Constante de transformação
k = (127/220)^2;
alpha = sqrt(3) - 1;

Rm = 1861.54;
Lm = 3.62;              % H

% =================== Tensões Nominais ===================
V2L = 127;       % tensão secundária nominal (linha)

% =================== Faixa de carga a analisar ===================
ZL_range = 1:50;   % de 1 a 200 ohms, passo 1

% =================== Valores MEDIDOS (referência ZL=25 Ω) ===================
V1_med      = 227; 
V2_NL_med   = 132;
V2L_med     = 127;
I2_med      = 4.83;
Regula_med  = 3.94;
PO_med      = 614;
Pin_med     = 652;
Pperdas_med = 38;
efic_med    = 94.17;

% =================== Pré-alocação ===================
erro_V1      = zeros(size(ZL_range));
erro_V2      = zeros(size(ZL_range));
erro_V2_NL   = zeros(size(ZL_range));
erro_I2      = zeros(size(ZL_range));
erro_Regula  = zeros(size(ZL_range));
erro_PO      = zeros(size(ZL_range));
erro_Pin     = zeros(size(ZL_range));
erro_Pperdas = zeros(size(ZL_range));
erro_Ef      = zeros(size(ZL_range));

% --- Resistências e Indutâncias dependentes de L1 ---
R2p = alpha * R1;   
R2  = k * R2p;      
L2p = alpha * L1;   
L2  = k * L2p;      

Z1 = R1 + 1j*w*L1;
Z2 = R2 + 1j*w*L2;
Zm = 1 / (1/Rm + 1/(1j*w*Lm));   % paralelo
Z2p = 3*Z2;

% =================== Loop sobre ZL ===================
for n = 1:length(ZL_range)
    ZL = ZL_range(n);

    % ---- Cálculos teóricos ----
    V1 = 127*sqrt(3) * abs((Z1 + Z2p + 3*ZL) / (3*ZL));
    V2NL = V1*(1/sqrt(3)) * abs(Zm/(Zm+Z1));
    I2L = abs(127/ZL);
    Reg = abs((V2NL - V2L)/V2L) * 100;    
    Po = V2L * (I2L)* cos(angle(ZL));
    Z_eq = Z1 + Z2p + 3*ZL;
    Pin = (V1^2 / abs(Z_eq)) * cos(angle(Z_eq));
    Perdas = Pin - Po;
    Ef = (Po/Pin)*100;

    % ---- Erros relativos a ZL=25 Ω (valores medidos) ----
    erro_V1(n)      = abs(V1 - V1_med) / abs(V1) * 100;
    erro_V2(n)      = abs(V2L - V2L_med) / abs(V2L) * 100;
    erro_V2_NL(n)   = abs(V2NL - V2_NL_med) / abs(V2NL) * 100;
    erro_I2(n)      = abs(I2L - I2_med) / abs(I2L) * 100;
    erro_Regula(n)  = abs(Reg - Regula_med) / abs(Reg) * 100;
    erro_PO(n)      = abs(Po - PO_med) / abs(Po) * 100;
    erro_Pin(n)     = abs(Pin - Pin_med) / abs(Pin) * 100;
    erro_Pperdas(n) = abs(Perdas - Pperdas_med) / abs(Perdas) * 100;
    erro_Ef(n)      = abs(Ef - efic_med) / abs(Ef) * 100;
end

% =================== Gráficos ===================
figure('Name','Todos os erros em função de ZL','NumberTitle','off','Position',[200 100 800 600]);

plot(ZL_range, erro_V1,      'LineWidth',1.5); hold on;
plot(ZL_range, erro_V2,      'LineWidth',1.5);
plot(ZL_range, erro_V2_NL,   'LineWidth',1.5);
plot(ZL_range, erro_I2,      'LineWidth',1.5);
plot(ZL_range, erro_Regula,  'LineWidth',1.5);
plot(ZL_range, erro_PO,      'LineWidth',1.5);
plot(ZL_range, erro_Pin,     'LineWidth',1.5);
plot(ZL_range, erro_Pperdas, 'LineWidth',1.5);
plot(ZL_range, erro_Ef,      'LineWidth',1.5);

xlabel('Z_L [\Omega]');
ylabel('Erro [%]');
title('Erros relativos em função de Z_L (referência: ZL=25 \Omega)');
legend({'V1','V2','V2 NL','I2','Regulação','Pout','Pin','Perdas','Eficiência'},...
       'Location','northeastoutside');
grid on;
