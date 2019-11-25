close all
Data1=BlebDiam.Ex3;
Data2=BlebDiam.Ex2;
Data3=BlebDiam.Ex1;

% Data1=BlebPerFr_idx.Ex3;
% Data2=BlebPerFr_idx.Ex2;
% Data3=BlebPerFr_idx.Ex1;

%Data1=BlebstoCelSizePerc.Ex3;
%Data2=BlebstoCelSizePerc.Ex2;
%Data3=BlebstoCelSizePerc.Ex1;
%hold on ;
%subplot(3,1,1)BlebstoCelSizePerc
binN=10;
h1=histfit(Data1,binN,'kernel');
        pd1 = fitdist(Data1,'Normal'); % distribution
        h1(1).FaceColor='g';   
        %set(h1(1),'FaceAlpha',.5); % Transparency 
        h1(2).Color=[0.47 0.67 0.19];%'g';
        MeanData1=pd1.mu;
        SigmaData1=pd1.sigma;
         
hold on% subplot(3,1,2)
h2=histfit(Data2,binN-2,'kernel');
    pd2 = fitdist(Data2,'Normal');
    h2(1).FaceColor = 'r';%'b'; %
    set(h2(1),'FaceAlpha',.5);
    MeanData2=pd2.mu;
    SigmaData2=pd2.sigma;

 hold on% subplot(3,1,3)
 
 h3=histfit(Data3,binN+2,'kernel');
    h3(1).FaceColor = [.8 .8 1];%'b'; %
    h3(2).Color='k';
    pd3 = fitdist(Data3,'Normal');
    set(h3(1),'FaceAlpha',.75);
    MeanData3=pd3.mu;
    SigmaData3=pd3.sigma;
        %AddText to the figure; 
 hold on        
xt = 6.5;
y1 = 85;y2=78;y3=73;
str1 = sprintf('%0.1f', (MeanData1));
str2 = sprintf('%0.1f', (SigmaData1));
text(xt,y1,['Exp3 = ' str1 '\pm' str2],'Color',[0.47 0.67 0.19],'FontSize',12)

 hold on        
str2 = sprintf('%0.1f', (MeanData2));
str3 = sprintf('%0.1f', (SigmaData2));
text(xt,y2,['Exp2 = ' str2 '\pm' str3],'Color','r','FontSize',12)

 hold on        
str4 = sprintf('%0.1f', (MeanData3));
str5 = sprintf('%0.1f', (SigmaData3));
text(xt,y3,['Exp1 = ' str4 '\pm' str5],'Color','k','FontSize',12)

set(findall(gcf,'-property','FontSize'),'FontSize',16)


%%

Data1max=max(BlebDiam.Ex3);
Data2max=max(BlebDiam.Ex2);
Data3max=max(BlebDiam.Ex1);

 hold on        
xt = -4;
y1 = 85;y2=78;y3=73;
str1 = sprintf('%0.1f', (Data1max));
text(xt,y1,['max = ' str1 ],'Color',[0.47 0.67 0.19],'FontSize',12)

 hold on        
str2 = sprintf('%0.1f', (Data2max));
text(xt,y2,['max = ' str2 ],'Color','r','FontSize',12)

 hold on        
str4 = sprintf('%0.1f', (Data3max));
text(xt,y3,['max = ' str4 ],'Color','k','FontSize',12)

set(findall(gcf,'-property','FontSize'),'FontSize',16)








%%
Gr1=histfit(BlebPerFr_idx.Ex3, 4,'Normal')