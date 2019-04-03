clear;
clc;

for i=4:4
tic
    ii=mat2str(i);
    filename=[ii,'.jpg'];
    eye=imread(filename);
%���ͼ��Ϊ��ɫ���ͣ������Ϊ�Ҷ�ͼ
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
eye_blur=1-eye_blur;%��ֵ���任���������ͨ������
% �����ǣ�һ���ʱֻʣ��������һ������Ϊͫ�ײ��֣���һ���ܴ��ڵ�����Ϊ��ë����
[L, num] = bwlabel(eye_blur, 4); 
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
edge_pupil=zeros(M,N);
%edge_pupilΪ����ͫ��������ֻ����������ͫ������ı�Ե��Ϣ��Ŀ���Ǽ���������
for x=1:M
    for y=1:N
if (x>xp-Rp-6&&x<xp+Rp+6)&&(y>yp-Rp-6&&y<yp+Rp+6)
    edge_pupil(x,y)=edge_w(x,y);
end
    end
end
%���л���任
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
%ֻ��ͫ�������Բ���д��������������任���ٶ�
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
