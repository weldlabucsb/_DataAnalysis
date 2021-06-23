# Data Analysis Package

The idea was to package together a bunch of functions that make building plots and analyzing data from RunDatas much easier.

## Getting Started
Read through the following tutorials.
1. For a tutorial in writing plot functions using this architecture, read plotFunctionTemplate.m.
2. Check out exampleAnalysis_QC.m to see an example of using selectRuns and the plot functions.

## DataManager
A RunDataLibrary of all the data you'd like to consider can be loaded from the Data folders on the citadel using the autoLibGen app contained in dataManager. See [the dataManager GitHub](https://github.com/weldlabucsb/dataManager) to get dataManager and view the documentation on autoLibGen.

### selectRuns
Once you have your initial RunDataLibrary, you can select subsets of this data using the selectRuns app. It takes a RunDataLibrary as its argument, which you will supply as the large RunDataLibrary you generated using autoLibGen. Call it with "selectRuns(DATA)", where DATA is your RunDataLibrary.
```matlab
selectRuns(DATA);
```
This will produce a GUI that looks like this:

<img src="https://i.imgur.com/R2uVqbD.png" alt="the selectRuns GUI" width="600"/>

Note that when you first open the GUI, the lower tables will not yet be populated.

From here, you can select the runs you'd like to plot by toggling the checkboxes at right. 
- You can select multiple runs at once by clicking into one of the rows to highlight a cell on that row, then holding shift and clicking a cell on a different row to highlight all the cells in between. You can then toggle all of their checkboxes by clicking the button at right.

Once you have the desired runs selected (checkboxes toggled), click the "Generate ..." button (step 3) to save the RunDataLibrary to your workspace. 
- This may generate MANY error messages, if some variables were added to atomdata in the later runs and are not present in others, but this is okay.

The app then reads out the variables stored in the RunDataLibrary you just built. It puts a list of any variables which take more than one value across all the selected runs into the leftmost column, under "Step 4". Select the independent variable for the set of runs you've selected. 
- The number of unique values for each variable are specified to help you identify which might be the varied variable for those runs.
- If the one you expect does not appear in the list, you can specify it manually in the box below, checking the box to specify that you want to use the manual value.

You can also select variables which were held constant within each run (heldvars each: middle table) or across all runs (heldvars all: right table). This list is populated with all of the variables stored in the RunDataLibrary. These are used for automatic generation of the legend, title, and axes labels.
- Again, variables can be specified manually below each table. For the heldvars tables, you can check values __and__ specify manual variables. All of them will be included in the RunVars struct.
- Multiple manual variables can be specified as comma-delimited variable names. Spaces are fine.

Clicking the "Step 6" button will put the RunVars variable into your workspace. I've included a function called __unpackRunDatas__ that can be used to split this into the variables used by the plotFunctions. See below for details.
- If you include selectRuns in line with your script, be sure to put a pause afterward so that you can take your time selecting data before continuing.
- One can also just leave selectRuns open on their computer, reselecting data and re-running plotFunctions in real time to analyze different subsets of data.

## Useful functions:

- __selectRuns__: this app is used to generate selected RunDatas from a RunDataLibrary, which presumably is generated from autoLibraryGenerator application. Take that RunDataLibrary, load it into matlab, and then call this function. 
    - As noted in the Getting Started section, if this function is called in your script, put a "pause" afterward so that you can take your time choosing runs before your code advances.
    ```matlab
        selectRuns(myRunDataLibrary)
    ```
    
- __avgRepeats__ averages the repeats in the provided RunData for each value of the specified varied cicero variable. Can average repeats over multiple RunDatas if provided as a cell array of RunDatas. Outputs an averaged atomdata-like structure with averaged values of each variable name in the cell array variables_to_be_averaged.
    ```matlab
        averaged_atomdata = avgRepeats(RunDatas, varied_variable, variables_to_be_averaged);
    ```

- __runDateList__: takes in a RunData object (or cell array of RunDatas), and outputs a string of the form "Runs {month}.{day} - {run numbers (space delimited)} ...". If the runs span multiple days, it will separate different date-run lists by commas. Example output:
    ```matlab
    >> exampleRunDateList = runDateList(RunDatas)
    ans = "Runs 6.10 - 10 23, 6.11 - 23 14, 6.15 - 14"
    ```

