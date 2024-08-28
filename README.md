# Affinity on Linux

![GOD_OF_WINE](./img/affinity-god-of-wine.png)

> [!NOTE]  
> Thanks to: [Affinity Wine Docs (by wanesty)](https://affinity.liz.pet/) & [tutorial installation (by Mattscreative)](https://www.youtube.com/watch?v=0gB4TdIXCOo)


## Brief intro

The Affinity Suite (Design, Photo, Publisher) is a proprietary design, photo editing and desktop publishing software suite developed for MacOS and Windows by Serif (now a subsidiary of Canva).

These applications are well known for being a real alternative to the Adobe suite such as PhotoShop, Illustrator and InDesign, and are considered better than well-known open source alternatives such as GIMP and Krita. As these applications were not developed for Linux and the FOSS alternatives are not at the same level, many attempts have been made to configure these applications correctly on Linux.

One of the big projects that permit to run Windows software on Linux is [WINE](https://en.wikipedia.org/wiki/Wine_(software)) a free and open-source compatibility layer to allow application software and computer games developed for Microsoft Windows to run on Unix-like operating systems.

Because there are many Windows applications and they are very different from each other, with dependencies, fonts, frameworks, configuring WINE is a very difficult job. For this reason graphical Wine prefixes and managers have emerged, some examples for apps are [Bottles](https://usebottles.com/), [rum](https://gitlab.com/xkero/rum), [CrossOver](https://www.codeweavers.com/crossover/) and for gaming [Lutris](https://lutris.net/), [Play On Linux](https://www.playonlinux.com/en/) or [Proton](https://github.com/ValveSoftware/Proton) to play Steam games on Linux-based operating systems.


## Requeriments to execute the script:
- Download affinity apps executables (.exe) from the [official website](https://affinity.serif.com/en-us/). There are trial version and the payment is only one time (better than PhotoShop).
- Copy .winmd files from Windows 10/11 "C:/windows/system32/WinMetadata".
- Create a folder WINE on your home (homwe/username/WINE).
- Copy the exes and WinMetadata under the "WINE" folder.

You should have these folders and files under /home/Your-Username/WINE.

```sh
╭─YOUR-USERNAME@SYS in ~/WINE
╰─λ tree
.
├── apps
│   ├── affinity-designer-msi-2.5.3.exe
│   ├── affinity-photo-msi-2.5.3.exe
│   └── affinity-publisher-msi-2.5.3.exe
└── WinMetadata
    ├── Windows.AI.winmd
    ├── Windows.ApplicationModel.winmd
    ├── Windows.Data.winmd
    ├── Windows.Devices.winmd
    ├── Windows.Foundation.winmd
    ├── Windows.Gaming.winmd
    ├── Windows.Globalization.winmd
    ├── Windows.Graphics.winmd
    ├── Windows.Management.Setup.winmd
    ├── Windows.Management.winmd
    ├── Windows.Media.winmd
    ├── Windows.Networking.winmd
    ├── Windows.Perception.winmd
    ├── Windows.Security.winmd
    ├── Windows.Services.winmd
    ├── Windows.Storage.winmd
    ├── Windows.System.winmd
    ├── Windows.UI.winmd
    ├── Windows.UI.Xaml.winmd
    └── Windows.Web.winmd
```


## Installation via script
> [!WARNING]
> Review the bash script and execute at your own risk

There are two options adapted from the [Affinity Wine Docs](https://affinity.liz.pet/docs/1-intro.html) which use [ElementalWarrior's Wine fork](https://gitlab.winehq.org/ElementalWarrior/wine/-/tree/affinity-photo3-wine9.13-part3):

1. Use WINE with [rum](https://gitlab.com/xkero/rum) (recommended)
    - Download and execute the script [affinity-wine-rum.sh](affinity-wine-rum.sh) running `sh affinity-wine-rum.sh`

2. Use WINE with [Bottles](https://usebottles.com/)
   - Import the configuration via [affinty-wine-bottles.yml](./affinty-wine-bottles.yml) or do it manually and execute the script [affinity-wine-bottles.sh](affinity-wine-bottles.sh) running `sh affinity-wine-bottles.sh`

## Extra: create desktop app
Create the desktop file launchers.
- Modify [designer.desktop](designer.desktop), [photo.desktop](photo.desktop), [publisher.desktop](publisher.desktop)
  - Change the "USERNAME" by your name (quick method search & replace in vscode)
  - Add the icon (svg or png) to the path of the installation the icons are on this repo under [img](./img/).

> If are using bottles the command to launch the app won't work, you need to adapt it or launch from Bottles.

Example of [publisher.desktop](publisher.desktop):
```
#!/usr/bin/env xdg-open
[Desktop Entry]
Name=Affinity Publisher 2
GenericName=Publisher on Wine
Comment=Run Affinity Publisher 2 under Wine
Exec=rum affinity-photo3-wine9.13-part3 /home/USERNAME/.wineAffinity wine '/home/USERNAME/.wineAffinity/drive_c/Program Files/Affinity/Publisher 2/Publisher.exe'
Icon=/home/USERNAME/.wineAffinity/drive_c/Program Files/Affinity/Publisher 2/publisher.svg
Categories=Graphics
Keywords=Graphics;
MimeType=application/x-affinity
NoDisplay=false
StartupNotify=true
Terminal=false
Type=Application
StartupWMClass=Publisher.exe
```


## More
- [Affinity Photo - WineHQ AppDB](https://appdb.winehq.org/objectManager.php?sClass=application&iId=18332)
- [ Affinity Suite V2 on Linux [Wine] - Affinity Forum](https://forum.affinity.serif.com/index.php?/topic/182758-affinity-suite-v2-on-linux-wine/page/25/)
- [Affinity running on Linux with Bottles - Affinity Forum](https://forum.affinity.serif.com/index.php?/topic/166159-affinity-photo-running-on-linux-with-bottles/page/8/)
- [Tips and fixes - affinity-wine-docs](https://codeberg.org/wanesty/affinity-wine-docs/src/branch/guide-wine9.13-part3/Tips-n-Fixes.md)
- [Why rum instead of Bottles? - Wanesty](https://affinity.liz.pet/docs/misc-QnA.html#q-why-use-rum-instead-of-bottles)
