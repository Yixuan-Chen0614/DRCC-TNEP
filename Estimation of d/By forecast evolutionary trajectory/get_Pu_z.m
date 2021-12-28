

clear all
clc
load GFDL_set  GFDL_set 
load('EC_set.mat', 'EC_set')
load SysPara_IEEE118  SysPara
load LoadData  loadData_years

%% meanings of index
% GDP={'stable','rapid','slow'};
% 
% EVcharging={'public','home','work'};
% 
% AC={'baseline','iea'};
% ssptype={'126','245','585'};
% GCM={'GDFL','EC3'};
% 
% 
%%   collecting index of different scenarios
i_s=0;

for i_EV=1:3
    for i_AC=1:2
         for i_GDP=1:3
                i_s=i_s+1;        
                load_scenario(i_s).i_EV= i_EV;
                load_scenario(i_s).i_AC=i_AC;
                load_scenario(i_s).i_GDP=i_GDP;
         end
    end
end
% index of climate scenario

 i_climate=0;
  for i_ssp=1:3
        for i_GCM=1:2
           i_climate=i_climate+1;
           climate_scenario( i_climate).i_ssp=i_ssp;
           climate_scenario( i_climate). i_GCM= i_GCM;
        end
  end
  
  %all scenario
      i_all_s=0;
    for i_s=1:18 % scenarios for load forecasting
        for i_climate=1:6 % scenarios for climate change
          
    
        i_all_s=i_all_s+1;
        
        all_scenario( i_all_s).i_EV=load_scenario(i_s).i_EV;
        all_scenario( i_all_s).i_AC= load_scenario(i_s).i_AC;
        all_scenario( i_all_s).i_GDP=load_scenario(i_s).i_GDP;
        all_scenario( i_all_s).i_ssp=climate_scenario( i_climate).i_ssp;
        all_scenario( i_all_s).i_GCM= climate_scenario( i_climate). i_GCM;
        end
    end
    
    select_index=[];
    ii=0;
    for i_all_s=1:108
       if all_scenario( i_all_s).i_ssp==1
          ii=ii+1;
          SSP(ii)=all_scenario( i_all_s);
          select_index=[select_index,i_all_s];
          
       end
    end

%% get wind data
for i_year=1:20
    i_climate=0;
    for i_ssp=1:3
        for i_GCM=1:2
            
               windspeed=[];
               for j=1 % three neighbors,  herein, only use the closet one           
                        if i_GCM==1
                            windspeed_GFDL=GFDL_set(i_ssp,j).windspeed;

                            day_i=1+(i_year-1)*365;
                            day_j=365+(i_year-1)*365;

                            windspeed0=windspeed_GFDL(:,day_i:day_j);
                        else
                            % ====== -----read EC---========        
                            windspeed0=EC_set(i_ssp,i_year,j).windspeed;
                        end
                        
                        % collect data of 3 neighbors of one windy state        
                        windspeed=[windspeed,windspeed0];
               end

                        i_climate=i_climate+1;
                        WindData_years(i_year,i_climate).windspeed=windspeed;

                        %% --from wind speed to wind power capacity factor (WindCF)
                        V_in=4;
                        V_out=22.22;
                        V_rate=10;

                        Aone=windspeed>=V_in;
                        WindCF=Aone.*windspeed;

                        Bone=WindCF<=V_out;
                        WindCF=Bone.*WindCF;    

                        WindCF=(WindCF-V_in)./(V_rate-V_in);
                        WindCF=max(WindCF,0);
                        WindCF=min(WindCF,1);    

                        %% from windCF to wind power
                        windCap=SysPara.windMax_years(:,i_year);
                        windPower=windCap.*WindCF;

                        WindData_years(i_year,i_climate).WindCF=WindCF;
                        WindData_years(i_year,i_climate).windPower=windPower;
                
               

        end
    end
    
end

%% get variable injection data: Pu=[PD;Pwind]
load('LoadData.mat', 'loadData_years')

for i_year=1:20
    i_all_s=0;
    for i_s=1:18 % scenarios for load forecasting
        for i_climate=1:6 % scenarios for climate change
          
    
        i_all_s=i_all_s+1;
        Pload=loadData_years(i_year,i_s).loadDataYear;
        Pwind=WindData_years(i_year,i_climate).windPower;
        Pwind=Pwind(:,1:365);

        Pu=[Pload;Pwind];

        %% normalization
        mean_Pu=mean(Pu');    
        std_Pu=std(Pu');
        cv_Pu=std_Pu./mean_Pu;
        
        L=chol(cov(Pu'));
        z00=(Pu'-mean_Pu)*inv(L);
     

        Pu_Data(i_year,i_all_s).Pu=Pu';
        Pu_Data(i_year,i_all_s).mean=mean_Pu;
        Pu_Data(i_year,i_all_s).std=std_Pu;
        Pu_Data(i_year,i_all_s).cv_Pu=cv_Pu;
        Pu_Data(i_year,i_all_s).z00=z00; % z every year every scenario
        
        % note! when we estimate the future pattern,  we should use the z
        % obtained in every year and every scenario
               
        end
    end

end
     save Pu_Data_2 Pu_Data
    
  
  
   







  
