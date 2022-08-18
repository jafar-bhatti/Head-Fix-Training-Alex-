function gonogo(ID,STAGE,paramFile)
close all
clearvars -except ID STAGE paramFile
delete(instrfindall)
dbstop if error

if nargin < 3 || ~exist('paramFile','var')
    paramFile = 'booth1-params.txt';
end
if nargin < 2 || ~exist('STAGE','var')
    STAGE = 0;
end
if nargin < 1 || ~exist('ID','var')
    ID = 'CA999';
end

addpath(genpath('_analysis'));
addpath(genpath('_task'));
addpath(genpath('_thresholds'));


%% SETUP
% load parameter file for this computer
[params, fs] = loadParameters(fullfile('_params',paramFile));

% setup sound output device
[s,params.fs] = setupSoundOutput(fs,params.device,params.channel);

% directory stuff:
params.IDstr    = ID;
params.base     = pwd;
params.data     = [pwd filesep '_data' filesep params.IDstr];
params.hex      = [pwd filesep '_hex'];
params.stage    = STAGE;
params.filtdir  = 'D:\GitHub\filters';
if ~exist(params.data,'dir')
    mkdir(params.data);
end
if ~exist(params.filtdir,'dir')
    error('Filter directory not found, pull from GitHub.');
end

%% PARAMETERS
% stimulus parameters
params.seed         = 1989;
params.filt         = load([params.filtdir filesep params.filtFile]);
params.filt         = params.filt.FILT;
params.stimVersion  = '200406';
params.noisedur     = 1.5;
params.noiseDB      = 50;
params.rampdur      = 0.005;
params.targetdur    = 0.050;
params.targetDB     = 70;
params.gracePeriod  = 0.5;
params.targetTimes  = params.gracePeriod + [0 0.025 0.05 0.075];

% task parameters
params.holdD    = 1.5; %interval between trials
params.respD    = 1; %?
params.timeoutD = 10.0;

% go into task sequence
cnt = 1;
while cnt <= length(STAGE)
    switch STAGE(cnt)
        case -1
            disp('RUNNING LICK TUBE PRIMING')
            prime(params);
            
        case 0
            disp('RUNNING HABITUATION');
            habituation(params);
            
        case 1
            disp('RUNNING TRAINING');            
            params.stimLabel = 'training';
            
            training(s,params); 
            
        case 1.1
            disp('RUNNING TRAINING W. ABORT');
            params.targetDBShift = 25;
            params.stimLabel = 'training';
            
            training_abort(s,params);
            
        case 2
            disp('RUNNING TESTING');
            psych(s,params);
            
    end
    cnt = cnt + 1;
end

close('all')
close all
clear all 