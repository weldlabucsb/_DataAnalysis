%make atom plot
clear atomNumsVec
seventh_fig = figure(7);
subplot(1,2,1);
    load('floquetatoms.mat')
    pColorCenteredNonGrid(gca,lambdas,Ts,atomNumsVec,1E-6,1E-6);
    hold on;
    plot(linspace(0,2*max(Ts),30),0.5*linspace(0,2*max(Ts),30),'r-','linewidth',2);
    hold off;
    xlabel('Lambda');
    ylabel('T''');
    title('Atom Number: Periodic Kicking');
    colorbar;
    caxis([0 6E4]);
subplot(1,2,2);
clear atomNumsVec
load('stochatoms.mat')
    pColorCenteredNonGrid(gca,lambdas,Ts,atomNumsVec,1E-6,1E-6);
    hold on;
    plot(linspace(0,2*max(Ts),30),0.5*linspace(0,2*max(Ts),30),'r-','linewidth',2);
    hold off;
    xlabel('Lambda');
    ylabel('T''');
    title('Atom Number: Stochastic Kicking');
    colorbar;
    caxis([0 6E4]);
    
                eig_fig = figure(8);
                clear fracWidthsvec;
                subplot(1,2,1);
                load('floquet.mat')
    mycolormap = customcolormap(linspace(0,1,11), {'#68011d','#b5172f','#d75f4e','#f7a580','#fedbc9','#f5f9f3','#d5e2f0','#93c5dc','#4295c1','#2265ad','#062e61'});
    colormap(mycolormap);
%     axis off;

%     pColorCenteredGrid(gca,lambdas,Ts,fracWidthsvec);
%     zlim([0 5E-5]);
    pColorCenteredNonGrid(gca,lambdas,Ts,fracWidthsvec,1E-6,1E-6);
    caxis([0 5E-5]);

    hold on;
    plot(linspace(0,2*max(Ts),30),0.5*linspace(0,2*max(Ts),30),'r-','linewidth',2);
    hold off;
%     xlim([0 0.03]);
        
    title('cloudSD_y: Periodic Kicking');
%     title(['width at ' num2str(frac) ' maximum (summedODy, au)']);
    colorbar;
    ylabel('T''');
    xlabel('Lambda');
    
                    subplot(1,2,2);
                    clear fracWidthsvec;
                load('stoch.mat')
    mycolormap = customcolormap(linspace(0,1,11), {'#68011d','#b5172f','#d75f4e','#f7a580','#fedbc9','#f5f9f3','#d5e2f0','#93c5dc','#4295c1','#2265ad','#062e61'});
    colormap(mycolormap);
%     axis off;

%     pColorCenteredGrid(gca,lambdas,Ts,fracWidthsvec);
%     zlim([0 5E-5]);
    pColorCenteredNonGrid(gca,lambdas,Ts,fracWidthsvec,1E-6,1E-6);
    caxis([0 5E-5]);

    hold on;
    plot(linspace(0,2*max(Ts),30),0.5*linspace(0,2*max(Ts),30),'r-','linewidth',2);
    hold off;
%     xlim([0 0.03]);
        
    title('cloudSD_y: Stochastic Kicking');
%     title(['width at ' num2str(frac) ' maximum (summedODy, au)']);
    colorbar;
    ylabel('T''');
    xlabel('Lambda');
    
    
    
    
    