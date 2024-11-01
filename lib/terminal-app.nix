{ config, lib, extraTerminalModules ? {}, ... }: rec {
	terminal-modules = (lib.filterAttrs (k: v: builtins.elem k ["alacritty" "foot"]) config.modules) // extraTerminalModules;
	terminal-module-list = lib.attrsToList terminal-modules;
	terminal-module = (lib.findFirst (m: m.value.enable) 0 terminal-module-list);
	terminal-app = "${terminal-module.value.package}/bin/${terminal-module.name}";
}
