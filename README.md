# PocketMine-Docker
Hosts the files used to build pmmp/pocketmine-mp docker image

## What is this?
Docker lets you install software more easily by "copying the whole machine over".
To use Docker, you must be on a Linux/MacOS machine.

To install Docker, refer to the [official Docker docs](https://docs.docker.com/engine/install/).

## Running PocketMine-MP from Docker (using Docker Hub)
This is really easy once you have `docker` installed.

(Although this is an ELI5, you still need to know how to run commands on a Linux/MacOS machine and already have Docker installed)

```
mkdir wherever-you-want
cd wherever-you-want
mkdir data plugins
sudo chown -R 1000:1000 data plugins
docker run -it -p 19132:19132/udp -v $PWD/data:/data -v $PWD/plugins:/plugins ghcr.io/pmmp/pocketmine-mp
```

To run a specific version, just add it to the end of the command, like this:
```
docker run -it -p 19132:19132/udp -v $PWD/data:/data -v $PWD/plugins:/plugins ghcr.io/pmmp/pocketmine-mp:4.0.0
```


## Changing the server port
Docker allows you to map ports, so you don't need to edit `server.properties`.

In the run command shown above, change `19132:19132/udp` to `<port number you want>:19132/udp`. **Note: Do not change the second number.**

**Note: Do not change the port in `server.properties`. This is unnecessary when using Docker and will make things more complicated.**

## Editing the server data
The server data (e.g. worlds, `server.properties`, etc.) will be stored in the `data` folder you created above.

**Note: If you add new files (e.g. a world), don't forget to change the ownership of the file/folder to `1000:1000`**:
```
sudo chown -R 1000:1000 <file/folder you added>
```
This is needed to make the server able to access the file/folder.

## Adding plugins
Plugins can be added by putting them in `plugins` folder you created earlier.


**Note: If you add new files, don't forget to change the ownership of the file/folder to `1000:1000`:
```
sudo chown -R 1000:1000 <file/folder you added>
```
This is needed to make the server able to access the file/folder.

## Run the server in the background
To run the server in the background, simply change `-it` to `-itd` in the last command above.
This will run the server in the background even if you closed console. (No need to `screen`/`tmux` anymore!)

### Opening the console of the server
Use `docker ps` to see a list of running containers. It will look like this:
```
user@DYLANS-PC:~/pm-docker-test$ docker ps
CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS         PORTS                                                                              NAMES
dc20edd3dd62   pmmp/pocketmine-mp:4.0.0   "start-pocketmine"       7 seconds ago   Up 6 seconds   19132/tcp, 0.0.0.0:19132-19133->19132-19133/udp, :::19132-19133->19132-19133/udp   brave_dijkstra
```
In this case, the container name is `brave_dijkstra`, but it might be something else in your case.

To open the console, run the following command:

```
docker attach <container name you saw in docker ps>
```

To leave the console, just press `Ctrl p` `Ctrl q`.

### Viewing the logs
To see the logs, run the following command:
```
docker logs --tail=100 <container name you saw in docker ps>
```
Change `--tail=100` to the number of recent lines in the log you want to see.

## Reference
This section is the technical reference for users who already know how to use Docker.

### Volumes
- `/data` is a read-write data directory where PocketMine stores all data in.
	This includes PocketMine config files, player data, worlds and plugin config files/data.
- `/plugins` is a read-only data directory where PocketMine loads plugins from.
	However, if the `POCKETMINE_PLUGINS` environment variable is set, the default start command may try to manage the plugins inside.

### Environment variables
- `$POCKETMINE_PLUGINS` is the list of plugins in the format `PluginOne:1.2.3 PluginTwo:4.5.6`. The version part (`:4.5.6`) can be omitted.
	The default start command will check if these plugins are loaded
	(by checking if `/plugins/PluginName.phar` exists, so if it has a different name, it will attempt to download again),
	and download missing plugins from Poggit.

### Start command
The default start script is located at `/usr/bin/start-pocketmine`.
It validates the permissions of /data and /plugins,
downloads plugins for `$POCKETMINE_PLUGINS`,
then runs the server.

The PHP binaries are located at `/usr/php`.
A symlink at `/usr/bin/php` points to the PHP executable there.
(`PHP_BINARY` will still report that it is installed in `/usr/php/bin/php`)

### Server directory
The server directory is located at `/pocketmine`.
This directory should only contain a `PocketMine-MP.phar` file,
and shall be the working directory of the server unless changed by plugins.

### Default user
`/pocketmine` is also the home directory of the default user `pocketmine`.
Unlike early pmmp/pocketmine-mp images, this default user is no longer a sudoer,
so plugins cannot acquire root access under normal circumstances.

## Building this image
The Dockerfile requires a build-arg `PMMP_TAG` indicating the tree on pmmp/PocketMine-MP to checkout for building.
Currently, this image does not support building from local PocketMine-MP source directories
and always uses a tree from pmmp/PocketMine-MP on GitHub.
However, this can be easily changed by simply changing the `git clone` command.
