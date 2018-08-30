# sas-install-github

This repository contains SAS code for downloading and installing other SAS code directly from GitHub. Gone will be the days of downloading ZIP files and writing %include statments. Simply point to the repository containing your SAS code and let %install_github take care of the rest.

```
%install_github(repo=RhoInc/sas-viridis)
%viridis(n=4)
```
