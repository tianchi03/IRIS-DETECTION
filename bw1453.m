 
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

 
 
zmax=max(max(g));%ȡ�����Ҷ�ֵ 
zmin=min(min(g));%ȡ����С�Ҷ�ֵ 
tk=(zmax+zmin)/2;%���ʼ��ֵ 
bcal=1; 
gsize=size(g);%ͼ���С 
% g=guidedfilter(g,g,3,0.1);
%  imshow(g)
 
while(bcal) 
    %����ǰ���ͱ��������� 
    iforeground=0; 
    ibackground=0; 
    %����ǰ���ͱ����ĻҶ��ܺ� 
    foreground=0; 
    background=0; 
    for i=1:gsize(1) 
        for j=1:gsize(2) 
            tmp=g(i,j); 
            if(tmp>=tk) 
                %ǰ���Ҷ�ֵ 
                iforeground=iforeground+1; 
                foreground=foreground+double(tmp); 
            else 
                %�����Ҷ�ֵ 
                ibackground=ibackground+1; 
                background=background+double(tmp); 
            end 
        end 
    end 
    zo=foreground/iforeground; 
    zb=background/ibackground; 
    %����ǰ���ͱ�����ƽ��ֵ 
    tktmp=uint8((zo+zb)/2); 
    %����ֵ���ٱ仯ʱ��˵���������� 
    if(tktmp==tk) 
        bcal=0; 
    else 
        tk=tktmp; 
    end 
end 
%disp(strcat('������ķ�ֵ',num2str(tk))); 
disp(strcat('������ķ�ֵ',double(tk))); 
newg=im2bw(g,double(tk)/255); 
figure(2),imshow(g); 
figure(3),imshow(newg); 
imwrite(newg,'99.jpg');