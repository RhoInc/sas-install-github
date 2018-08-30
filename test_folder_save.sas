options mprint;


*---------- Point to your local copy of install_github.sas. ----------;
%include "H:\GitHub\RhoInc\sas-install-github\src\install_github.sas";


*---------- Point to where repos/macros/output should be saved. ----------;
%let path = H:\temp\sascodefromgithub;


*---------- Install (and save) all files in a folder. ----------;
%install_github
    (repo=RhoInc/sas-violinPlot
    ,folder=src
    ,savePath=H:/temp/sascodefromgithub
    )

%violinPlot
    (data = sashelp.cars 
    ,outcomeVar = mpg_city 
    ,outPath = &path 
    ,outName = violin_folder
    )
