for i=1:59
    ii=num2str(i);
    filename=[ii,'.jpg'];
    A=imread(filename);
    A=imcrop(A);
    imwrite(A,filename);
end