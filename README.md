# Installer for Eclipse-TITAN TTCN3 IDE

The following script will download the required binaries from eclipse project and will install them locally

The tools/scripts require the following system-packages on your host: ` curl git g++ expect libssl-dev libxml2-dev ibncurses5-dev flex bison xutils-dev default-jdk`

Install them with following commands (requires sudo/admin-permissions)
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

Corresponding environment variables will be defined in `${HOME}/.bashrc`

A startup script will be located: `${HOME}/bin/titan-ide`
