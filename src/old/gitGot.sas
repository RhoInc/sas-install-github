/*----------------------- Copyright 2016, Rho, Inc.  All rights reserved. ------------------------\

  Program:  gitGot.sas

    Purpose:
    
        Import files from GitHub, save locally, and include file in SAS session (if .sas file).

  /-----------------------------------------------------------------------------------------------\
    Parameters
  \-----------------------------------------------------------------------------------------------/

        repo
            - repository URL on GitHub, e.g. https://github.com/RhoInc/sas-codebook
        folder
            - repository folder which contains files, e.g. Macros
        file
            - repository file, including containing folder(s), e.g. Macros/codebook_generic.sas
        savePath
            - local directory in which to save files

/-------------------------------------------------------------------------------------------------\
  Program history:
\-------------------------------------------------------------------------------------------------/

    Date        Programmer          Description
    ----------  ------------------  --------------------------------------------------------------
    2016-11-03  Spencer Childress   Create
    2017-06-24  Spencer Childress   Import all files, not just .sas files

\------------------------------------------------------------------------------------------------*/

%macro gitGot
    (repo = 
    ,folder = 
    ,file = 
    ,savePath = %sysfunc(pathname(temp)));

  %*Include all files in a GitHub repository folder.; 
    %if %nrbquote(&folder) ne %then %do;

        %put;
        %put %str(NOTE-   --> Reading in all files in &folder from &repo..);

        %if %nrbquote(&savePath) ne %nrbquote(%sysfunc(pathname(temp))) %then
            %put %str(NOTE-   -->     Saving files in %nrbquote(&savePath).);

        %let inFolder = &repo/tree/master/&folder;
        filename inFolder "&savePath\inFolder.txt";
            proc http
                url = "&inFolder"
                method = 'GET'
                out = inFolder;
            run;

            data files (where = (match));
                length
                    fileName $100
                    fileExtension $10
                    fileURL inFile outFile procHTTP $1000;
                infile inFolder pad dsd
                    lrecl = 32767
                    dlm = '~'
                    end = eof;
                input
                    text $char1000.;

                if _n_ = 1 then
                    putlog "NOTE-   -->     Processing files in &repo/tree/master/&folder.." /;

                match = index(lowcase(text), strip(lowcase("&folder"))) and prxmatch('/^\s*<span/i', text);

                if match then do;
                    fileName = scan(text, -4, '<>');
                    fileExtension = scan(fileName, -1, '.');
                    fileURL = catx('/', tranwrd("&repo", 'github.com', 'raw.githubusercontent.com'), 'master', "&folder", fileName);

                    if fileName ne fileExtension then do;
                        if "&savePath" ne pathname('temp') then
                            putlog "NOTE-   -->         Saving " fileName "in &savePath";

                        inFile = 'filename inFile url "' || strip(fileURL) || '";';

                        call execute(inFile);

                            outFile = cats("filename outFile '&savePath\", fileName, "';");

                           *Save file.;
                            call execute(outFile);

                                procHTTP = catx(' ',
                                    'proc http',
                                        'url = "' || strip(fileURL) || '"',
                                        'method = "GET"',
                                        'out = outFile;',
                                    'run;');
                                call execute(procHTTP);

                            call execute('filename outFile;');

                           *Include file if file has .sas extension.;
                            if lowcase(fileExtension) = 'sas' then
                                call execute('%include inFile;');

                        call execute('filename inFile;');
                    end;
                end;

                if eof then putlog / 'NOTE-   -->     Processing complete.' / 'NOTE-';
            run;

        filename inFolder;
        %sysexec del "&savePath\inFolder.txt";
    %end;
  %*Import a single file from a GitHub repository.;
    %else %if %nrbquote(&file) ne %then %do;
        %let fileName = %scan(&file, -1, /);
        %let fileExtension = %scan(&fileName, -1, .);
        %let fileURL = %sysfunc(tranwrd(%nrbquote(&repo), github.com, raw.githubusercontent.com))/master/&file;

        %put;
        %put %str(NOTE-   --> Reading in &file from &repo..);

        %if %nrbquote(&savePath) ne %nrbquote(%sysfunc(pathname(temp))) %then
            %put %str(NOTE-   -->     Saving &fileName in %nrbquote(&savePath).);

        %put;

      %*Save file.;
        filename filePath
            "&savePath\%scan(&file, -1, /)";

            proc http
                url = "&fileURL"
                method = 'GET'
                out = filePath;
            run;

        filename filePath;

      %*Include file if file has a .sas extension.;
        %if %upcase(&fileExtension) = SAS %then %do;
            filename fileURL url "&fileURL";
                %include fileURL;
            filename fileURL;
        %end;

    %end;

%mend  gitGot;
