# Installer for Eclipse-TITAN TTCN3 IDE

The following installer-script will download the required Eclipse-binaries of the TTCN3-Titan-project 
from eclipse project-page and will install them locally.

The installer-script requires a Debian-like system, such as Ubuntu or Debian. It has been tested on Ubuntu-16.04 and Ubuntu-17.10.

At first the installer-script is checking for presence of certain deb-packages, being required by the build-process of Titan.

The tools/scripts require the following system-packages on your host: ` curl git g++ expect libssl-dev libxml2-dev ibncurses5-dev flex bison xutils-dev default-jdk`

Install them using the following commands (requires sudo/admin-permissions)
```
sudo apt-get install -y curl git g++ expect libssl-dev libxml2-dev
sudo apt-get install -y libncurses5-dev flex bison xutils-dev
sudo apt-get install -y default-jdk
```

Afterwards the following command will download the TITAN-installer bash-script, and will execute it directly (no further sudo/admin-permissions required)


```
curl https://raw.githubusercontent.com/frehberg/ttcn3-titan-installer/master/install_titan.sh  -sSf | bash
```

The script will download the packages from eclipse-project-pages and will place the following tools in your workspace

-   **eclipse**          ${HOME}/ttcn3-tools/eclipse
-   **TTCN3 titan.core** ${HOME}/ttcn3-tools/titan.core/Install

Finally the corresponding environment variables will be added to `${HOME}/.bashrc`

and a startup-script will be placed at: `${HOME}/bin/titan-ide`
