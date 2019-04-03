 
I=imread('55.jpg');
 A=imcrop(I);
 imwrite(A,'8999C.jpg');
g=imread('8999C.jpg'); 
% g=rgb2gray(I); 
% [M,N]=size(g);
% if 232<i&&i<595&217<j&&j<482
%     g(i,j)=g(i,j);
% else
%     g(i,j)=0;
% end
% imshow(g)

 
 
zmax=max(max(g));%取出最大灰度值 
zmin=min(min(g));%取出最小灰度值 
tk=(zmax+zmin)/2;%求初始阀值 
bcal=1; 
gsize=size(g);%图像大小 
% g=guidedfilter(g,g,3,0.1);
%  imshow(g)
 
while(bcal) 
    %定义前景和背景像素数 
    iforeground=0; 
    ibackground=0; 
    %定义前景和背景的灰度总和 
    foreground=0; 
    background=0; 
    for i=1:gsize(1) 
        for j=1:gsize(2) 
            tmp=g(i,j); 
            if(tmp>=tk) 
                %前景灰度值 
                iforeground=iforeground+1; 
                foreground=foreground+double(tmp); 
            else 
                %背景灰度值 
                ibackground=ibackground+1; 
                background=background+double(tmp); 
            end 
        end 
    end 
    zo=foreground/iforeground; 
    zb=background/ibackground; 
    %计算前景和背景的平均值 
    tktmp=uint8((zo+zb)/2); 
    %当阀值不再变化时，说明迭代结束 
    if(tktmp==tk) 
        bcal=0; 
    else 
        tk=tktmp; 
    end 
end 
%disp(strcat('迭代后的阀值',num2str(tk))); 
disp(strcat('迭代后的阀值',double(tk))); 
newg=im2bw(g,double(tk)/255); 
figure(2),imshow(g); 
figure(3),imshow(newg); 
imwrite(newg,'99.jpg');