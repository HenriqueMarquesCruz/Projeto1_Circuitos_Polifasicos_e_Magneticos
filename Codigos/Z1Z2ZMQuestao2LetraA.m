clc; clear; close all;

% =================== Dados do Transformador ===================
f = 60;                 
w = 2*pi*f;

% Valores conhecidos
R1 = 0.95;

% Faixa de variação de L1
L1_range = linspace(0.5e-3, 5e-3, 200);   % 0.5 mH a 5 mH

% Constante de transformação
k = (127/220)^2;
alpha = sqrt(3) - 1;

Rm = 1861.54;
Lm = 3.62;              % H

% =================== Tensões Nominais ===================
V2L = 127;       % tensão secundária nominal (linha)

% =================== Cargas a analisar ===================
ZL_list = [25, 4 + 25.13j, -24.99j];  % corrigido último ZL

% =================== Valores MEDIDOS ===================
V1_med      = [227, 221, 218]; 
V2_NL_med   = [132, 128.3, 126.1];
V2L_med     = [127, 127, 127];
I2_med      = [4.83, 4.02, 4.48];
Regula_med  = [3.94, 1.02, 0.71];
PO_med      = [614, 67, 0];
Pin_med     = [652, 106, 38];
Pperdas_med = [38, 39, 38];
efic_med    = [94.17, 87.72, 0];

% =================== Pré-alocação ===================
erro_Regula_vs_L1  = zeros(size(L1_range));
erro_Pperdas_vs_L1 = zeros(size(L1_range));
erro_Pin_vs_L1     = zeros(size(L1_range));

% =================== Loop sobre L1 ===================
for n = 1:length(L1_range)
    L1 = L1_range(n);

    % --- Resistências e Indutâncias dependentes de L1 ---
    R2p = alpha * R1;   
    R2  = k * R2p;      
    L2p = alpha * L1;   
    L2  = k * L2p;      

    Z1 = R1 + 1j*w*L1;
    Z2 = R2 + 1j*w*L2;
    Zm = 1 / (1/Rm + 1/(1j*w*Lm));   % paralelo
    Z2p = 3*Z2;

    for kZ = 1:length(ZL_list)
        ZL = ZL_list(kZ);

        % ---- Cálculos teóricos ----
        V1 = 127*sqrt(3) * abs((Z1 + Z2p + 3*ZL) / (3*ZL));
        V2NL = V1*(1/sqrt(3)) * abs(Zm/(Zm+Z1));
        I2L = abs(127/ZL);
        Reg = abs((V2NL - V2L)/V2L) * 100;    
        Po = V2L * (I2L)* cos(angle(ZL));
        Z_eq = Z1 + Z2p + Zm*3*ZL/(Zm + 3*ZL);
        Pin = (V1^2 / abs(Z_eq)) * cos(angle(Z_eq));
        Perdas = Pin - Po;
        Ef = (Po/Pin)*100;

        % ---- Erros percentuais ----
        erro_Regula  = abs(Reg - Regula_med(kZ)) / abs(Reg) * 100;
        erro_Pperdas = abs(Perdas - Pperdas_med(kZ)) / abs(Perdas) * 100;
        erro_Pin     = abs(Pin - Pin_med(kZ)) / abs(Pin) * 100;

        % ---- Guardar só os pedidos ----
        if kZ == 1
            erro_Regula_vs_L1(n) = erro_Regula; % ZL=25
        elseif kZ == 2
            erro_Pperdas_vs_L1(n) = erro_Pperdas; % ZL=4+25.13j
        elseif kZ == 3
            erro_Pin_vs_L1(n) = erro_Pin; % ZL=-24.99j
        end
    end
end

% =================== Gráficos ===================
figure('Name','Erros em função de L1','NumberTitle','off','Position',[200 100 1200 600]);

subplot(1,3,1);
plot(L1_range*1e3, erro_Regula_vs_L1,'b','LineWidth',2);
xlabel('L1 [mH]'); ylabel('Erro Regulação [%]');
title('Erro Regulação (ZL=25 \Omega)');
grid on;

subplot(1,3,2);
plot(L1_range*1e3, erro_Pperdas_vs_L1,'r','LineWidth',2);
xlabel('L1 [mH]'); ylabel('Erro Perdas [%]');
title('Erro Perdas (ZL=4+25.13j)');
grid on;

subplot(1,3,3);
plot(L1_range*1e3, erro_Pin_vs_L1,'k','LineWidth',2);
xlabel('L1 [mH]'); ylabel('Erro Pin [%]');
title('Erro Pin (ZL=-24.99j)');
grid on;
