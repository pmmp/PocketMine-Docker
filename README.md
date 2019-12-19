# PocketMine-Docker
Hosts the files used to build pmmp/pocketmine-mp docker image

## What is this?
Docker lets you install software more easily by "copying the whole machine over".
To use Docker, you must be on a Linux/MacOS machine.
(Docker also works on Windows, but trying to run Linux containers on Windows usually creates more problems than it solves)

To install Docker, refer to the [official Docker docs](https://docs.docker.com/install/).

## Explained Like I'm 5
(If you prefer a more technical reference, there is a [Reference](#reference) section below)

(You do NOT need to clone this repo to install PocketMine-Docker)

(Although this is an ELI5, you still need to know how to run commands on a Linux/MacOS machine and already have Docker installed)

First, create the directories `data` and `plugins` somewhere to store the server data:

```
mkdir data plugins
```

Set the owner of these directories to user of UID `1000`.
Docker containers identify file owners using the UID,
so if your current user is coincidentally also UID 1000 (you can check this with `echo $UID`),
this operation might do nothing.
Otherwise, you might need root access to change the owner of a directory:

```
sudo chown -R 1000:1000 data plugins
```

`data` will store the server data, and `plugins` will store the server plugins.
You can install plugins inside the `plugins` directory before starting the server.

Now you can run PocketMine-Docker with the following command:

```
docker run -it -p 19132:19132 -v $PWD/data:/data -v $PWD/plugins:/plugins pmmp/pocketmine-mp
```

Do NOT change the server port in server.properties.
If you want to open the server on another port (e.g. `12345` instead),
change the `19132:19132` above to `12345:19132`.
(The second number is ALWAYS `19132`)

### Run the server in the background
To run the server in the background, simply change `-it` to `-itd` in the last command above.
This will run the server in the background even if you closed console. (No need to `screen`/`tmux` anymore!)

When you run this command, it will display the container name that runs the server,
e.g. `admiring_boyd`, `bold_kilby`, or other random names.

To open the console, run the following command:

```
docker attach container_name
```

To leave the console, just press `Ctrl p` `Ctrl q`.

Alternatively, use `docker logs container_name` to view the console output without getting stuck in the console.

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
The Dockerile requires a build-arg `PMMP_TAG` indicating the tree on pmmp/PocketMine-MP to checkout for building.
Currently, this image does not support building from local PocketMine-MP source directories
and always uses a tree from pmmp/PocketMine-MP on GitHub.
However, this can be easily changed by simply changing the `git clone` command.
