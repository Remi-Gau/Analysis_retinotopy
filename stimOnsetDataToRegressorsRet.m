function [pathRegrFiles] = stimOnsetDataToRegressorsRet(pathData, pathRegr, iSess, runNo, typeRet, typeGLM)
    % computes regressors for retinotopy and wedge left vs. right comparison
    % pathData = exat path to data retinotopy
    % pathRegr = folder were to store file with names, onsets, durations for each run
    % runNo = runs in which retinitopy was done
    % typeRet = polar angle mapping with wedge or polar eccentricity mapping
    % with ring
    % typeGLM = 1 = phase mapping GLM; = 2 = left vs. right wedge GLM

    for iRun = runNo
        % within session, increment run no of behavioural files of one retinotopy type
        fileNames = dir([pathData, '*', '_Run' num2str(iRun), '*', typeRet, '*']);
        load([pathData fileNames.name], 'Vols_per_Expmt', 'Parameters', 'startFirstVols');

        % load movement regressors;
        movRegrPath = [pathRegr 'Run' num2str(iRun) '_Ret' typeRet '\'];
        rpTxt = dir([movRegrPath 'rp_acf*.txt']);
        movRegr = load([movRegrPath rpTxt.name]);

        % check if really polar or ecc
        if (strcmp(Parameters.Apperture, 'Wedge') && strcmp(typeRet, 'Ecc')) || ...
               (strcmp(Parameters.Apperture, 'Ring') && strcmp(typeRet, 'Polar'))
            error('Specified retinotopy type and type specified in behavioural data dont agree!');
        end
        noVolsRun(1, iRun) = Vols_per_Expmt + Parameters.Overrun;
        noVolsCycle(1, iRun) = Parameters.Vols_per_Cycle;
        noVolsOverrun(1, iRun) = Parameters.Overrun;
        TR(iRun) = Parameters.TR;
        if sum(round(diff(100 * startFirstVols)) ~= round(repmat(100 * TR(iRun), [3, 1]))) > 0
            error('first vol triggers not equidistant!');
        end
        durationCycle(1, iRun) = noVolsCycle(1, iRun) *  TR(iRun);
        stimOnsets(:, iRun) = cumsum(ones(noVolsRun(iRun), 1) * TR(iRun)) - TR(iRun); % first "trial starts @ 0"
        % test if run-direction association correct
        if ~strcmp(fileNames.name(end - 6), Parameters.Direction)
            error('Run-direction association wrong!');
        end
        direction(1, iRun) = Parameters.Direction;

        names = {};
        onsets = {};
        durations = {};

        if typeGLM == 1
            names{1} = ['OnsetsVol'];
            onsets{1} = stimOnsets(:, iRun);
            durations{1} = [0];
            % parametric modulators: sine/cosine with period = noVolsCycle*TR
            pmod(1).name = {[typeRet '_' direction(1, iRun) '_sine'], [typeRet '_' direction(1, iRun) '_cosine']};
            sinRegr = [sin(stimOnsets(1:noVolsRun(1, iRun) - noVolsOverrun(1, iRun), iRun) / durationCycle(1, iRun) * 2 * pi); zeros(noVolsOverrun(1, iRun), 1)];
            cosRegr = [cos(stimOnsets(1:noVolsRun(1, iRun) - noVolsOverrun(1, iRun), iRun) / durationCycle(1, iRun) * 2 * pi); zeros(noVolsOverrun(1, iRun), 1)];
            pmod(1).param = {sinRegr, cosRegr};
            pmod(1).poly = {1, 1};
            pathRegrFiles{iRun} = [pathRegr, 'CondOns_Ret', typeRet, '_Run' num2str(iRun) '.mat'];
            save(pathRegrFiles{iRun}, 'names', 'onsets', 'durations', 'pmod');

            % implement sin/cos as regressor without SPM hrf convolution
            %     [hrf] = spm_hrf(TR(iRun));
            %     hrfDiff = diff(hrf);
            %     sinRegrConv = filter(hrf,1,sinRegr);
            %     cosRegrConv = filter(hrf,1,cosRegr);
            %     sinRegrConvTmpDer = filter(hrfDiff,1,sinRegr);
            %     cosRegrConvTmpDer = filter(hrfDiff,1,cosRegr);
            %
            %     R = [sinRegrConv,cosRegrConv,movRegr];
            %     pathRegrFiles{runNo(iRun)} = [pathRegr,'CondOns_Ret',typeRet,'_Run' num2str(runNo(iRun))];
            %     save(pathRegrFiles{runNo(iRun)},'R');
        elseif typeGLM == 2
            % glm includes regressors indicating the timepoint of left and
            % right horizontal meridian stimulation
            widthWedge = Parameters.Apperture_Width;
            % alpha describes the angle of the frontside of the wedge
            % at a given timepoint of the cycle (assumption: wedge starts at 3
            % o'clock), in degree
            if strcmp(direction(1, iRun), '+') % clockwise
                alpha = 360 - mod(stimOnsets(:, iRun) / durationCycle(1, iRun) * 360 + widthWedge / 2, 360) - 1;
                LRegr = (alpha >= 180 - widthWedge) & (alpha <= 180); % 180-width <= alpha <= 180
                RRegr = (alpha <= 360) & (alpha >= 360 - widthWedge); % 0 <= alpha <= 360-width
            elseif strcmp(direction(1, iRun), '-') % counterclockwise
                alpha = mod(stimOnsets(:, iRun) / durationCycle(1, iRun) * 360 + widthWedge / 2, 360) + 1;
                LRegr = (alpha >= 180) & (alpha <= 180 + widthWedge); % 180-width <= alpha <= 180
                RRegr = (alpha >= 0) & (alpha <= widthWedge); % 180-width <= alpha <= 180
            end
            LRegr = stimOnsets(LRegr, iRun);
            RRegr = stimOnsets(RRegr, iRun);
            names = {'OnLRegr', 'OnRRegr'};
            onsets = {LRegr, RRegr};
            durations = {0, 0};
            pathRegrFiles{runNo(iRun)} = [pathRegr, 'CondOns_Ret', typeRet, '_LvsR_Run' num2str(runNo(iRun))];
            save(pathRegrFiles{runNo(iRun)}, 'names', 'onsets', 'durations');
        end

    end
