<?php

/**
 * @name plugin-test
 * @version 1.0.0
 * @api 3.11.1
 * @main PluginTest
 * @author PMMP Team
 */

class PluginTest extends \pocketmine\plugin\PluginBase {
	public function onEnable() : void {
		$plugin = $this->getServer()->getPluginManager()->getPlugin("PurePerms");
		if($plugin === null) {
			$this->getLogger()->critical("PurePerms is not downloaded");
			exit(1);
		}
		$this->getLogger()->notice("Test passed: PurePerms is downloaded");

		if($plugin->getDescription()->getVersion() !== "1.4.2-c2a") {
			$this->getLogger()->critical("PurePerms has wrong version");
			exit(1);
		}
		$this->getLogger()->notice("Test passed: PurePerms has the correct version");

		$plugin = $this->getServer()->getPluginManager()->getPlugin("PureChat");
		if($plugin === null) {
			$this->getLogger()->critical("PureChat is not downloaded");
			exit(1);
		}
		$this->getLogger()->notice("Test passed: PureChat is downloaded");
	}
}
