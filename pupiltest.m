clc;
clear;
for i=1:50
ii=mat2str(i);
    filename=[ii,'.jpg'];
    eye=imread(filename);
%���ͼ��Ϊ��ɫ���ͣ������Ϊ�Ҷ�ͼ
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
%ͼ���һ��
%step1��%ȡ��С�ҶȾ�ֵ��Ϊ��ֵ���ж�ֵ�任
%��ͼ�񻮷�ΪK*l����СΪ12��12����
k=floor(M/7);
l=floor(N/7);
%����һ����СΪK*L��ע�⣡����ĸl��������1����Ԫ�����飬���ڴ��ÿ�����ڵ����лҶ�ֵ
A=cell(k*l,1);
%����ÿ�����ڵĻҶȾ�ֵ
x=1;
for i=1:k
    y=1;
   for j=1:l       
    A{(i-1)*l+j}=eye1(x:x+floor(M/k-1),y:y+floor(N/l-1));
    y=y+N/l;
    end
    x=x+M/k;
end
%%����һ����СΪK*L��ע�⣡����ĸl��������1����Ԫ�����飬���ڴ��ÿ�����ڵĻҶȾ�ֵ
B=cell(k*l,1);
for i=1:k*l
B{i}=sum(sum(A{i}))/M/N*k*l;
end
B=cell2mat(B);%ת��Ԫ������Ϊ����
T=min(B);%����С�ҶȾ�ֵ��Ϊ��ֵ�任��ֵ
eye_bw=im2bw(eye1,T+8/256);%%��ʼ��ֵ��λ8���Զ�ֵ�����Ӱ�����Ҫ�����ǽ�ë
%step2��%%�ҳ�����������������Ϊͫ������
eye_blur = medfilt2(eye_bw,[7 7],'symmetric');%%��ȥ��ֵ��ͼ���еĵ�״����
eye_blur=1-eye_blur;
figure,imshow(eye_blur);
end