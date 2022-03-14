clear all;
clc;
addpath(genpath('E:/Programs/SPM/spm8/spm8'));
spm_get_defaults;
spm_jobman('initcfg');

%% LOOP
subjects_list = 8; % [2,4,5,11:12,15,18];

for subj = subjects_list

    clear matlabbatch;

    %% Entering values in matlabbatch
    FFX_folder = sprintf('E:\\Data\\VisualNeglect\\iTMS-fMRI\\fMRI_Data\\Subj%d\\NativeSpaceAnalysis\\Retinotopy\\FFX', subj);
    matlabbatch{1, 1}.spm.stats.con.spmmat = {sprintf('%s\\SPM.mat', FFX_folder)};

    load(sprintf('%s\\SPM.mat', FFX_folder));
    for run = 1:length(SPM.Sess)
        columns_sess{run} =  SPM.Sess(run).col; %#ok<SAGROW>
    end

    numberColumns = size(SPM.xX.X, 2);

    clear SPM;

    %% F_contrasts
    mat_AllConditionsHRF = [];

    for run = 1:length(columns_sess)
        mat_run = [];

        for cond = 1:2
            mat_aux = zeros(1, numberColumns);
            mat_aux(columns_sess{run}(cond + 1)) = 1;
            mat_run = [mat_run; mat_aux]; %#ok<AGROW>
        end

        mat_AllConditionsHRF = [mat_AllConditionsHRF; mat_run]; %#ok<AGROW>
        mat_AllConditionsHRF_run{run} = mat_run; %#ok<SAGROW>
    end

    matlabbatch{1, 1}.spm.stats.con.consess{1, 1}.fcon.name = 'F_con';
    matlabbatch{1, 1}.spm.stats.con.consess{1, 1}.fcon.convec{1, 1} = mat_AllConditionsHRF;
    matlabbatch{1, 1}.spm.stats.con.consess{1, 1}.fcon.sessrep = 'none';

    for run = 1:length(columns_sess)
        matlabbatch{1, 1}.spm.stats.con.consess{1, end + 1}.fcon.name = ['F_con Run', num2str(run)];
        matlabbatch{1, 1}.spm.stats.con.consess{1, end}.fcon.convec{1, 1} = mat_AllConditionsHRF_run{run};
        matlabbatch{1, 1}.spm.stats.con.consess{1, end}.fcon.sessrep = 'none';
    end

    matlabbatch{1, 1}.spm.stats.con.delete = 1;

    cd(FFX_folder);
    eval(['save contrast_subj', num2str(subj)]);
    spm_jobman('run', matlabbatch);

end
