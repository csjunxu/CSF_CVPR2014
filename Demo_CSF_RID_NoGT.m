
%--------------------------------------------------------------------------
clc;
clear;

setname          = 'real_image_noise_dataset';
method           =  'CSF';
ref_folder       =  fullfile('C:\Users\csjunxu\Desktop\CVPR2017\crosschannel_CVPR2016\',setname);

den_folder       =  ['Results_',setname,'_',method];
if ~isdir(den_folder)
    mkdir(den_folder)
end

noise_levels     =  [15];
images           =  dir(fullfile(ref_folder,'*.png'));
format compact;

modelname = 'csf_7x7';

for i = 1 : numel(images)
    [~, name, exte]  =  fileparts(images(i).name);
    I =   im2double(imread( fullfile(ref_folder,images(i).name) ));
    [h,w,ch] = size(I);
    % color or gray image
    if ch==1
        IMin_y = I;
    else
        % change color space, work on illuminance only
        IMin_ycbcr = rgb2ycbcr(I);
        IMin_y = IMin_ycbcr(:, :, 1);
        IMin_cb = IMin_ycbcr(:, :, 2);
        IMin_cr = IMin_ycbcr(:, :, 3);
    end
    for j = 1 : numel(noise_levels)
        disp([i,j]);
        nSig               =    noise_levels(j);
        load(fullfile('models','table1',['sigma',num2str(nSig)],modelname));
        %         randn('seed',0);
        %         noise_img          =   I+ nSig*randn(size(I));
        
        IMout_y = csf_predict(model,IMin_y*255);
        %         PSNR_value = csnr(uint8(I),uint8(im{end}),0,0);
        %         PSNR(i,j) = PSNR_value;
    end
    if ch==1
        IMout = IMout_y{end}/255;
    else
        IMout_ycbcr = zeros(size(I));
        IMout_ycbcr(:, :, 1) = IMout_y{end}/255;
        IMout_ycbcr(:, :, 2) = IMin_cb;
        IMout_ycbcr(:, :, 3) = IMin_cr;
        IMout = ycbcr2rgb(IMout_ycbcr);
    end
        imwrite(IMout, ['C:\Users\csjunxu\Desktop\CVPR2017\1_Results\Real_CSF\CSF_Real_' num2str(noise_levels) '_' name '.png']);
    
end

% mean_value = mean(PSNR,1);

% save(['PSNR_',setname,'_',method],'noise_levels','PSNR','mean_value');


