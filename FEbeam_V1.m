
function RF_data_processing_GUI_EJ_V5
% 

global proc_window IV_full_fname_list;
IV_full_fname_list = {};

% Selecting raw data window and components
select_rawdat_window = figure('Visible','off','Position',[50,400,400,275],...
                'Name','Select Raw Data Files','NumberTitle','off');
rawdat_btn    = uicontrol(select_rawdat_window,'Style','pushbutton','String',...
             'Browse directory for raw data files','Position',[10,230,190,25],...
             'Callback',@browsedatafile_Callback);     
DirectoryLocationLabel = uicontrol(select_rawdat_window,"Style","text","Position",...
                [0,185,400,25],"String","Directory Location");            
rawdat_table = uicontrol(select_rawdat_window,"Style","listbox",...
                "Position",[10,40,370,150],"Max",100,"Min",2);
select_add_btn = uicontrol(select_rawdat_window,"Style","pushbutton",...
            "String","Select files and add from another directory",...
            "Position",[10,10,220,25],"Callback",@importdat_Callback);
select_done_btn = uicontrol(select_rawdat_window,"Style","pushbutton",...
            "Position",[230,10,125,25],"String",...
            "Select files and continue", "Callback",@importdat_Callback);
if_imaging_btn = uicontrol(select_rawdat_window,"Style","checkbox",...
            "String","Image Processing?", "Position",...
            [220,210,120,25],"Callback",@imageproc_Callback);
if_postpross_btn = uicontrol(select_rawdat_window,"Style","checkbox",...
            "String","Post Processing?", "Position",...
            [220,250,130,25],"Callback",@postpross_Callback);
        
% window to enter gradient values for post processing plotting
pp_gradient_window = figure("Visible","off","Position",[475,550,220,100],...
                    'Name','Datasets','NumberTitle','off');

pp_n_dats_txt = uicontrol(pp_gradient_window,"Style","text","String",...
                "Enter number of datasets:","Position",[5,70,140,25]);
pp_n_dats_val = uicontrol(pp_gradient_window,"Style","edit","Position",...
                [140,75,30,25],"Callback",@pp_n_dats_Callback);
pp_gradient_table = uitable('Parent',pp_gradient_window,'ColumnName',...
            "Gradient [MV/m]",'Position',[10 50 140 200],...
            'ColumnEditable',[true],...
            "Visible","off","RowName","numbered");
pp_gradients_done = uicontrol(pp_gradient_window,"Style","pushbutton",...
            "String","Done","Position",[170,5,50,25],"Visible","off",...
            "Callback",@postpross_Callback) 
        
function pp_n_dats_Callback(source,eventdata)
      set(pp_gradient_window,"Position",[475,350,220,300]);
      set(pp_n_dats_txt,"Position",[5,270,140,25]);
      set(pp_n_dats_val,"Position",[140,275,30,25]);
      n_rows = str2num(source.String);
      %t_data(1:n_rows,1) = {''};
      set(pp_gradient_table,"Data",zeros(n_rows,1));
      set(pp_gradient_table,"Visible","on");
      set(pp_gradients_done,"Visible","on");
      
    end
        
%functions for selecting raw data files window
rawfiles_list = {};
global rawpaths_list;
rawpaths_list = {};
    function browsedatafile_Callback(source,eventdata)        
        path=uigetdir;                    % Calls 'uigetdir' to obtain the directory location from the use     
        DirectoryLocationLabel.String=path;  % Sets the label text to be the selected path

        a=dir(path);                         % Obtains the contents of the selected path.
        b={a(:).name}';                      % Gets the name of the files/folders of the contents and stores them appropriately in a cell array
        b(ismember(b,{'.','..'})) = [];      % Removes unnecessary '.' and '..' results from the display.

        rawdat_table.String=b;                  % Displays the directory information to the UITable.
    end

    function importdat_Callback(source,eventdata)
        n_files = length(rawdat_table.Value);
        all_files = rawdat_table.String;
        selected = rawdat_table.Value;
        path = DirectoryLocationLabel.String;
        for i=1:(n_files)
            index = selected(i);
            
            rawpaths_list = [rawpaths_list, path];
            rawfiles_list = [rawfiles_list, all_files{index,1}];
        end
        
        if source == select_done_btn
            select_rawdat_window.Visible = "off";
            dat_info_window.Visible = "on";
        else
            rawdat_table.String=[];
        end
    end 

    function imageproc_Callback(source, eventdata)
        if source.Value == 1
            set(img_window,"Visible","on");
        else
            set(img_window,"Visible","off");
        end
    end
    function postpross_Callback(source, eventdata)
        if source == if_postpross_btn
            if source.Value == 1
                set(pp_gradient_window,"Visible","on");
                set(PP_window,"Visible","on");
            else
                set(pp_gradient_window,"Visible","off");
                set(PP_window,"Visible","off");
            end
        elseif source == pp_gradients_done
            set(pp_gradient_window, "Visible","off");
        end
    end

%datasets info window
dat_info_window = figure("Visible","off","Position",[475,550,300,100],...
                    'Name','Datasets Information','NumberTitle','off');

n_dats_txt = uicontrol(dat_info_window,"Style","text","String",...
                "Enter number of datasets:","Position",[5,70,140,25]);
n_dats_val = uicontrol(dat_info_window,"Style","edit","Position",...
                [140,75,30,25],"Callback",@n_dats_Callback);
dats_table = uitable('Parent',dat_info_window,'ColumnName',...
            {"Timestamp","Gradient [MV/m]"},'Position',[10 50 230 200],...
            'ColumnEditable',[true true],...
            "Visible","off","RowName","numbered");
done_dats_info = uicontrol(dat_info_window,"Style","pushbutton",...
            "String","Done","Position",[250,5,50,25],"Visible","off",...
            "Callback",@finish_datasets_info_Callback)

    function n_dats_Callback(source,eventdata)
      set(dat_info_window,"Position",[475,350,300,300]);
      set(n_dats_txt,"Position",[5,270,140,25]);
      set(n_dats_val,"Position",[140,275,30,25]);
      n_rows = str2num(source.String);
      set(dats_table,"Data",zeros(n_rows,2));
      set(dats_table,"Visible","on");
      set(done_dats_info,"Visible","on");
      
    end
    function finish_datasets_info_Callback(source,eventdata)
        dat_info_window.Visible = "off";
        set(proc_window, "Visible","on");

         end

%image processing window features
img_window = figure("Visible","off","Position",[50,100,260,200],...
                'Name','Image Processing','NumberTitle','off');             
select_img_btn = uicontrol(img_window,"Style","pushbutton",...
                "Position",[20,170,100,25],"String","Select image files",...
                "Callback",@select_img_file_Callback);
cbar_txt = uicontrol(img_window,"Style","text",...
                "Position",[70,130,120,25],"String","Set colorbar range",...
                "FontWeight","bold");
min_max_txt = uicontrol(img_window,"Style","text",...
                "Position",[40,115,180,25],"String",...
                "Minimum (10^3)  Maximum (10^4)");
yag_min = uicontrol(img_window,"Style","edit",...
                "Position",[60,100,60,20]);
yag_max = uicontrol(img_window,"Style","edit",...
                "Position",[130,100,60,20]);
yag2_min = uicontrol(img_window,"Style","edit",...
                "Position",[60,80,60,20]);
yag2_max = uicontrol(img_window,"Style","edit",...
                "Position",[130,80,60,20]);
yag3_ap0_min = uicontrol(img_window,"Style","edit",...
                "Position",[60,60,60,20]);
yag3_ap0_max = uicontrol(img_window,"Style","edit",...
                "Position",[130,60,60,20]);
yag3_ap1_min = uicontrol(img_window,"Style","edit",...
                "Position",[60,40,60,20]);
yag3_ap1_max = uicontrol(img_window,"Style","edit",...
                "Position",[130,40,60,20]);
yag_txt = uicontrol(img_window,"Style","text",...
                "Position",[10,95,40,20],"String","YAG1");
yag2_txt = uicontrol(img_window,"Style","text",...
                "Position",[10,75,40,20],"String","YAG2");
yag3_ap0_txt = uicontrol(img_window,"Style","text",...
                "Position",[0,55,60,20],"String","YAG3_AP0");
yag3_ap1_txt = uicontrol(img_window,"Style","text",...
                "Position",[0,35,60,20],"String","YAG3_AP1");
align([yag_txt,yag2_txt,yag3_ap0_txt,yag3_ap1_txt],"HorizontalAlignment",...
                "Right");
proc_img_btn = uicontrol(img_window,"Style","pushbutton",...
                "Position",[150,10,100,25],"String","Process and save",...
                "Callback",@proc_img);
            
            
 %post processing window features
PP_window = figure("Visible","off","Position",[50,100,500,200],...
                'Name','Post Processing','NumberTitle','off');
Plot_txt = uicontrol(PP_window,"Style","text",...
                "Position",[200,160,120,30],"String","Ploting Options",...
                "FontWeight","bold");
select_FN_btn = uicontrol(PP_window,"Style","pushbutton",...
                "Position",[20,10,100,25],"String","Select FN files",...
                "Callback",@select_FN_file_Callback);
select_LM_btn = uicontrol(PP_window,"Style","pushbutton",...
                "Position",[350,10,100,25],"String","Select LM files",...
                "Callback",@select_LM_file_Callback);            
QE_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","Q v.E curves", "Position",...
            [10,140,130,25]);
logQE_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","log(Q)v.(E)", "Position",...
            [10,120,130,25]);
Millikan_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","Millikan-Log(Q)v.(1/E)", "Position",...
            [10,100,130,25]);
Millikan_R2_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","Millikan R^2 v.E", "Position",...
            [10,80,130,25]);
Local_max_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","# of Local Maximums- LM v.E", "Position",...
            [10,60,175,25]); 
SC_F_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","Norm. F_SC-(Q/LM*E^2) v. E", "Position",...
            [10,40,175,25]);         
dc_QFN_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","DC FN-log(Q/E^2) v. (1/E)", "Position",...
            [180,140,150,25]);
dc_IFN_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","DC FN-log(I/E^2) v. (1/E)", "Position",...
            [180,120,150,25]); 
rf_QFN_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","RF FN-log(Q/E^2.5) v. (1/E)", "Position",...
            [180,100,150,25]);
rf_IFN_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","RF FN-log(I/E^2.5) v. (1/E)", "Position",...
            [180,80,150,25]);
FN_R2_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","FN plot fitting R^2 plot", "Position",...
            [180,60,130,25],"Callback",@postpross_Callback);
FN_R2E_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","FN R^2-R^2 v. E", "Position",...
            [180,40,130,25],"Callback",@postpross_Callback)
beta_Q_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","beta using Q v.E", "Position",...
            [350,140,150,25],"Callback",@postpross_Callback);
beta_I_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","beta using I v.E", "Position",...
            [350,120,150,25],"Callback",@postpross_Callback);
betaE_Q_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","E_l using Q v.E", "Position",...
            [350,100,150,25],"Callback",@postpross_Callback);
betaE_I_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","E_l using I v.E", "Position",...
            [350,80,150,25],"Callback",@postpross_Callback);
Ae_Q_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","A_e using Q v.E", "Position",...
            [350,60,150,25],"Callback",@postpross_Callback);
Ae_I_btn = uicontrol(PP_window,"Style","checkbox",...
            "String","A_e using I v.E", "Position",...
            [350,40,150,25],"Callback",@postpross_Callback);  
run_Pproc_btn = uicontrol(PP_window,"Style","pushbutton","Position",...
                [225,10,60,35],"String","Run","Callback",@Run_Post_control,...
                'BackgroundColor','r');        
     
