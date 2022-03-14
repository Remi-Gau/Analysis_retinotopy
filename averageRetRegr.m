function [] = averageRetRegr(subject, baseDir)
    %
    % -- average the sin/cos regr of different runs---

    firstLevAna = {'RetPolar_s3_spCorr', 'RetEccen_s3_spCorr'};

    for iSubj = 5:size(subject, 1)

        for iAna = 1:length(firstLevAna)
            retMapFolder = [baseDir, ...
                            subject(iSubj).folder, ...
                            '\fMRI\scans\1stLevel\' firstLevAna{iAna} '\averagedTrigRegr\'];
            if ~exist(retMapFolder)
                mkdir(retMapFolder);
            end
            % bpath dim1 = run, dim2 = sin/cos regr.
            firstLevFolder = [baseDir, ...
                              subject(iSubj).folder, ...
                              '\fMRI\scans\1stLevel\', firstLevAna{iAna}, '\'];
            clear SPM directions;
            load([firstLevFolder, 'SPM.mat'], 'SPM');
            % get names of regressors in 1st lev model of subj
            regrNames = [];
            for iRegr = 1:length(SPM.Vbeta)
                str = SPM.Vbeta(1, iRegr).descrip(29:end);
                blankInd = isspace(str);
                str(blankInd) = [];
                regrNames{iRegr} = str;
            end
            noRuns = length(find(strcmp('constant', regrNames)));
            bPath = cell(noRuns, 2);
            trigRegrName = {'sine', 'cosine'};
            for iTrig = 1:2  % 2 trigonometric fcts

                if strcmp(firstLevAna{iAna}, 'RetPolar_s3_spCorr')
                    str_direc1 = ['OnsetsVolxPolar_+_'  trigRegrName{iTrig} '^1*bf(1)'];
                    str_direc2 = ['OnsetsVolxPolar_-_'  trigRegrName{iTrig} '^1*bf(1)'];
                elseif strcmp(firstLevAna{iAna}, 'RetEccen_s3_spCorr')
                    str_direc1 = ['OnsetsVolxEcc_+_'  trigRegrName{iTrig} '^1*bf(1)'];
                    str_direc2 = ['OnsetsVolxEcc_-_'  trigRegrName{iTrig} '^1*bf(1)'];
                end
                betaNo1 = find(strcmp(str_direc1, regrNames));
                betaNo2 = find(strcmp(str_direc2, regrNames));
                betaNo = [betaNo1'; betaNo2'];
                noRuns = length(betaNo);
                % 1 = clockwise/expanding; 2 = counterclockwise/contracting
                directions = [ones(length(betaNo1), 1); ones(length(betaNo2), 1) * 2];
                [betaNo, sortInd] = sort(betaNo);
                directions = directions(sortInd);

                % selecting runs for power ana
                %              noSelecRuns = 1;
                %              betaNo = betaNo(1:noSelecRuns);
                %              directions = directions(1:noSelecRuns,:);

                if isempty(betaNo1) || isempty(betaNo2)
                    error(['Could not find regressors of all runs in first level spm: ', ...
                           'S' num2str(iSubj) ' Sess' num2str(iSession) 'Run' num2str(iRun)]);
                end
                for iRun = 1:noRuns
                    bPath{iRun, iTrig} = [firstLevFolder, ...
                                          'beta_', ...
                                          num2str(betaNo(iRun), '%04d'), ...
                                          '.img'];
                end
            end
            noD1Runs = sum(directions(:, 1) == 1);
            indD1Runs = find(directions(:, 1) == 1);
            noD2Runs = sum(directions(:, 1) == 2);
            indD2Runs = find(directions(:, 1) == 2);

            F_eoi_path = [];
            for iRun = 1:noRuns
                F_eoi_path = str2mat(F_eoi_path, [firstLevFolder 'spmF_000' num2str(iRun) '.img']);
            end
            F_eoi_path(1, :) = [];

            % --- read beta vols & and residual mean squared error -----
            bPath_d1_sin = str2mat(bPath{directions == 1, 1});
            bPath_d2_sin = str2mat(bPath{directions == 2, 1});
            bPath_d1_cos = str2mat(bPath{directions == 1, 2});
            bPath_d2_cos = str2mat(bPath{directions == 2, 2});
            path_rems = [firstLevFolder, 'ResMS.img'];

            V_d1_sin = spm_vol(bPath_d1_sin);
            dims = V_d1_sin.dim;
            V_d2_sin = spm_vol(bPath_d2_sin);
            V_d1_cos = spm_vol(bPath_d1_cos);
            V_d2_cos = spm_vol(bPath_d2_cos);
            V_rems = spm_vol(path_rems);
            V_F_eoi = spm_vol(F_eoi_path);

            % ---- load cos and sin parts for each direction
            [Y_d1_sin, XYZ_d1_sin] = spm_read_vols(V_d1_sin);
            [Y_d2_sin, XYZ_d2_sin] = spm_read_vols(V_d2_sin);
            [Y_d1_cos, XYZ_d1_cos] = spm_read_vols(V_d1_cos);
            [Y_d2_cos, XYZ_d2_cos] = spm_read_vols(V_d2_cos);
            Y_rems = spm_read_vols(V_rems);
            Y_F_eoi = spm_read_vols(V_F_eoi);

            % concatenate cos/sin betas from different runs, imag part of counterclockwise has *-1
            % (cf. Sam Schwarzkopfs http://www.fil.ion.ucl.ac.uk/~sschwarz/retinotopy_analysis.html)
            Y_sinRuns = zeros([size(Y_d1_sin(:, :, :, 1)), noD1Runs + noD2Runs]);
            Y_cosRuns = Y_sinRuns;
            Y_sinRuns(:, :, :, indD1Runs) = Y_d1_sin;
            Y_sinRuns(:, :, :, indD2Runs) = -Y_d2_sin;
            Y_cosRuns(:, :, :, indD1Runs) = Y_d1_cos;
            Y_cosRuns(:, :, :, indD2Runs) = Y_d2_cos;

            % --- average real (cos) and img (sin) part from different directions
            % average with equal weighting
            Y_sin = mean(Y_sinRuns, 4);
            Y_cos = mean(Y_cosRuns, 4);
            % average with optimal weights proportional to F_eoi^2 ~ SNR^2, (only optimal for SNR > 2) see
            % Warnking 2002 & Swisher 2007
            Y_F_eoi(Y_F_eoi < 2) = NaN;
            Y_sin_optWeigh = sum(Y_sinRuns .* (Y_F_eoi.^2), 4) ./ sum(Y_F_eoi.^2, 4);
            Y_cos_optWeigh = sum(Y_cosRuns .* (Y_F_eoi.^2), 4) ./ sum(Y_F_eoi.^2, 4);
            Y_sin_optWeigh(isnan(Y_sin_optWeigh)) = 0;
            Y_cos_optWeigh(isnan(Y_cos_optWeigh)) = 0;

            % --- compute phase & amplitude & F ration
            % if wedge starts at 3o'clock = phase = 0 / ring starts at fixation
            % = phase = 0
            Y_phase = mod(atan2(Y_sin, Y_cos) * 180 / pi, 360);
            % normFact = 1/((360+exp(1))*log(360+exp(1))- (360+exp(1))) ;
            % foV = 39;
            % Y_ecc = ((Y_phase+exp(1)) .* log(Y_phase+exp(1)) - (Y_phase+exp(1))) *funcFact * foV;

            if strcmp(firstLevAna{iAna}(1:8), 'RetPolar')
                % to express phase as phase of a cosine wave (cf. Schwarzkopf)
                Y_sin = -Y_sin;
            elseif strcmp(firstLevAna{iAna}(1:8), 'RetEcc')
                % Ecc mustnt -1 to match color wheel!
                Y_sin = Y_sin;
            end
            Y_ampl = abs(Y_cos + i * Y_sin);
            Y_SNR = Y_ampl ./ Y_rems; % correct? search for references!
            Y_complex = Y_cos + i * Y_sin;

            % --- write phase and amplitude volume
            V_d1_sin(1).fname = [retMapFolder, ...
                                 'Su' num2str(iSubj) '_', ...
                                 firstLevAna{iAna}(1:8), '_sin_imag.img'];
            spm_write_vol(V_d1_sin(1), Y_sin);
            V_d1_sin(1).fname = [retMapFolder, ...
                                 'Su' num2str(iSubj) '_', ...
                                 firstLevAna{iAna}(1:8), '_cos_real.img'];
            spm_write_vol(V_d1_sin(1), Y_cos);
            V_d1_sin(1).fname = [retMapFolder, ...
                                 'Su' num2str(iSubj) '_', ...
                                 firstLevAna{iAna}(1:8), '_sin_imag_optWeight.img'];
            spm_write_vol(V_d1_sin(1), Y_sin_optWeigh);
            V_d1_sin(1).fname = [retMapFolder, ...
                                 'Su' num2str(iSubj) '_', ...
                                 firstLevAna{iAna}(1:8), '_cos_real_optWeight.img'];
            spm_write_vol(V_d1_sin(1), Y_cos_optWeigh);
            V_d1_sin(1).fname = [retMapFolder, ...
                                 'Su' num2str(iSubj) '_', ...
                                 firstLevAna{iAna}(1:8), '_phase.img'];
            spm_write_vol(V_d1_sin(1), Y_phase);
            V_d1_sin(1).fname = [retMapFolder, ...
                                 'Su' num2str(iSubj) '_', ...
                                 firstLevAna{iAna}(1:8), '_ampl.img'];
            spm_write_vol(V_d1_sin(1), Y_ampl);
            V_d1_sin(1).fname = [retMapFolder, ...
                                 'Su' num2str(iSubj) '_', ...
                                 firstLevAna{iAna}(1:8), '_SNR.img'];
            spm_write_vol(V_d1_sin(1), Y_SNR);
            V_d1_sin(1).fname = [retMapFolder, ...
                                 'Su' num2str(iSubj) '_', ...
                                 firstLevAna{iAna}(1:8), '_complex.img'];
            spm_write_vol(V_d1_sin(1), Y_complex);

        end

    end
