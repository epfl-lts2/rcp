# Initial steps

Those steps are meant to be performed only once on the client machine you plan to use
https://wiki.rcp.epfl.ch/home/CaaS/Quick_Start

## Local installation
- Login to https://rcpepfl.run.ai/ using "Sign in with SSO"
- download the runai CLI: help button on the top right of the page then click "Researcher command line interface" and follow the instructions. If you do not save it in a directory belonging to your `$PATH` remember to execute it as local binary, e.g. `./runai`
- download the file https://wiki.rcp.epfl.ch/public/files/config.yaml and save it as `~/.kube/config` (you may need to create the `.kube` directory in your home folder)
- install `kubectl` using the documentation [here](https://kubernetes.io/docs/tasks/tools/#kubectl)
- login with `runai login` (you will need to enter a code generated from the RunAI portal)
- set the default project `./runai config project <project name>`  where the project name should be `lts2-<gaspar username>`

## Install using the faculty jumphost
- you can use an existing host `haas001.rcp.epfl.ch` on which you can login using your gaspar username and password
- this host already has `kubectl` and `runai` installed
- download the file https://wiki.rcp.epfl.ch/public/files/config.yaml and save it as `~/.kube/config` (you may need to create the `.kube` directory in your home folder)
- Do the `runai login` step
- set the default project 
- NB: you will *not* be able to build docker images on the faculty jumphost

# Running a job on the cluster

## Build a custom docker image
If you want to fine tune the environment, build your own docker image
- First, install docker on your computer following the [instructions](https://docs.docker.com/engine/install/)
- You can use the instructions here https://wiki.rcp.epfl.ch/en/home/CaaS/how-to-rootless or modify the `Dockerfile` provided in this repository. The supplied `Dockerfile` and `environment.yml` are used to build a base image, containing
  - miniconda
  - cuda 11.8
  - pytorch (2.1)
  - jupyter
  - pytorch geometric

All python packages are installed in the `base` environment.
This image is available in the RCP registry as `registry.rcp.epfl.ch/lts2-public/pytorch-base`. The file `user/Dockerfile` allows you to customize this base image using your uid/gid and additional packages.
- Although it is possible to skip the uid/gid customization, remember the files created on a volume outside the container will have messed up ownership in this case.
- GID is common to LTS2 = 10423. Your uid is unique, check it in the directory as explained in the link above
- If not done, login with your gaspar username/password on the [EPFL registry](https://registry.rcp.epfl.ch) and create a PUBLIC project. While containers can work with private registries, the setup is much more complicated. If your docker image does not contain sensitive information (and it really should not), go for public.
- make sure you are logged in: `docker login registry.rcp.epfl.ch`
- Build the container, e.g.
```
docker build -t registry.rcp.epfl.ch/<projectname>/<reponame>:latest user \
--build-arg LDAP_GID=10423 \
--build-arg LDAP_UID=<Your EPFL uid> \
--build-arg LDAP_USERNAME=<Your gaspar username> \
--build-arg LDAP_GROUPNAME=lts2 \
```
- Then push it to the registry `docker push registry.rcp.epfl.ch/<projectname>/<reponame>:latest`

## Submit a job to the cluster
- Customize the sample `job.yml` file provided in this repository
- Submit the job `kubectl create -f job.yml`. Although you can submit a job with the `runai` command, this is not recommended as it will not handle the uid/gid properly.
- If everything goes well, your job should be running. You can then forward a port from the container to your local machine, e.g. `kubectl port-forward lts2-test-0-0 8888:8888` if you have a jupyter server running on the default port. (check the container name on the dashboard and of course, adapt the port number accordingly to your needs). 
- You can access a shell inside the container by running `runai exec -it lts2-test /bin/bash` (using the appropriate job name of course)
