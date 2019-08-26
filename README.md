# pfred-docker

# Description
This is a repository for the Dockerfile and file dependencies for the RESTful-PFRED service that is compiled as a `.war` file (see [pfred-rest-service](https://github.com/pfred/pfred-rest-service)). 

# Creating the pfredservice docker container
## Cloning this repository (Windows)
If you are cloning this repository and wnat to create the service in a Windows machine, then set `git` to not change the scripts `EOL` Unix setting. Do this via the following git command in CLI:

`git config --global core.autocrlf false`

Then the environment on WIndows should be ready to deploy.

## Image builder
To use this Dockerfile layer, run the following docker command:

`docker build -t pfredimg .`

Note that this process will setup the pfredservice environment and install all needed
dependencies. Process might take up to 10 mins in a regular modern laptop.

## Running the service container

Once the pfredimg image has been created, docker should now show the status and running uptime:

`docker images`

Then, the container can be loaded by the following command:

`docker-compose up -d`

If run for the first time, this will create a docker volume named `dockerfiles-sl_pfred-vol` and a docker container 
named `pfredservice`. Note that the `-d` flag will detach the shell from the running container, the RESTful service will not be ready to use until the command `docker-compose logs` shows a `Tomcat started` message.

Once the service is ready, you should be able to access the REST API at http://localhost:8080/PFREDRestService/api. Keep in mind that the `entrypoint` will download the scripts and data generated from `bowtie`, therefore it might take up to 10 mins while the container downloads everything it needs before the pfredservice is ready.

The `entrypoint` will also create a docker volume named `pfred-docker_pfred-vol` so that if the pfredservice docker container is killed, it can be reloaded via the command:

`docker-compose up -d pfred-service`

And the service container should be immediately ready for use since all the data has been stored into `pfred-docker_pfred-vol`.

## Unloading the service container and cleaning up

Once the service has been used and it is not longer needed, execute:

`docker-compose down`

This will remove containers, networks, volumes and images created by `docker-compose up`.

If the pfredimg is not longer needed, it can be removed via the command:

`docker rmi pfredimg`

Docker provides a single command that will clean up any resources — images, containers, volumes, and networks
that are dangling (not associated with a container), and to additionally remove any stopped containers and
all unused images (not just dangling images), add the -a flag to the command:

`docker system prune -a`

Then you should see no images or volumes,

`docker images -a`

`docker volume ls`
