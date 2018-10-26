# RetroArch Maintenance Scripts

Powershell scripts for updating a [RetroArch](http://www.retroarch.com/) installation. Currently there are the following scripts:

1. *RetroArchCoreUpdater.ps1* - Updates all of your installed cores

## How to use
    .\RetroArchCoreUpdater.ps1 -CoreUpdaterUrl <core_updater_buildbot_url> -RetroArchPath <retroarch_install_path>

`core_updater_buildbot_url` - URL stored in this property in your retroarch.cfg (eg *http://buildbot.libretro.com/nightly/windows/x86_64/latest/*)
`retroarch_path_install` - Fully qualified path to your RetroArch installation folder (eg. *D:\RetroArch*)
