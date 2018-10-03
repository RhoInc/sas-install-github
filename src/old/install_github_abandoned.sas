/*----------------------- Copyright 2016, Rho, Inc.  All rights reserved. ------------------------\

  Program:  install_github.sas

    Purpose:
    
        Download files from GitHub, save locally, and install files in SAS session.
            %include is used to install files if file= or folder= are used.
            sasautos is used to install files if neither file= nor folder= are used.

  /-----------------------------------------------------------------------------------------------\
    Parameters
  \-----------------------------------------------------------------------------------------------/

    - REQUIRED
        repo
            - repository name in user/repo form
                e.g. RhoInc/sas-violinPlot
            
    - OPTIONAL
        file
            - a single repository file, including containing folder(s)
                e.g. src/violinPlot.sas
        folder
            - repository folder which contains files
                e.g. src
        savePath
            - local directory in which to save files
                e.g. H:/mygithubdownloads/exotic-plots
    
  /-----------------------------------------------------------------------------------------------\
    Caution
  \-----------------------------------------------------------------------------------------------/

    The folders within a repository are added to the SASAUTOS list when an entire repo or
    folder are downloaded. If you need to add more paths to SASAUTOS after running 
    install_github, use the following syntax to avoid losing the macros you have just installed  
    via %install_github().
        OPTIONS INSERT=(SASAUTOS=("_additional_path_1_" "_additional_path_2_"));
        
    When using the FOLDER= option, subfolders are not downloaded. If you want subfolders, 
    do not use the FOLDER= option (use the REPO= option by itself).
    
  /-----------------------------------------------------------------------------------------------\
    Examples
  \-----------------------------------------------------------------------------------------------/

    Download an entire repo to TEMP.
        %install_github(repo=RhoInc/sas-violinPlot)
    
    Download a single file to TEMP.
        %install_github
            (repo=RhoInc/sas-violinPlot
            ,file=src/violinPlot.sas
            )
    
    Download and save a folders worth of files to a non-TEMP location.
        %install_github
            (repo=RhoInc/sas-violinPlot
            ,folder=src
            ,savePath=H:/mygithubdownloads/exotic-plots
            )

  /-------------------------------------------------------------------------------------------------\
    Program history:
  \-------------------------------------------------------------------------------------------------/

    Date        Programmer          Description
    ----------  ------------------  --------------------------------------------------------------
    2016-11-03  Spencer Childress   Create
    2017-06-24  Spencer Childress   Import all files, not just .sas files
    2018-08-13  Shane Rosanbalm     Edits for PhUSE submission.
                                    [x] Extraneous cosmetic/aesthetic edits.
                                    [x] Allow shorter repo= specification.
                                    [x] Allow for repo-only call.
    2018-08-14  Shane Rosanbalm     Rewrite to use GitHub API.
    2018-08-29  Shane Rosanbalm     Fix folder= bug in savePath= mode.

\------------------------------------------------------------------------------------------------*/



%*--------------------------------------------------------------------------------;
%* Macro to download a single file. ;
%*--------------------------------------------------------------------------------;

%macro ig_file
        (fileName=
        ,fileURL=
        ,filePath=
        ,fileInclude=no
        );

    %* Download the file. ;
    filename outFile "&filePath/&fileName";

        %* Download file. ;
        proc http
            url = "&fileURL"
            method = 'GET'
            out = outFile
            ;
        run;

    filename outFile;
   
    %* Percent-include the file. ;
    %if &fileInclude eq yes %then %do;

        filename fileURL url "&fileURL";

            %include fileURL;

        filename fileURL;

    %end;

%mend ig_file;



%*--------------------------------------------------------------------------------;
%* Macro to scan a folder. ;
%*--------------------------------------------------------------------------------;

