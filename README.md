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
    ,outPath = C:\temp
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

While the SAS macro takes the inspiration for its name from the corresponding R package, because of fundamental differences in how SAS and R work, the SAS macro behaves somewhat differently than the R package. In particular, the SAS macro does not try to save the code being accessed. The SAS macro reads the code into your session directly from the web and does not save a local copy. The implicit assumption behind this behavior is that the only reason to save a local copy of SAS code that lives on GitHub would be if you wanted to modify it in some way. In which case, you would no longer need to point to GitHub. So, if you're pointing to GitHub to get the macro, it's either because (a) you scoff at the tedious manual process of using the [Clone/Download] button or (b) you want be sure you are using the most current version of the code with all of the latest bug fixes.
