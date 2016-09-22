
%--------------------------------------------------------------------------
clc;
clear;

setname          = 'Set20';
method           =  'CSF';
ref_folder       =  fullfile('D:\matlab1\DL_code\demo_denoising_v1.0_simplenn\data\Test',setname);

den_folder       =  ['Results_',setname,'_',method];
if ~isdir(den_folder)
    mkdir(den_folder)
end

noise_levels     =  [25];
images           =  dir(fullfile(ref_folder,'*.png'));
format compact;

modelname = 'csf_7x7'; 

for i = 1 : numel(images)
    [~, name, exte]  =  fileparts(images(i).name);
    I =   double(imread( fullfile(ref_folder,images(i).name) ));
    for j = 1 : numel(noise_levels)
        disp([i,j]);
        nSig               =    noise_levels(j);
        load(fullfile('models','table1',['sigma',num2str(nSig)],modelname));
        randn('seed',0);
        noise_img          =   I+ nSig*randn(size(I));
        
        im = csf_predict(model,noise_img);
        PSNR_value = csnr(uint8(I),uint8(im{end}),0,0);
        imwrite(im{end}/255, fullfile(den_folder, [name, '_sigma=' num2str(nSig,'%02d'),'_',method,'_PSNR=',num2str(PSNR_value,'%2.2f'), exte] ));
        PSNR(i,j) = PSNR_value;
    end
end

mean_value = mean(PSNR,1);

save(['PSNR_',setname,'_',method],'noise_levels','PSNR','mean_value');


