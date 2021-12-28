clear all
clc
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

ssptype={'126','245','585'};
for i_ssp=1:3
    source=['sfcWind_day_GFDL-ESM4_ssp', ssptype{i_ssp}, '_r1i1p1f1_gr1_20150101-20341231.nc'];
    %finfo = ncinfo(source);

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
    
    
    GFDL_set(i_ssp,j).windspeed=windspeed;
    clearvars windspeed  
end
end
%% --from wind speed to wind power capacity factor



save GFDL_set  GFDL_set 


