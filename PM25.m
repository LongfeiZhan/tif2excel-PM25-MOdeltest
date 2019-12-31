clear;
clc;

[hb_num,hb_str] = xlsread('D:\PartTime\Date\20191101\�ӱ����վ��PM14-17.xlsx','Sheet3');
% [bj_num,bj_str] = xlsread('D:\PartTime\Date\20191101\2014\beijing_20140101-20141231\PM\beijing_all_20140101.csv');

r = 1;
for i = 1 : length(hb_num)-1
    temp1 = hb_num(i,1:2);
    temp2 = hb_num(i+1,1:2);
    if temp1(1,1) ~= temp2(1,1) | temp1(1,2) ~= temp2(1,2)
        hb_pm(r,:) = temp1;
        r = r + 1;
    end
end
hb_pm(r,:) = temp1;

%% ��ʼ�����żҿ�PM2.5����
count = 0;
r = 1;
for i = 1 : length(hb_str)
    date_hb = char(hb_str(i,1));   %cell��ʽתΪ�ַ�����ʽ���Ա��ж����
    if strcmp(date_hb(1:4),'2014')  %�ж��Ƿ�Ϊ2014��
        PM25_hb(r,:) = hb_str(i,:); %��ȡ��2014������
        PM25_hb_num(r,:) = hb_num(i,:);
        r = r + 1;
    end
end
%-----�ҳ�����ȱ������һ��---------
t1 = datetime(2014,1,1);
t2 = datetime(2014,12,31);
t = char(t1:t2);
r = 1;
for i = 1 : length(PM25_hb)
    if strcmp(char(PM25_hb(i,1)),char(PM25_hb(1,1)))
        change_points(r,1) = i;
        r = r + 1;
    end
end

r = 1;
for j = 1 : length(change_points)
    for i = 1 : 365
        str_hb_data = char(PM25_hb(i+change_points(j,1)-1,1));
        if str_hb_data(end) ~= t(i,10)
            miss(r,1)=i+change_points(j,1)-1;%��¼ȱ�����ڵ�λ��
            r = r + 1;
            break
        end
    end
end
%------�������й���--------
r = 1;j = 3;
for i = 1 : length(PM25_hb_num)-1
    if PM25_hb_num(i,1) ~= PM25_hb_num(i+1,1) | ...
            PM25_hb_num(i,2) ~= PM25_hb_num(i+1,2)
        hb_pm(r,j) = PM25_hb_num(i,6);
        r = r +1;
        j = 3;
    else
        for rr = 1 : length(miss)
            if i == miss(rr,1)
                hb_pm(r,j) = NaN;  %��ȱ�����ڴ�����NaN
                j = j + 1;
            end
        end
        hb_pm(r,j) = PM25_hb_num(i,6);
        j = j + 1;
    end
end
hb_pm(r,j) = PM25_hb_num(i+1,6);
save('hb_pm.mat','hb_pm');
disp('�żҿ�PM2.5�����������')

%% ��ʼ������PM2.5����

rr = 1;
path = 'D:\PartTime\Date\20191101\2014\beijing_20140101-20141231\PM\';
file = dir([path,'*csv']);
for i = 1 : length(file)
    temp = [];
    r = 1;
    [bj_num,bj_str] = xlsread([path,file(i).name]);
    for j = 2 : size(bj_str,1)
        if strcmp(char(bj_str(j,3)),'PM2.5')
            temp(r,:) = bj_num(j-1,:);
            for ii = 1:size(temp,2)
                if temp(r,ii) < 0  
                    temp(r,ii) = NaN;  %С��0����Ϊ��ֵ
                end
            end
            r = r + 1;
        end
    end  
    bj_pm(rr,1) = bj_num(1,1);
    bj_pm(rr,2:size(temp,2)-2) = mean(temp(:,4:end),'omitnan');
    rr = rr + 1;
end

%-------Ѱ��ȱʧ����-------
r = 1;
for i = 1 : length(t)-1  %��1����Ϊ����û��2014��12��31��
    date_str = num2str(bj_pm(i,1));
    if strcmp(t(i,6:7),date_str(5:6)) &  strcmp(t(i,9:10),date_str(7:8))
        continue
    else
        date_str2num = str2num([t(i,1:4),t(i,6:7),t(i,9:10)]);
        insert_row(1,1) = date_str2num;
        insert_row(1,2:size(bj_pm,2)) = NaN;
        bj_pm = [bj_pm(1:i-1,:);insert_row;bj_pm(i:end,:)];
    end
end
save('bj_pm.mat','bj_pm');
disp('��������PM2.5�����������')


%% �������𲽻ع�



























