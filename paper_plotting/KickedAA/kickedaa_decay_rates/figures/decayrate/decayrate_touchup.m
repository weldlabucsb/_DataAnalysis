set(gcf,'Position',[-408, 889, 312, 291]);

title('');

h = gcf;
chil = get(h,'Children');
axs = chil.Axes;

set(gca,'FontSize', 9)
set(gca,'FontName','Times New Roman')
% set(gca,'TextFontName','Times New Roman')

ylim([0,2.2]*1e4)

set(gca,'YTickLabel',[]);

set(gca,'TickDir','out');

ylabel('Localized Population (a.u.)')
