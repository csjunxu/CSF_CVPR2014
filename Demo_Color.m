%--------------------------------------------------------------------------
clear;
Original_image_dir  =    'C:\Users\csjunxu\Desktop\JunXu\Datasets\kodak24\kodak_color\';
fpath = fullfile(Original_image_dir, '*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);

method           =  'CSF';
%% write image directory

write_sRGB_dir = ['C:\Users\csjunxu\Desktop\ICCV2017\24images\'];
if ~isdir(write_sRGB_dir)
    mkdir(write_sRGB_dir)
end
nSig = [40 20 30];
format compact;
modelname = 'csf_7x7';
for EnSig  =  [15]
    PSNR = [];
    SSIM = [];
    CCPSNR = [];
    CCSSIM = [];
    for i = 1 : im_num
        IM_GT = double(imread(fullfile(Original_image_dir, im_dir(i).name)));
        S = regexp(im_dir(i).name, '\.', 'split');
        IMname = S{1};
        [h, w, ch] = size(IM_GT);
        IM = zeros(size(IM_GT));
        for c = 1:ch
            randn('seed',0);
            IM(:, :, c) = IM_GT(:, :, c) + nSig(c) * randn(size(IM_GT(:, :, c)));
        end
        fprintf('%s: \n', im_dir(i).name);
        fprintf('The initial PSNR = %2.4f, SSIM = %2.4f. \n', csnr( IM,IM_GT, 0, 0 ), cal_ssim( IM, IM_GT, 0, 0 ));
        % color or gray image
        IMout = zeros(size(IM));
        load(fullfile('models','table1',['sigma',num2str(EnSig)],modelname));
        for c = 1:ch
            %% denoising
            IMoutcc = csf_predict(model, IM(:,:,c));
            IMout(:,:,c) = IMoutcc{end};
        end
        PSNR = [PSNR csnr( IMout, IM_GT, 0, 0 )];
        SSIM = [SSIM cal_ssim( IMout, IM_GT, 0, 0 )];
        fprintf('The final PSNR = %2.4f, SSIM = %2.4f. \n', PSNR(end), SSIM(end));
        %% output
        imwrite(IMout/255, [write_sRGB_dir method '_nSig' num2str(nSig(1)) num2str(nSig(2)) num2str(nSig(3)) '_' IMname '.png']);
    end
    mPSNR = mean(PSNR);
    mSSIM = mean(SSIM);
    mCCPSNR = mean(CCPSNR);
    mCCSSIM = mean(CCSSIM);
    save(['C:/Users/csjunxu/Documents/GitHub/Weighted/OtherMethods/', method, '_nSig' num2str(nSig(1)) num2str(nSig(2)) num2str(nSig(3)) '_' num2str(EnSig) '.mat'],'nSig','PSNR','mPSNR','SSIM','mSSIM');
end