#!/usr/bin/env php
<?php
echo "Running pmmp/phpstan analyzer\n";

if(!is_dir("/plugin")) {
	echo "/plugin is not mounted!\n";
	exit(1);
}

if(!is_readable("/plugin")) {
	echo "/plugin is not readable by user 1000.\n";
	exit(1);
}

chdir("/plugin");

if(!is_file("plugin.yml")) {
	echo "plugin.yml not found in /plugin. Are the paths set correctly?\n";
	exit(1);
}

if(!is_dir("src")) {
	echo "src not found in /plugin. Are the paths set correctly?\n";
	exit(1);
}

$manifest = yaml_parse(file_get_contents("plugin.yml"));
$deps = [];
foreach(["depend", "softdepend", "loadbefore"] as $attr) {
	if(isset($manifest[$attr])) {
		array_push($deps, ...$manifest[$attr]);
	}
}

foreach($deps as $dep) {
	if(empty($dep)) continue;
	echo "Attempting to download dependency $dep from Poggit...\n";
	$code = pclose(popen("wget -O /deps/$dep.phar https://poggit.pmmp.io/get/$dep", "r"));
	if($code !== 0) {
		echo "Warning: Failed to downloading dependency $dep\n";
		// still continue executing
	}
}

$proc = proc_open("phpstan analyze", [["file", "/dev/null", "r"], STDOUT, STDERR], $pipes);
if(is_resource($proc)) {
	$code = proc_close($proc);
	exit($code);
}
