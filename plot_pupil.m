function plot_pupil(circle_num)  
%------------------------------输入参数-----------------------------  
%给定圆的参数画出一个圆形  
%圆参数   circle_num:  
%                   circle_num(1) : 圆心横坐标  
%                   circle_num(2) ：圆心纵坐标  
%                   circle_num(3) ：圆的半径  
%-------------------------------------------------------------------  
radius_y = circle_num(1);  
radius_x = circle_num(2);  
radius = circle_num(3);  
  
alpha=0:pi/20:2*pi;%角度[0,2*pi]  
R=radius;           %半径  
%规整到图的对应位置  
x=R*cos(alpha)+radius_x-1;     
y=R*sin(alpha)+radius_y-1;  
 hold on,plot(x,y,'g-','Linewidth',1)
% fill(x,y,'w')
