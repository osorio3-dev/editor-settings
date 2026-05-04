# ===============
# MAIN SETUP
# ===============
sudo apt update

# Carpetas
mkdir -p "$HOME/code"
mkdir -p "$HOME/code/mockups"
mkdir -p "$HOME/code/database"
mkdir -p "$HOME/code/mobile"
mkdir -p "$HOME/code/php"
mkdir -p "$HOME/code/scripts"
mkdir -p "$HOME/code/python"

# Tools
sudo apt install eza
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"


# ===============
# INSTALL EDITORS
# ===============
# ZED
curl -f https://zed.dev/install.sh | sh

# JETBRAINS
sudo apt-get install -y libfuse2
cd ~/
wget -c https://download.jetbrains.com/toolbox/jetbrains-toolbox-3.4.3.81140.tar.gz
sudo tar -xzf jetbrains-toolbox-3.4.3.81140.tar.gz -C /opt
/opt/jetbrains-toolbox-3.4.3.81140/bin/jetbrains-toolbox

# ===============
# INSTALL HOMBREW
# ===============
sudo apt update
sudo apt install -y build-essential procps curl file git

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Homebrew a shell
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Validar
brew --version
brew doctor


# ===============
# INSTALL DOCKER
# ===============
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

UBUNTU_CODENAME=$(cat /etc/upstream-release/lsb-release | grep CODENAME | cut -d '=' -f 2)
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Validar
docker --version
docker compose version

# Usar sin SUDO
sudo usermod -aG docker $USER
newgrp docker

# Prueba
docker run --rm hello-world

# ==================
# Instalar UV
# ==================
curl -LsSf https://astral.sh/uv/install.sh | sh

# ==================
# INSTALAR Gentleman Doftiles
# ==================
brew install Gentleman-Programming/tap/gentleman-dots
gentleman-dots

# Starship
curl -sS https://starship.rs/install.sh | sh
starship init fish | source
starship preset catppuccin-powerline -o ~/.config/starship.toml

# ==================
# FIX 3070
# ==================
sudo apt purge 'nvidia*' 'libnvidia*' -y
sudo apt autoremove -y
sudo apt update
sudo apt install linux-headers-$(uname -r) dkms -y
sudo apt install nvidia-driver-570 nvidia-utils-570 libnvidia-gl-570 -y
sudo reboot

# Blender Environment:
# __NV_PRIME_RENDER_OFFLOAD=1
# __GLX_VENDOR_LIBRARY_NAME=nvidia
# CUDA_VISIBLE_DEVICES=1

# Steam Environment:
# __NV_PRIME_RENDER_OFFLOAD=1
# __GLX_VENDOR_LIBRARY_NAME=nvidia
# __VK_LAYER_NV_optimus=NVIDIA_only
# CUDA_VISIBLE_DEVICES=1

# Heroic Launcher Environment:
# __NV_PRIME_RENDER_OFFLOAD=1
# __GLX_VENDOR_LIBRARY_NAME=nvidia
# MANGOHUD=1  \# FPS monitor
