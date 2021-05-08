function VVA_vector = ErToVVA(Er915_vector, options)
% ErToVVA(vva_vector, options) converts lattice depth values for the 915
% lattice (in units of 1064 Ers) into VVA voltage.
%
% Optional arguments:
%     DefaultKDValue (default = true): logical, if true use the KD
%     calibration from 3/23 (a recent value).
%
%     StrontiumDataPath (default: "X:\StrontiumData\"): If DefaultKDValue =
%     false, this is where the file picker will default to and ask you to
%     choose an atomdata.
%
%     KDAtomdata (default = empty): You can provide the atomdata from a KD
%     run to extract the KD calibration for a particular run. (This is only
%     used if DefaultKDValue = false.)
%
%     SecondaryPDGain (default = 1): In case it was something else for a
%     given run. Typically = 10 for static lattice runs, and = 1 for kicked
%     runs.
%
    arguments
        Er915_vector
    end
    arguments
       options.DefaultKDValue (1,1) logical = 0
       options.StrontiumDataPath = "X:\StrontiumData\"
       options.KDAtomdata = []
       options.secondaryPDGain = 1
    end
    secondaryPDGain = options.secondaryPDGain;

    if options.DefaultKDValue
%         secondaryErPerVolt = 13.4527; % from 3/23
        secondaryErPerVolt = 12.54; % from 2/27
        atomdata = [];
    else
        % if not using default value, load an atomdata and grab the Er per
        % volt value from there.
        if isempty(options.KDAtomdata)
           [atomdata_path, fpath] =...
               uigetfile(fullfile(options.StrontiumDataPath,"*.mat"),"Choose the KD atomdata."); 
            atomdata = load( fullfile(fpath,atomdata_path) );
            atomdata = atomdata.atomdata;
        else
           atomdata = options.KDAtomdata; 
        end
        
        secondaryErPerVolt = unique(arrayfun(@(x) x.fitKD.B, atomdata));
    end
    
    voltage_vector = Er915_vector * secondaryPDGain / secondaryErPerVolt;
    
    VVA_vector = VoltageToVVA( voltage_vector,...
        'DefaultKDValue', options.DefaultKDValue, ...
        'KDAtomdata', atomdata);

end