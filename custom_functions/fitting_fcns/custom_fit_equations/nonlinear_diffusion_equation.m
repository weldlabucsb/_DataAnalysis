function y = nonlinear_diffusion_equation(x,t,a,x0,A)

model = A * t^( 1/(2+a) ) * ( 1 - x.^2 / x0^2 ).^(1/a) + c;

domain_mask = (x > -x0) & (x < x0);

y = domain_mask .* model;

% for j = 1:length(x)
%     
%     if x(j) > -x0 && x(j) < x0
%         y(j) = A * t^( 1/(2+a) ) * ( 1 - x(j)^2 / x0^2 )^(1/a) + c;
%     else
%         y(j) = 0;
%     end
%     
% end

end
        
        