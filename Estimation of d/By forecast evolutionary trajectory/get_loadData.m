clear all
clc

GDP={'stable','rapid','slow'};

EVcharging={'public','home','work'};

AC={'baseline','iea'};

State={'Andhra Pradesh_', 'Arunachal Pradesh_','Assam_','Bihar_','Chhattisgarh_','Delhi_','Goa_','Gujarat_',...
    'Haryana_','Himachal Pradesh_','Jammu & Kashmir_','Jharkhand_','Karnataka_','Kerala_','Madhya Pradesh_',...
    'Maharashtra_','Manipur_','Meghalaya_','Mizoram_','Nagaland_','Odisha_','Punjab_','Rajasthan_','Sikkim_',...
    'Tamil Nadu_','Telangana_','Tripura_','Uttar Pradesh_','Uttarakhand_','West Bengal_'};

Year={'2020','2025','2030','2035','2040'};


A=zeros(365,8760);
for i_day=1:365
    i_hour=1+(i_day-1)*24;
    j_hour=24+(i_day-1)*24;
    A(i_day,i_hour:j_hour)=1;
end

%%
i_s=0;
for i_EV=1:3
    for i_AC=1:2
         for i_GDP=1:3
             
                i_s=i_s+1;        
                
              for i_year=1:5         
                    for i_state=1:30

                            folder_name=['/Users/chenyixuan/OneDrive - connect.hku.hk/【2】科研/【11】Tio_TENP/IEEE118/load_data_Indian',...
                                           '/', GDP{i_GDP},...
                                           '/', EVcharging{i_EV},...
                                           '/',AC{i_AC},...
                                           '/state',...
                                           '/', State{i_state},Year{i_year},'.csv'];


                                data=csvread(folder_name,1,1); 
                                data=abs(data);
                                load_hourly=sum(data,2);
                                %----from 8760 to 365---
                                load_daily0=A*load_hourly/24;
                                load_daily_allState(i_state,:)= load_daily0;
                                
                    end
                    ALL_load(i_s,i_year).load_daily_allState=load_daily_allState;
             end
              
                
          end
    end
end

save LoadData ALL_load

%% from 5 years' data to 20 years'
load SysPara_IEEE118 SysPara


for i_year=1:20
     loadDataYear=[];
    for i_s=1:18
        i_stage=ceil(i_year/5)+1;
%        [i_year, i_stage]
   
        load_year=ALL_load(i_s,i_stage).load_daily_allState;
        load_year=load_year';
        loadCF=load_year./max( load_year);
  
        
        loadCap= SysPara.Pd_years(:,i_year);
        loadData0=loadCF.*loadCap';
        loadDataYear=loadData0';
        
         loadData_years(i_year,i_s).loadDataYear=loadDataYear;
    end
end

 

save LoadData  loadData_years -append
            