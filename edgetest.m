clc;
clear;
%k:ͼ������ϵ��
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
    ratio=round(1200/K)/10;%����ͼ���С����ͼ��
    eye1=imresize(eye,ratio);
    [M,N]=size(eye1);
k=floor(M/12);
l=floor(N/12);
%����һ����СΪK*L��ע�⣡����ĸl��������1����Ԫ�����飬���ڴ��ÿ�����ڵ����лҶ�ֵ
A=cell(k*l,1);
%����ÿ�����ڵĻҶȾ�ֵ
x=1;
for i=1:k
    y=1;
   for j=1:l       
    A{(i-1)*l+j}=eye1(x:x+M/k-1,y:y+N/l-1);
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
eye_bw=im2bw(eye1,T+6/256);%%��ʼ��ֵ��λ8���Զ�ֵ�����Ӱ�����Ҫ�����ǽ�ë
%step2��%%�ҳ�����������������Ϊͫ������
eye_blur = medfilt2(eye_bw,[7 7],'symmetric');%%��ȥ��ֵ��ͼ���еĵ�״����
eye_blur=1-eye_blur;%��ֵ���任���������ͨ������
% �����ǣ�һ���ʱֻʣ��������һ������Ϊͫ�ײ��֣���һ���ܴ��ڵ�����Ϊ��ë����
[L, num] = bwlabel(eye_blur, 8); 
stats = regionprops(L, 'Basic'); 
Bd = cat(1,stats.BoundingBox);%��struct:stats��BoundingBox���򷽿�������ת��Ϊ����
Ar=cat(1,stats.Area);%��struct:stats��Area�������������ת��Ϊ����
[s1, s2] = size(Bd);
p=zeros(s1,1);
mx=max(Ar);
[j,s]=find(Ar==mx);%%�ҳ�����������������Ϊͫ������
cirp=Bd(j,:);
Rp=round((cirp(1,3)+cirp(1,4))/4);%ͫ��Բ�ġ��뾶�ֶ�λ
xp=round(Rp+cirp(1,2));
yp=round(Rp+cirp(1,1));
%%���ֶ�λ��Բȫ��Ϳ�ף��ָ���ֶ�λ��ͫ������,ͫ�׵Ĵַָ����
%�����˲��������ƣ�������Ե
edge_w=edge(eye1,'canny');
%%��ȥ���İ׵㣬����������
for m=xp-Rp:xp+Rp
    for  n=yp-Rp:yp+Rp
       R2=(m-xp)^2+(n-yp)^2;
       if R2<=Rp^2*0.9
           edge_w(m,n)=0;
       end
    end
end
edge_copy=zeros(M,N);
%edge_copyΪ����ͫ��������ֻ����������ͫ������ı�Ե��Ϣ��Ŀ���Ǽ���������
for x=1:M
    for y=1:N
if (x>xp-Rp-6&&x<xp+Rp+6)&&(y>yp-Rp-6&&y<yp+Rp+6)
    edge_copy(x,y)=edge_w(x,y);
end
    end
end
%���л���任
mean_circle=houghcircle(edge_copy,0.2,0.0872,Rp-3,Rp+3,0.7);%ֻ��ͫ�������Բ���д��������������任���ٶ�
% figure,imshow(eye);
x1=mean_circle(1,1);%%ͫ�׵ľ���λ
y1=mean_circle(2,1);
Rr=mean_circle(3,1);
figure,imshow(eye1),title('����ͫ������ȥ������Բ���Ե');
plot_circle(mean_circle);

eye1=histeq(eye1);%ͼ����ǿӦ����ͫ�׶�λ����Ժ���Ϊͼ����ǿ��Ӵ�ͼ���������Ϣ
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
% x=mcircle(1,1);%%ͫ�׵ľ���λ
% y=mcircle(2,1);
% Rr=mcircle(3,1);
% plot_circle(mcircle);
% figure,imshow(edge_w);
% 
% for i=1:length(dot)
%     text(dot(i,2),dot(i,1),'*','color','r');
% end
end