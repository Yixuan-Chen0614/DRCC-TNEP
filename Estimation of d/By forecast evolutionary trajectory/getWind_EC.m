
clear all
clc
load GFDL_set  GFDL_set 
load SysPara_IEEE118 SysPara


ssptype={'126','245','585'};
yearList=[2020:1:2040];

% https://mnre.gov.in/wind/current-status/
loc=[
    23.20141888066118, 70.83265346619623;%Gujarat
    26.85462699319902, 73.27130513040322;%Rajasthan
    19.637521341830123, 75.6471540290107;%Maharashtra
    11.6799481303289, 78.72545260052638;%Tamil Nadu
    23.627115695073023, 77.20451772340385%Madhya Pradesh
    14.825797927412994, 75.62323902483054;%Karnataka
    14.961810373344214, 78.74400838816719;%Andhra Pradesh
];


%%

for i_year=1:20
    windspeed=[];
    for i_ssp=1:3

                
        % ====== -----read EC---========
        source=['sfcWind_day_EC-Earth3_ssp',ssptype{i_ssp},...
                      '_r1i1p1f1_gr_',...
                      num2str(yearList(i_year)),'0101-',...
                      num2str(yearList(i_year)),'1231.nc'];

        % finfo = ncinfo(source);

        lat_data=ncread(source,'lat');
        long_data=ncread(source,'lon');
        wind_data=ncread(source,'sfcWind');


                for j=1:3
                    for i=1:7
                        latt=loc(i,1);
                        longg=loc(i,2);

                        lat_disabs=abs(lat_data-latt);
                        long_disabs=abs(long_data-longg);


                        [~, grid_latSet]=sort(abs(lat_data-latt),'ascend');
                        [ ~, grid_longSet]=sort(abs(long_data-longg),'ascend');

                         windspeed_js=[];

                          grid_lat=grid_latSet(j);
                          grid_long=grid_longSet(j);
                          ws_j=squeeze(wind_data(grid_lat,grid_long,:));
                          windspeed(i,:)=ws_j;
                    end 


                    EC_set(i_ssp,i_year,j).windspeed=windspeed;
                    clearvars windspeed  
                end
         
    end
end
        

save EC_set EC_set
        
    
