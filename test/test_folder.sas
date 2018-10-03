%let path = H:\GitHub\RhoInc\sas-install-github\test;

options mprint;



*---------- Point to your local copy of install_github.sas. ----------;
%include "H:\GitHub\RhoInc\sas-install-github\src\install_github.sas";


*---------- Install all files in a folder. ----------;
%sysmacdelete violinplot / nowarn;

%install_github
    (repo=RhoInc/sas-violinPlot
    ,folder=src
    );

%violinPlot
    (data = sashelp.cars 
    ,outcomeVar = mpg_city 
    ,outPath = &path
    ,outName = violin_folder
    );


*---------- Second test case. ----------;
%sysmacdelete codebook_generic / nowarn;

%install_github
   (repo=RhoInc/sas-codebook
   ,folder=Macros
   );

%codebook_generic
   (data=sashelp.class
   ,pdfpath=&path
   );