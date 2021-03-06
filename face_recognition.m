%% FACE RECOGNITION
%Loading of training set database
%the training is made up of 600 images.
%the images will be used for the recognition process.

w=load_database(); %loading database
size (w)
%% writing in xlsx datasheet named on month
fname = sprintf('file_%s.xlsx', datestr(now, 'mmmm'));
 
             dt = datestr(now,'dd');
             dt=str2num(dt);
             %% fixing the coloumn of datasheet
             if dt<26
    sf='A'+dt;
             end
             
              if dt==26
                  sf='AA';
              end
               if dt==27
                  sf='AB';
              end
                   if dt==28
                  sf='AC';
                   end
               if dt==29
                  sf='AD';
               end
               if dt==30
                  sf='AE';
              end
              if dt==31
                  sf='AF';
              end
     f=strcat(sf,num2str(60));
  xlswrite(fname,dt,'Sheet1',f);
 
  


%% initializations
%the initial conditions are initialized.
%the new image input and video configuarion.
%that will be used for recognition is set.

vid = videoinput('winvideo', 1, 'YUY2_160x120'); %initialize video input
triggerconfig (vid, 'manual')                    %configure trigger
vid.FramesPerTrigger = 1;
set (vid,'TriggerFrameDelay',20);                %Set trigger delay
preview(vid);

  %% build serial communication with arduino
  delete(instrfind(('port'),('COM19')));
  arduino=serial('COM19','BaudRate',9600);
%% taking photo

start(vid);
trigger(vid)                                     %Triggering snapshot
set(vid, 'ReturnedColorSpace','grayscale')
rgbImage = getdata(vid);
stop(vid);

fullImageFileName = fullfile(pwd, 'new.pgm');
imwrite(rgbImage,fullImageFileName);
B=imread('new.pgm');

r = imresize(B, [112 92]);                       %Resizing image to 112x92
imwrite(r,'new.pgm');

im =(r);            %r contains the image we use to test the algorithm

tempimg = im(:,:,1);
r = reshape(tempimg, 10304,1);
v=w;                                    %v contains the database

N=50;               %number of signatures used for each image*

%%subtracting the mean from v

O=uint8(ones(1,size(v,2)));
m=uint8(mean(v,2));     %m is the mean of all images

vzm=v-uint8(single(m)*single(O));       %vzm is v with the mean removed

%%calculating eigenvectors of the correlation matrix
% we are picking N of the 600 eigenfaces.

L=single(vzm)'*single(vzm);
[V,D]=eig(L);
V=single(vzm)*V;
V=V(:,end:-1:end-(N-1));        %pick the eigenvalues corresponding to the %10 largest eigenvalues

%%calculating the signature for each image
cv=zeros(size(v,2),N);
for i=1:size(v,2);
cv(i,:)=single(vzm(:,i))'*V;    %each row in cv is the signature for one image
end

%%recognition
%now, we run the algorithm and see if we ca correctly recognize the face.
figure (1)
subplot(121);
imshow(reshape(r,112,92));title('Looking for ...', 'FontWeight','bold','Fontsize',16,'color','red');

subplot(122);
p=r-m;      %subtract the mean
s=single(p)'*V;
z=[];
for i=1:size(v,2)
    z=[z,norm(cv(i,:)-s,2)];
    if(rem(i,20)==1),
       imshow(reshape(v(:,i),112,92)),end;
    drawnow;
end

[a,i]=min(z);
j=1+i/10;
 n=int16(fix(j));
 m=n+60;
%% writing the attendence in the roll sheet according name & roll
 sd=strcat(sf,num2str(m));
           xlswrite(fname,'1','Sheet1',sd);

subplot(122);
imshow(reshape(v(:,i),112,92));title('Found','FontWeight','bold','Fontsize',16,'color','red');
 %% diplaying the roll in dispaly
 fopen(arduino);
 for c=1:3
 fprintf(arduino,'%s',char(m));
pause(1);
 end
 

fclose(arduino);
close all;

closepreview;