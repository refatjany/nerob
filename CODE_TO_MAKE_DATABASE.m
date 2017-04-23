
vid = videoinput('winvideo', 1, 'YUY2_160x120'); %initialize video input
triggerconfig (vid, 'manual')                    %configure trigger
vid.FramesPerTrigger = 1;
set (vid,'TriggerFrameDelay',20);                %Set trigger delay
preview(vid);
for c=2:10
start(vid);
trigger(vid)                                     %Triggering snapshot
set(vid, 'ReturnedColorSpace','grayscale')
rgbImage = getdata(vid);
stop(vid);
fname = sprintf('%d.pgm',c);
fullImageFileName = fullfile(pwd, fname);
imwrite(rgbImage,fullImageFileName);
B=imread(fname);
r = imresize(B, [112 92]);
imwrite(r,fname);
h=image(B);
imsave(h); 
end
