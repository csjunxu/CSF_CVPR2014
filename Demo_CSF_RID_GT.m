%--------------------------------------------------------------------------
clear;
%% read  image directory
% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\DJI_Results\Real_MeanImage\';
% GT_fpath = fullfile(GT_Original_image_dir, '*.JPG');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\DJI_Results\Real_NoisyImage\';
% TT_fpath = fullfile(TT_Original_image_dir, '*.JPG');
% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_MeanImage\';
% GT_fpath = fullfile(GT_Original_image_dir, '*.png');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_NoisyImage\';
% TT_fpath = fullfile(TT_Original_image_dir, '*.png');
% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
% GT_fpath = fullfile(GT_Original_image_dir, '*mean.png');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\cc_Results\Real_ccnoise_denoised_part\';
% TT_fpath = fullfile(TT_Original_image_dir, '*real.png');
% GT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\our_Results\Real_MeanImage\';
% GT_fpath = fullfile(GT_Original_image_dir, '*.JPG');
% TT_Original_image_dir = 'C:\Users\csjunxu\Desktop\CVPR2017\our_Results\Real_NoisyImage\';
% TT_fpath = fullfile(TT_Original_image_dir, '*.JPG');
GT_Original_image_dir = 'C:/Users/csjunxu/Desktop/RID_Dataset/RealisticImage/';
GT_fpath = fullfile(GT_Original_image_dir, '*mean.JPG');
TT_Original_image_dir = 'C:/Users/csjunxu/Desktop/RID_Dataset/RealisticImage/';
TT_fpath = fullfile(TT_Original_image_dir, '*real.JPG');

GT_im_dir  = dir(GT_fpath);
TT_im_dir  = dir(TT_fpath);
im_num = length(TT_im_dir);

method           =  'CSF';
%% write image directory
write_MAT_dir = ['C:/Users/csjunxu/Desktop/CVPR2018 Denoising/PolyU_Results/'];
write_sRGB_dir = ['C:/Users/csjunxu/Desktop/CVPR2018 Denoising/PolyU_Results/' method];
if ~isdir(write_sRGB_dir)
    mkdir(write_sRGB_dir)
end

format compact;
modelname = 'csf_7x7';
for nSig     =  [15]
    PSNR = [];
    SSIM = [];
    nPSNR = [];
    nSSIM = [];
    RunTime = [];
    for i = 1 : im_num
        IM =   im2double(imread( fullfile(TT_Original_image_dir,TT_im_dir(i).name) ));
        IM_GT = im2double(imread(fullfile(GT_Original_image_dir, GT_im_dir(i).name)));
        % S = regexp(TT_im_dir(i).name, '\.', 'split');
        IMname = TT_im_dir(i).name(1:end-9);
        [h,w,ch] = size(IM);
        fprintf('%s: \n',TT_im_dir(i).name);
        nPSNR = [nPSNR csnr( IM*255,IM_GT*255, 0, 0 )];
        nSSIM = [nSSIM cal_ssim( IM*255, IM_GT*255, 0, 0 )];
        fprintf('The initial PSNR = %2.4f, SSIM = %2.4f. \n', nPSNR(end), nSSIM(end));
        % color or gray image
        IMout = zeros(size(IM));
        %         randn('seed',0);
        %         noise_img          =   I+ nSig*randn(size(I));
        time0 = clock;
        load(fullfile('models','table1',['sigma',num2str(nSig)],modelname));
        for cc = 1:ch
            %% denoising
            IMoutcc = csf_predict(model,IM(:,:,cc)*255);
            IMout(:,:,cc) = IMoutcc{end};
        end
        RunTime = [RunTime etime(clock,time0)];
        fprintf('Total elapsed time = %f s\n', (etime(clock,time0)) );
        PSNR = [PSNR csnr( IMout, IM_GT*255, 0, 0 )];
        SSIM = [SSIM cal_ssim( IMout, IM_GT*255, 0, 0 )];
        fprintf('The final PSNR = %2.4f, SSIM = %2.4f. \n', PSNR(end), SSIM(end));
        %% output
        imwrite(IMout/255, [write_sRGB_dir '/' method '_our_' IMname '.png']);
    end
    mPSNR = mean(PSNR);
    mSSIM = mean(SSIM);
    mnPSNR = mean(nPSNR);
    mnSSIM = mean(nSSIM);
    mRunTime = mean(RunTime);
    matname = sprintf([write_MAT_dir method '_our.mat']);
    save(matname,'PSNR','SSIM','mPSNR','mSSIM','nPSNR','nSSIM','mnPSNR','mnSSIM','RunTime','mRunTime');
end