%functions and processing for img processing window
    function select_img_file_Callback(source,eventdata)
        global img_file_name img_file_path;
         [img_file_name,img_file_path,~]=uigetfile({'*.dat'},...
            'MultiSelect','on','Select Info File');
    end

    function proc_img(source,eventdata)
        global img_file_name img_file_path;
        file_name = img_file_name;
        file_path = img_file_path;
        len_file=length(file_name);
        for k_file=1:len_file
            [Data,Frame,Dx,Dy]=func_highpower_read_image(file_path,file_name{k_file});
            name_loop=file_name{k_file};
            %fig =figure("Visible","off");imagesc(Data{1},[1000 65535]);
           
            if contains(file_name{k_file},"YAG3_AP0")
                Imin = str2double(yag3_ap0_min.String);
                Imax = str2double(yag3_ap0_max.String);
            elseif contains(file_name{k_file},"YAG3_AP1")
                Imin = str2double(yag3_ap1_min.String);
                Imax = str2double(yag3_ap1_max.String);
            elseif contains(file_name{k_file},"YAG2")
                Imin = str2double(yag2_min.String);
                Imax = str2double(yag2_max.String);
            elseif contains(file_name{k_file},"YAG1")
                Imin = str2double(yag_min.String);
                Imax = str2double(yag_max.String);
            end
            fig =figure("Visible","off");imagesc(Data{1},[Imin.*1e3 Imax.*1e4]);
            colorbar
            axis equal;
            axis off;
            idcs = strfind(file_path, filesep);
            save_path = strcat(file_path(1:idcs(end-1)-1),'\png\');
        
            save_filename = strcat(save_path,file_name{k_file}(1:end-4),'.png');
            saveas(fig,save_filename);
        end
    end

%functions and processing for post processing window
    function select_FN_file_Callback(source,eventdata)
        global FN_file_name FN_file_path;
         [FN_file_name,FN_file_path,~]=uigetfile({'*.mat'},...
            'MultiSelect','on','Select Info File');
    end
    function select_LM_file_Callback(source,eventdata)
        global LM_file_name LM_file_path;
         [LM_file_name,LM_file_path,~]=uigetfile({'*.txt'},...
            'MultiSelect','off','Select Info File');
    end
      function Run_Post_control(source,eventdata)
          global FN_file_name FN_file_path LM_file_name LM_file_path;
        % loading in gradient list
        pp_gradients = pp_gradient_table.Data(:,1);
        min_gradient = min(pp_gradients); % numeric values for plot
        max_gradient = max(pp_gradients);
        N_knee=0;
        Nmax=1e3;
        Fontsize=16;
        len_file=length(FN_file_name);
        for k_file=1:len_file %zzz
        filename=strcat(FN_file_path,FN_file_name{k_file});
        for n=1:length(pp_gradients)
            gradient_val_temp = pp_gradients(n);
            gradient_str_temp = num2str(gradient_val_temp);
            if contains(gradient_str_temp,'.') == 1
                idx_dec = strfind(gradient_str_temp,'.');             
                gradient_str_temp = gradient_str_temp(1:idx_dec+1);
            
            end 
            if contains(FN_file_name{k_file}, gradient_str_temp) == 1
                break  
            end
        end
        
        gradient_str = gradient_str_temp
        if contains(gradient_str,'.') == 1
            idx_dec = strfind(gradient_str,'.');
            phase_str = strcat('Phase',{' '},gradient_str(idx_dec+1))
            gradient_str = gradient_str(1:idx_dec-1);
        else
            phase_str = ' '
        end
        
        
        s=load(filename);
        sE=s.E;
        Emax(k_file)=max(sE);
        sC=s.C;
        Cmax(k_file)=max(sC);
        sI_ave=s.I_ave;
        sxxx=s.xxx;
        syyy=s.yyy;
        xxxMs=1./sE;
        yyyMs=log10(sC);
        test=fitlm(xxxMs,yyyMs);
        R2(k_file)=test.Rsquared.Ordinary;
        if QE_btn.Value==1
            N_EC=length(s.E);
            Z_EC=zeros(Nmax-N_EC,1);
            E(:,k_file)=cat(1,sE,Z_EC);
            C(:,k_file)=cat(1,sC,Z_EC);
        end
        if Millikan_btn.Value==1
            figure,plot(xxxMs,yyyMs,'*')
            set(gca,'FontSize',16)
            xlabel('1/E (nm/V)','FontSize',16)
            ylabel('log_{10}(Q)','FontSize',16)
            title(strcat('Millikan plot for E_h = ',gradient_str,{' '},'MV/m',{' '},phase_str))
            
        end
        if logQE_btn.Value==1
            figure,plot(sE./1e6,yyyMs,'*')
            set(gca,'FontSize',Fontsize)
            xlabel('E (MV/m)','FontSize',16)
            ylabel('log_{10} (Q) ','FontSize',16)
            title(strcat('Semi log of Q for E_h = ',gradient_str,{' '},'MV/m',{' '},phase_str))
        end
        if dc_IFN_btn.Value==1
            figure,plot(sxxx.*1e9,log10(sI_ave./sE.^2),'*')
            set(gca,'FontSize',Fontsize)
            xlabel('1/E (nm/V)','FontSize',16)
            ylabel('log_{10} (I/E^2) ','FontSize',16)
            title(strcat('DC Fowler-Nordeheim (IE corr.) for E_h = ',gradient_str,{' '},'MV/m',{' '},phase_str))
        end
        if dc_QFN_btn.Value==1
            figure,plot(sxxx.*1e9,log10(sC./sE.^2),'*')
            set(gca,'FontSize',Fontsize)
            xlabel('1/E (nm/V)','FontSize',16)
            ylabel('log_{10} (I/E^2) ','FontSize',16)
            title(strcat('DC Fowler-Nordeheim (QE corr.) for E_h = ',gradient_str,{' '},'MV/m',{' '},phase_str))
        end   
        if rf_IFN_btn.Value==1
            figure,plot(sxxx.*1e9,syyy,'*')
            hold on
            set(gca,'FontSize',Fontsize)
            xlabel('1/E (nm/V)','FontSize',16)
            ylabel('log_{10} (I/E^2) ','FontSize',16)
            title(strcat('RF Fowler-Nordeheim (IE corr.)for E_h = ',gradient_str,{' '},'MV/m',{' '},phase_str))
            if s.knee_location>0
            y2 = get(gca,'ylim');
            plot([s.knee_location.*1e9 s.knee_location.*1e9],y2,'g-')
            end
        end
        if rf_QFN_btn.Value==1
            figure,plot(sxxx.*1e9,log10(sC./sE.^(2.5)),'*')
            hold on
            set(gca,'FontSize',Fontsize)
            xlabel('1/E (nm/V)','FontSize',16)
            ylabel('log_{10} (I/E^2) ','FontSize',16)
            title(strcat('RF Fowler-Nordeheim in (QE corr.) for E_h = ',gradient_str,{' '},'MV/m',{' '},phase_str))
            if s.knee_location>0
            y2 = get(gca,'ylim');
            plot([s.knee_location.*1e9 s.knee_location.*1e9],y2,'g-')
            end
        end 
        if FN_R2_btn.Value==1
            figure,plot(s.r2_x,s.firstr2,'r-','LineWidth',2)
            hold on;
            plot(s.r2_x,s.secondr2,'k-','LineWidth',2)
            
            ylims_r2 = get(gca,'ylim');
            hold on;
            plot([s.knee_location,s.knee_location],ylims_r2,'g-','LineWidth',2);
            ylim(ylims_r2);
            title(strcat("Iterations Linearly fit for Applied Field of ",gradient_str,{' '},'MV/m',{' '},phase_str)); 
            xlabel('Knee Location 1/E [m/V]','FontSize',Fontsize)
            ylabel('R^2 Value','FontSize',Fontsize)
        end
            if s.knee_location>0
                N_knee=N_knee+1;
               secondr2_range(k_file)=range(s.secondr2);        
               firstr2_range(k_file)=range(s.firstr2); 
               fitting_results_high(:,k_file)=(s.fitting_results_high).';
               fitting_results_low(:,k_file)=(s.fitting_results_low).';
%                fitting_results_high_Q(:,k_file)=(s.fitting_results_high_QE).';
%                fitting_results_low_Q(:,k_file)=(s.fitting_results_low_QE).';
               Emax_low(:,k_file)=max(sE);
               Emax_high(:,k_file)=max(sE);
            elseif s.knee_location==0
                N_knee=N_knee;
               fitting_results_high(:,k_file)=[];
               fitting_results_low(:,k_file)=(s.fitting_results).';
%                fitting_results_high_Q(:,k_file)=[];
%                fitting_results_low_Q(:,k_file)=(s.fitting_results_QE).';
               Emax_low(:,k_file)=max(sE);
               Emax_high(:,k_file)=[];
            end

        end
            if QE_btn.Value == 1
                figure,plot(E./1e6,C.*1e9,'*')
                xlabel('Applied RF Field (MV/m)','FontSize',Fontsize)
                ylabel('Charge (nC)','FontSize',Fontsize)
                title('Q-E Curves')
                set(gca,'FontSize',Fontsize)
                xlim([min_gradient-5 max_gradient+5])
            end
            if N_knee==0
            if beta_I_btn.Value==1
                Beta_L=fitting_results_low(1,:);
                del_beta_L=fitting_results_low(3,:)-fitting_results_low(1,:);
                figure,errorbar(Emax_low/1e6,Beta_L,del_beta_L,'b*')
                xlabel('Applied RF Field (MV/m)','FontSize',Fontsize)
                set(gca,'FontSize',Fontsize)
                ylabel('field enhancement factor{\beta}','FontSize',Fontsize)
                title('field enhancement factor (IE corr.)')
            end
            if betaE_I_btn.Value==1
                BetaE_L=fitting_results_low(4,:);
                del_betaE_L=fitting_results_low(6,:)-fitting_results_low(4,:);
                figure,errorbar(Emax_low/1e6,BetaE_L/1e9,del_betaE_L/1e9,'b*')
                xlabel('Applied RF Field (MV/m)','FontSize',Fontsize)
                set(gca,'FontSize',Fontsize)
                ylabel('Field on Cathode Surface (GV/m)','FontSize',Fontsize)
                title('Field on Cathode Surface (IE corr.)')
            end
            if Ae_I_btn.Value==1
                Ae_L=fitting_results_low(7,:);
                figure,semilogy(Emax/1e6,Ae_L*1e18,'b')
                set(gca,'FontSize',Fontsize)
                xlabel('Applied RF Feild (MV/m)','FontSize',Fontsize)
                ylabel('Effective Emission Area (nm^2)','FontSize',Fontsize)
                title('Effective Emission Area (IE corr.) 12')
            end
%             if beta_Q_btn.Value==1
%                 Beta_L=fitting_results_low_Q(1,:);
%                 del_beta_L=fitting_results_low_Q(3,:)-fitting_results_low_Q(1,:);
%                 figure,errorbar(Emax_low/1e6,Beta_L,del_beta_L,'b*')
%                 xlabel('Applied RF Field (MV/m)','FontSize',Fontsize)
%                 set(gca,'FontSize',Fontsize)
%                 ylabel('field enhancement factor{\beta}','FontSize',Fontsize)
%                 title('field enhancement factor (QE corr.)')
%             end
%             if betaE_Q_btn.Value==1
%                 BetaE_L=fitting_results_low_Q(4,:);
%                 del_betaE_L=fitting_results_low_Q(6,:)-fitting_results_low_Q(4,:);
%                 figure,errorbar(Emax_low/1e6,BetaE_L/1e9,del_betaE_L/1e9,'b*')
%                 xlabel('Applied RF Feild (MV/m)','FontSize',Fontsize)
%                 set(gca,'FontSize',Fontsize)
%                 ylabel('Feild on Cathode Surface (GV/m)','FontSize',Fontsize)
%                 title('Feild on Cathode Surface (QE corr.)')
%             end
%             if Ae_Q_btn.Value==1
%                 Ae_L=fitting_results_low_Q(7,:);
%                 figure,semilogy(Emax_low/1e6,Ae_L*1e18,'b')
%                 set(gca,'FontSize',Fontsize)
%                 xlabel('Applied RF Feild (MV/m)','FontSize',Fontsize)
%                 ylabel('Effective Emission Area (nm^2)','FontSize',Fontsize)
%                 title('Effective Emission Area (QE corr.) 12')
%             end
            else
            if beta_I_btn.Value==1
                Beta_L=fitting_results_low(1,:);
                del_beta_L=fitting_results_low(3,:)-fitting_results_low(1,:);
                Beta_H=fitting_results_high(1,:);
                del_beta_H=fitting_results_high(3,:)-fitting_results_high(1,:);
                figure,errorbar(Emax_low/1e6,Beta_L,del_beta_L,'b*')
                hold on
                errorbar(Emax_high/1e6,Beta_H,del_beta_H,'r*')
                xlabel('Applied RF Field (MV/m)','FontSize',Fontsize)
                set(gca,'FontSize',Fontsize)
                ylabel('field enhancement factor{\beta}','FontSize',Fontsize)
                legend({'Fowler Nordheim','non-Fowler Nordheim'},'FontSize',10)
                title('field enhancement factor (IE corr.)')
            end
            if betaE_I_btn.Value==1
                BetaE_L=fitting_results_low(4,:);
                del_betaE_L=fitting_results_low(6,:)-fitting_results_low(4,:);
                BetaE_H=fitting_results_high(4,:);
                del_betaE_H=fitting_results_high(6,:)-fitting_results_high(4,:);
                figure,errorbar(Emax_low/1e6,BetaE_L/1e9,del_betaE_L/1e9,'b*')
                hold on
                errorbar(Emax_high/1e6,BetaE_H/1e9,del_betaE_H/1e9,'r*')
                xlabel('Applied RF Field (MV/m)','FontSize',Fontsize)
                set(gca,'FontSize',Fontsize)
                ylabel('Field on Cathode Surface (GV/m)','FontSize',Fontsize)
                legend({'Fowler Nordheim','non-Fowler Nordheim'},'FontSize',10)
                title('Field on Cathode Surface (IE corr.)')
            end
            if Ae_I_btn.Value==1
                Ae_H=fitting_results_high(7,:);
                Ae_L=fitting_results_low(7,:);
                figure,semilogy(Emax/1e6,Ae_L*1e18,'b*')
                hold on
                set(gca,'FontSize',Fontsize)
                semilogy(Emax/1e6,Ae_H*1e18,'r*')
                xlabel('Applied RF Feild (MV/m)','FontSize',Fontsize)
                ylabel('Effective Emission Area (nm^2)','FontSize',Fontsize)
                legend({'Fowler Nordheim','non-Fowler Nordheim'},'FontSize',10)
                title('Effective Emission Area (IE corr.) 12')
            end
%             if beta_Q_btn.Value==1
%                 Beta_L=fitting_results_low_Q(1,:);
%                 del_beta_L=fitting_results_low_Q(3,:)-fitting_results_low_Q(1,:);
%                 Beta_H=fitting_results_high_Q(1,:);
%                 del_beta_H=fitting_results_high_Q(3,:)-fitting_results_high_Q(1,:);
%                 figure,errorbar(Emax_low/1e6,Beta_L,del_beta_L,'b*')
%                 hold on
%                 errorbar(Emax_high/1e6,Beta_H,del_beta_H,'r*')
%                 xlabel('Applied RF Field (MV/m)','FontSize',Fontsize)
%                 set(gca,'FontSize',Fontsize)
%                 ylabel('field enhancement factor{\beta}','FontSize',Fontsize)
%                 legend({'Fowler Nordheim','non-Fowler Nordheim'},'FontSize',10)
%                 title('field enhancement factor (QE corr.)')
%             end
%             if betaE_Q_btn.Value==1
%                 BetaE_L=fitting_results_low_Q(4,:);
%                 del_betaE_L=fitting_results_low_Q(6,:)-fitting_results_low_Q(4,:);
%                 BetaE_H=fitting_results_high_Q(4,:);
%                 del_betaE_H=fitting_results_high_Q(6,:)-fitting_results_high_Q(4,:);
% 
%                 figure,errorbar(Emax_low/1e6,BetaE_L/1e9,del_betaE_L/1e9,'b*')
%                 hold on
%                 errorbar(Emax_high/1e6,BetaE_H/1e9,del_betaE_H/1e9,'r*')
%                 xlabel('Applied RF Feild (MV/m)','FontSize',Fontsize)
%                 set(gca,'FontSize',Fontsize)
%                 ylabel('Feild on Cathode Surface (GV/m)','FontSize',Fontsize)
%                 legend({'Fowler Nordheim','non-Fowler Nordheim'},'FontSize',10)
%                 title('Feild on Cathode Surface (QE corr.)')
%             end
%             if Ae_Q_btn.Value==1
%                 Ae_H=fitting_results_high_Q(7,:);
%                 Ae_L=fitting_results_low_Q(7,:);
%                 figure,semilogy(Emax_low/1e6,Ae_L*1e18,'b*')
%                 hold on
%                 set(gca,'FontSize',Fontsize)
%                 semilogy(Emax_high/1e6,Ae_H*1e18,'r*')
%                 xlabel('Applied RF Feild (MV/m)','FontSize',Fontsize)
%                 ylabel('Effective Emission Area (nm^2)','FontSize',Fontsize)
%                 legend({'Fowler Nordheim','non-Fowler Nordheim'},'FontSize',10)
%                 title('Effective Emission Area (QE corr.) 12')
%             end
            end
            if FN_R2E_btn.Value==1
               figure,plot(Emax_low./1e6,firstr2_range,'k*')
               hold on
               fugure,plot(Emax_high./1e6,secondr2_range,'r*')
               set(gca,'FontSize',Fontsize)
               xlabel('Applied RF Feild (MV/m)','FontSize',Fontsize)
               ylabel('Fowler Nordheim R^2 Range','FontSize',Fontsize)
               legend({'non-Fowler Nordheim','Fowler Nordheim'},'FontSize',10)
               title('Fowler Nordheim R^2 Range IE corr.) 12')
            end
            if Millikan_R2_btn.Value==1
                figure,plot(Emax.*1e-6,R2,'k*')
                set(gca,'FontSize',Fontsize)
                xlabel('E_h (MV/m)','FontSize',16)
                ylabel('R^2','FontSize',16)
                title('Millikan plot R^2')
            end
            if Local_max_btn.Value==1 | SC_F_btn.Value==1
                filename=strcat(LM_file_path,LM_file_name);
                LM_mat=readmatrix(filename);
                LM=LM_mat(:,2);
                if Local_max_btn.Value==1
                plot(Emax/1e6,LM,'g')
                xlabel('Applied RF Feild (MV/m)','FontSize',Fontsize)
                ylabel('Number of local maximums','FontSize',Fontsize)
                title('Local Maximums from Image Processing')    
                end
                if SC_F_btn.Value==1
                F_sc=Cmax./(LM.*Emax.^2);
                F_sc_max=max(F_sc);
                norm_F_sc=F_sc./F_sc_max;
                figure,plot(Emax.*1e-6,norm_F_sc,'k*')
                set(gca,'FontSize',Fontsize)
                xlabel('E_h (MV/m)','FontSize',16)
                ylabel('Normalize Space Charge Force','FontSize',16)
                title('Normalize Space Charge Force')    
                end
            end

            
      end

%main processing window
proc_window = figure("Visible","off","Position",[475,470,350,190],...
                'Name','FEbeam','NumberTitle','off');
charge_btn(1) = uicontrol(proc_window,"Style","radiobutton",...
                'String','Low charge', "Position",[10,160,100,25],...
                "Callback", @charge_Callback, "Value",0);
charge_btn(2) = uicontrol(proc_window,"Style","radiobutton",...
                'String','High charge', "Position",[10,135,100,25],...
                "Callback", @charge_Callback, "Value",0);
slct_params_btn = uicontrol(proc_window,"Style","pushbutton",...
                "Position",[110, 160,135,25], "String",...
                "Select parameters data file", "Callback", ...
                @select_params_Callback,"Visible","off");
timeconst_btn = uicontrol(proc_window,"Style","pushbutton",...
                "Position",[110,135,145,25],"String",...
                "Select time constant data file","Callback",...
                @select_timeconst_Callback, "Visible","off");
lowcharge_set_params_btn = uicontrol(proc_window,"Style","pushbutton",...
                "Position",[260,160,80,25],"String","Set parameters",...
                "Callback",@set_params_Callback, "Visible","off");
highcharge_set_params_btn = uicontrol(proc_window,"Style","pushbutton",...
                "Position",[260,160,80,25],"String","Set parameters",...
                "Callback",@set_params_Callback, "Visible","off");
line = uicontrol(proc_window,"Style","text","String",...
  "__________________________________________________________________________",...
    "Position",[0,123,350,13]);            
workfunction_txt = uicontrol(proc_window,"Style","text",...
                "Position",[10,90,150,25],...
                "String","Enter workfunction value [eV]: ");
workfunction_val = uicontrol(proc_window,"Style","edit","Position",[160,100,20,20]);
tshift_txt = uicontrol(proc_window,"Style","text",...
                "Position",[180,90,150,25],...
                "String","Enter time shift: ");
t_shift_val = uicontrol(proc_window,"Style","edit","Position",[300,100,50,20]);
rf_envelope_btn = uicontrol(proc_window,"Style","pushbutton","Position",...
                [10,40,140,25],"String","Select RF Envelope file", ...
                "Callback",@slct_rf_envelope_Callback);
rf_filter_btn = uicontrol(proc_window,"Style","pushbutton","Position",...
                [10,70,140,25],"String","Select RF Filter file", ...
                "Callback",@slct_rf_filter_Callback);
run_proc_btn = uicontrol(proc_window,"Style","pushbutton","Position",...
                [270,10,60,25],"String","Run","Callback",@run_proc_Callback,...
                'BackgroundColor','r');

    function charge_Callback(source,eventdata)
        
        global charge;
        
        otherRadio = charge_btn(charge_btn ~= source);
        if source.Value == 0 & otherRadio.Value == 0
            set(slct_params_btn,"Visible","off");
            set(timeconst_btn,"Visible","off");
            set(highcharge_set_params_btn,"Visible","off");
            set(lowcharge_set_params_btn,"Visible","off");
        else
            set(otherRadio, 'Value', 0);
            set(slct_params_btn,"Visible","on");
        
        end
        charge = get(source, "String");
        if contains(source.String,'Low')==1
            set(timeconst_btn, "Visible","on");
            set(lowcharge_set_params_btn,"Visible","on");
            set(highcharge_set_params_btn,"Visible","off");
        else
            set(timeconst_btn,"Visible","off");
            set(highcharge_set_params_btn,"Visible","on");
            set(lowcharge_set_params_btn,"Visible","off");
        end 
              
    end
    function select_params_Callback(source, eventdata)
        global info_fname_params fpath_params;
        
        [file_name_params,file_path_params,~]=...
        uigetfile({'*.csv','All Files (*.csv)'},'MultiSelect','off',...
        'Select file to set parameters with');
    
        fprintf('%s  ',file_name_params);
        [fpath_params, info_fname_params] = func_highpower_read_csv(file_path_params,file_name_params);
        fprintf('\n');
        
        
    end

    function select_timeconst_Callback(source,eventdata)
        global info_timeconst pathname_timeconst filename_timeconst ;
        
        [filename_timeconst, pathname_timeconst, ~] = uigetfile({'*.mat','All Files (*.mat)'},...
        'MultiSelect','off','Select Time Data File');
        full_filename_timeconst=strcat(pathname_timeconst,filename_timeconst);
        info_timeconst=load(full_filename_timeconst);
        set(FC_settings_window, "Visible","on");
        make_initial_FC_plots(pathname_timeconst,filename_timeconst);
        
    end
    function make_initial_FC_plots(path, fname)
        global info_timeconst;
        info = info_timeconst;
        [len,N_channel]=size(info.info{1,1}.info_Ch);
        figure(plot_window);
        for k=1:N_channel
            subplot(2,2,k),plot(info.info{1}.info_Ch(:,k));
            grid on;
            title(strcat('Ch ',num2str(k)));
        end
        for k=N_channel+1:4
            subplot(2,2,k);
            title(strcat('Ch',num2str(k)));
        end
    end
    function set_params_Callback(source,eventdata)
        global info_fname_params fpath_params charge;
        
        params_settings_window.Visible = "on";
        
        make_initial_plots(fpath_params,info_fname_params);
    end
    function slct_rf_envelope_Callback(source,eventdata)
        global rf_env_fname rf_env_fpath;
        [rf_env_fname,rf_env_fpath,~]=uigetfile({'*.dat','All Files (*.mat)'},...
        'Select RF Envelope File');
    end
    function slct_rf_filter_Callback(source,eventdata)
        global rf_filt_fname rf_filt_fpath;
        [rf_filt_fname,rf_filt_fpath,~]=uigetfile({'*.mat','All Files (*.mat)'},...
        'Select RF Filter File');
    end  
   
    function run_proc_Callback(~,~)
        global rf_env_fname rf_env_fpath rf_filt_fname rf_filt_fpath;
        disp('RUNNING');
        EC_info_path_list = {};
        EC_info_file_list = {};
        
        for n=1:length(rawfiles_list)
            [fpath, info_fname] = func_highpower_read_csv(rawpaths_list{n},rawfiles_list{n});
            [EC_info_path, EC_info_fname] = apply_settings_Lecroy_K4(fpath, info_fname);
            EC_info_path_list = [EC_info_path_list, EC_info_path];
            EC_info_file_list = [EC_info_file_list, EC_info_fname];
        end
        
        timestamps = dats_table.Data(:,1);
        gradients = dats_table.Data(:,2);
        
        for n=1:length(timestamps)
            grad_EC_path_list = {};
            grad_EC_file_list = {};
            
            stamp = timestamps(n);
            grad = gradients(n);
            grad_rep = strcat('G',num2str(grad),'MVm');
            
            for i=1:length(EC_info_file_list)
                current_file = EC_info_file_list(i);
                current_path = EC_info_path_list(i);
                if contains(current_file, grad_rep) == 1
                    grad_EC_path_list = [grad_EC_path_list,current_path];
                    grad_EC_file_list = [grad_EC_file_list,current_file];
                end
            end

            combine_EC(grad_EC_path_list, grad_EC_file_list,grad);
        end
        
        % RF envelope and filter processing
        % originally from main_highpower_cal_FE_rf_pulse_K4
        global phi betaE t_duration pathname_timeconst;
        phi = str2double(workfunction_val.String);
        t_shift = str2double(t_shift_val.String);
        env_full_fname = strcat(rf_env_fpath, rf_env_fname);
        filt_full_fname = strcat(rf_filt_fpath, rf_filt_fname);
        
        info = load(env_full_fname);
        s = load(filt_full_fname);
        
%         t_shift=2.0; % for 20GHz
        t_shift=16.0; % for 10 GHz
        
        betaE=(0.5:0.1:50)*1e9;
        len_E=length(betaE);
        %t_duration=zeros(len_E,1);
        t_duration=zeros(1,len_E);
        
        dt=mean(diff(info(:,1)));

        len=length(info(:,2));
        time=(0:1:len-1)*dt;
        signal=conv(info(:,2),s.Num);
        signal=signal(1:len);
        
        info_env=func_highpower_cal_rf_envelope(signal,50);
        info_env_smooth=smooth(info_env,10000);
        [E_max,pos]=max(info_env_smooth);

        for k=1:len_E
            EE=info_env_smooth/E_max*betaE(k);
            E_t(:,k)=EE;
            I_mean=EE.^2.5.*exp(-6.53e9*phi^1.5./EE);
            I_mean=I_mean/max(I_mean);
            t_duration(k)=trapz(info(:,1),I_mean);
        end
        path = rawpaths_list{1};
        clf(plot_window,"reset");
        figure(plot_window); set(plot_window,"Visible","off");
        hold on;
        plot(time*1e6-t_shift,info(:,2),'b');
        plot(time*1e6-t_shift,info_env_smooth(1:len),'r','Linewidth',12);
        xlabel('Time ({\mu}s)');
        xlim([-1 18]);
        
        idcs = strfind(path, filesep);
        save_path = strcat(path(1:idcs(end-1)-1),'\figures\');
        save_filename = strcat(save_path,"RF_envelope.png");
        saveas(plot_window,save_filename);

        clf(plot_window,"reset");
        figure(plot_window); set(plot_window,"Visible","off");
        hold on;
        box on;
        plot(betaE/1e9,t_duration*1e6,'b');
        xlabel('{\beta}E_{c,max} (GV/m)');
        ylabel('{\tau} ({\mu}s)');
        xlim([0.5 50]);
        
        save_filename = strcat(save_path, "pulse_length.png");
        saveas(plot_window,save_filename);
        
        proc_window.Visible = 'off';
        view_FN_plot.String = dats_table.Data(:,2);
                
        FN_option_window.Visible = 'on';
        
        make_FN_plots_knee(0,0)
    end
    function make_FN_plots_knee(~,~)
        global  phi t_duration betaE knee_loc;
        one_knee.Value = 1;
        no_knee.Value = 0;
        num_knee_Callback(1,0);
        grad_index = view_FN_plot.Value;
        gradient = view_FN_plot.String(grad_index,:);
%         disp('grad index');
%         disp(grad_index);
%         disp('class of view_FN_plot string ');
%         disp(class(view_FN_plot.String));
%         disp('view_FN.plot.string(grad_index,:)');
%         disp(view_FN_plot.String(grad_index,:));
        
        for i=1:length(IV_full_fname_list)
            current_IV_file = IV_full_fname_list{i};
            %disp(current_IV_file);
            if contains(current_IV_file,gradient)==1
                s = load(current_IV_file);
            end
        end
        
        % n_cut_high=input('BD numbers to cut: ');
        n_cut_high=0;
        if n_cut_high>0

        %     E_mid=s.E_mid;
            E_mid=s.E;
            C=s.C;
            index=find(isnan(E_mid));
            E_mid(index)=[];
            C(index)=[];   
            [C,index_order]=sort(C);
            E_mid=E_mid(index_order);
            n=length(E_mid);
            E_mid=E_mid(1:n-n_cut_high);
            C=C(1:n-n_cut_high);
        else
            E_mid=s.E;
            C=s.C;
            index=find(isnan(E_mid));
            E_mid(index)=[];
            C(index)=[];
        end
        
        yyy=log10(C./(E_mid.^2.5));
        xxx=1./E_mid;
        
        xxx_py = py.list(xxx);
        yyy_py = py.list(yyy);
        
        results = py.kneefx.find_knee(xxx_py,yyy_py);
        knee_loc = results{1};
        x_fit1 = double(results{2});
        x_fit2 = double(results{3});
        y_fit_1 = double(results{4});
        y_fit_2= double(results{5});
        firstr2 = double(results{6});
        secondr2 = double(results{7});
        r2_x = double(results{8});
        
        E = E_mid;
        x_boundary_l = min(xxx)-0.05e-8;
        x_boundary_r = knee_loc;
        x_boundary_high = [x_boundary_l,x_boundary_r];
        [fitting_results_high,E,I_ave_high_temp]=...
            func_highpower_cal_beta_EC_I_K4(E,C,phi,x_boundary_high,betaE,t_duration);
        index=find((xxx>=x_boundary_high(1))&(xxx<=x_boundary_high(2)));
        I_ave_high=I_ave_high_temp(index);
        X=xxx(index);
        Y=yyy(index);

        coe=fit(X,Y,'poly1');
        conf_95=confint(coe,0.95);
        QE_beta=-6.53e9*log10(exp(1))*phi^(1.5)/coe.p1;
        QE_betaE=QE_beta*max(E);
        QE_beta_low=-6.53e9*log10(exp(1))*phi^(1.5)/conf_95(1,1);
        QE_beta_high=-6.53e9*log10(exp(1))*phi^(1.5)/conf_95(2,1);
        QE_betaE_low=QE_beta_low*max(E);
        QE_betaE_high=QE_beta_high*max(E);
        QE_area=10^(coe.p2-2.5*log10(beta)-log10(5.7e-12*10^(4.52*phi^(-0.5))/...
            phi^(1.75)));
        QE_area_low=10^(conf_95(1,2)-2.5*log10(beta)-...
            log10(5.7e-12*10^(4.52*phi^(-0.5))/phi^(1.75)));
        QE_area_high=10^(conf_95(2,2)-2.5*log10(beta)-...
            log10(5.7e-12*10^(4.52*phi^(-0.5))/phi^(1.75)));
        fitting_results_high_QE=[QE_beta,QE_beta_low,QE_beta_high,QE_betaE,QE_betaE_low,...
            QE_betaE_high,QE_area,QE_area_low,QE_area_high];
        
        x_boundary_l = knee_loc;
        x_boundary_r = max(xxx)+0.05e-8;
        x_boundary_low = [x_boundary_l,x_boundary_r];
        [fitting_results_low,E,I_ave_low_temp]=...
            func_highpower_cal_beta_EC_I_K4(E,C,phi,x_boundary_low,betaE,t_duration);
        index=find((xxx>=x_boundary_low(1))&(xxx<=x_boundary_low(2)));
        I_ave_low=I_ave_low_temp(index);
    %disp('index');
    %disp(index);
        X=xxx(index);
        Y=yyy(index);

        coe=fit(X,Y,'poly1');
        conf_95=confint(coe,0.95);
        QE_beta=-6.53e9*log10(exp(1))*phi^(1.5)/coe.p1;
        QE_betaE=QE_beta*max(E);
        QE_beta_low=-6.53e9*log10(exp(1))*phi^(1.5)/conf_95(1,1);
        QE_beta_high=-6.53e9*log10(exp(1))*phi^(1.5)/conf_95(2,1);
        QE_betaE_low=QE_beta_low*max(E);
        QE_betaE_high=QE_beta_high*max(E);
        QE_area=10^(coe.p2-2.5*log10(beta)-log10(5.7e-12*10^(4.52*phi^(-0.5))/...
            phi^(1.75)));
        QE_area_low=10^(conf_95(1,2)-2.5*log10(beta)-...
            log10(5.7e-12*10^(4.52*phi^(-0.5))/phi^(1.75)));
        QE_area_high=10^(conf_95(2,2)-2.5*log10(beta)-...
            log10(5.7e-12*10^(4.52*phi^(-0.5))/phi^(1.75)));
        fitting_results_low_QE=[QE_beta,QE_beta_low,QE_beta_high,QE_betaE,QE_betaE_low,...
            QE_betaE_high,QE_area,QE_area_low,QE_area_high];
        I_ave = cat(1,I_ave_high,I_ave_low);
        knee_location=knee_loc;
        path = rawpaths_list{1};
        idcs = strfind(path, filesep);
        save_path = strcat(path(1:idcs(end-1)-1),'\FN data\');
        FN_save_filename = strcat(save_path,'FN_',gradient,'MVm.mat');
        save(FN_save_filename,'xxx','yyy','x_fit1','x_fit2','y_fit_1','y_fit_2',...
                'firstr2','secondr2','r2_x','C','E','I_ave','fitting_results_low',...
                'fitting_results_high','fitting_results_low_QE','fitting_results_high_QE','knee_location');
        
        Fontsize=14;
        Linewidth=2;
        
        clf(FN_plot_window,"reset");
        FN_plot_window.Name = "FN Plot";
        FN_plot_window.NumberTitle = "off";
        clf(Rsq_plot_window,"reset");
        Rsq_plot_window.Name = "R-squared Plot";
        Rsq_plot_window.NumberTitle = "off";
        
        figure(FN_plot_window)
        plot(xxx,yyy,'*')
        hold on
        set(gca,'Fontsize',Fontsize);
        xlabel(' 1/E (m/V)','Fontsize',Fontsize)
        ylabel('Log_{10} (I/E^{2.5})','Fontsize',Fontsize)
        hold on
        plot(x_fit1,y_fit_1,'r-','LineWidth',Linewidth)
        plot(x_fit2,y_fit_2,'k-','LineWidth',Linewidth)
        title(strcat("FN Plot: Applied Field of ",gradient,' MV/m'))
        hold on
        y1=get(gca,'ylim');
        plot([knee_loc knee_loc],y1,'g-')
        axis_lims_table.Data(:,2) = ylim;
        axis_lims_table.Data(:,1) = xlim;
        
        figure(Rsq_plot_window);
        plot(r2_x,firstr2,'r-','LineWidth',2)
        hold on;
        plot(r2_x,secondr2,'k-','LineWidth',2)
        ylims_r2 = get(gca,'ylim');
        hold on;
        plot([knee_loc,knee_loc],ylims_r2,'g-','LineWidth',Linewidth)
        ylim(ylims_r2);
        title(strcat("Iterations Linearly fit for Applied Field of ",gradient,' MV/m')); 
        xlabel('Knee Location 1/E [m/V]','FontSize',Fontsize)
        ylabel('R^2 Value','FontSize',Fontsize)
        %text(knee_loc,min(firstr2),['Knee: ',num2str(knee_loc)])
        axis_lims_table.Data(:,3) = xlim;
        axis_lims_table.Data(:,4) = ylim;
        
    end
    function [EC_info_path, EC_info_fname] = apply_settings_Lecroy_K4(fpath, fname)
        global charge settings;
        filename = strcat(fpath,fname);
        s = load(filename);
        if charge == "Low charge"
            ch_forward_val=settings(1);
            ch_backward_val=settings(2);
            ch_FC_val=settings(3);
            k_background_FP_val=settings(4);
            k_background_BP_val=settings(5);
            k_background_FC_val=settings(6);
            k_range_FC_L_val=settings(7);
            k_range_FC_R_val=settings(8);
            tao_ms=settings(9);
            att_waveguide_val=settings(10);
            att_forward_val=settings(11);
            att_backward_val=settings(12);
            factor_power_val=settings(13);
            
            FP=s.info{1}.info_Ch(:,ch_forward_val);
            FB=s.info{1}.info_Ch(:,ch_backward_val);
            FC=s.info{1}.info_Ch(:,ch_FC_val);
            FP=FP-mean(FP(1:k_background_FP_val));
            FB=FB-mean(FB(1:k_background_BP_val));
            FC=FC-mean(FC(1:k_background_FC_val));
            
            k_range_FC=[k_range_FC_L_val,k_range_FC_R_val];
            attf=att_forward_val-att_waveguide_val;    %dB
            attb=att_backward_val+att_waveguide_val;    %dB

            n_smooth=20;    %smooth point for each rf signal
            Rl=1e6;
            tao=tao_ms/1e3;

            % calculate E, C, and I of each section, and estimate the ones with noise
            group=length(s.t_interval);
            E=zeros(group,1);
            P_fwd=zeros(group,1);
            C=zeros(group,1);
            
            for k=1:group
                if k==1
                    flag_plot_maxp=1;
                else
                    flag_plot_maxp=0;
                end
                info_f=s.info{k}.info_Ch(:,ch_forward_val);
                info_f=info_f-mean(info_f(1:k_background_FP_val));
                info_b=s.info{k}.info_Ch(:,ch_backward_val);
                info_b=info_b-mean(info_b(1:k_background_BP_val));
                FC=s.info{k}.info_Ch(:,ch_FC_val);
                FC=FC-mean(FC(1:k_background_FC_val));
                [~,~,max_p]=func_highpower_cal_max_inputpower_v3_K4(info_f,...
                    info_b,attf,attb,k_background_FP_val,n_smooth,flag_plot_maxp);
                P_fwd(k)=max_p;
                E(k)=sqrt(max_p/factor_power_val)*1e6;
                C(k)=func_highpower_cal_C_range(FC,tao,k_range_FC,Rl,flag_plot_maxp);
            end

            index_zero=find(C<0);
            C(index_zero)=NaN;
            E(index_zero)=NaN;

            idcs = strfind(fpath,filesep);
            EC_info_path = strcat(fpath(1:idcs(end-1)-1),'\EC_info\');
            EC_info_fname = strcat('EC_',fname);
            EC_info_full_filename=strcat(EC_info_path,EC_info_fname);
            
            save(EC_info_full_filename,'E','C');
            
        else %high charge
            ch_forward_val=settings(1);
            ch_backward_val=settings(2);
            ch_FC_val=settings(3);
            k_background_FP_val=settings(4);
            k_background_BP_val=settings(5);
            k_background_FC_val=settings(6);
            k_range_FC_L_val=settings(7);
            k_range_FC_R_val=settings(8);
            att_waveguide_val=settings(9);
            att_forward_val=settings(10);
            att_backward_val=settings(11);
            factor_power_val=settings(12);
            
            FP=s.info{1}.info_Ch(:,ch_forward_val);
            FB=s.info{1}.info_Ch(:,ch_backward_val);
            FC=s.info{1}.info_Ch(:,ch_FC_val);
            FP=FP-mean(FP(1:k_background_FP_val));
            FB=FB-mean(FB(1:k_background_BP_val));
            FC=FC-mean(FC(1:k_background_FC_val));
            
            k_range_FC=[k_range_FC_L_val,k_range_FC_R_val];
            attf=att_forward_val-att_waveguide_val;    %dB
            attb=att_backward_val+att_waveguide_val;    %dB
            
            n_smooth=20;    %smooth point for each rf signal
            Rl=50;

            % calculate E, C, and I of each section, and estimate the ones with noise
            group=length(s.t_interval);
            E=zeros(group,1);
            P_fwd=zeros(group,1);
            C=zeros(group,1);
            
            for k=1:group
                if k==1
                    flag_plot_maxp=1;
                else
                    flag_plot_maxp=0;
                end
                info_f=s.info{k}.info_Ch(:,ch_forward_val);
                info_f=info_f-mean(info_f(1:k_background_FP_val));
                info_b=s.info{k}.info_Ch(:,ch_backward_val);
                info_b=info_b-mean(info_b(1:k_background_BP_val));
                FC=s.info{k}.info_Ch(:,ch_FC_val);
                FC=FC-mean(FC(1:k_background_FC_val));
                [~,~,max_p,mid_p,min_p]=...
                    func_highpower_cal_max_inputpower_v3_K4(info_f,...
                    info_b,attf,attb,k_background_FP_val,n_smooth,flag_plot_maxp);
                P_fwd(k)=max_p;
                %E_max(k)=sqrt(max_p/factor_power)*1e6;
                E(k)=sqrt(mid_p/factor_power_val)*1e6;
                %E_min(k)=sqrt(min_p/factor_power)*1e6;
                FC_range=FC(k_range_FC(1):k_range_FC(2));
                ttt_range=(0:1:length(FC_range)-1)'*s.t_interval(k);
                C(k)=-trapz(ttt_range,FC_range)/Rl;
            end

            index_zero=find(C<0);
            C(index_zero)=NaN;
            E(index_zero)=NaN;
            
            idcs = strfind(fpath,filesep);
            EC_info_path = strcat(fpath(1:idcs(end-1)-1),'\EC_info\');
            EC_info_fname = strcat('EC_',fname);
            EC_info_full_filename=strcat(EC_info_path,EC_info_fname);
            
            save(EC_info_full_filename,'E','C');

        end
    end

    function combine_EC(path_list, file_list, gradient)
        %disp(path_list);
        E=zeros(10000,1);
        C=zeros(10000,1);

        n=0;
        if ~ischar(file_list)
            len_file=length(file_list);
            
            for k_file=1:len_file
                fprintf('%s  ',file_list{k_file});
                filename=strcat(path_list{k_file},file_list{k_file});
                s=load(filename);
                len=length(s.E);
                E(n+1:n+len)=s.E;
                C(n+1:n+len)=s.C;
                n=n+len;
                fprintf('\n');
                
            end
        end

        E=E(1:n);
        C=C(1:n);

        %disp(path_list);
        path = path_list{1};
        idcs = strfind(path,filesep);
        new_path = strcat(path(1:idcs(end-2)-1),'\all I V curves\');
        name = strcat('I_V_',num2str(gradient),'_MVm');
        %global filename_save_IV;
        filename_save_IV=strcat(new_path,name,'.mat');
        save(filename_save_IV,'E','C');
        IV_full_fname_list = [IV_full_fname_list, filename_save_IV];
        end
    
          
%time constant settings with Faraday Cup
FC_settings_window = figure("Visible","off","Position",[850,100,300,200],...
            "Name","Faraday Cup Settings","NumberTitle","off");
        
ch_FC_txt = uicontrol(FC_settings_window,"Style","text","String",...
            "Channel of Faraday Cup:","Position",[5,170,130,25]);
ch_FC2 = uicontrol(FC_settings_window,"Style","edit","Position",...
            [135,175,50,20],"Callback",@replot_FC_Callback);
k_background_txt = uicontrol(FC_settings_window,"Style","text",...
            "Position",[5,140,165,25],"String",'Number of points for background:');
k_background_val = uicontrol(FC_settings_window,"Style","edit","Position",...
            [170,145,50,20],"Callback",@replot_FC_Callback);
min_threshold_txt = uicontrol(FC_settings_window,"Style","text",...
            "String","Minimum Threshold: (Recommended Value: 0.85)","Position",[5,95,140,40]);
min_threshold_val = uicontrol(FC_settings_window,"Style","edit",...
            "Position",[150,115,50,20],"Callback",@replot_FC_Callback);
max_threshold_txt = uicontrol(FC_settings_window,"Style","text",...
            "String","Maximum Threshold: (Recommended Value: 0.15)","Position",[5,55,140,40]);
max_threshold_val = uicontrol(FC_settings_window,"Style","edit",...
            "Position",[150,75,50,20],"Callback",@replot_FC_Callback)
save_FC_settings_btn = uicontrol(FC_settings_window,"Style","pushbutton",...
            "Position",[150,30,100,25],"String","Save and continue",...
            "Callback",@calc_tao_ms_Callback);
 
    function replot_FC_Callback(source,eventdata)
        global info_timeconst k_start k_end Channel_FC FC minf ...
            threshold1 threshold2 k_background;
        
        info = info_timeconst;
        [len,N_channel]=size(info.info{1,1}.info_Ch);
        
        clf(plot_window,"reset");
        plot_window.Name = "Faraday Cup Plot";
        plot_window.NumberTitle = "off";
        
        if source == ch_FC2
            Channel_FC = str2num(ch_FC2.String);
            FC=info.info{1}.info_Ch(:,Channel_FC);
            figure(plot_window),plot(FC);
            title("Faraday Cup");
            grid on;
        elseif source == k_background_val
            k_background = str2num(k_background_val.String);
            FC=info.info{1}.info_Ch(:,Channel_FC)-...
                mean(info.info{1}.info_Ch(1:k_background,Channel_FC));
            figure(plot_window),plot(FC);
            title("Faraday Cup");
            grid on;
        elseif source == min_threshold_val
            threshold1=str2double(min_threshold_val.String);
            [minf,pos]=min(FC);
            for l=pos:len-1
                if (FC(l)<=minf*threshold1)&&(FC(l+1)>=minf*threshold1)
                    k_start=l;
                break;
                end
            end
            figure(plot_window),plot(FC);
            hold on,plot(k_start,FC(k_start),'rs');
            title("Faraday Cup");
            grid on;
            
        elseif source == max_threshold_val
            threshold2=str2double(max_threshold_val.String);
            for l=k_start:len-1
                if (FC(l)<=minf*threshold2)&&(FC(l+1)>=minf*threshold2)
                    k_end=l;
                break;
                end
            end
            figure(plot_window),plot(FC);
            hold on,plot(k_start,FC(k_start),'rs');
            hold on,plot(k_end,FC(k_end),'ro');
            title("Faraday Cup");
            grid on;      
        end      
    end
    function calc_tao_ms_Callback(source,eventdata)
        global info_timeconst FC tao_mean Channel_FC k_background ...
            threshold1 threshold2 pathname_timeconst filename_timeconst;
        
        %save FC plot
        idcs = strfind(pathname_timeconst, filesep);
        save_path = strcat(pathname_timeconst(1:idcs(end-2)-1),'\figures\');
        save_filename = strcat(save_path,"FC_plot_",filename_timeconst(1:end-4),".png");
        saveas(plot_window,save_filename);
        
        info = info_timeconst;
        
        group_cal=length(info.t_interval);
        tao=zeros(group_cal,1);
        tao_low=zeros(group_cal,1);
        tao_high=zeros(group_cal,1);
        for k=1:group_cal
            FC=info.info{k}.info_Ch(:,Channel_FC);
            FC=FC-mean(FC(1:k_background));
            len=length(FC);
            [minf,pos]=min(FC);
            for l=pos:len-1
                if (FC(l)<=minf*threshold1)&&(FC(l+1)>=minf*threshold1)
                    k_start=l;
                    break;
                end
            end
            for l=k_start:len-1
                if (FC(l)<=minf*threshold2)&&(FC(l+1)>=minf*threshold2)
                    k_end=l;
                    break;
                end
            end
            ll=k_end-k_start+1;
            yy=FC(k_start:k_end);
            xx=linspace(1,ll,ll)'*info.t_interval(k);
            X=xx;
            Y=log(-yy);
            [p,S] = polyfit(X,Y,1); 
            tao(k)=-1./p(1,1);
            [y_fit,delta] = polyval(p,X,S);
            
        end
        set(plot_window,"Visible","off");
        set(FC_settings_window,"Visible","off");
        tao_mean=mean(tao)*1e3; %ms
        %disp(tao_mean);
    end

    
%initial channel plotting window
plot_window = figure("Position",[850,410,400,300],...
                'Name','Channel Plots','NumberTitle','off',...
                "Visible","off");
            
    function make_initial_plots(file_path,file_name)
        filename=strcat(file_path,file_name);
    global s;
    s=load(filename);

    [~,N_channel]=size(s.info{1}.info_Ch);

  
    % plot one signal to determine the channel of forward power and Faraday Cup
    figure(plot_window);
    
    for k=1:N_channel
        subplot(2,2,k),plot(s.info{1}.info_Ch(:,k));
        grid on;
        title(strcat('Ch ',num2str(k)));
    end
    for k=N_channel+1:4
        subplot(2,2,k);
        title(strcat('Ch',num2str(k)));
    end
    end
            
%enter parameter settings window
params_settings_window = figure("Position",[850,50,400,300],"Visible","off",...
                "Name","Parameter File Settings","NumberTitle","off");

channels_header = uicontrol(params_settings_window, "Style","text",...
            "String","Enter channels below","Position",[70,275,150,25],...
            "FontWeight","bold");
ch_forward_txt = uicontrol(params_settings_window,"Style","text",...
            "String","Channel of Forward Power:","Position",[5,250,150,25]);
ch_forward = uicontrol(params_settings_window,"Style","edit","Position",...
            [150,260,50,20]);
ch_backward_txt = uicontrol(params_settings_window,"Style","text","String",...
            "Channel of Backward Power:","Position",[1,225,150,25]);
ch_backward = uicontrol(params_settings_window,"Style","edit","Position",...
            [150,235,50,20]);
ch_FC_txt = uicontrol(params_settings_window,"Style","text","String",...
            "Channel of Faraday Cup:","Position",[11,200,150,25]);
ch_FC = uicontrol(params_settings_window,"Style","edit","Position",...
            [150,210,50,20]);
replot_ch_btn = uicontrol(params_settings_window,"Style","pushbutton","String",...
            "Replot channels","Position",[220,210,85,20],"Callback",...
            @replot_ch_Callback);
        
line(1) = uicontrol(params_settings_window,"Style","text","String",...
    "_______________________________________________________________________________",...
            "Position",[0,195,400,15]);
        
points_header = uicontrol(params_settings_window,"Style","text","String",...
            "Enter number of points for...","Position",[10,170,160,25],...
            "FontWeight","bold");
k_background_FP_txt = uicontrol(params_settings_window,"Style","text","String",...
            "Forward power background:",...
            "Position",[5,150,150,25]);
k_background_FP = uicontrol(params_settings_window,"Style","edit","Position",...
            [160,160,50,20]);
k_background_BP_txt = uicontrol(params_settings_window,"Style","text","String",...
            "Backward power background:",...
            "Position",[5,125,150,25]);
k_background_BP = uicontrol(params_settings_window,"Style","edit","Position",...
            [160,135,50,20]);
k_background_FC_txt = uicontrol(params_settings_window,"Style","text","String",...
            "Faraday Cup background:",...
            "Position",[5,100,150,25]);
k_background_FC = uicontrol(params_settings_window,"Style","edit","Position",...
            [160,110,50,20]);
        
line(2) = uicontrol(params_settings_window,"Style","text","String",...
  "_______________________________________________________________________________",...
            "Position",[0,95,400,15]);
line(3) = uicontrol(params_settings_window,"Style","text","String",...
            "| | | | | | | ","Position",[215,100,5,95],"FontWeight","bold");
        
FC_header = uicontrol(params_settings_window,"Style","text","String",...
            "Boundaries for Faraday Cup",...
            "Position",[220,170,170,25],"FontWeight","bold");
        
k_range_FC_L_txt = uicontrol(params_settings_window,"Style","text","String",...
            'Left boundary:',"Position",...
            [230,150,80,25]);
k_range_FC_L = uicontrol(params_settings_window,"Style","edit","Position",...
            [310,160,50,20]);
k_range_FC_R_txt = uicontrol(params_settings_window,"Style","text","String",...
            'Right boundary:',"Position",...
            [230,120,80,25]);
k_range_FC_R = uicontrol(params_settings_window,"Style","edit","Position",...
            [310,130,50,20]);
        
replot_points_btn = uicontrol(params_settings_window,"Style","pushbutton",...
            "Position",[320,105,70,20],"String","Replot points",...
            "Callback",@replot_points_Callback);
        
waveguide_attn_txt = uicontrol(params_settings_window,"Style","text",...
            "String",'Waveguide attenuation (dB):', "Position",...
            [10,70,140,25]);
waveguide_attn = uicontrol(params_settings_window,"Style","edit",...
            "Position",[150,75,50,20]);
forward_attn_txt = uicontrol(params_settings_window,"Style","text",...
            "String",'Forward attenuation (dB):',"Position",...
            [10,50,130,25]);
forward_attn = uicontrol(params_settings_window,"Style","edit",...
            "Position",[150,55,50,20]);
backward_attn_txt = uicontrol(params_settings_window,"Style","text",...
            "String",'Backward attenuation (dB):',"Position",...
            [10,30,140,25]);
backward_attn = uicontrol(params_settings_window,"Style","edit",...
            "Position",[150,35,50,20]);
power_factor_txt = uicontrol(params_settings_window,"Style","text",...
            "String",'Simulated power for 1 MV/m (W):',"Position",...
            [10,10,165,25]);
power_factor = uicontrol(params_settings_window,"Style","edit",...
            "Position",[180,15,50,20]);
        
save_settings_btn = uicontrol(params_settings_window,"Style","pushbutton",...
            "Position",[320,10,75,25],"String","Save settings",...
            "Callback",@save_settings_Callback);


        
    function replot_ch_Callback(source,eventdata)
        ch_forward_val = str2num(ch_forward.String);
        ch_backward_val = str2num(ch_backward.String);
        ch_FC_val = str2num(ch_FC.String);
        
        clf(plot_window,"reset");
        plot_window.Name = "Channel Plots";
        plot_window.NumberTitle = "off";
        global s FP FB FC;
        
        FP=s.info{1}.info_Ch(:,ch_forward_val);
        figure(plot_window);
        subplot(3,1,1),plot(FP);
        grid on;
        title('Forward Power');
       
        FB=s.info{1}.info_Ch(:,ch_backward_val);
        subplot(3,1,2),plot(FB);
        grid on;
        title('Backward Power');
    
        FC=s.info{1}.info_Ch(:,ch_FC_val);
        subplot(3,1,3),plot(FC);
        grid on;
        title('Faraday Cup');
    end
    function replot_points_Callback(source,eventdata)
        global FP FB FC;
        
        clf(plot_window,"reset");
        plot_window.Name = "Channel Plots";
        plot_window.NumberTitle = "off";
        figure(plot_window);
        
        k_background_FP_val = str2num(k_background_FP.String);
        k_background_BP_val = str2num(k_background_BP.String);
        k_background_FC_val = str2num(k_background_FC.String);
        
        k_range_FC_L_val = str2num(k_range_FC_L.String);
        k_range_FC_R_val = str2num(k_range_FC_R.String);
        
        FP=FP-mean(FP(1:k_background_FP_val));
        subplot(3,1,1),plot(FP);
        grid on;
        title('Forward Power');
    
        FB=FB-mean(FB(1:k_background_BP_val));
        subplot(3,1,2),plot(FB);
        grid on;
        title('Backward Power');
    
        FC=FC-mean(FC(1:k_background_FC_val));
        subplot(3,1,3),plot(FC);
        grid on;
        title('Faraday Cup');
    
        subplot(3,1,3);
        hold on,plot(k_range_FC_L_val,FC(k_range_FC_L_val),'rs');
    
        subplot(3,1,3);
        hold on,plot(k_range_FC_R_val,FC(k_range_FC_R_val),'ro');
    
    end

    function save_settings_Callback(source,eventdata)
        global tao_mean fpath_params info_fname_params ...
            filename_save_settings charge;
        
        idcs = strfind(fpath_params,filesep);
        save_path = strcat(fpath_params(1:idcs(end-2)-1),'\figures\');
        save_filename = strcat(save_path,"Scope_settings_",info_fname_params(1:end-4),".png");
        saveas(plot_window,save_filename);
        
        load_filename = strcat(fpath_params,info_fname_params);
        s = load(load_filename);
        
        ch_forward_val = str2num(ch_forward.String);
        ch_backward_val = str2num(ch_backward.String);
        ch_FC_val = str2num(ch_FC.String);
        k_background_FP_val = str2num(k_background_FP.String);
        k_background_BP_val = str2num(k_background_BP.String);
        k_background_FC_val = str2num(k_background_FC.String);
        k_range_FC_L_val = str2num(k_range_FC_L.String);
        k_range_FC_R_val = str2num(k_range_FC_R.String);
        att_waveguide_val = str2double(waveguide_attn.String);
        att_forward_val = str2double(forward_attn.String);
        att_backward_val = str2double(backward_attn.String);
        factor_power_val = str2double(power_factor.String);
        
        global settings;
        if charge == "Low charge"
            tao_ms = tao_mean;
            
            settings=[ch_forward_val,ch_backward_val,ch_FC_val,...
            k_background_FP_val,k_background_BP_val,k_background_FC_val,...
            k_range_FC_L_val,k_range_FC_R_val,tao_ms,att_waveguide_val,...
            att_forward_val,att_backward_val,factor_power_val];
        
            k_range_FC=[k_range_FC_L_val,k_range_FC_R_val];
            attf=att_forward_val-att_waveguide_val;    %dB
            attb=att_backward_val+att_waveguide_val;    %dB
            % calculate E, C, and I of each section, and estimate the ones with noise
            n_smooth=20;    %smooth point for each rf signal
            Rl=1e6;
            tao=tao_ms/1e3;
            
            group=length(s.t_interval);
            E=zeros(group,1);
            P_fwd=zeros(group,1);
            C=zeros(group,1);

            for k=1:group
                if k==1
                    flag_plot_maxp=1;
                else
                    flag_plot_maxp=0;
                end
                info_f=s.info{k}.info_Ch(:,ch_forward_val);
                info_f=info_f-mean(info_f(1:k_background_FP_val));
                info_b=s.info{k}.info_Ch(:,ch_backward_val);
                info_b=info_b-mean(info_b(1:k_background_BP_val));
                FC=s.info{k}.info_Ch(:,ch_FC_val);
                FC=FC-mean(FC(1:k_background_FC_val));
                [~,~,max_p]=func_highpower_cal_max_inputpower_v3_K4(info_f,...
                    info_b,att_forward_val,att_backward_val,k_background_FP_val,...
                    n_smooth,flag_plot_maxp);
                P_fwd(k)=max_p;
                E(k)=sqrt(max_p/factor_power_val)*1e6;
                C(k)=func_highpower_cal_C_range(FC,tao,k_range_FC,Rl,flag_plot_maxp);
                end

            index_zero=find(C<0);
            C(index_zero)=NaN;
            E(index_zero)=NaN;

            global EC_info_full_filename;
            idcs = strfind(fpath_params,filesep);
            EC_info_path = strcat(fpath_params(1:idcs(end-1)-1),'\EC_info\');
            EC_info_fname = strcat('EC_',info_fname_params);
            EC_info_full_filename=strcat(EC_info_path,EC_info_fname);
            
            save(EC_info_full_filename,'E','C');
        
        else
            settings=[ch_forward_val,ch_backward_val,ch_FC_val,...
            k_background_FP_val,k_background_BP_val,k_background_FC_val,...
            k_range_FC_L_val,k_range_FC_R_val,att_waveguide_val,...
            att_forward_val,att_backward_val,factor_power_val]
        
            k_range_FC=[k_range_FC_L_val,k_range_FC_R_val];
            attf=att_forward_val-att_waveguide_val;    %dB
            attb=att_backward_val+att_waveguide_val;    %dB

            n_smooth=20;    %smooth point for each rf signal
            Rl=50;

            % calculate E, C, and I of each section, and estimate the ones with noise
            group=length(s.t_interval);
            E=zeros(group,1);
            P_fwd=zeros(group,1);
            C=zeros(group,1);

            for k=1:group
                if k==1
                    flag_plot_maxp=1;
                else
                    flag_plot_maxp=0;
                end
                info_f=s.info{k}.info_Ch(:,ch_forward_val);
                info_f=info_f-mean(info_f(1:k_background_FP_val));
                info_b=s.info{k}.info_Ch(:,ch_backward_val);
                info_b=info_b-mean(info_b(1:k_background_BP_val));
                FC=s.info{k}.info_Ch(:,ch_FC_val);
                FC=FC-mean(FC(1:k_background_FC_val));
                [~,~,max_p,mid_p,min_p]=...
                    func_highpower_cal_max_inputpower_v3_K4(info_f,...
                    info_b,attf,attb,k_background_FP_val,n_smooth,flag_plot_maxp);
                P_fwd(k)=max_p;
                %E_max(k)=sqrt(max_p/factor_power_val)*1e6;
                E_mid(k)=sqrt(mid_p/factor_power_val)*1e6;
                %E_min(k)=sqrt(min_p/factor_power_val)*1e6;
                FC_range=FC(k_range_FC(1):k_range_FC(2));
                ttt_range=(0:1:length(FC_range)-1)'*s.t_interval(k);
                C(k)=-trapz(ttt_range,FC_range)/Rl;
            end

            index_zero=find(C<0);
            C(index_zero)=NaN;
            E(index_zero)=NaN;

%             figure,plot(E_mid/1e6,C*1e9,'*');
%             grid on;
%             xlabel('Max Ec (MV/m)');
%             ylabel('Charge (nC)');
            E = E_mid;

            global EC_info_full_filename;
            idcs = strfind(fpath_params,filesep);
            EC_info_path = strcat(fpath_params(1:idcs(end-1)-1),'\EC_info\');
            EC_info_fname = strcat('EC_',info_fname_params);
            EC_info_full_filename=strcat(EC_info_path,EC_info_fname);
            
            save(EC_info_full_filename,'E','C');
        end
        set(plot_window, "Visible","off");
        set(params_settings_window,"Visible","off");
    end
 %FN plot window
 FN_plot_window = figure('Visible','off','Position',[615,386,635,324],'Name','FN Plot',...
                'NumberTitle','off');
 Rsq_plot_window = figure('Visible','off','Position',[615,62,635,324],'Name','R-squared Plot',...
                'NumberTitle','off');
% FN plot option window
FN_option_window = figure('Visible','off','Position',[197,429,400,207],...
                'Name','FN Options','NumberTitle','off');
view_FN_plot_txt(1) = uicontrol(FN_option_window,'Style','text','String',...
                'View plot for gradient: ','Position',[14,178,110,25]);
view_FN_plot_txt(2) = uicontrol(FN_option_window,'Style','text','String',...
                'MV/m','Position',[184,176,30,25]);
view_FN_plot = uicontrol(FN_option_window,'Style','popupmenu',...
                'Position',[128,181,50,25],'Callback',@make_FN_plots_knee);
%view_FN_plot = uicontrol(FN_option_window,'Style','popupmenu','String',{'20','10'},...
%                'Position',[125,220,50,25]);
knee_options = uibuttongroup(FN_option_window, 'Position',...
                 [0.65,0.75,0.35,0.25],'SelectionChangedFcn',@num_knee_Callback);
 one_knee = uicontrol(knee_options,'Style','radiobutton','Position',[10,25,100,25],...
                 'String','One knee point');
 no_knee = uicontrol(knee_options,'Style','radiobutton','Position',[10,0,110,25],...
                 'String','No knee point');
% two_knee = uicontrol(knee_options,'Style','radiobutton','Position',[10,50,110,25],...
%                 'String','Two knee points');
% handpick_knee = uicontrol(knee_options,'Style','radiobutton','Position',[10,30,120,25],...
%                 'String','Hand pick knee point');
% enter_handpick_txt = uicontrol(knee_options,'Style','text','String','Enter value:',...
%                 'Position',[27,5,60,25]);
% enter_handpick = uicontrol(knee_options,'Style','edit','Position',[87,13,50,20]);

axis_lims_text = uicontrol(FN_option_window,'Style','text','String','Enter axis limits:',...
                'Position',[10,150,100,20],'FontWeight','bold');
axis_lims_table = uitable(FN_option_window,'ColumnName',...
                {'FN x-axis','FN y-axis','R^2 x-axis','R^2 y-axis'},...
                'RowName',{'minimum','maximum'},'Position',[10,91,382,60],...
                'ColumnEditable',[true true true true]);
replot_axis_btn = uicontrol(FN_option_window,'Style','pushbutton','Position',[302,62,90,25],...
                'String','Replot axis limits','Callback',@replot_FN_axis_Callback);
save_FN_plot_btn = uicontrol(FN_option_window,'Style','pushbutton','Position',...
                [143,17,100,25],'String','Save current plots','Callback',@save_FN_plot_Callback);
finish_btn = uicontrol(FN_option_window,'Style','pushbutton','Position',...
                [250,17,100,25],'String','Finish and Exit','Callback',@done_Callback);
    function num_knee_Callback(x,~)
        if no_knee.Value == 1
            axis_lims_table.Data = [];
            axis_lims_table.ColumnName = {'FN x-axis','FN y-axis'};
            axis_lims_table.Position = [10,91,230,60];
            axis_lims_table.ColumnEditable = [true, true];
            make_FN_plots_no_knee(0,0);
            
        elseif one_knee.Value == 1
            axis_lims_table.Data = [];
            axis_lims_table.ColumnName = {'FN x-axis','FN y-axis','R^2 x-axis','R^2 y-axis'};
            axis_lims_table.Position = [10,91,382,60];
            axis_lims_table.ColumnEditable = [true,true,true,true];
            if x ~= 1
                make_FN_plots_knee(0,0);
            end
        end
    end
    function make_FN_plots_no_knee(~,~)
        global  phi t_duration betaE knee_loc;
        one_knee.Value = 0;
        no_knee.Value = 1;
        grad_index = view_FN_plot.Value;
        gradient = view_FN_plot.String(grad_index,:);
%         disp('grad index');
%         disp(grad_index);
%         disp('class of view_FN_plot string ');
%         disp(class(view_FN_plot.String));
%         disp('view_FN.plot.string(grad_index,:)');
%         disp(view_FN_plot.String(grad_index,:));
        
        for i=1:length(IV_full_fname_list)
            current_IV_file = IV_full_fname_list{i};
            %disp(current_IV_file);
            if contains(current_IV_file,gradient)==1
                s = load(current_IV_file);
            end
        end
        
        % n_cut_high=input('BD numbers to cut: ');
        n_cut_high=0;
        if n_cut_high>0

        %     E_mid=s.E_mid;
            E_mid=s.E;
            C=s.C;
            index=find(isnan(E_mid));
            E_mid(index)=[];
            C(index)=[];   
            [C,index_order]=sort(C);
            E_mid=E_mid(index_order);
            n=length(E_mid);
            E_mid=E_mid(1:n-n_cut_high);
            C=C(1:n-n_cut_high);
        else
            E_mid=s.E;
            C=s.C;
            index=find(isnan(E_mid));
            E_mid(index)=[];
            C(index)=[];
        end
        
        yyy=log10(C./(E_mid.^2.5));
        xxx=1./E_mid;
        
        fit = polyfit(xxx,yyy,1);
        y_fit = fit(1)*xxx + fit(2);
        
        E = E_mid;
        x_boundary_l = min(xxx)-0.05e-8;
        x_boundary_r = max(xxx)+0.05e-8;
        x_boundary_high = [x_boundary_l,x_boundary_r];
        [fitting_results,E,I_ave]=...
            func_highpower_cal_beta_EC_I_K4(E,C,phi,x_boundary_high,betaE,t_duration);
        
        path = rawpaths_list{1};
        idcs = strfind(path, filesep);
        save_path = strcat(path(1:idcs(end-1)-1),'\FN data\');
        FN_save_filename = strcat(save_path,'FN_',gradient,'MVm.mat');
        save(FN_save_filename,'xxx','yyy','C','E','I_ave','fitting_results','y_fit');
        
        Fontsize=14;
        Linewidth=2;
        
        clf(FN_plot_window,"reset");
        FN_plot_window.Name = "FN Plot";
        FN_plot_window.NumberTitle = "off";
        
        Rsq_plot_window.Visible = "off";
        
        figure(FN_plot_window)
        plot(xxx,yyy,'*')
        hold on
        set(gca,'Fontsize',Fontsize);
        xlabel(' 1/E (m/V)','Fontsize',Fontsize)
        ylabel('Log_{10} (I/E^{2.5})','Fontsize',Fontsize)
        hold on
        plot(xxx,y_fit,'r-','LineWidth',Linewidth)
        
        title(strcat("FN Plot: Applied Field of ",gradient,' MV/m'))
        hold on
        
        axis_lims_table.Data(:,2) = ylim;
        axis_lims_table.Data(:,1) = xlim;
        
        
    end
    function done_Callback(~,~)
        select_rawdat_window.Visible = 'off';
        proc_window.Visible = 'off';
        img_window.Visible = 'off';
         dat_info_window.Visible = 'off';
         plot_window.Visible = 'off';
         params_settings_window.Visible = 'off';
         FC_settings_window.Visible = 'off';
         FN_option_window.Visible = 'off';
         FN_plot_window.Visible = 'off';
         Rsq_plot_window.Visible = 'off';
    end

    function replot_FN_axis_Callback(source,eventdata)
        global knee_loc ;
        
        FN_min_x = axis_lims_table.Data(1,1);
        FN_max_x = axis_lims_table.Data(2,1);
        FN_min_y = axis_lims_table.Data(1,2);
        FN_max_y = axis_lims_table.Data(2,2);
        if one_knee.Value == 1
            Rsq_min_x = axis_lims_table.Data(1,3);
            Rsq_max_x = axis_lims_table.Data(2,3);
            Rsq_min_y = axis_lims_table.Data(1,4);
            Rsq_max_y = axis_lims_table.Data(2,4);
        end
        figure(FN_plot_window);
        hold on
        %yyaxis left 
        ylim([FN_min_y FN_max_y]);
        xlim([FN_min_x FN_max_x]);
        y1=get(gca,'ylim');
        plot([knee_loc knee_loc],y1,'g-')
        if one_knee.Value == 1
            figure(Rsq_plot_window);
            hold on
            ylim([Rsq_min_y Rsq_max_y]);
            xlim([Rsq_min_x Rsq_max_x]);
            y2 = get(gca,'ylim');
            plot([knee_loc knee_loc],y2,'g-')
        end
    end
    function save_FN_plot_Callback(~,~)
        %change following lines to be correct
        
        %global rawpaths_list ;
        path = rawpaths_list{1};
        grad_index = view_FN_plot.Value;
        gradient = view_FN_plot.String(grad_index,:);
        idcs = strfind(path, filesep);
        save_path = strcat(path(1:idcs(end-1)-1),'\figures\');
        save_filename_FN = strcat(save_path,"FN_plot_",gradient,"MVm.png");
        saveas(FN_plot_window,save_filename_FN);
        if one_knee.Value == 1
            save_filename_Rsq = strcat(save_path,"Rsq_plot_",gradient,"MVm.png");
            saveas(Rsq_plot_window,save_filename_Rsq);
        end
    end
 
%functions from server
    function [fpath, info_fname] = func_highpower_read_csv(file_path,file_name)
    
    filename = strcat(file_path,'\',file_name);
    
    %filename=strcat(file_path,file_name);
    %disp('full filename from read csv');
    %disp(filename);
    sheet=file_name(1:end-4);
    if length(sheet)>31
        info_temp=xlsread(filename,sheet(1:31));
        [~,length_temp,~]=xlsread(filename,sheet(1:31),'A4');
    else
        info_temp=xlsread(filename,sheet);
        [~,length_temp,~]=xlsread(filename,sheet,'A4');
    end
    index=find(isnan(info_temp(:,1)));
    info_temp(index,:)=[];

    length_temp=length_temp{1};
    k=strfind(length_temp,':');
    n_length=round(str2double(length_temp(k+1:end)));
    [m,N_channel]=size(info_temp);
    N_channel=N_channel-1;
    group=round(m/n_length);

    info=cell(group,1);
    t_trigger=zeros(group,1);
    t_interval=zeros(group,1);

    for k_group=1:group
        time=info_temp((k_group-1)*n_length+1:k_group*n_length,1);
        t_interval(k_group)=mean(diff(time));
        info_Ch=info_temp((k_group-1)*n_length+1:k_group*n_length,2:N_channel+1);
        info{k_group}=struct('info_Ch',info_Ch);
    end

    % save the infomation to mat file
    timestamps = dats_table.Data(:,1);
    gradients = dats_table.Data(:,2);
    for n=1:length(timestamps)
        stamp = num2str(timestamps(n));
        grad = num2str(gradients(n));
        grad_rep = strcat('G',grad,'MVm');
        if_stamp = contains(file_name,stamp);
        if if_stamp == 1
            file_name = strrep(file_name,stamp,grad_rep);
        
        end
    end
    idcs = strfind(file_path,filesep);
    if file_path(end) == file_path(idcs(end))
        fpath = strcat(file_path(1:idcs(end-1)-1),'\raw matlab\');
    else
        fpath = strcat(file_path(1:idcs(end)-1),'\raw matlab\');
    end
    info_fname = strcat('info_',file_name(1:end-4),'.mat');
    file_save=strcat(fpath,info_fname);
    save(file_save,'info','t_trigger','t_interval');

end
function [Data,Frame,Dx,Dy]=func_highpower_read_image(file_path,file_name)

filename=strcat(file_path,file_name);
fid=fopen(filename,'rb');

Size_Image=fread(fid,2,'short');
Frame=fread(fid,1,'int');
Dx=Size_Image(1);
Dy=Size_Image(2);
Data=cell(Frame,1);

offset=12;
fseek(fid,offset,-1);
for k=1:Frame
    Data{k}=fread(fid,[Dx,Dy],'uint16');
    Data{k}=Data{k}';
end

fclose(fid);
clear fid;

end
    function [Powerf,Powerb,max_p,mid_p,min_p]=func_highpower_cal_max_inputpower_v3_K4(...
        info_f,info_b,attf,attb,n_average,n_smooth,flag_plot_maxp)
    
info_f=info_f-mean(info_f(1:n_average));
info_b=info_b-mean(info_b(1:n_average));

info_f=smooth(info_f,n_smooth);
info_b=smooth(info_b,n_smooth);

[Powerf,Powerb]=func_circuit_cal_power_fb_downstairs_K4(info_f,info_b,attf,attb);

Powerf=smooth(Powerf,20);
n_range=80;    %half of the sum range, for 584
len=length(Powerf)-2*n_range;
p_sum=zeros(len,1);
for k=1:len
    p_sum(k)=sum(Powerf(k:k+2*n_range))/(2*n_range+1);
end
[max_p,max_Ec]=max(p_sum);
[mid_Ec,mid_p]=fun_highpower_cal_flattop(Powerf);
del_Ec=max_Ec-mid_Ec;
min_Ec=mid_Ec-del_Ec;
min_p=Powerf(min_Ec);

% if flag_plot_maxp==1
%     figure,plot(Powerf);
%     hold on,plot(max_Ec,max_p,'r*');
%     hold on,plot(mid_Ec,mid_p,'b*');
%     hold on,plot(min_Ec,min_p,'g*');
%     grid on;
%     title('Forward power');
    
    
end

    function C=func_highpower_cal_C_range(faraday,tao,k_range,Rl,flag_plot_C)

        F=mean(faraday(k_range(1):k_range(2)));

        C=-tao*F/Rl;

        %if flag_plot_C==1
        %    figure,plot(faraday);
        %    hold on,plot(k_range(1),faraday(k_range(1)),'rs');
        %    hold on,plot(k_range(2),faraday(k_range(2)),'ro');
        %end

        end
    
    function [Powerf,Powerb]=func_circuit_cal_power_fb_downstairs_K4(info_f,...
        info_b,attf,attb)

% negative power to positive field in mV
tempf=-info_f*1000;
tempb=-info_b*1000;
% LINAC6 forward
Powerf=-0.034+0.0477*tempf+0.0006617*tempf.^2+0.000004948*tempf.^3-...
    0.00000005411*tempf.^4+0.0000000003129*tempf.^5-...
    0.0000000000008789*tempf.^6+0.0000000000000009657*tempf.^7;
Powerf=max(Powerf,0);
% LINAC6 reflection
Powerb=-0.159+0.07052*tempb-0.000024*tempb.^2+0.0000186*tempb.^3-...
    0.0000001925*tempb.^4+0.000000001079*tempb.^5-...
    0.000000000003028*tempb.^6+0.00000000000000337*tempb.^7;
Powerb=max(Powerb,0);
% convert to W, witness gun side
Powerf=Powerf*10^((attf+60.1)/10)/10^3;
Powerb=Powerb*10^((attb+59.8)/10)/10^3;

    end 
function [Ec,Pmax]=fun_highpower_cal_flattop(Pf_data)
y=Pf_data;
A_tot=trapz(y);
Ah=A_tot./2;
N=length(y);
tol=1e-6;
for j=2:N
    yi=y(1:j);
    A=trapz(yi);
    if (Ah-A)< tol
        index=j;
        break
    end
end
Ec=index;
Pmax=y(index);
end

function settings=func_highpower_cal_EC_Lecroy_K4(file_path,file_name,...
        file_path_setting,file_name_setting)
    
fprintf('\n');
    
filename=strcat(file_path,file_name);
global s;
s=load(filename);

[~,N_channel]=size(s.info{1}.info_Ch);

if isnan(file_path_setting)  
    % plot one signal to determine the channel of forward power and Faraday Cup
    figure(plot_window);
    
    for k=1:N_channel
        subplot(2,2,k),plot(s.info{1}.info_Ch(:,k));
        grid on;
        title(strcat('Ch ',num2str(k)));
    end
    for k=N_channel+1:4
        subplot(2,2,k);
        title(strcat('Ch',num2str(k)));
    end
    

end

k_range_FC=[k_range_FC_L_val,k_range_FC_R_val];
attf=att_forward-att_waveguide;    %dB
attb=att_backward+att_waveguide;    %dB

n_smooth=20;    %smooth point for each rf signal
Rl=1e6;
tao=tao_ms/1e3;

% calculate E, C, and I of each section, and estimate the ones with noise
group=length(s.t_interval);
E=zeros(group,1);
P_fwd=zeros(group,1);
C=zeros(group,1);

for k=1:group
    if k==1
        flag_plot_maxp=1;
    else
        flag_plot_maxp=0;
    end
    info_f=s.info{k}.info_Ch(:,Channel_forward);
    info_f=info_f-mean(info_f(1:k_background_FP));
    info_b=s.info{k}.info_Ch(:,Channel_backward);
    info_b=info_b-mean(info_b(1:k_background_FB));
    FC=s.info{k}.info_Ch(:,Channel_FC);
    FC=FC-mean(FC(1:k_background_FC));
    [~,~,max_p]=func_highpower_cal_max_inputpower_v3_K4(info_f,...
        info_b,attf,attb,k_background_FP,n_smooth,flag_plot_maxp);
    P_fwd(k)=max_p;
    E(k)=sqrt(max_p/factor_power)*1e6;
    C(k)=func_highpower_cal_C_range(FC,tao,k_range_FC,Rl,flag_plot_maxp);
end

index_zero=find(C<0);
C(index_zero)=NaN;
E(index_zero)=NaN;

% figure,plot(E/1e6,C*1e9,'*');
% grid on;
% xlabel('Max Ec (MV/m)');
% ylabel('Charge (nC)');

filename_save=strcat(file_path,'EC_',file_name);
clear s;
save(filename_save,'E','C');

settings=[Channel_forward,Channel_backward,Channel_FC,...
    k_background_FP,k_background_FB,k_background_FC,k_range_FC_l,...
    k_range_FC_r,tao_ms,att_waveguide,att_forward,att_backward,...
    factor_power];
end
function y_env=func_highpower_cal_rf_envelope(y,k_half)

    n=length(y);
    y_env=zeros(n,1);
    flag=zeros(n,1);
    for k=1:n
        if y(k)==max(y(max(1,k-k_half):min(n,k+k_half)))
            y_env(k)=y(k);
            flag(k)=1;
        end
    end
    for k=1:n
        if flag(k)==1
            for l=1:k
                y_env(l)=y(k);
                flag(l)=1;
            end
            break;
        end
    end
    for k=n:-1:1
        if flag(k)==1
            for l=n:-1:k
                y_env(l)=y(k);
                flag(l)=1;
            end
            break;
        end
    end
    k=1;
    while k<n
        if (flag(k)==1)&&flag(k+1)==0
            for l=1:n-k
                if flag(k+l)==1
                    break;
                end
            end
            y_env(k:k+l)=linspace(y_env(k),y_env(k+l),l+1);
            k=k+l;
        else
            k=k+1;
        end
    end

end

function [fitting_results,E,I_ave]=...
        func_highpower_cal_beta_EC_I_K4(E,C,phi,x_boundary,betaE_1,t_duration_1)
    
N_round_max=20;
beta_guess=100;
threshold=0.05;

%fprintf('\n');
for k=1:N_round_max
    %disp(k);
    t_duration=interp1(betaE_1,t_duration_1,E*beta_guess);
    I_ave=C./t_duration;

    Y_I_temp=log10(I_ave./(E.^2.5));
    X_temp=1./E;

    index=find((X_temp>=x_boundary(1))&(X_temp<=x_boundary(2)));
    %disp('index');
    %disp(index);
    X=X_temp(index);
    Y=Y_I_temp(index);

    coe=fit(X,Y,'poly1');
    conf_95=confint(coe,0.95);
    beta=-6.53e9*log10(exp(1))*phi^(1.5)/coe.p1;
    betaE=beta*max(E);
    beta_low=-6.53e9*log10(exp(1))*phi^(1.5)/conf_95(1,1);
    beta_high=-6.53e9*log10(exp(1))*phi^(1.5)/conf_95(2,1);
    betaE_low=beta_low*max(E);
    betaE_high=beta_high*max(E);
    area=10^(coe.p2-2.5*log10(beta)-log10(5.7e-12*10^(4.52*phi^(-0.5))/...
        phi^(1.75)));
    area_low=10^(conf_95(1,2)-2.5*log10(beta)-...
        log10(5.7e-12*10^(4.52*phi^(-0.5))/phi^(1.75)));
    area_high=10^(conf_95(2,2)-2.5*log10(beta)-...
        log10(5.7e-12*10^(4.52*phi^(-0.5))/phi^(1.75)));
    
    %fprintf('beta_guess=%.1f, beta=%.1f, beta_beta-beta_guess=%.1f\n',...
     %   beta_guess,beta,beta-beta_guess);
    if abs(beta-beta_guess)<=threshold
        break;
    else
        beta_guess=beta;
    end
end

fitting_results=[beta,beta_low,beta_high,betaE,betaE_low,betaE_high,...
    area,area_low,area_high];

% show results
% fprintf('\n');
% fprintf('Emax = %.1f (MV/m)\n',betaE/beta/10^6);
% fprintf('beta = %.1f',beta);
% fprintf(' (%.1f',beta_low);
% fprintf(', %.1f)\n',beta_high);
% fprintf('beta*Emax = %.1f',betaE/10^9);
% fprintf(' (%.1f',betaE_low/10^9);
% fprintf(', %.1f) (GV/m)\n',betaE_high/10^9);
% fprintf('Area = %.3g',area);
% fprintf(' (%.3g',area_low);
% fprintf(', %.3g) (m^2)\n',area_high);
% x=linspace(min(X),max(X),1000);
% y=x*coe.p1+coe.p2;
% 
% E_plot=linspace(min(E),max(E),1000);
% I_plot=5.7e-12*10^(4.52*phi^(-0.5))*area/phi^(1.75)*(beta*E_plot).^2.5.*...
%     exp(-6.53e9*phi^1.5./(beta*E_plot));


end

 % delete or comment out following lines before finishing
 % makes all windows visible for editing purposes
 select_rawdat_window.Visible = 'on';
 proc_window.Visible = 'off';
 img_window.Visible = 'off';
 dat_info_window.Visible = 'off';
 plot_window.Visible = 'off';
 params_settings_window.Visible = 'off';
 FC_settings_window.Visible = 'off';
 FN_option_window.Visible = 'off';
 FN_plot_window.Visible = 'off';
 Rsq_plot_window.Visible = 'off';
end