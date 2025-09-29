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
Zm = 1 / (1/Rm + 1/(1j*w*Lm));   % paralelo Rm // j w Lm
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
efic_med    = 63.21;

% =================== Malha de variação |ZL| e fase ===================
mag_range   = linspace(15,40,100);      % módulo
theta_range = deg2rad(linspace(75,85,100)); % fase em radianos

[Mag,Theta] = meshgrid(mag_range,theta_range);

% Matrizes de erro e custo
Erro_V1  = zeros(size(Mag));
Erro_I2  = zeros(size(Mag));
Erro_Pin = zeros(size(Mag));
Erro_Po  = zeros(size(Mag));
Erro_Per = zeros(size(Mag));
Erro_Ef  = zeros(size(Mag));
Custo    = zeros(size(Mag));

% =================== Loop de cálculo (usando as fórmulas do seu trecho) ===================
for i = 1:size(Mag,1)
    for j = 1:size(Mag,2)
        ZL = Mag(i,j) * exp(1j*Theta(i,j));   % forma polar

        % --- cálculos teóricos (igual ao seu snippet)
        Z_eq = Z1 + Zm*(3*ZL + Z2p)/(Zm + 3*ZL+ Z2p);   % com ramo magnetizante em paralelo
        
        V1  = 127*sqrt(3) * abs((Z1 + Z2p + 3*ZL) / (3*ZL));
        V2NL = V1*(1/sqrt(3)) * abs(Zm/(Zm+Z1));
        I2L = abs(127/ZL);
        Reg = abs((V2NL - V2L)/V2L) * 100;    % em %
        Po = V2L * (I2L)* cos(angle(ZL));
        Pin = (V1^2 / abs(Z_eq)) * cos(angle(Z_eq));
        Perdas = Pin - Po;
        Ef = (Po/Pin)*100;

        % --- erros percentuais (seguindo exatamente o seu cálculo)
        % uso max(..., eps) para evitar divisão por zero numérica
        Erro_V1(i,j)  = abs(V1 - V1_med)/max(abs(V1), eps) * 100;
        Erro_V2_line  = abs(V2L - V2L_med)/max(abs(V2L), eps) * 100; 
        Erro_V2_NL(i,j)= abs(V2NL - V2_NL_med)/max(abs(V2NL), eps) * 100; 
        Erro_I2(i,j)  = abs(I2L - I2_med)/max(abs(I2L), eps) * 100;
        Erro_Regula   = abs(Reg - Regula_med)/max(abs(Reg), eps) * 100; 

        Erro_Po(i,j)  = abs(Po - PO_med)/max(abs(Po), eps) * 100;
        Erro_Pin(i,j) = abs(Pin - Pin_med)/max(abs(Pin), eps) * 100;
        Erro_Per(i,j) = abs(Perdas - Pperdas_med)/max(abs(Perdas), eps) * 100;
        Erro_Ef(i,j)  = abs(Ef - efic_med)/max(abs(Ef), eps) * 100;

        % --- custo: norma Euclidiana do vetor de erros das 6 grandezas pedidas
        vet_erro = [ Erro_Pin(i,j), Erro_Po(i,j), Erro_Per(i,j), ...
                     Erro_V1(i,j), Erro_I2(i,j), Erro_Ef(i,j)];
        Custo(i,j) = norm(vet_erro);  % norma 2
    end
end

% =================== Procurar mínimo ===================
[min_custo, idx] = min(Custo(:));
[row,col] = ind2sub(size(Custo), idx);

mag_opt   = Mag(row,col);
theta_opt = rad2deg(Theta(row,col));   % em graus

% erros no ponto ótimo
erroV1_opt  = Erro_V1(row,col);
erroI2_opt  = Erro_I2(row,col);
erroPin_opt = Erro_Pin(row,col);
erroPo_opt  = Erro_Po(row,col);
erroPer_opt = Erro_Per(row,col);
erroEf_opt  = Erro_Ef(row,col);

fprintf('🔎 Melhor ponto encontrado (norma dos 6 erros):\n');
fprintf('|ZL| = %.4f Ω, θ = %.2f°\n', mag_opt, theta_opt);
fprintf('Erro Pin = %.3f%%, Erro Pout = %.3f%%, Erro Perdas = %.3f%%\n',...
    erroPin_opt, erroPo_opt, erroPer_opt);
fprintf('Erro V1 = %.3f%%, Erro I2 = %.3f%%, Erro Ef = %.3f%%\n',...
    erroV1_opt, erroI2_opt, erroEf_opt);
fprintf('Custo (norma) = %.3f\n', min_custo);

% =================== Plot 3D do custo e ponto ótimo ===================
figure('Name','Custo (norma dos 6 erros) vs |ZL| e fase','NumberTitle','off');
surf(mag_range, rad2deg(theta_range), Custo, ...
     'FaceAlpha',1.0, ...     % transparência
     'EdgeColor','none');     % sem grade "xadrez"
xlabel('|Z_L| [\Omega]');
ylabel('Fase de Z_L [graus]');
zlabel('Norma dos Erros [%]');
title('Norma do Vetor de Erros');
colorbar;
colormap turbo;
shading interp;
view(45,30);
hold on;
plot3(mag_opt, theta_opt, min_custo, 'ro', 'MarkerFaceColor','r', 'MarkerSize',8);
grid on;
