
subdirs = {'jsonlab';'pSPOT';'spot';,'operators'};

for k = 1:length(subdirs)
    p = fullfile(pwd(),'shared',subdirs{k});
    addpath(p)
end

addpath(fullfile(pwd(),'shared'))
