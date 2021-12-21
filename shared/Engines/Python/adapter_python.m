function [back]=adapter(drcell_path, TS, AMP, rec_dur, SaRa ,Selection, time_win, FR_min, N, binSize)


        % remove old DrCell/Neuro/Cardio folder from search path
        PathCell = textscan(path, '%s', 'Delimiter', pathsep);
        PathCell = PathCell{1,1}; % unpack cell (as textscan was used)
        for i=1:size(PathCell,1)
            if any(strfind(PathCell{i},'DrCell')) % remove all entries that contain string "DrCell"
              rmpath(PathCell{i});
            end
        end

        % Add all DrCell folder to matlab search path
        % path_full = mfilename('fullpath'); % get path of this m-file (.../path/DrCell.m)
        path_full = drcell_path % path of the main-folder (.../path/DrCell.m)

        disp(['Voller Path' path_full])
        [path_drcell,~] = fileparts(path_full); % separate path and m-file-name

        p=genpath(path_drcell); % get path of all subfolders
        disp(p)
        addpath(p); % add to matlab search path

    if iscell(Selection)
        disp("To many arguemnts")
        return
        end
    MERGED.TS= TS;
    MERGED.AMP = AMP;
    MERGED.PREF.rec_dur = rec_dur;
    MERGED.PREF.SaRa = SaRa;
    N = 0;
    binSize = 0;

    [WIN]=CalcFeatures_function(MERGED,Selection,time_win,FR_min,N,binSize)
    mean = WIN(1).parameter(1).mean
    values = WIN(1).parameter(1).values
    std = WIN(1).parameter(1).std
    allEl = WIN(1).parameter(1).allEl
    back = {[mean], [values], [std], [allEl]}
%    for i = 1:size(WIN, 1)
%        for y = 1:size(WIN(i.parameter, 1))
%                mean(i, y) = WIN(i).paramter(y).mean
%                values = WIN(i).paramter(y).values
%                std = WIN(i).paramter(y).std
%                allEl = WIN(i).paramter(y).allEl
%            end
%        end

end