%macro ig_folder
        (folderName=
        ,folderURL=
        ,folderPath=
        ,folderSub=yes
        );

    %* Create folder &folderPath/&folderName. ;
    %if not %sysfunc(filename(fileref,&folderPath/&folderName)) %then %do;
        %put Folder &folderPath/&folderName already exists.;
    %end;
    %else %do;
        %put Creating folder &folderPath/&folderName..;
        %let rc = %sysfunc(dcreate(&folderName,&folderPath));
        %put rc = [&rc];
        %if not %sysfunc(filename(fileref,&folderPath/&folderName)) %then 
            %put %str(W)ARNING: something went wrong with folderName!;
    %end;
    %let insert_sasautos = "&folderPath/&folderName" &insert_sasautos;
    %put &=insert_sasautos;

    %* Increment filename/libname counter. ;
    %let ghfnum = %sysfunc(putn(%eval(&ghfnum+1),z4.));
    %put &=ghfnum;

    filename resp&ghfnum temp;

        %* Get folder information. ;
        proc http
                url = "&folderURL"
                method = 'GET'
                out = resp&ghfnum
                ;
        run;

        libname ghf&ghfnum json fileref = resp&ghfnum;

        %* Take action based on item type. ;
        data root&ghfnum;
            set ghf&ghfnum..root;
            length extension $100 action $2000;

            if type = "file" then do;
                extension = scan(name, -1, '.');
                action = cats
                    ('%ig_file'
                        ,'(fileName=',path
                        ,',fileURL=',download_url
                        ,',filePath=',"&savePath/&repo"
                        ,');'
                        );
            end;

            %if &folderSub eq yes %then %do;

                else if type = "dir" then do;
                    length pathTail $500;
                    if index(path,'/') then do;
                        lastslashloc = findc(path,'/','b');
                        pathTail = '/'||substr(path,1,lastslashloc-1);
                    end;
                    else do;
                        pathTail = '';
                    end;
                    action = cats
                        ('%ig_folder'
                            ,'(folderName=',name
                            ,',folderURL=',url
                            ,',folderPath=',"&savePath/&repo",pathTail
                            ,');'
                            );
                end;

            %end;

            if action ne '' then do;
                put action=;
                call execute(action);
            end;
        run;

%mend ig_folder;



%*--------------------------------------------------------------------------------;
%* Macro to install a repository. ;
%*--------------------------------------------------------------------------------;

%macro install_github
        (repo=
        ,file=
        ,folder=
        ,savePath=%sysfunc(pathname(temp))
        );

    %* In-stan-ti-a-tion (ooooh). ;
    %let ghfnum = 0;
    %let insert_sasautos = ;
    %let fileref = dummy;

    %* Create folder &savePath/&repoUser. ;
    %let repoUser = %scan(&repo,1,/);
    %put &=repoUser;
    %let repoName = %scan(&repo,2,/);
    %put &=repoName;
    %if not %sysfunc(filename(fileref,&savePath/&repoUser)) %then %do; 
        %put Folder &savePath/&repoUser already exists.;
    %end;
    %else %do; 
        %put Creating folder &savePath/&repoUser..;
        %let rc = %sysfunc(dcreate(&repoUser,&savePath));
        %put rc = [&rc];
        %if not %sysfunc(filename(fileref,&savePath/&repoUser)) %then
            %put %str(W)ARNING: something went wrong with repoUser!;
    %end;

    %* If just one file is needed, keep it simple. ;
    %if %nrbquote(&file) ne %str() %then %do;

        %if not %sysfunc(filename(fileref,&savePath/&repoUser/&repoName)) %then %do; 
            %put Folder &savePath/&repoUser already exists.;
        %end;
        %else %do;
            %put Creating folder &savePath/&repoUser/&repoName..;
            %let rc = %sysfunc(dcreate(&repoName,&savePath/&repoUser));
            %put rc = [&rc];
            %if not %sysfunc(filename(fileref,&savePath/&repoUser/&repoName)) %then 
                %put %str(W)ARNING: something went wrong with repoName!;
        %end;

        %ig_file
            (fileName=%scan(&file, -1, /)
            ,fileURL=https://raw.githubusercontent.com/&repo/master/&file
            ,filePath=&savePath/&repo
            ,fileInclude=yes
            )

    %end;

    %* If just one folder is needed, keep it almost as simple. ;
    %else %if %nrbquote(&folder) ne %str() %then %do;

        %* Scan single folder. ;
        %ig_folder
            (folderName=&folder
            ,folderURL=https://api.github.com/repos/&repo/contents/&folder
            ,folderPath=&savePath/&repo
            ,folderSub=no
            )

        %* Clean up. ;
        libname ghf0001;
        filename resp0001;
        options insert=(sasautos=&insert_sasautos);

    %end;

    %* If whole repo is needed, time to iterate. ;
    %else %do;

        %* Start scanning at the top level. ;
        %ig_folder
            (folderName=&repoName
            ,folderURL=https://api.github.com/repos/&repo/contents
            ,folderPath=&savePath/&repoUser
            )

        %* Clean up. ;
        %do i = 1 %to &ghfnum;
            %let ifmt = %sysfunc(putn(&i,z4.));
            libname ghf&ifmt;
            filename resp&ifmt;
        %end;
        options insert=(sasautos=(&insert_sasautos));

    %end;

%mend install_github;

