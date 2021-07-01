function rate = calcTransRate(finalQuasi,finalBand)
if nargin < 2
    finalQuasi = linspace(-1,1,100);
    finalBand = 2;
end
    
    %%transition parameters (from where to where)
    initQuasi = 0;
    initBand = 1; %ground band = 1

    depth1 = 10; %1064 depth
    depth2 = 1; %915 depth

    lambda1 = 1064;
    lambda2 = 915;
    beta = lambda1/lambda2;

    %like GPE, x = 2\pi is 1064 lattice site
    n = 20; %points per 1064
    N = 1000; % 1064 sites
    dx = 2*pi/n;
    x = -N*pi:dx:N*pi-dx;


    %%make bloch states for matrix element. Position space
    initState = multiBlochStateX1D(depth1,initBand,initQuasi,x');

    finalState = multiBlochStateX1D(depth1,finalBand,finalQuasi,x');

    pot = depth2*cos(beta.*x);
    %%calculate matrix element
    matrixElem = abs((conj(initState).*pot)*(finalState.'));
    
    %%calculate density of states for the final band, which is really just
    %%the inverse gradient
    [E,~] = bloch1D(depth1,finalQuasi,2*finalBand + 21);
    E = E(finalBand,:);
    density = abs(gradient(E,finalQuasi(2)-finalQuasi(1)).^(-1));
    
    rate = (matrixElem.^2).*density;
    
    %%now we have to find the rate where the relevant transition is
    
    
    if 0
        figure(1);
        pl = plot(finalQuasi,matrixElem);
        %makes sense, driving quasimomentum difference of 915 lattice
        xline(2-beta);
        xline(beta-2);
        set(pl,'linewidth',2);
    %     ylabel('Matrix Element');
        xlabel('Quasimomentum');
        legend('','\pm(\beta - 2)');
        set(gca,'fontsize',13);
            figure(2);
        pl = plot(finalQuasi,density);
        %makes sense, driving quasimomentum difference of 915 lattice
        xline(2-beta);
        xline(beta-2);
        set(pl,'linewidth',2);
    %     ylabel('Matrix Element');
        xlabel('Quasimomentum');
        legend('','\pm(\beta - 2)');
        set(gca,'fontsize',13);
    end
    
end