%-----！！！！注意：该程序应放在投影文件夹同级目录下，放在其他路径会报错！！！！---------
clc;clear;
file_am = dir('Terra2014project\*.tif');   %需要改名字，例如Terra2015project\*.tif
file_pm = dir('Aqua2014project\*.tif');    %需要改名字，例如Terra2015project\*.tif
k_am = 1; k_pm = 1;

%% 上午卫星缺测量判断，挑选出缺测少的时次作为上午的资料
for i = 1 : length(file_am) - 1
% i = 1;
% while i <= length(file_am)-1
    name1 = file_am(i).name;
    name2 = file_am(i+1).name;
    data1 = geotiffread(['Terra2014project\',file_am(i).name]);    %需要改名字，例如Terra2015project\*.tif
    data2 = geotiffread(['Terra2014project\',file_am(i+1).name]);   %需要改名字，例如Terra2015project\*.tif
    if str2num(name1(22:24)) == str2num(name2(22:24))
        count1 = 0; count2 = 0;
        for row = 1 : size(data1,1)
            for col = 1 : size(data1,2)
                if data1(row,col) == -28672
                    count1 = count1 + 1;
                end
                if data2(row,col) == -28672
                    count2 = count2 + 1;
                end
            end            
        end
        if count1 > count2
            filter_am{k_am,1} = name2;
            k_am = k_am + 1;
        else
            filter_am{k_am,1} = name1;
            k_am = k_am + 1;
        end
%         i = i + 2;
%     end
%     if str2num(name1(22:24)) ~= str2num(name2(22:24))       
%         filter_am{k_am,1} = file_am(i).name;
%         k_am = k_am + 1;
%         i = i + 1;
    end
end
%加入上午只过境一次情况的资料
for ii = 1 : length(file_am)
    for jj = 1 : length(filter_am)
        name_temp = cell2mat(filter_am(jj));
        if file_am(ii).name(22:24) == name_temp(22:24)
            break
        end
        if jj == length(filter_am)
            filter_am{k_am,1} = file_am(ii).name;
            k_am = k_am + 1;
        end
    end
end
filter_am = sort(filter_am);
disp('---------上午资料整理完毕------------')
%% 下午卫星缺测量判断，挑选出缺测少的时次作为下午的资料
for i = 1 : length(file_pm) - 1
    name1 = file_pm(i).name;
    name2 = file_pm(i+1).name;
    data3 = geotiffread(['Aqua2014project\',file_pm(i).name]);     %需要改名字，例如Terra2015project\*.tif
    data4 = geotiffread(['Aqua2014project\',file_pm(i+1).name]);   %需要改名字，例如Terra2015project\*.tif
    if str2num(name1(22:24)) == str2num(name2(22:24))
        count1 = 0; count2 = 0;
        for row = 1 : size(data3,1)
            for col = 1 : size(data3,2)
                if data3(row,col) == -28672
                    count1 = count1 + 1;
                end
                if data4(row,col) == -28672
                    count2 = count2 + 1;
                end
            end
        end
        if count1 > count2
            filter_pm{k_pm,1} = name2;
            k_pm = k_pm + 1;
        else
            filter_pm{k_pm,1} = name1;
            k_pm = k_pm + 1;
        end
    end
end
disp('---------下午资料整理完毕------------')
%% 上、下午卫星数据融合并逐日存储至data_day中
%-----------训练回归模型-----------
data_am = geotiffread(['Terra2014project\',cell2mat(filter_am(1))]);    %需要改名字，例如Terra2015project\*.tif
data_pm = geotiffread(['Aqua2014project\',cell2mat(filter_pm(1))]);     %需要改名字，例如Terra2015project\*.tif
r = 1;
for j = 1:1038
    for k = 1:1388
        if data_am(j,k) ~= -28672 & data_pm(j,k) ~= -28672
            data_xy(r,1) = double(data_am(j,k));
            data_xy(r,2) = double(data_pm(j,k));
            r = r + 1;
        end
    end
end
p1 = polyfit(data_xy(:,1),data_xy(:,2),1);%回归上午推下午
p2 = polyfit(data_xy(:,2),data_xy(:,1),1);%回归下午推上午
disp('---------回归模型训练完毕-----------')

for i = 1 : length(filter_am) 
    i
    r = 1; data_xy = [];
    data_am = geotiffread(['Terra2014project\',cell2mat(filter_am(i))]);    %需要改名字，例如Terra2015project\*.tif
    data_pm = geotiffread(['Aqua2014project\',cell2mat(filter_pm(i))]);     %需要改名字，例如Terra2015project\*.tif
    for j = 527:776
        for k = 891:1232
            if data_am(j,k) == -28672 & data_pm(j,k) == -28672
                data_am(j,k) = NaN;
                data_pm(j,k) = NaN;
                data_day(j-526,k-890,i) = NaN;
            elseif data_am(j,k) == -28672 & data_pm(j,k) ~= -28672
                data_am(j,k) = p2(1) * data_pm(j,k) + p2(2);
                data_day(j-526,k-890,i) = (data_am(j,k) + data_pm(j,k))/2;
            elseif data_am(j,k) ~= -28672 & data_pm(j,k) == -28672
                data_pm(j,k) = p1(1) * data_am(j,k) + p1(2);
                data_day(j-526,k-890,i) = (data_am(j,k) + data_pm(j,k))/2;
            end
        end
    end
end
save('AOD_Day.mat','data_day');
disp('---------融合并存储逐日AOD数据完毕------------')
%%  经纬度配置（北京+张家口）
info = geotiffinfo(['Terra2014project\',cell2mat(filter_am(1))]);  %需要改名字，例如Terra2015project\*.tif
box_xy = info.BoundingBox;
dx = (box_xy(2,1) - box_xy(1,1))/1387;
dy = (box_xy(2,2) - box_xy(1,2))/1037;
lon = box_xy(1,1) : dx : box_xy(2,1);
lat = box_xy(2,2) : -dy : box_xy(1,2);
[x,y] = meshgrid(lon(1,891:1232),lat(1,527:776));
disp('---------经纬度配置完毕------------');
%% 日均值AOD结果
data_output = zeros(1,length(filter_am)); 
for ii = 1 : length(filter_am)
     data_output(1,ii) = ii;
    data_output(2,ii) = mean(mean(data_day(:,:,ii),'omitnan'),'omitnan')*0.001;
end
% xlswrite('2014日均值AOD.xlsx',data_output);
%% 年均AOD、各季AOD结果
r = 1;
for i = 1 : 250
    for j = 1 : 342
        AOD_a(r,1) = x(i,j);%经度
        AOD_a(r,2) = y(i,j);%纬度
        AOD_a(r,3) = mean(data_day(i,j,:),'omitnan')*0.001;%全年AOD
        AOD_a(r,4) = mean(data_day(i,j,60:151),'omitnan')*0.001;%春季AOD
        AOD_a(r,5) = mean(data_day(i,j,152:243),'omitnan')*0.001;%夏季AOD
        AOD_a(r,6) = mean(data_day(i,j,244:334),'omitnan')*0.001;%秋季AOD
        AOD_a(r,7) = (mean(data_day(i,j,1:59),'omitnan')*0.001...
             + mean(data_day(i,j,335:end),'omitnan')*0.001)/2;%冬季AOD
        r = r + 1;
    end
end
% xlswrite('2014年及各季AOD.xls',AOD_a);
disp('---------计算完毕------------')
