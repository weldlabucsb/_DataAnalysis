function [JetWhite] = getJetWhite()
%GETJETWHITE Returns JetWhite, a colormap that Esat uses.
JetWhite = load('JetWhite.mat');
JetWhite = JetWhite.JetWhite;
end

