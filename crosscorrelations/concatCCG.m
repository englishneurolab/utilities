% Concatenate CCGs

dirN ={
    'D:\Data\Axoaxonic_Data_Lianne\u19_200310_135409';...%3
    'D:\Data\Axoaxonic_Data_Lianne\u19_200313_120452';...%2
    'D:\Data\Axoaxonic_Data_Lianne\u19_200313_155505';...%3
};

     ccgALLIN = [];
     ccgALLOUT = [];
for iSess = 1:length(dirN)
     load([basename '.ccginout.events.mat'])
     ccgALLIN = [ccgALLIN; ccgIN];
     ccgALLOUT = [ccgALLOUT;ccgOUT];
end
