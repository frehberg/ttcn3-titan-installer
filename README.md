# Installer for Eclipse-TITAN TTCN3 IDE

The following installer-script will download the required Eclipse-binaries of the TTCN3-Titan-project 
from eclipse project-page and will install them locally.

The installer-script requires a Debian-like system, such as Ubuntu or Debian. It has been tested on Ubuntu-16.04 and Ubuntu-17.10.

At first the installer-script is checking for presence of certain deb-packages, being required by the build-process of Titan.

The tools/scripts require the following system-packages (deb) on your host: 
`curl git g++ expect libssl-dev libxml2-dev ibncurses5-dev flex bison xutils-dev default-jdk`

The installer-script will terminate with error if these packages are not present on the host.

Please install them using the following commands (requires sudo/admin-permissions)
```
sudo apt-get install -y curl git g++ expect libssl-dev libxml2-dev
sudo apt-get install -y libncurses5-dev flex bison xutils-dev
sudo apt-get install -y default-jdk
```

Afterwards execute the following curl-command to install the Titan-IDE and Titan-binaries on the local host. The curl command will download the TITAN-installer bash-script `install_titan.sh`, and it will be executed  by `bash`  directly (no further sudo/admin-permissions required)

```
curl https://raw.githubusercontent.com/frehberg/ttcn3-titan-installer/master/install_titan.sh  -sSf | bash
```

The script `install_titan.sh` will download the packages from eclipse-project-pages and will place the following tools in your workspace

-   **eclipse**          ${HOME}/ttcn3-tools/eclipse
-   **TTCN3 titan.core** ${HOME}/ttcn3-tools/titan.core/Install

Finally the corresponding environment variables will be added to `${HOME}/.bashrc`

and a startup-script will be placed at: `${HOME}/bin/titan-ide`

## TODOs

- Use generic URL locations for latest eclipse, and latest builds of Titan-bins and Titan-Eclipse-Plugin
- Parameterize installation prefix, instead of fix prefix ${HOME}/ttcn3-tools
- Download and deploy protocol modules, for example UDP, IP, DHCP, etc. (not sure how protocol modules are added)
- Port installer-script to Redhat/Suse and others.

 
