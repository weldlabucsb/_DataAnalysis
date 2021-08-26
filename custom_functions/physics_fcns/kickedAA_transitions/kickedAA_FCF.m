function FCF_groundToExcited_squared = kickedAA_FCF(q0, s1, options)

arguments
    q0 = 0
    s1 = 10
end
arguments
    options.PositiveMomentumKick = 1
end

[~,euk0]=bloch1Dsorted(10,q0,6);

if options.PositiveMomentumKick
    [~,euks]=bloch1Dsorted(10,q0 + 2*1064/915 - 2,6);
else
    [~,euks]=bloch1Dsorted(10,q0 - 2*1064/915 + 2,6);
end

normk0=euk0'*euk0;
normks=euks'*euks;
FCF = euk0'*euks;
FCF_groundToExcited_squared = FCF(1,:).^2;

end

