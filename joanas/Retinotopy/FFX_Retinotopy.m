addpath(genpath('E:/Programs/SPM/spm8/spm8'));

spm_get_defaults;
spm_jobman('initcfg');

subjects_list = 8;
no_of_runs = 6;
total_scans = 156;
scans_to_drop = 3;
no_of_scans = total_scans - scans_to_drop;
TR = 2.48;

cond_names_total = {'Sine', 'Cosine'};

onset_vec = 0:TR:(no_of_scans - 1) * TR;
regressor{1} = sin(2 * pi * 1 / (17 * TR) .* onset_vec);
regressor{2} = cos(2 * pi * 1 / (17 * TR) .* onset_vec);

for subj = subjects_list

    clear matlabbatch;

    RESPONSE_folder = sprintf('E:\\Data\\VisualNeglect\\iTMS-fMRI\\fMRI_Data\\Subj%d\\ResponseData\\Day1', subj);
    list = dir([RESPONSE_folder '/Re*']);

    if strcmp(list(end).name(end - 6), '+')
        order = [1 2 1 2 1 2]; % - + - + - +
    else
        order = [2 1 2 1 2 1];
    end

    %% Scans
    for run = 1:no_of_runs

        BASIS_folder = sprintf('E:\\Data\\VisualNeglect\\iTMS-fMRI\\fMRI_Data\\Subj%d\\NativeSpaceAnalysis\\Retinotopy', subj);
        SCANS_folder = sprintf('%s\\Run%d', BASIS_folder, run);
        cd(SCANS_folder);

        scans_dir = dir('su*.img');

        for vol = 1:no_of_scans
            scans{run, vol} = [SCANS_folder, '\', scans_dir(vol).name]; %#ok<SAGROW>
        end

        mov_parameter_dir = dir('without3Last_rp*.txt');
        mov_parameter{run} = [SCANS_folder, '\', mov_parameter_dir.name]; %#ok<SAGROW>

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% FMRI_SPEC
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    FFX_folder = sprintf('E:\\Data\\VisualNeglect\\iTMS-fMRI\\fMRI_Data\\Subj%d\\NativeSpaceAnalysis\\Retinotopy\\FFX', subj);
    if ~exist(FFX_folder)  %#ok<EXIST>
        mkdir(FFX_folder);
    end

    matlabbatch{1, 1}.spm.stats.fmri_spec.dir{1, 1} = FFX_folder;
    matlabbatch{1, 1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1, 1}.spm.stats.fmri_spec.timing.RT = TR;
    matlabbatch{1, 1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1, 1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;

    for run = 1:no_of_runs

        for vol = 1:no_of_scans
            matlabbatch{1, 1}.spm.stats.fmri_spec.sess(1, run).scans{vol, 1} = scans{run, vol};
        end

        matlabbatch{1, 1}.spm.stats.fmri_spec.sess(1, run).cond.name = 'Onsets';
        matlabbatch{1, 1}.spm.stats.fmri_spec.sess(1, run).cond.onset = onset_vec;
        matlabbatch{1, 1}.spm.stats.fmri_spec.sess(1, run).cond.duration = zeros(no_of_scans, 1);
        matlabbatch{1, 1}.spm.stats.fmri_spec.sess(1, run).cond.tmod = 0;

        for parametric_mod = 1:length(cond_names_total)

            matlabbatch{1, 1}.spm.stats.fmri_spec.sess(1, run).cond.pmod(parametric_mod).name = cond_names_total{parametric_mod};

            if parametric_mod == 1
                if order(run) == 2 % + (clockwise)
                    matlabbatch{1, 1}.spm.stats.fmri_spec.sess(1, run).cond.pmod(parametric_mod).param = -regressor{parametric_mod}';
                else
                    matlabbatch{1, 1}.spm.stats.fmri_spec.sess(1, run).cond.pmod(parametric_mod).param = regressor{parametric_mod}';
                end
            else
                matlabbatch{1, 1}.spm.stats.fmri_spec.sess(1, run).cond.pmod(parametric_mod).param = regressor{parametric_mod}';
            end

            matlabbatch{1, 1}.spm.stats.fmri_spec.sess(1, run).cond.pmod(parametric_mod).poly = 1;
        end

        matlabbatch{1, 1}.spm.stats.fmri_spec.sess(1, run).multi{1} = '';
        matlabbatch{1, 1}.spm.stats.fmri_spec.sess(1, run).multi_reg{1} = mov_parameter{run};
        matlabbatch{1, 1}.spm.stats.fmri_spec.sess(1, run).hpf = 128;

    end

    matlabbatch{1, 1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1, 1}.spm.stats.fmri_spec.bases.hrf.derivs = [0, 0];
    matlabbatch{1, 1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1, 1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1, 1}.spm.stats.fmri_spec.mask = {};
    matlabbatch{1, 1}.spm.stats.fmri_spec.cvi = 'AR(1)';

    %% FMRI_EST
    matlabbatch{1, end + 1} = {}; %#ok<SAGROW>
    matlabbatch{1, end}.spm.stats.fmri_est.spmmat{1, 1} = [FFX_folder, '\SPM.mat'];     % set the spm file to be estimated
    matlabbatch{1, end}.spm.stats.fmri_est.method.Classical = 1;

    cd(FFX_folder);
    save(['design', num2str(subj)], 'matlabbatch');
    spm_jobman('run', matlabbatch);

end
