options mprint;

%sysmacdelete viridis / nowarn;


*---------- Point to your local copy of install_github.sas. ----------;
%include "H:\GitHub\RhoInc\sas-install-github\src\install_github.sas";


*---------- Install a single file. ----------;
%install_github
    (repo=RhoInc/sas-viridis
    ,file=src/viridis.sas
    )

%viridis(n=4)

