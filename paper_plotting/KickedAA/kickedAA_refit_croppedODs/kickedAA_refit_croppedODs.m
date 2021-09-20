if ispc 
    if isfolder("V:/")
        default_data_dir_path = "V:/";
    elseif isfolder("X:/")
        default_data_dir_path = "X:/";
    end
elseif ismac
    if isfolder("/Volumes/WeldLab2/")
        default_data_dir_path = "/Volumes/WeldLab2/";
    else
        default_data_dir_path = "";
    end
end