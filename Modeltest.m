clear;
clc;


tic
load('AOD_a.mat'); %AOD
load('AOD_Day.mat');
load('rh.mat');%���ʪ��
rh(rh(:,:,:)<20) = NaN;
rh(rh(:,:,:)>100) = NaN;
load('t.mat');%����
t(t(:,:,:)>45) = NaN;
t(t(:,:,:)<-20) = NaN;
load('v.mat');%����
v(v(:,:,:)>10)=NaN;
v(v(:,:,:)<0)=NaN;
load('bj_pm.mat');%����PM2.5
for i = 1 : size(bj_pm,1)
    for j = 2 : size(bj_pm,2)
        if bj_pm(i,j)> 500
            bj_pm(i,j) = NaN;
        end
    end
end

load('hb_pm.mat');%�żҿ�PM2.5
hb_cor = hb_pm(:,1:2);
toc
% bj_cor = xlsread('�������վ������1.0.xlsx','����');
bj_cor = load('�������վ������.txt');
disp('Finshed reading')
%-------����PM2.5��������תΪ��������--------
%% ��һ����ȡ������������
bj_spr_pm25 = []; bj_sum_pm25 = []; bj_aut_pm25 = []; bj_win_pm25 = [];
time_str = num2str(bj_pm(:,1));
for i = 1 : length(bj_pm)
    time_str = num2str(bj_pm(i,1));
    if strcmp(time_str(5:6),'03') | strcmp(time_str(5:6),'04') | strcmp(time_str(5:6),'05')     %����
        temp = bj_pm(i,:);
        bj_spr_pm25 = [bj_spr_pm25;temp];
    elseif strcmp(time_str(5:6),'06') | strcmp(time_str(5:6),'07') | strcmp(time_str(5:6),'08') %�ļ�
        temp = bj_pm(i,:);
        bj_sum_pm25 = [bj_sum_pm25;temp];
    elseif strcmp(time_str(5:6),'09') | strcmp(time_str(5:6),'10') | strcmp(time_str(5:6),'11') %�＾
        temp = bj_pm(i,:);
        bj_aut_pm25 = [bj_aut_pm25;temp];
    else                                                                                         %����
        temp = bj_pm(i,:);
        bj_win_pm25 = [bj_win_pm25;temp];
    end
end

%% �ڶ�����������������ƽ��
bj_ave_pm25(:,1) = mean(bj_spr_pm25(:,2:end),'omitnan')';
bj_ave_pm25(:,2) = mean(bj_sum_pm25(:,2:end),'omitnan')';
bj_ave_pm25(:,3) = mean(bj_aut_pm25(:,2:end),'omitnan')';
bj_ave_pm25(:,4) = mean(bj_win_pm25(:,2:end),'omitnan')';

%-------�żҿ�PM2.5��������תΪ��������--------
%% ����ʱ������
t1 = datetime(2014,1,1);
t2 = datetime(2014,12,31);
series_t = char(t1:t2);
hb_pm = hb_pm(:,3:end)';
%% ��һ����ȡ������������
hb_spr_pm25 = [];  hb_win_pm25=[];  hb_sum_pm25=[];  hb_aut_pm25 = [];
for i = 1 : length(series_t)
    if strcmp(series_t(i,6:7),'03') | strcmp(series_t(i,6:7),'04') | strcmp(series_t(i,6:7),'05')     %����
        temp = hb_pm(i,:);
        hb_spr_pm25 = [hb_spr_pm25;temp];
    elseif strcmp(series_t(i,6:7),'06') | strcmp(series_t(i,6:7),'07') | strcmp(series_t(i,6:7),'08') %�ļ�
        temp = hb_pm(i,:);
        hb_sum_pm25 = [hb_sum_pm25;temp];
    elseif strcmp(series_t(i,6:7),'09') | strcmp(series_t(i,6:7),'10') | strcmp(series_t(i,6:7),'11') %�＾
        temp = hb_pm(i,:);
        hb_aut_pm25 = [hb_aut_pm25;temp];
    else                                                                                        %����
        temp = hb_pm(i,:);
        hb_win_pm25 = [hb_win_pm25;temp];
    end
end
%% �ڶ�����������������ƽ��

