subjects_list = 6; % [2,3,4,5,6,8,11:12,14,15,17,18];

for subj = subjects_list

    FFX_folder = sprintf('E:\\Data\\VisualNeglect\\iTMS-fMRI\\fMRI_Data\\Subj%d\\NativeSpaceAnalysis\\Retinotopy\\FFX_Test', subj);
    RETINO_folder = sprintf('%s\\RetinotopyAnalysis', FFX_folder);

    if ~exist(RETINO_folder)  %#ok<EXIST>
        mkdir(RETINO_folder);
    end

    clear SPM;
    load(sprintf('%s\\SPM.mat', FFX_folder));

    no_of_runs = length(SPM.Sess);
    sine_columns = [];
    cosine_columns = [];

    for run = 1:no_of_runs
        columns_sess{run} =  SPM.Sess(run).col; %#ok<SAGROW>
        sine_columns = [sine_columns columns_sess{run}(2)]; %#ok<AGROW>
        cosine_columns = [cosine_columns columns_sess{run}(3)]; %#ok<AGROW>
    end

    BETA_images = cell(no_of_runs, 2);
    %     Fcon_images = cell(no_of_runs,1);

    for run = 1:no_of_runs
        BETA_images{run, 1} = sprintf('%s\\beta_%04d.img', FFX_folder, sine_columns(run));
        BETA_images{run, 2} = sprintf('%s\\beta_%04d.img', FFX_folder, cosine_columns(run));

        %         Fcon_images{run} = sprintf('%s\\spmF_000%d.img', FFX_folder, run+1);
    end

    %     ResMs_image = sprintf('%s\\ResMS.img', FFX_folder); %image of the variance of the error

    %% reading headers for images of interest
    Sine_hdr = spm_vol(str2mat(BETA_images{:, 1})); %#ok<FPARK>
    Cosine_hdr = spm_vol(str2mat(BETA_images{:, 2})); %#ok<FPARK>
    %     ResMS_hdr = spm_vol(ResMs_image);
    %     Fcon_hdr = spm_vol(str2mat(Fcon_images)); %#ok<FPARK>

    %% read volumes of the respective headers
    Sine_vols = spm_read_vols(Sine_hdr);
    Cosine_vols = spm_read_vols(Cosine_hdr);
    %     ResMS_vols = spm_read_vols(ResMS_hdr);
    %     Fcon_vols = spm_read_vols(Fcon_hdr);

    %% average beta images for of sine/cosine regressors
    % (note: clock/anticlockwise directions have been accounted for in the
    % FFX model so no need to care about them here)
    mean_SineBetas = mean(Sine_vols, 4);
    mean_CosineBetas = mean(Cosine_vols, 4);

    %% compute phase and amplitude
    Y_phase = mod(atan2(mean_SineBetas, mean_CosineBetas) * 180 / pi, 360);
    Y_ampl = sqrt(mean_SineBetas.^2 + mean_CosineBetas.^2);

    %% write phase and amplitude volume

    % taking header information from one of the images above
    newImgInfo = Sine_hdr(1);

    % writing image for mean beta for sine regressor
    meanSineBetas_hdr = newImgInfo;
    meanSineBetas_hdr.fname = sprintf('%s\\Test_PolarRetino_subj%d_meanSineBetas.img', RETINO_folder, subj);
    meanSineBetas_hdr.private.dat.fname = meanSineBetas_hdr.fname;
    spm_write_vol(meanSineBetas_hdr, mean_SineBetas);

    % writing image for mean beta for sine regressor
    meanCosineBetas_hdr = newImgInfo;
    meanCosineBetas_hdr.fname = sprintf('%s\\Test_PolarRetino_subj%d_meanCosineBetas.img', RETINO_folder, subj);
    meanCosineBetas_hdr.private.dat.fname = meanCosineBetas_hdr.fname;
    spm_write_vol(meanCosineBetas_hdr, mean_CosineBetas);

    % writing image for phase
    %     phase_hdr = newImgInfo;
    %     phase_hdr.fname = sprintf('%s\\PolarRetino_subj%d_phase.img', RETINO_folder, subj);
    %     phase_hdr.private.dat.fname = phase_hdr.fname;
    %     spm_write_vol(phase_hdr, Y_phase);
    %
    %     % writing image for amplitude
    %     amplitude_hdr = newImgInfo;
    %     amplitude_hdr.fname = sprintf('%s\\PolarRetino_subj%d_amplitude.img', RETINO_folder, subj);
    %     amplitude_hdr.private.dat.fname = amplitude_hdr.fname;
    %     spm_write_vol(amplitude_hdr, Y_ampl);

end
