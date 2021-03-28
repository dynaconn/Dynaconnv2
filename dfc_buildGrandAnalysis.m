%Do an Exhaustive Task-Modulation Analysis
%given a DFC matrix and mean Region timecourse of two groups, do all kinds of task-modulation computations
%DFC matrix size: (numSubjs x numRegions x numRegions x numWindows)
%average region timecourse matrix size: (numSubjs x numRegions x TClength
%numRegions = 116,
numRegions = length(squeeze(squeeze(RegAveData(1,:,1))));
%Dynaconn stores numWindows where?
numWindows=37,
TClength = length(squeeze(squeeze(RegAveData(1,1,:))));

%Randomly creating these datasets, replace them when you obtain the
%actual compuations:
tic

myROIDfc_GroupZero = load('C:\GW_DFC_Data\Data_Out\11-02-2020_median_Data\Data\myROIDFC_GroupZero.mat'); %rand(30,116,116,37)-1;
myROIDfc_GroupTwo = load('C:\GW_DFC_Data\Data_Out\11-02-2020_median_Data\Data\myROIDFC_GroupTwo.mat'); %rand(23,116,116,37)-1;
myROIDfc_GroupOne = load('C:\GW_DFC_Data\Data_Out\11-02-2020_median_Data\Data\myROIDFC_GroupOne.mat'); %rand(30,116,116,37)-1;
myROIDfc_GroupThree = load('C:\GW_DFC_Data\Data_Out\11-02-2020_median_Data\Data\myROIDFC_GroupThree.mat'); %rand(23,116,116,37)-1;


myROIDfc_GroupZero = myROIDfc_GroupZero.myROIDFC_GroupZero;
myROIDfc_GroupOne = myROIDfc_GroupOne.myROIDFC_GroupOne;
myROIDfc_GroupTwo = myROIDfc_GroupTwo.myROIDFC_GroupTwo;
myROIDfc_GroupThree = myROIDfc_GroupThree.myROIDFC_GroupThree;

mysubjectsignal_allsubjects = load('C:\GW_DFC_Data\Data_Out\11-02-2020_median_Data\Data\myavgsignal_allsubjects.mat'); %randn(90,116,320);
mysubjectsignal_GroupZero = load('C:\GW_DFC_Data\Data_Out\11-02-2020_median_Data\Data\myavgsignal_allsubjects_GroupZero.mat'); %randn(30,116,320);
mysubjectsignal_GroupTwo = load('C:\GW_DFC_Data\Data_Out\11-02-2020_median_Data\Data\myavgsignal_allsubjects_GroupTwo.mat'); %randn(23,116,320);
mysubjectsignal_GroupOne = load('C:\GW_DFC_Data\Data_Out\11-02-2020_median_Data\Data\myavgsignal_allsubjects_GroupOne.mat'); %randn(30,116,320);
mysubjectsignal_GroupThree = load('C:\GW_DFC_Data\Data_Out\11-02-2020_median_Data\Data\myavgsignal_allsubjects_GroupThree.mat'); %randn(23,116,320);
mysubjectsignal_allsubjects = mysubjectsignal_allsubjects.myavgsignal_allsubjects;
mysubjectsignal_GroupZero = mysubjectsignal_GroupZero.myavgsignal_allsubjects_GroupZero;
mysubjectsignal_GroupOne = mysubjectsignal_GroupOne.myavgsignal_allsubjects_GroupOne;
mysubjectsignal_GroupTwo = mysubjectsignal_GroupTwo.myavgsignal_allsubjects_GroupTwo;
mysubjectsignal_GroupThree = mysubjectsignal_GroupThree.myavgsignal_allsubjects_GroupThree;% toc % < 1 second

%Resample the time course data to use for task-modulation subsequently
tic
for i=1:30,  % i=1:numSubjects_GroupZero
    for j=1:116,  %j=1:numRegions
        mysubjectsignal_GroupZero_resampled(i,j,:) = resample(squeeze(mysubjectsignal_GroupZero(i,j,:)),37,320);
        mysubjectsignal_GroupZero_resampled_normd(i,j,:) = normalize(mysubjectsignal_GroupZero_resampled(i,j,:),'range',[-1 1]);
    end
end
toc %< a few seconds
%figure,subplot(211),plot(squeeze(mysubjectsignal_GroupZero(i,j,:))),subplot(212), plot(squeeze(mysubjectsignal_GroupZero_resampled(i,j,:)),':')
tic
for i=1:19,     % i=1:numSubjects_GroupOne 
    for j=1:116,
        mysubjectsignal_GroupOne_resampled(i,j,:) = resample(squeeze(mysubjectsignal_GroupOne(i,j,:)),37,320);
        mysubjectsignal_GroupOne_resampled_normd(i,j,:) = normalize(mysubjectsignal_GroupOne_resampled(i,j,:),'range',[-1 1]);
    end
end
toc %a few seconds
tic
for i=1:23,
    for j=1:116,
        mysubjectsignal_GroupTwo_resampled(i,j,:) = resample(squeeze(mysubjectsignal_GroupTwo(i,j,:)),37,320);
        mysubjectsignal_GroupTwo_resampled_normd(i,j,:) = normalize(mysubjectsignal_GroupTwo_resampled(i,j,:),'range',[-1 1]);
    end
end
toc %a few seconds
tic
for i=1:18,
    for j=1:116,
        mysubjectsignal_GroupThree_resampled(i,j,:) = resample(squeeze(mysubjectsignal_GroupThree(i,j,:)),37,320);
        mysubjectsignal_GroupThree_resampled_normd(i,j,:) = normalize(mysubjectsignal_GroupThree_resampled(i,j,:),'range',[-1 1]);
    end
end
toc %a few seconds


%30,116,116,37 myROIDfc_GroupZero
%30,116,37 mysubjectsignal_GroupZero_resampled and mysubjectsignal_GroupTwo_resampled


tic
for iNS=1:30,
    iNS=iNS
    for i=1:116,
        i=i
        for j=1:116,
            for k=1:116,
                taskMod_GroupZero(iNS,i,j,k) = corr(squeeze(myROIDfc_GroupZero(iNS,i,j,:)),squeeze(mysubjectsignal_GroupZero_resampled_normd(iNS,k,:)));
            end
        end
    end
end
toc

% tic
% for iNS=1:19,
%     iNS=iNS
%     for i=1:116,
%         i=i
%         for j=1:116,
%             for k=1:116,
%                 taskMod_GroupOne(iNS,i,j,k) = corr(squeeze(myROIDfc_GroupOne(iNS,i,j,:)),squeeze(mysubjectsignal_GroupOne_resampled_normd(iNS,k,:)));
%             end
%         end
%     end
% end
% toc

tic
for iNS=1:23,
    iNS=iNS
    for i=1:116,
        i=i
        for j=1:116,
            for k=1:116,
                taskMod_GroupTwo(iNS,i,j,k) = corr(squeeze(myROIDfc_GroupTwo(iNS,i,j,:)),squeeze(mysubjectsignal_GroupTwo_resampled_normd(iNS,k,:)));
            end
        end
    end
end
toc

% tic
% for iNS=1:18,
%     iNS=iNS
%     for i=1:116,
%         i=i
%         for j=1:116,
%             for k=1:116,
%                 taskMod_GroupThree(iNS,i,j,k) = corr(squeeze(myROIDfc_GroupThree(iNS,i,j,:)),squeeze(mysubjectsignal_GroupThree_resampled_normd(iNS,k,:)));
%             end
%         end
%     end
% end
% toc

alpha=0.01;
[H02,P02,T02,STATS02] = ttest2(taskMod_GroupZero,taskMod_GroupTwo,'dim',1,'tail','both','Alpha',alpha,'Vartype','unequal');

[minval,minindex] = min(P02(:))
size(minindex)

[aa,bb,cc,dd] = ind2sub(size(P02),minindex);

[aa(1),bb(1),cc(1),dd(1)], [P02(aa(1),bb(1),cc(1),dd(1))]
% [aa(2),bb(2),cc(2),dd(2)], [P02(aa(2),bb(2),cc(2),dd(2))]

i=bb(1),j=cc(1),k=dd(1),
P02val = P02(aa(1),bb(1),cc(1),dd(1)),
figure, title(['DFC (solid) of regions ',num2str(i),' & ',num2str(j),' modulated by Region ',num2str(k),' TC (dotted)'])
for pp=1:10, %just pick 6 subjects per group to plot: Left: One Group, Right: Another Group
    subplot(7,2,2*pp-1),plot(squeeze(myROIDfc_GroupZero(pp,i,j,:))','-'), hold on,
                        plot(squeeze(mysubjectsignal_GroupZero_resampled_normd(pp,k,:))',':'), ylabel(['Subj ',num2str(pp)])
                        c1=corr(squeeze(myROIDfc_GroupZero(pp,i,j,:)),squeeze(mysubjectsignal_GroupZero_resampled_normd(pp,k,:)));
                        legend(['cc=',num2str(c1,3)])
    subplot(7,2,2*pp),plot(squeeze(myROIDfc_GroupTwo(pp,i,j,:))','-'),hold on,
                      plot(squeeze(mysubjectsignal_GroupTwo_resampled_normd(pp,k,:))',':'),
                      c2=corr(squeeze(myROIDfc_GroupTwo(pp,i,j,:)),squeeze(mysubjectsignal_GroupTwo_resampled_normd(pp,k,:)));
                        legend(['cc=',num2str(c2,3)])
end
subplot(7,1,7), title(['DFC (solid) of regions ',num2str(i),' & ',num2str(j),' modulated by Region ',num2str(k),' TC (dotted)'])
