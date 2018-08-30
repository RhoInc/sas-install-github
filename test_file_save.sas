options mprint;


*---------- Point to your local copy of install_github.sas. ----------;
%include "H:\GitHub\RhoInc\sas-install-github\src\install_github.sas";


*---------- Point to where repos/macros/output should be saved. ----------;
%let path = H:\temp\sascodefromgithub;


*---------- Install (and save) a single file. ----------;
%install_github
    (repo=RhoInc/sas-viridis
    ,file=src/viridis.sas
    ,savePath=H:/temp/sascodefromgithub
    )

%viridis(n=4)

