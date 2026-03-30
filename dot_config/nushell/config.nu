mkdir ($nu.data-dir | path join "vendor/autoload")

starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
atuin init nu | save -f ($nu.data-dir | path join "vendor/autoload/atuin.nu")

source ($nu.default-config-dir | path join "catppuccin_mocha.nu")

$env.config.show_banner = false

