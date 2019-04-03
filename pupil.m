clear;
clc;

for i=4:4
tic
    ii=mat2str(i);
    filename=[ii,'.jpg'];
    eye=imread(filename);
%如果图像为彩色类型，将其改为灰度图
if ndims(eye)==3
eye=rgb2gray(eye);
end
[M1,N1]=size(eye);
if M1>=500
    eye=imresize(eye,0.2);
    eye1=imresize(eye,0.5);
else  
    eye1=imresize(eye,0.4);    
 end

eye1=double(eye1)/256;
[M,N]=size(eye1);
%图像归一化
%step1：%取最小灰度均值作为阈值进行二值变换
%将图像划分为K*l个大小为12×12窗口
k=floor(M/7);
l=floor(N/7);
%构建一个大小为K*L（注意！是字母l不是数字1）的元胞数组，用于存放每个窗口的所有灰度值
A=cell(k*l,1);
%计算每个窗口的灰度均值
x=1;
for i=1:k
    y=1;
   for j=1:l       
    A{(i-1)*l+j}=eye1(x:x+floor(M/k-1),y:y+floor(N/l-1));
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
eye_bw=im2bw(eye1,T+8/256);%%初始增值定位8，对二值化结果影响的主要因素是睫毛
%step2：%%找出最大面积的区域设置为瞳孔区域
eye_blur = medfilt2(eye_bw,[7 7],'symmetric');%%除去二值化图像中的点状噪声
eye_blur=1-eye_blur;%二值反变换方面后续连通区域标记
% 区域标记，一般此时只剩两个区域，一个区域为瞳孔部分，另一可能存在的区域为睫毛部分
[L, num] = bwlabel(eye_blur, 4); 
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
edge_pupil=zeros(M,N);
%edge_pupil为最终瞳孔轮廓，只保留了中心瞳孔区域的边缘信息，目的是减少运算量
for x=1:M
    for y=1:N
if (x>xp-Rp-6&&x<xp+Rp+6)&&(y>yp-Rp-6&&y<yp+Rp+6)
    edge_pupil(x,y)=edge_w(x,y);
end
    end
end
%进行霍夫变换
eye1=histeq(eye1,8);
edge_iris=edge(eye1,'canny',0.4);
for x=1:M
    for y=1:N
if (x>xp-Rp-6&&x<xp+Rp+6)&&(y>yp-Rp-6&&y<yp+Rp+6)
    edge_iris(x,y)=0;
end
    end
end
mean_circle=houghcircle(edge_pupil,0.2,0.0872,Rp,Rp+5,0.7);
% figure,imshow(eye1);
%只对瞳孔区域的圆进行处理，大大提升霍夫变换的速度
bw=edge_iris;
% r_min=mean_circle(3,1);
r_min=35;
r_max=N;
x0=mean_circle(2,1);
y0=mean_circle(1,1);
step_r=1;
p=3;
size_r=round((r_max-r_min)/step_r);
houghspace=zeros(p*2+1,p*2+1,size_r);
[rows,cols]=find(bw);
count=size(rows);
for i=1:(p*2+1)
    for j=1:(p*2+1)
        for r=1:size_r
            for k=1:count
                diff=(cols(k)-x0+p+1-i)^2+(rows(k)-y0+p+1-j)^2-(r_min+step_r*r)^2;
                if abs(diff)<10
                    houghspace(i,j,r)=houghspace(i,j,r)+1;
                end
            end
        end
    end
end
dot_max=max(max(max(houghspace)));
j=1;
for i=1:size_r
    for m=1:p*2+1
        for n=1:p*2+1
    if houghspace(m,n,i)==dot_max
   centro(j,1)=m;
   centro(j,2)=n;
   centro(j,3)=i;
    j=j+1;
    end
        end
    end
end

 iris_y=mean(centro(:,2))+y0-p-1;
 iris_x=mean(centro(:,1))+x0-p-1;
 iris_r=mean(centro(:,3))*step_r+r_min+1;
 iris=[floor(iris_y);floor(iris_x);floor(iris_r)];
iris=houghiris(edge_iris,1,0.0872,iris_r-1,iris_r+5,0.7,iris_y,iris_x);
 figure,imshow(eye1);
 plot_circle(iris);
 text(floor(iris_x),floor(iris_y),'*','Color','w');
 plot_circle(mean_circle);
 text(mean_circle(2),mean_circle(1),'*','Color','r');
 toc
end
