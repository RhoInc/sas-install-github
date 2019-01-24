options mprint;

%sysmacdelete viridis / nowarn;


*---------- Point to your local copy of install_github.sas. ----------;
%include "I:\SHARE\USERS\srosanba\install_github\src\install_github.sas";


*---------- Install a single file. ----------;
%install_github
    (repo=RhoInc/sas-viridis
    ,file=src/viridis.sas
    );

*---------- Generate some colors. ----------;
%viridis(n=4);