bj_hb_ave_pm25(:,1) = [bj_ave_pm25(:,1);mean(hb_spr_pm25(:,:),'omitnan')'];
bj_hb_ave_pm25(:,2) = [bj_ave_pm25(:,2);mean(hb_sum_pm25(:,:),'omitnan')'];
bj_hb_ave_pm25(:,3) = [bj_ave_pm25(:,3);mean(hb_aut_pm25(:,:),'omitnan')'];
bj_hb_ave_pm25(:,4) = [bj_ave_pm25(:,4);mean(hb_win_pm25(:,:),'omitnan')'];

bj_hb_ave_pm25_cor = [[bj_cor(:,1:2);hb_cor(:,1:2)],bj_hb_ave_pm25];%6�зֱ�Ϊ���ȡ�γ�ȡ������ġ����PM2.5

disp('PM2.5���������������')

% ��ʼ����AOD_a,���зֱ�Ϊ���ȡ�γ�ȡ���ƽ���������ġ����ƽ��
%% ����PM2.5վ�㾭γ����ȡAod_a���λ��,������ƽ���������ġ����ƽ�������
AOD_a_cor = [];
for i = 1 : length(bj_hb_ave_pm25_cor)
    [arclen,~] = distance(bj_hb_ave_pm25_cor(i,2),...
        bj_hb_ave_pm25_cor(i,1),AOD_a(:,2),AOD_a(:,1));%������γ��֮�����������ԽС������Խ��arclen*6371*1000*2*pi/360
    %�������д���ȼ������漸��ע�͵Ĵ��룬���ӿ�������Ч�ʣ���ǧ���򱶣�
    %     for j = 1 : length(AOD_a)
    %         [arclen,~] = distance(bj_hb_ave_pm25_cor(i,2),...
    %             bj_hb_ave_pm25_cor(i,1),AOD_a(j,2),AOD_a(j,1));%������γ��֮�����������ԽС������Խ��arclen*6371*1000*2*pi/360
    %         temp_arclen = [temp_arclen;arclen];
    %     end
    AOD_a_cor = [AOD_a_cor;AOD_a(arclen(:,1) == min(arclen),:)];%matlab������д����������������Ч�ʣ����ȼ������漸��ע�͵Ĵ���
    %     for k = 1 : length(temp_arclen)
    %         if temp_arclen(k,1) == min(temp_arclen)
    %             AOD_a_cor = [AOD_a_cor;AOD_a(k,:)];
    %             break
    %         end
    %     end
end
disp('AOD���������������')

% ��ʼ������������,���зֱ�Ϊ���ȡ�γ�ȡ���ƽ���������ġ����ƽ��

lon = unique(AOD_a(:,1))';
lat = unique(AOD_a(:,2))';
[x,y] = meshgrid(lon,lat);
y = flipud(y);
%% ��һ����ȡ2014����������� ���ʪ�� ��������
%2014�괺����Ӧ����ά�±�Ϊ365+31+28+1=425 ~ 365+31+28+31+30+31=516
r = 1;
for i = 1 : size(x,1)
    for j = 1 : size(x,2)
        meto_spr(r,1) = x(i,j);
        meto_spr(r,2) = y(i,j);
        meto_spr(r,3) = mean(t(i,j,425:516),'omitnan');%����
        meto_spr(r,4) = mean(v(i,j,425:516),'omitnan');%����
        meto_spr(r,5) = mean(rh(i,j,425:516),'omitnan');%����
        r = r + 1;
    end
end

%2014���ļ���Ӧ����ά�±�Ϊ517 ~ 516+30+31+31=608
r = 1;
for i = 1 : size(x,1)
    for j = 1 : size(x,2)
        meto_sum(r,1) = x(i,j);
        meto_sum(r,2) = y(i,j);
        meto_sum(r,3) = mean(t(i,j,517:608),'omitnan');%����
        meto_sum(r,4) = mean(v(i,j,517:608),'omitnan');%����
        meto_sum(r,5) = mean(rh(i,j,517:608),'omitnan');%����
        r = r + 1;
    end
end
%2014���＾��Ӧ����ά�±�Ϊ609 ~ 608+30+31+30=699
r = 1;
for i = 1 : size(x,1)
    for j = 1 : size(x,2)
        meto_aut(r,1) = x(i,j);
        meto_aut(r,2) = y(i,j);
        meto_aut(r,3) = mean(t(i,j,609:699),'omitnan');%����
        meto_aut(r,4) = mean(v(i,j,609:699),'omitnan');%����
        meto_aut(r,5) = mean(rh(i,j,609:699),'omitnan');%����
        r = r + 1;
    end
end
%2014�궬����Ӧ����ά�±�Ϊ366 ~ 365+31+28=424 ��700~730
r = 1;
for i = 1 : size(x,1)
    for j = 1 : size(x,2)
        meto_win(r,1) = x(i,j);
        meto_win(r,2) = y(i,j);
        meto_win(r,3) = mean(t(i,j,[366:424,700:730]),'omitnan');%����
        meto_win(r,4) = mean(v(i,j,[366:424,700:730]),'omitnan');%����
        meto_win(r,5) = mean(rh(i,j,[366:424,700:730]),'omitnan');%����
        r = r + 1;
    end
end

%% �ڶ�����ȡPM2.5�۲�վ������봦������ֵ
meto_spr_cor = []; meto_sum_cor = []; meto_aut_cor = []; meto_win_cor = [];
for i = 1 : length(bj_hb_ave_pm25_cor)
    [arclen,~] = distance(bj_hb_ave_pm25_cor(i,2),...
        bj_hb_ave_pm25_cor(i,1),meto_aut(:,2),meto_aut(:,1));%������γ��֮�����������ԽС������Խ��arclen*6371*1000*2*pi/360
    
    meto_spr_cor = [meto_spr_cor;meto_spr(arclen(:,1) == min(arclen),:)];%matlab������д����������������Ч�ʣ����ȼ������漸��ע�͵Ĵ���
    meto_sum_cor = [meto_sum_cor;meto_sum(arclen(:,1) == min(arclen),:)];
    meto_aut_cor = [meto_aut_cor;meto_aut(arclen(:,1) == min(arclen),:)];
    meto_win_cor = [meto_win_cor;meto_win(arclen(:,1) == min(arclen),:)];
end

disp('���󼾶������������')

%% ��ʼ�𲽻ع�
% r = 1;
% aod_aut = mean(data_day(:,:,244:334),3,'omitnan');
% for i = 1 : size(aod_aut,1)
%     for j = 1 : size(aod_aut,2)
%         aod(r,1) = aod_aut(i,j);
%         r = r + 1;
%     end
% end

%�����𲽻ع�
stepwise([AOD_a_cor(:,4),meto_spr_cor(:,3:5)],bj_hb_ave_pm25_cor(:,3))%x1~x4�ֱ�Ϊaod ���� ���� ���ʪ��
pm25(:,1) = meto_spr(:,3)*beta(2) + meto_spr(:,5)*beta(4) + stats.intercept;
%�ļ��𲽻ع�
stepwise([AOD_a_cor(:,5),meto_sum_cor(:,3:5)],bj_hb_ave_pm25_cor(:,4))%x1~x4�ֱ�Ϊaod ���� ���� ���ʪ��
pm25(:,2) = meto_sum(:,3)*beta1(2)+meto_sum(:,5)*beta1(4)+stats1.intercept;
%�＾�𲽻ع�
stepwise([AOD_a_cor(:,6),meto_aut_cor(:,3:5)],bj_hb_ave_pm25_cor(:,5))%x1~x4�ֱ�Ϊaod ���� ���� ���ʪ��
pm25(:,3) = AOD_a(:,6)*beta2(1) +stats2.intercept;
%�����𲽻ع�
stepwise([AOD_a_cor(:,7),meto_win_cor(:,3:5)],bj_hb_ave_pm25_cor(:,6))%x1~x4�ֱ�Ϊaod ���� ���� ���ʪ��
pm25(:,4) = meto_win(:,3)*beta3(2)+meto_win(:,5)*beta3(4)+stats3.intercept;
%����𲽻ع�
meto_a_cor(:,1:2) = meto_win_cor(:,1:2);
meto_a_cor(:,3) = (meto_spr_cor(:,3)+meto_sum_cor(:,3)+meto_aut_cor(:,3)+meto_win_cor(:,3))/4;
meto_a(:,3) = (meto_spr(:,3)+meto_sum(:,3)+meto_aut(:,3)+meto_win(:,3))/4;
meto_a_cor(:,4) = (meto_spr_cor(:,4)+meto_sum_cor(:,4)+meto_aut_cor(:,4)+meto_win_cor(:,4))/4;
meto_a_cor(:,5) = (meto_spr_cor(:,5)+meto_sum_cor(:,5)+meto_aut_cor(:,5)+meto_win_cor(:,5))/4;
meto_a(:,5) = (meto_spr(:,5)+meto_sum(:,5)+meto_aut(:,5)+meto_win(:,5))/4;
% mean(bj_hb_ave_pm25_cor(:,3:6),2,'omitnan');
stepwise([AOD_a_cor(:,3),meto_a_cor(:,3:5)],mean(bj_hb_ave_pm25_cor(:,3:6),2,'omitnan'))%x1~x4�ֱ�Ϊaod ���� ���� ���ʪ��
pm25(:,5) = meto_a(:,3)*beta4(2)+meto_a(:,5)*beta4(4)+stats4.intercept;
pm25 = [meto_win(:,1:2),pm25];
dlmwrite('ģ�ͼ����PM25.txt',pm25,'precision','%5f','delimiter','\t');
disp('�𲽻ع�������')


