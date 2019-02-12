/*----------------------- Copyright 2016, Rho, Inc.  All rights reserved. ------------------------\

  Program:  install_github.sas

    Purpose:

        Import file(s) from GitHub and install file(s) in SAS session (if .sas file).

  /-----------------------------------------------------------------------------------------------\
    Parameters
  \-----------------------------------------------------------------------------------------------/

    REQUIRED
        repo
            - repository name in user/repo form
                e.g., RhoInc/sas-violinPlot

    EXACTLY ONE OF THE FOLLOWING                
        file
            - a single repository file, including containing folder(s)
                e.g., src/violinPlot.sas

        - OR -

        folder
            - repository folder which contains files
                e.g., src

  /-----------------------------------------------------------------------------------------------\
    Examples
  \-----------------------------------------------------------------------------------------------/

    Install a single file.
        %install_github(
            repo = RhoInc/sas-violinPlot,
            file = src/violinPlot.sas
        );

    Install a folder full of files.
        %install_github(
            repo = RhoInc/sas-codebook,
            folder = Macros
        );

  /-------------------------------------------------------------------------------------------------\
    Program history:
  \-------------------------------------------------------------------------------------------------/

    Date        Programmer          Description
    ----------  ------------------  --------------------------------------------------------------
    2016-11-03  Spencer Childress   Create.
    2017-06-24  Spencer Childress   Import all files, not just .sas files.
    2018-10-03  Shane Rosanbalm     Remove save option. 
                                    Shorten repo format from full URL to just user/repo.
                                    Switch to API approach for processing a folder.

\------------------------------------------------------------------------------------------------*/

%macro install_github(
    repo = ,
    file = ,
    folder = 
);


    %*---------- All files saved to TEMP. ----------;
    %let savePath = %sysfunc(pathname(TEMP));

    %*--------------------------------------------------------------------------------;
    %*---------- Macro to install a single file from a GitHub repository. ----------;
    %*--------------------------------------------------------------------------------;

    %macro ig_file(file = );

        %put;
        %put %str(NOTE-   --> Reading in &file from &repo..);

        %let fileName = %scan(&file, -1, /);
        %let fileExtension = %scan(&fileName, -1, .);
        %let fileURL = https://raw.githubusercontent.com/&repo/master/&file;

        %*Include file if file has a .sas extension.;
        %if %upcase(&fileExtension) = SAS %then %do;
            filename fileURL url "&fileURL";
                %include fileURL;
            filename fileURL;
        %end;

    %mend ig_file;

    %*--------------------------------------------------------------------------------;
    %*---------- Either install a single file... ----------;
    %*--------------------------------------------------------------------------------;

    %if %nrbquote(&file) ne %then
        %ig_file(file = &file);

    %*--------------------------------------------------------------------------------;
    %*---------- ...or install an entire folder. ----------;
    %*--------------------------------------------------------------------------------;

    %else %if %nrbquote(&folder) ne %then %do;

        %put;
        %put %str(NOTE-   --> Reading in all .sas files in &folder from &repo..);

        %let folderURL = https://api.github.com/repos/&repo/contents/&folder;

        filename inFolder temp;

            proc http
                url = "&folderURL"
                method = 'GET'
                out = inFolder;
            run;

            libname inFolder json fileref = inFolder;

            data root;
                set inFolder.root;
                length extension $100 action $2000;
                if type = "file" then do;
                    extension = scan(name, -1, '.');
                    if upcase(extension) = "SAS" then do;
                        action = cats('%ig_file(file = ',path,');');
                        call execute(action);
                    end;
                end;
            run;

            libname inFolder;

        filename inFolder;

    %end;

%mend install_github;
