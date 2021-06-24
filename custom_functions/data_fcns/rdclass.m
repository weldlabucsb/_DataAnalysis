function trueIfCell = rdclass(RunData)
% Returns true if input is a cell of RunDatas, false if the input is a
% RunData.
% 
% I am not sure if this function has any real excuse to not exist inside
% cellWrap. However, I may have referenced this function in some core
% function of DataAnalysis, so do not remove it.

if class(RunData) == "cell"
    if class(RunData{1}) == "RunData"
        trueIfCell = 1;
    else
        badClass();
    end
elseif class(RunData) == "RunData"
    trueIfCell = 0;
else
    
    return;
end

    function badClass()
        disp('What have you given me, it is not a RunData or a cell of RunDatas.');
    end

end