function [EditedUSA] = getEditedUSA()
%GETEDITEDUSA returns an edited blue red diverging colormap for the high T
%data.

EditedUSA = load('EditedUSA.mat');
EditedUSA = EditedUSA.ans;
end

