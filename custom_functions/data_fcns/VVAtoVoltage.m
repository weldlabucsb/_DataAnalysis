function voltage = VVAtoVoltage(VVA_vector, options)
% VVATOVOLTAGE(VVA_vector, options) converts vva values for the secondary
% lattice into PD voltages. These are then to be converted to a lattice
% depth using the KD calibration.
%
% Optional arguments:
%   DefaultKDValue (default = 1): If true, uses values from 3/23.
%
%   KDAtomdata (default = []): If nonempty (and if DefaultKDValue = false),
%   function will extract vva to voltage conversion from the provided
%   atomdata from a KD run.

    arguments
        VVA_vector
    end
    arguments
       options.DefaultKDValue (1,1) logical = 1
       options.KDAtomdata = []
    end
    atomdata = options.KDAtomdata;
    
    % 2/27
    if options.DefaultKDValue
        % if true, uses values from 3/23.
        V0s = [0.000000000000000,0.073678350810385,0.091932523321550,0.140775622496791,0.177681318284420,0.213707250228924,0.244105225971579,0.256827061740513,0.278925131974928,0.289462482914505,0.315246479230482,0.332958057066155,0.346744790852344,0.332958057066155,0.381614474966698,0.402993079662267,0.408784741151747,0.427199505248519,0.437485713621218,0.452582892831114];
        vvas = [1,2,2.1,2.4,2.6,2.8,3,3.1,3.3,3.4,3.6,3.8,4,4.2,4.4,4.7,5,5.5,6,7.5];
        V0s(14) = [];
        vvas(14) = [];
        
        % if true, uses values from 2/27
%         V0s = [0.0297611340889169,0.0320000000016725,0.0360000000000222,0.0620546063258612,0.0719909967293660,0.100286258828503,0.132132920348285,0.160270640980708,0.194334313681227,0.216658564267728,0.230893463124005,0.254476729560220,0.267785474698420,0.284191264615461,0.300403320122237,0.316392760370631,0.335449780883353,0.341275399292686,0.355480424302642,0.370968685011421,0.386239458185895,0.393433865352977,0.408399987686944];
%         vvas = [1,1.80000000000000,1.90000000000000,2,2.10000000000000,2.20000000000000,2.40000000000000,2.60000000000000,2.80000000000000,3,3.10000000000000,3.30000000000000,3.40000000000000,3.60000000000000,3.80000000000000,4,4.20000000000000,4.40000000000000,4.70000000000000,5,5.50000000000000,6,7.50000000000000];
    else
        % if not using default values....
        
        if isempty(atomdata)
            % load a new atomdata if you didn't provide one
            atomdata = load("X:\StrontiumData\*.m"); atomdata = atomdata.atomdata;
            options.atomdata = atomdata;
        end
        
        vvas = arrayfun(@(x) x.vars.Lattice915VVA, atomdata);
        V0s = arrayfun(@(x) x.V0, atomdata);
    end
      voltage = interp1(vvas,V0s,VVA_vector);
end