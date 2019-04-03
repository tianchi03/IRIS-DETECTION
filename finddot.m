xo=xp;
yo=yp;
for theta=1:15
    for y=yo:-1:1
        x=round(tand(-theta)*(y-yo)+xo);
    if edge_w(x,y)==1
        dot(count,:)=[x,y];
        distance(count,:)=sqrt((x-xo)^2+(y-yo)^2);
       count=count+1;
    end
    end
end
for theta=1:15
    for y=yo:1:N
        x=round(tand(theta)*(y-yo)+xo);
    if edge_w(x,y)==1
        dot(count,:)=[x,y];
        distance(count,:)=sqrt((x-xo)^2+(y-yo)^2);
       count=count+1;
    end
    end
end
imshow(edge_w);
for i=1:length(dot)
    text(dot(i,2),dot(i,1),'*','color','r');
end

