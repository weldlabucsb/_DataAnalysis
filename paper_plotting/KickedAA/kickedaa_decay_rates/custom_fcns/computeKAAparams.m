function latticeParams = computeKAAparams( inData )
% COMPUTEKAAPARAMS(inData) takes in a RunData, RunDataLibrary, or cell of
% RunDatas and returns the corresponding J, Delta, Lambda, T', etc values.
%
% Optional arguments:
%     DefaultKDValue (default = true): logical, if true use the KD
%     calibration from 3/23 (a recent value).
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
        inData
    end
    arguments
        options.DefaultKDValue = 1
        options.KDAtomdata = []
        options.secondaryPDGain = 1

    if class(inData) == "RunDataLibrary"
       runDatas = Data.RunDatas; 
    elseif class(inData) == "cell"
        runDatas = inData;
    elseif class(inData) == "RunData"
        runDatas = {inData};
    end
    
    lattice915VVA_vals = ...
        cellfun( @(rd) arrayfun( @(ad) ...
        rd.ad.vars.Lattice915VVA, ...
        rd.Atomdata), runDatas, ...
        'UniformOutput', false);
    
    s1 = cellfun( @(rd) arrayfun( @(ad) ...
        rd.ad.vars.VVA1064_Er, ...
        rd.Atomdata), runDatas, ...
        'UniformOutput', false);
    
    for j = 1:length(lattice915VVA_vals)
       latticeParams(j).s2 = VVAto915Er( lattice915VVA_vals{j} );
       
       for ii = 1:length( lattice915VVA_vals{j} )
           [ latticeParams(j).J(ii), ...
               latticeParams(j).Delta(ii) ] = J_Delta_PiecewiseFit( s1, 
    end

end