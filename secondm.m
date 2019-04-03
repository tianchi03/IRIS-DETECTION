
%������˹��ͨ�˲���
clear; close all
fp=3400;
fs=4000;
Rp=3;
As=40;
[N,fc]=buttord(fp,fs,Rp,As,'s')
[B,A]=butter(N,fc,'s');
[hf,f]=freqs(B,A,1024);
figure,
plot(f,20*log10(abs(hf)/abs(hf(1))))
grid on;
xlabel('f/Hz');
ylabel('����(dB)')
axis([0 4000 -40 5])
line([0,4000],[3,-3]);
line([3400,3400],[-90,5]);
%�����˲���

b=1000;
a=[1,1000];
w=[0:1000*2*pi];
[hf,w]=freqs(b,a,w);
figure,
subplot(231)
plot(w/2/pi,abs(hf));
grid on;
title('(a)|Ha(jf)|')
xlabel('f(Hz)');
ylabel('����');
title('(a)ģ���˲���Ƶ������');
Fs0=[1000,500];
for m=1:2
    Fs=Fs0(m)
    [d,c]=impinvar(b,a,Fs)
    [f,e]=bilinear(b,a,Fs)
    wd=[0:512]*pi/512;
    hw1=freqz(b,c,wd);
    hw2=freqz(f,e,wd);
    subplot(232);
    plot(wd/pi,abs(hw1)/abs(hw1(1)));
    title('������Ӧ���䷨')
    hold on;
    subplot(233);
    plot(wd/pi,abs(hw2)/abs(hw2(1)));
    title('˫���Ͳ��䷨')
    hold on;
end



%������
n=50;
window=boxcar(n);
[h,w]=freqz(window,1);
figure,
subplot(411)
stem(window);
grid on;
title('���δ�');
xlabel('n');
ylabel('h(n)');
subplot(413);
plot(w/pi,20*log(abs(h)/abs(h(1))));
grid on;
title('Ƶ������');
xlabel('w/pi');
ylabel('����(dB)')
%�����˲���

N=21;
wc=pi/4;
n=0:N-1;
r=(N-1)/2;
hdn=sin(wc*(n-r))/pi./(n-r);
if rem(N,2)~=0
    hdn(r+1)=wc/pi;
end
wn1=boxcar(N);
hn1=hdn.*wn1';
wn2=hamming(N);
hn2=hdn.*wn2';
figure,
subplot(221);
stem(n,hn1,'.');
grid on;
title('���δ���Ƶ�h(n)');
xlabel('n');
ylabel('h(n)');
hw1=fft(hn1,512);
w1=2*[0:511]/512;
subplot(222);
plot(w1,20*log10(abs(hw1)));
grid on;
title('��������(dB)');
xlabel('w/pi');
ylabel('Manitide(dB)');
subplot(223);
stem(n,hn2,'.');
grid on;
title('hamming����Ƶ�h(n)');
xlabel('n');
ylabel('h(n)');
hw2=fft(hn2,512);
w2=2*[0:511]/512;
subplot(224);
plot(w2,20*log10(abs(hw2)));
grid on;
title('��������(dB)');
xlabel('w/pi');
ylabel('Manitide(dB)')