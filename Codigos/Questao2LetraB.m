% Dados: [Pout Pin]
dados = {
    '50 \Omega',     [347 377];
    '25 \Omega',     [614 652];
    '30 || 50 \Omega', [889 942];
    '25 || 50 \Omega', [953 1015];
};

figure; hold on; grid on;

for i = 1:size(dados,1)
    nome = dados{i,1};
    Pout = dados{i,2}(1);
    Pin  = dados{i,2}(2);
    eta  = Pout/Pin;
    
    plot(Pout, eta, 'o', 'DisplayName', nome, 'LineWidth', 2, 'MarkerSize', 8);
end

xlabel('P_{out} [W]');
ylabel('\eta = P_{out}/P_{in}');
title('Rendimento vs P_{out}');
legend('Location','best');
