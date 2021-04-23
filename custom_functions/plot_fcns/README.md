# PlotDataPixelCenetered

Frequently, one wants to plot data with two independent coordinates (x,y)  and a specified dependent value (z) as a color plot, so that the (x,y) point is specified with two axes and the z value is represented with a color.  Usually, the (x,y) values to be plotted form points on a grid of rectangles, and one would like the color plot to look like a patchwork of rectangular pixels so that each pixel is centered on its (x,y) coordinate and has the color defined by a color map for the corresponding value of z.

For the above desired plot, Matlab has the function imagesc, which suffices when the grid of points (x,y) are evenly spaced.  That is, when all the rectangles of the grid are equally spaced.  However, it fails in other cases.  Consider for example, when the values of x are spaced such that the values log(x) are equally spaced.

Matlab's pcolor function has no restriction on arrangement of the points (x,y), but it does not shade pixels so that the pixels are centered on the points (x,y).  Instead, the corner of the pixel is at the value (x,y).  This does not cause confusion, if the values of (x,y) are very finely spaced, but this is not always possible.  You can also interpolate the colors, but this can misrepresent coursely spaced data.

To realize the described plot, this repository has been written.  Details of usage are written in the function header, and it will show if you use Matlab's help [function name].  The repository contains the following functions:

pColorCenteredGrid.m -- This creates the plot exactly as described.

pColorCenteredGridLogLog.m -- This is for a related situation in which the values of log(x) and log(y) are equally spaced, and one wishes to plot the data on a loglog plot such that visually, the loglog plot pixels are centered on the grid in loglog space.  Note that you can still use pColorCenteredGrid and set the axes to loglog if you want the pixel colors to represent the value of the closed value of x and y (rather than the closest value of log(x) and log(y) as this function does).

pColorCenteredGridLogX.m (pColorCenteredGridLogY.m) -- This is similar to pColorCenteredGridLogLog.m for the situation where the values of log(x) (log(y)) are evenly spaced, but the values of y (x)  are linearly spaced.
