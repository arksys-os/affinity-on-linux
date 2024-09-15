# Affinity on Linux

![GOD_OF_WINE](./img/affinity-god-of-wine.png)

> [!NOTE]
> This is possible thanks to this people:
- [Affinity Wine Docs (by wanesty)](https://affinity.liz.pet/)
- [Wine patch for Affinity apps (by ElementalWarrior)](https://gitlab.winehq.org/ElementalWarrior/wine/-/commits/affinity-photo3-wine9.13-part3)
- [Video installation (by Mattscreative)](https://www.youtube.com/watch?v=0gB4TdIXCOo)


## Brief intro

The Affinity Suite (Design, Photo, Publisher) is a proprietary design, photo editing and desktop publishing software suite developed for MacOS and Windows by Serif (now a subsidiary of Canva).

These applications are well known for being good alternatives to the Adobe suite such as PhotoShop, Illustrator and InDesign, and sometimes are considered better than well-known open source alternatives such as GIMP and Krita. As these applications were not developed for Linux and the FOSS alternatives are not at the same level, many attempts have been made to install correctly Affinity apps on Linux.

One of the big projects that permit to run Windows software on Linux is [WINE](https://en.wikipedia.org/wiki/Wine_(software)) "a free and open-source compatibility layer to allow application software and computer games developed for Microsoft Windows to run on Unix-like operating systems". WINE is developed using reverse-engineering to avoid copyright issues, and each application has unique dependencies, making configuration complex. To simplify this GUI wine prefixer exist like [Bottles](https://usebottles.com/), [Lutris](https://lutris.net/), [PlayOnLinux](https://www.playonlinux.com/en/), [Winetricks](https://github.com/Winetricks/winetricks). Also tools based on WINE with custom patches, extra libraries and tweaks are needed for specific cases like games with [Proton](https://github.com/ValveSoftware/Proton) and [Proton-GE](https://github.com/GloriousEggroll/proton-ge-custom) and Affinity apps like [ElementalWarrior Wine](https://gitlab.winehq.org/ElementalWarrior/wine/-/commits/affinity-photo3-wine9.13-part3). 


## Requeriments to execute the script:
> WINE requires Xorg (Window System display server), if you are on Wayland needs the XWayland bridge.
- Download only **".exe"** from the [Affinity (serif) website](https://affinity.serif.com/en-us/) or direclty from the Affinity apps links: [Designer](https://store.serif.com/en-us/update/windows/designer/2/), [Photo](https://store.serif.com/en-us/update/windows/photo/2/), [Publisher](https://store.serif.com/en-us/update/windows/publisher/2/).
- Copy .winmd files from Windows 10/11 "C:/windows/system32/WinMetadata".
- Create a folder WINE on your home (home/username/WINE).
- Copy the exes and WinMetadata under the "WINE" folder.

You should have these folders and files under `/home/Your-Username/WINE`.

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

This installation is based on [Affinity Wine Docs](https://affinity.liz.pet/docs/1-intro.html) which use [ElementalWarrior's](https://gitlab.winehq.org/ElementalWarrior/wine/-/tree/affinity-photo3-wine9.13-part3) wine fork.

### 1. WINE with [rum](https://gitlab.com/xkero/rum) (recommended)

> [!note]
> Rum is a simple utility designed to work with Wine prefixes. The scirpt works for Arch, Debian, Fedora, OpenSUSE

- Download and execute the script [affinity-wine-rum.sh](./scripts/affinity-wine-rum.sh) running `sh ./scripts/affinity-wine-rum.sh`

> [!note]
> For Arch you can also run [affinity-photo-wine-rum-archlinux.sh](./scripts/affinity-photo-wine-rum-archlinux.sh) or try the [arch PKGBUILD](./arch-affinity-photo/) (experimental), but you need the 'WinMetada' dir.


<details>
  <summary>
    1. Use WINE with [Bottles](https://usebottles.com/) (not working and not recommended)
  </summary>
  <div>
    <ul>
    <li>Option A. Do it manually, via scripts CLI.
        <ul>
          <li>Compile manually ElementalWarior WINE:
            <pre>
              <code class="lang-sh">
                git clone https://gitlab.winehq.org/ElementalWarrior/wine.git "$HOME/WINE/ElementalWarrior-wine"
                cd $HOME/WINE/ElementalWarrior-wine
                git switch affinity-photo3-wine9.13-part3
                mkdir -p winewow64-build/ wine-install/
                cd winewow64-build
                ../configure --prefix="$HOME/WINE/ElementalWarrior-wine/wine-install" --enable-archs=i386,x86_64
                make --jobs 4
                make install
              </code>
            </pre>
          </li>
          <li>Install <a href="https://flathub.org/apps/com.usebottles.bottles">Bottles from FlatHub</a> if you don&#39;t have it, you need flatpak <code>flatpak install flathub com.usebottles.bottles</code>.</li>
          <li>Add the compiled Wine build as a &quot;runner&quot; in Bottles to this directory
          <pre>
            <code>
              mkdir -p "$HOME/.var/app/com.usebottles.bottles/data/bottles/runners/affinity-photo3-wine9.13-part3"
              cp -r "$HOME/WINE/ElementalWarrior-wine/wine-install" "$HOME/.var/app/com.usebottles.bottles/data/bottles/runners/affinity-photo3-wine9.13-part3/"
            </code>
          </pre>
          </li>
          <li>Open &quot;Bottles&quot; and create a bottle using the &quot;affinity-photo3-wine9.13-part3&quot; runner.</li>
          <li>
            Install winetricks with your package manager and add &quot;dotnet48&quot; running on a terminal
            <code>WINEPREFIX="$HOME/.var/app/com.usebottles.bottles/data/bottles/bottles/[bottle-name]" winetricks dotnet48</code>. Replace [bottle-name] with the name of your bottle.
          </li>
          <li>Install allfonts dependency from Bottles.</li>
          <li>Set the &quot;Windows Version&quot; back to win10.</li>
        </ul>
      </li>
    </ul>
    <ul>
      <li>Option B. Execute the script <a href="./scripts/affinity-wine-bottles.sh">affinity-wine-bottles.sh</a> running <code>sh ./scripts/affinity-wine-bottles.sh</code></li>
    </ul>
  </div>
</details>


## Extra: create desktop app
Create the desktop file launchers.
- Modify [designer.desktop](./desktop/designer.desktop), [photo.desktop](./desktop/photo.desktop), [publisher.desktop](./desktop/publisher.desktop)
  - Change "$HOME" by your path "/home/username" (quick method search & replace in vscode)
  - Add the icon (svg or png) to the path of the installation the icons are on this repo under [img](./img/).

> If are using bottles the command to launch the app won't work, you need to adapt it or launch from Bottles.

Example of [publisher.desktop](./desktop/publisher.desktop):
```
#!/usr/bin/env xdg-open
[Desktop Entry]
Name=Affinity Publisher 2
GenericName=Publisher on Wine
Comment=Run Affinity Publisher 2 under Wine
Exec=rum affinity-photo3-wine9.13-part3 $HOME/.wineAffinity wine '$HOME/.wineAffinity/drive_c/Program Files/Affinity/Publisher 2/Publisher.exe'
Icon=$HOME/.wineAffinity/drive_c/Program Files/Affinity/Publisher 2/publisher.svg
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
- [Why use rum instead of Bottles? - Wanesty](https://affinity.liz.pet/docs/misc-QnA.html#q-why-use-rum-instead-of-bottles)
