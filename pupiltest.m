clc;
clear;
for i=1:50
ii=mat2str(i);
    filename=[ii,'.jpg'];
    eye=imread(filename);
%如果图像为彩色类型，将其改为灰度图
if ndims(eye)==3
eye=rgb2gray(eye);
end
[M1,N1]=size(eye);
if M1>=500
    eye=imresize(eye,0.8);
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
eye_blur=1-eye_blur;
figure,imshow(eye_blur);
end