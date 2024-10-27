# Affinity on Linux

![GOD_OF_WINE](./resources/affinity_god_of_wine.png)

> [!NOTE] This is possible thanks to:
>
> - [Affinity Wine Docs (by wanesty)](https://affinity.liz.pet/)
> - [Wine patch for Affinity apps (by ElementalWarrior)](https://gitlab.winehq.org/ElementalWarrior/wine/-/commits/affinity-photo3-wine9.13-part3)
> - [WINE (compatibilit layer)](https://www.winehq.org/)

<!--
## Brief intro
The Affinity Suite (Design, Photo, Publisher) is a proprietary design, photo editing and desktop publishing software suite developed
for MacOS and Windows by Serif (now a subsidiary of Canva).
These applications are well known for being good alternatives to the Adobe suite such as PhotoShop, Illustrator and InDesign, and sometimes
are considered better than well-known open source alternatives such as GIMP and Krita. As these applications were not developed for Linux
and the FOSS alternatives are not at the same level, many attempts have been made to install correctly Affinity apps on Linux.
One of the big projects that permit to run Windows software on Linux is [WINE](https://en.wikipedia.org/wiki/Wine_(software))
"a free and open-source compatibility layer to allow application software and computer games developed for Microsoft Windows to run on
Unix-like operating systems". WINE is developed using reverse-engineering to avoid copyright issues, and each application has unique dependencies,
making configuration complex. To simplify this GUI wine prefixer exist like [Bottles](https://usebottles.com/), [Lutris](https://lutris.net/),
[PlayOnLinux](https://www.playonlinux.com/en/), [Winetricks](https://github.com/Winetricks/winetricks). Also tools based on WINE with custom patches,
extra libraries and tweaks are needed for specific cases like games with [Proton](https://github.com/ValveSoftware/Proton) and [Proton-GE](https://github.com/GloriousEggroll/proton-ge-custom)
and Affinity apps like [ElementalWarrior Wine](https://gitlab.winehq.org/ElementalWarrior/wine/-/commits/affinity-photo3-wine9.13-part3). 
-->

## Requeriments
>
> [!NOTE]
> WINE requires Xorg (Window System Display Server), if you use Wayland you need the XWayland bridge.
>
- Create a folder to group content on the directory  .
- Download **".exe"** apps from here [Designer](https://store.serif.com/en-us/update/windows/designer/2/),
  [Photo](https://store.serif.com/en-us/update/windows/photo/2/), [Publisher](https://store.serif.com/en-us/update/windows/publisher/2/) and copy under the directory "$HOME/WINE/apps".
- Copy WinMetadata directory from Windows 10/11 "C:\windows\system32\WinMetadata" to the directory "$HOME/WINE".

<details>
  <summary>You should have these folders and files under `$HOME/WINE`:</summary>

```sh
╭─YOUR-USERNAME@SYS in ~/WINE
╰─λ tree
.
├── apps
│   ├── affinity-designer-msi-2.5.3.exe
│   ├── affinity-photo-msi-2.5.3.exe
│   └── affinity-publisher-msi-2.5.3.exe
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

</details>

## Installation
>
> [!WARNING]
> Review the bash script and execute at your own risk

<!-- This installation is based on [Affinity Wine Docs](https://affinity.liz.pet/docs/1-intro.html) which use
[ElementalWarrior's](https://gitlab.winehq.org/ElementalWarrior/wine/-/tree/affinity-photo3-wine9.13-part3) wine fork. -->

<details>
  <summary>
    <b>1. WINE with <a href="https://gitlab.com/xkero/rum">rum</a> (recommended)</b>
  </summary>
  <ul>
    <li>For Arch, Debian, Fedora or OpenSUSE download and execute the script
      <a href="./scripts/affinity-wine-rum.sh">affinity-wine-rum.sh</a>
      running <code>sh ./scripts/affinity-wine-rum.sh</code>.
    </li>
  </ul>
</details>
<details>
  <summary>
    <b>2. Use WINE with <a href="https://usebottles.com/">Bottles</a> (not working)</b>
  </summary>

- Option A. Do it manually, via scripts CLI.
  - Compile manually ElementalWarior WINE:

  ```sh
  git clone https://gitlab.winehq.org/ElementalWarrior/wine.git "$HOME/WINE/ElementalWarrior-wine"
  cd $HOME/WINE/ElementalWarrior-wine
  git switch affinity-photo3-wine9.13-part3
  mkdir -p winewow64-build/ wine-install/
  cd winewow64-build
  ../configure --prefix="$HOME/WINE/ElementalWarrior-wine/wine-install" --enable-archs=i386,x86_64
  make --jobs 4
  make install
  ```

  - Install [Bottles from FlatHub](https://flathub.org/apps/com.usebottles.bottles) as `flatpak install flathub com.usebottles.bottles`.
  - Add the compiled Wine build as a runner in Bottles to this directory.

  ```sh
  mkdir -p "$HOME/.var/app/com.usebottles.bottles/data/bottles/runners/affinity-photo3-wine9.13-part3"
  cp -r "$HOME/WINE/ElementalWarrior-wine/wine-install" "$HOME/.var/app/com.usebottles.bottles/data/bottles/runners/affinity-photo3-wine9.13-part3/"
  ```

  - Open "Bottles" and create a bottle using the `affinity-photo3-wine9.13-part3` runner.
  - Install winetricks with your package manager and add "dotnet48" running `WINEPREFIX="$HOME/.var/app/com.usebottles.bottles/data/bottles/bottles/[bottle-name]" winetricks dotnet48`.
  - Install allfonts dependency from Bottles.
  - Set the "Windows Version" back to win10.

- Option B. Execute the script [affinity-wine-bottles.sh](./scripts/affinity-wine-bottles.sh) running `sh ./scripts/affinity-wine-bottles.sh`

</details>

## Extra: create desktop shortcut

> The desktop shortcut only works for rum

- Create desktop shortcuts to launch the apps from your desktop environment and modify the icon and app path to your case. Here are the three Affinity shortcut apps:
  - [designer.desktop](./resources/designer.desktop)
  - [photo.desktop](./resources/photo.desktop)
  - [publisher.desktop](./resources/publisher.desktop)

## More

- [Affinity Photo - WineHQ AppDB](https://appdb.winehq.org/objectManager.php?sClass=application&iId=18332)
- [ Affinity Suite V2 on Linux [Wine] - Affinity Forum](https://forum.affinity.serif.com/index.php?/topic/182758-affinity-suite-v2-on-linux-wine/page/25/)
- [Affinity running on Linux with Bottles - Affinity Forum](https://forum.affinity.serif.com/index.php?/topic/166159-affinity-photo-running-on-linux-with-bottles/page/8/)
- [Why use rum instead of Bottles? - Wanesty](https://affinity.liz.pet/docs/misc-QnA.html#q-why-use-rum-instead-of-bottles)
