
subdirs = {'jsonlab';'pSPOT';'spot'};

for k = 1:length(subdirs)
    p = fullfile(pwd(),'shared',subdirs{k});
    addpath(p)
end
