function [counter] = make_gif(flag,filename,counter,options)
% MAKE_GIF(flag,filename,counter,options) creates a gif if flag == true at
% location filename. Must supply a counter variable that starts at 1!
% Output of function updates counter variable by 1.

arguments
    flag
    filename
    counter
end
arguments
    options.FrameTime double = 1
end

frame_time = options.FrameTime;

if flag
      
  frame = getframe(gcf);
  im = frame2im(frame);
  [A,map] = rgb2ind(im,256);

    if counter == 1
  	 imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',frame_time);
    else
     imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',frame_time);
    end
    
    counter = counter + 1;

end

end