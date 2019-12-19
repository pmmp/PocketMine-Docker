#!/usr/bin/php -dphar.readonly=0
<?php
if(!isset($argv[3])){
	echo "Usage: inject-metadata <PHAR> <KEY> <VALUE>";
	exit(1);
}
$phar = new Phar($argv[1]);
$metadata = $phar->getMetadata();
$metadata[$argv[2]] = $argv[3];
$phar->setMetadata($metadata);
