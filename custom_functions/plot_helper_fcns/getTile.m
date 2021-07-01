function thisTile = getTile(fig_handle,tile_number)
    h = fig_handle;
    
    tileLayout = get(h,'Children');
    tileChil = get(tileLayout,'Children');
    
    axesTypes = arrayfun(@(x) class(x), tileChil, 'UniformOutput', false);
    axes = tileChil( axesTypes == "matlab.graphics.axis.Axes" );
    
    thisTile = axes( end - tile_number + 1 );
end