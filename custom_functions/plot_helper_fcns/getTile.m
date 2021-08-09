function thisTile = getTile(tile_number,fig_handle)
    arguments
        tile_number % specified from top
        fig_handle = gcf
    end
    
    h = fig_handle;
    
    tileLayout = get(h,'Children');
    tileChil = get(tileLayout,'Children');
    
    axesTypes = arrayfun(@(x) class(x), tileChil, 'UniformOutput', false);
    axes = tileChil( axesTypes == "matlab.graphics.axis.Axes" );
    
    thisTile = axes( end - tile_number + 1 );
end