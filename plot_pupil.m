function plot_pupil(circle_num)  
%------------------------------�������-----------------------------  
%����Բ�Ĳ�������һ��Բ��  
%Բ����   circle_num:  
%                   circle_num(1) : Բ�ĺ�����  
%                   circle_num(2) ��Բ��������  
%                   circle_num(3) ��Բ�İ뾶  
%-------------------------------------------------------------------  
radius_y = circle_num(1);  
radius_x = circle_num(2);  
radius = circle_num(3);  
  
alpha=0:pi/20:2*pi;%�Ƕ�[0,2*pi]  
R=radius;           %�뾶  
%������ͼ�Ķ�Ӧλ��  
x=R*cos(alpha)+radius_x-1;     
y=R*sin(alpha)+radius_y-1;  
 hold on,plot(x,y,'g-','Linewidth',1)
% fill(x,y,'w')
