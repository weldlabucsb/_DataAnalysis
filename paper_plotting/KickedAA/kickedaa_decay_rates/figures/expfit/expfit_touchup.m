set(gcf,'Position',[-408, 889, 312, 291]);

title('');

set(gca,'FontSize', 9)
set(gca,'FontName','Times New Roman')
% set(gca,'TextFontName','Times New Roman')

ylim([0.7,2.9]*1e4)
xlim([-100,1900])

% set(gca,'YTickLabel',[]);

set(gca,'TickDir','out');
ytickformat('%1.1f')

ylabel('Localized Population (a.u.)')

% ylabel(

h = gcf;
ax = get(gcf,'Children');
chil = get(ax,'Children');

cs = lines(3);
L1 = chil(2)
L1.MarkerFaceColor = colormap(cs(3,:))

L2 = chil(1)
L2.Color = 'k'
