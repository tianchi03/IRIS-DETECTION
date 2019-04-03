clc;
clear;
%k:图像缩放系数
for i=36:36
   
    ii=num2str(i);
    filename=[ii,'.jpg'];
    eye=imread(filename);
    
    if ndims(eye)==3
        eye=rgb2gray(eye);
    end
    
    eye=double(eye);
    eye=eye/256;
    [K,J]=size(eye);
    ratio=round(1200/K)/10;%根据图像大小缩放图像
    eye1=imresize(eye,ratio);
    [M,N]=size(eye1);
k=floor(M/12);
l=floor(N/12);
%构建一个大小为K*L（注意！是字母l不是数字1）的元胞数组，用于存放每个窗口的所有灰度值
A=cell(k*l,1);
%计算每个窗口的灰度均值
x=1;
for i=1:k
    y=1;
   for j=1:l       
    A{(i-1)*l+j}=eye1(x:x+M/k-1,y:y+N/l-1);
    y=y+N/l;
    end
    x=x+M/k;
end
%%构建一个大小为K*L（注意！是字母l不是数字1）的元胞数组，用于存放每个窗口的灰度均值
B=cell(k*l,1);
for i=1:k*l
B{i}=sum(sum(A{i}))/M/N*k*l;
end
B=cell2mat(B);%转化元胞数组为矩阵
T=min(B);%将最小灰度均值作为二值变换阈值
eye_bw=im2bw(eye1,T+6/256);%%初始增值定位8，对二值化结果影响的主要因素是睫毛
%step2：%%找出最大面积的区域设置为瞳孔区域
eye_blur = medfilt2(eye_bw,[7 7],'symmetric');%%除去二值化图像中的点状噪声
eye_blur=1-eye_blur;%二值反变换方面后续连通区域标记
% 区域标记，一般此时只剩两个区域，一个区域为瞳孔部分，另一可能存在的区域为睫毛部分
[L, num] = bwlabel(eye_blur, 8); 
stats = regionprops(L, 'Basic'); 
Bd = cat(1,stats.BoundingBox);%将struct:stats的BoundingBox区域方框中内容转化为矩阵
Ar=cat(1,stats.Area);%将struct:stats的Area区域面积中内容转化为矩阵
[s1, s2] = size(Bd);
p=zeros(s1,1);
mx=max(Ar);
[j,s]=find(Ar==mx);%%找出最大面积的区域设置为瞳孔区域
cirp=Bd(j,:);
Rp=round((cirp(1,3)+cirp(1,4))/4);%瞳孔圆心、半径粗定位
xp=round(Rp+cirp(1,2));
yp=round(Rp+cirp(1,1));
%%将粗定位的圆全部涂白，分割出粗定位的瞳孔区域,瞳孔的粗分割完成
%导向滤波消除杂纹，保留边缘
edge_w=edge(eye1,'canny');
%%除去中心白点，减少运算量
for m=xp-Rp:xp+Rp
    for  n=yp-Rp:yp+Rp
       R2=(m-xp)^2+(n-yp)^2;
       if R2<=Rp^2*0.9
           edge_w(m,n)=0;
       end
    end
end
edge_copy=zeros(M,N);
%edge_copy为最终瞳孔轮廓，只保留了中心瞳孔区域的边缘信息，目的是减少运算量
for x=1:M
    for y=1:N
if (x>xp-Rp-6&&x<xp+Rp+6)&&(y>yp-Rp-6&&y<yp+Rp+6)
    edge_copy(x,y)=edge_w(x,y);
end
    end
end
%进行霍夫变换
mean_circle=houghcircle(edge_copy,0.2,0.0872,Rp-3,Rp+3,0.7);%只对瞳孔区域的圆进行处理，大大提升霍夫变换的速度
% figure,imshow(eye);
x1=mean_circle(1,1);%%瞳孔的精定位
y1=mean_circle(2,1);
Rr=mean_circle(3,1);
figure,imshow(eye1),title('根据瞳孔数据去除中心圆后边缘');
plot_circle(mean_circle);

eye1=histeq(eye1);%图像增强应放在瞳孔定位完成以后，因为图像增强会加大图像的纹理信息
eye1 = medfilt2(eye1,[10 10],'symmetric');
edge_w=edge(eye1,'canny');
for i=1:M
    for j=1:N
    if (x1-i)^2+(y1-j)^2<=50/Rp*Rr^2
        edge_w(i,j)=0;
    end
    end
end
xo=x1;
yo=y1;
count1=1;
count2=1;
for theta=1:30
    for y=yo:-1:1
        x=min(round(tand(-theta)*(y-yo)+xo),M);
    if edge_w(x,y)==1
        dot1(count1,:)=[x,y];
        distance1(count1,:)=sqrt((x-xo)^2+(y-yo)^2);
       count1=count1+1;
    end
    end
end
for theta=1:30
    for y=yo:1:N-4
        x=min(round(tand(theta)*(y-yo)+xo)+1,M);
    if edge_w(x,y)==1
        dot2(count2,:)=[x,y];
        distance2(count2,:)=sqrt((x-xo)^2+(y-yo)^2);
       count2=count2+1;
    end
    end
end
A1=hist(distance1,60);
A2=hist(distance2,60);
R2p1=find(A1==max(A1))+min(distance);
R2p2=find(A2==max(A2))+min(distance);
% mcircle=houghcircle(edge_w,0.5,0.0874,R2p-4,R2p+10,0.7);
% x=mcircle(1,1);%%瞳孔的精定位
% y=mcircle(2,1);
% Rr=mcircle(3,1);
% plot_circle(mcircle);
% figure,imshow(edge_w);
% 
% for i=1:length(dot)
%     text(dot(i,2),dot(i,1),'*','color','r');
% end
end