# sas-install-github

This repository contains SAS code for downloading and installing other SAS code directly from GitHub. Gone will be the days of downloading ZIP files and writing %include statments. Simply point to the repository containing your SAS code and let %install_github take care of the rest.

```
*--- install a single file ---;
%install_github
    (repo=RhoInc/sas-violinPlot
    ,file=src/violinPlot.sas
    )
%violinPlot    
    (data = sashelp.cars 
    ,outcomeVar = mpg_city 
    ,outPath = &path
    ,outName = violin_folder
    );


*--- install a folder full of files ---;
%install_github
    (repo=RhoInc/sas-codebook
    ,folder=Macros
    )
%codebook_generic
    (data=sashelp.class
    ,pdfpath=C:\temp
    )
```
