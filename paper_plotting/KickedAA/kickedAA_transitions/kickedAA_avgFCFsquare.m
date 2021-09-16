function [avgFCF,FCF,qvector] = kickedAA_avgFCFsquare(s1,samples,options)

arguments
    s1 = 10
    samples = 1e3
end
arguments
    options.Plot (1,1) logical = 1
end

qvector = linspace(-1,1,samples);

for ii = 1:samples
   FCF(ii,:) = kickedAA_FCF(qvector(ii),'PositiveMomentumKick',0);
end
for ii = 1:samples
    FCF(samples+ii,:) = kickedAA_FCF(qvector(ii),'PositiveMomentumKick',1);
end

avgFCF = sum(FCF)/(2*samples);

if options.Plot
    L = length(2:size(FCF,2));
    colrs = colormap(lines(L));
%     for ii = 2:size(FCF,2)
%        semilogy(qvector',FCF(1:samples,ii),'LineWidth',1,'Color',colrs(ii-1,:));
%        hold on;
%     end
%     for ii = 2:size(FCF,2) 
%        semilogy(qvector',FCF(samples+1:end,ii),'--','LineWidth',1,'Color',colrs(ii-1,:));
%     end
    for ii = 2:size(FCF,2)
        semilogy(qvector',FCF(1:samples,ii) + FCF(samples+1:end,ii),'LineWidth',1,'Color',colrs(ii-1,:));
        hold on;
    end
    hold off;
    leg = legend([...
        "g to 1st excited",
        "g to 2nd excited",
        "g to 3rd excited",
        "g to 4th excited",
        "g to 5th excited"]);
    set(leg,'Location','southeast');
    title({'FCF^2 vs. q_0 for transitions from q_0 to q_0\pm2k_s';'FCF^2 = |<q + 2k_S| exp(i 2k_S x) |q_0>|^2 + (- \leftrightarrow +)'})
    ylabel('FCF^2')
    xlabel('q_0 (k_P)')
end

end