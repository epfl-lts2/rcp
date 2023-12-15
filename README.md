# Initial steps

Those steps are meant to be performed only once on the client machine you plan to use
https://wiki.rcp.epfl.ch/home/CaaS/Quick_Start

## Local installation
- Login to https://rcpepfl.run.ai/ using "Sign in with SSO"
- download the runai CLI: help button on the top right of the page then click "Reasearcher command line interface" and follow the instructions. If you do not save it in a directory belonging to your `$PATH` remember to execute it as local binary, e.g. `./runai`
- download the file https://wiki.rcp.epfl.ch/public/files/config.yaml and save it as `~/.kube/config` (you may need to create the `.kube` directory in your home folder)
- install `kubectl` using the documentation [here](https://kubernetes.io/docs/tasks/tools/#kubectl)
-  set the default project `./runai config project <project name>`  where the project name should be `lts2-<gaspar username>`

## Install using the faculty jumphost
- you can use an existing host `haas001.rcp.epfl.ch` on which you can login using your gaspar username and password
- this host already has `kubectl` and `runai` installed
- download the file https://wiki.rcp.epfl.ch/public/files/config.yaml and save it as `~/.kube/config` (you may need to create the `.kube` directory in your home folder)
- set the default project 


# Build a custom docker image
- If you want to fine tune the environment, build your own docker image
- You can use the instructions here https://wiki.rcp.epfl.ch/en/home/CaaS/how-to-rootless or modify the Dockerfile provided in this repository. 
- Although it is possible to skip the uid/gid customization, remember the files created on a volume outside the container will have messed up ownership in this case.
- GID is common to LTS2 = 10423. Your uid is unique, check it in the directory as explained in the link above