- __plotTitle__: takes in a RunData object or a cell array of RunData objects, and outputs a multi-line plotTitle. First line specifies the dependent variable being plotted (any string) and the varied variable (a cicero variable). Varargs (cell array of cicero variable names (strings)) optionally adds a line of cicero variables that were held constant and their values. Next line specifies the dates and run numbers that were present in the provided RunData(s). Function outputs title as a cell array of strings which can be passed to title().
    ```matlab
    plot_title = plotTitle(RunDatas,plotted_dependent_variable,varied_variable_name,varargin)
    ```
    Example:
    ```matlab
    >> plotTitle(RunDatas,'Cloud Width','LatticeHold',{'T','tau','Lattice915VVA'})
    ans = 
    {["Cloud Width vs LatticeHold"          ]}
    {["T - 250, tau - 15, Lattice915VVA - 3"]}
    {["Runs 6.21 - 12 13 14"                ]}
    ```

- __filenameFromPlotTitle__: takes in cell array (of strings) output from plotTitle and outputs a .png filename which can be used to save the figure.
    ```matlab
    plotPNG_filename = filenameFromPlotTitle(plot_title)
    ```

- __setupPlot__: an absolute beast of a function with a billion optional arguments. Call the same way as plotTitle. Passes several of its arguments to plotTitle. Uses this plotTitle and the other optional arguments to adjust x/y labels, x/ylims, etc. See docstring for optional arguments. Also outputs the figure title output of plotTitle.
    - To pass arguments to setupPlot, it is recommended to call setupPlot through its wrapper function, __setupPlotWrap__.
    - Automatically outputs a figure filename as its second argument, to be used when saving the figure. It includes the same information as the plot title: run dates and numbers, dependent and independent variables, and values of held variables.
    - legendvars is a cell array of variable names whose names should be included in the legend title, and whose values should be associated with each entry in the legend. Example: legendvars = {'VVA1064_Er','VVA915_Er'} produces a legend where each entry is labeled by the 1064 depth and 915 depth.
        - Leave the LegendLabels and LegendTitle options unspecified to automatically generate the legends this way. If you specify them as options to setupPlot, you will respectively override the automatic generation of the legend labels/title.
    - If calling setupPlot in a plot function, I generally give the plot function the same optional arguments that are to be passed to setupPlot and adjust the default values according to the plot function I'm writing. Then at the end of the plot function, call it through its wrapper function, setupPlotWrap (see below).

- __setupPlotWrap__: a wrapper function for setupPlot that allows you to feed it the full options struct of your plot function, so that the copy/pasted block doesn't end up being quite so obnoxious. Call it like this (I recommend you just copy/paste this line into your plot function):
    ```matlab
    [plot_title, plotPNG_filename] = setupPlotWrap( figure_handle, options, RunDatas, dependent_var, varied_variable_name, legendvars, varargin);
    ```

- __unpackRunVars__: for use with the RunVars struct generated by selectRuns. This function assigns the variable names in the struct to the variables used as arguments in the plotFunctions.
    - By default, assigns legendvars_each = varied_var and legendvars_all = heldvars_each. Read the comments in unpackRunVars for details on why. 
    - Use legendvars_each as the legendvars input of your plotFunctions for a plot of a single run, and legendvars_all for a plot of all the selected runs.
    - I recommend that you just copy/paste this line:
    ```matlab
    [varied_var, ...
    heldvars_each, ...
    heldvars_all, ...
    legendvars_each, ...
    legendvars_all] = unpackRunVars(RunVars);
    ```
    
- __saveFigure__ takes a figure handle, filename, and output_folder_path. Saves the figure specified by the figure handle to fullfile(output_folder_path,filename).
    - Accepts cell arrays of figure handles and filenames. Must be the same length.
    
## Existing PlotFunctions
The plot functions sort of naturally fall into two categories: plots for visualizing a single run (like a stacked expansion plot), and plots for visualizing multiple runs on the same axes. I'll start labeling the docstrings of the plotfunctions with [one plot per run] or [multi-run plot] just after the function name.

I typically put the single-run plotfunctions in a for-loop, and loop over the RunDatas I'm looking at. The multi-run plots will just take the entire cell array of RunDatas as is. See exampleAnalysis.m for an example.

- stackedExpansionPlot [one run per plot]
- widthEvolutionPlot [multi-run plot]
- oortZoomPlot [one run per plot]
- centersPlot [multi-run plot]

## Current State of Affairs
The custom functions also include a few of my fitting functions that are holdovers from an older version of my analysis code. fracWidth works reasonably well (to find the width at which a function hits a fraction of its maximum value), but still chokes on noisy distributions. I would not expect the rest to work well until I update them.
