%--------------------------------------------------------------------------
clear;

Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2018 Denoising\dnd_2017\images_srgb\';
fpath = fullfile(Original_image_dir, '*.mat');
im_dir  = dir(fpath);
im_num = length(im_dir);
load 'C:\Users\csjunxu\Desktop\CVPR2018 Denoising\dnd_2017\info.mat';

method = 'CSF';
% write image directory
write_MAT_dir = ['C:/Users/csjunxu/Desktop/CVPR2018 Denoising/dnd_2017Results/'];
write_sRGB_dir = [write_MAT_dir method];
if ~isdir(write_sRGB_dir)
    mkdir(write_sRGB_dir)
end

format compact;
modelname = 'csf_7x7';
nSig = 15;
PSNR = [];
SSIM = [];
nPSNR = [];
nSSIM = [];
RunTime = [];
for i = 1 %1:im_num
    Par.image = i;
    load(fullfile(Original_image_dir, im_dir(i).name));
    S = regexp(im_dir(i).name, '\.', 'split');
    [h,w,ch] = size(InoisySRGB);
    for j = 2 % 1:size(info(1).boundingboxes,1)
        IMname = [S{1} '_' num2str(j)];
        fprintf('%s: \n', IMname);
%         bb = info(i).boundingboxes(j,:);
%         IM = InoisySRGB(bb(1):bb(3), bb(2):bb(4),:);
        IM = double(imread([Original_image_dir '/' IMname '.png']));
        IM_GT = IM;
        % noise estimation
        IMout = zeros(size(IM));
        time0 = clock;
        load(fullfile('models','table1',['sigma',num2str(nSig)],modelname));
        for cc = 1:ch
            %% denoising
            IMoutcc = csf_predict(model,IM(:,:,cc));
            IMout(:,:,cc) = IMoutcc{end};
        end
        RunTime = [RunTime etime(clock,time0)];
        fprintf('Total elapsed time = %f s\n', (etime(clock,time0)) );
        %% output
        imwrite(IMout/255, [write_sRGB_dir '/' method '_our_' IMname '.png']);
    end
end
