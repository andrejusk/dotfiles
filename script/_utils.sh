# Utility functions for common tasks

ARCH=$(dpkg --print-architecture)

# @arg $1 URL to download
# @arg $2 Path to file
function download_file {
    curl \
        --silent \
        --show-error \
        --location \
        --output $2 \
        $1
}

# @arg $1 URL to run
# @arg $2 binary to use
function download_run {
    file=$(mktemp)
    download_file $1 $file
    cat $file | $2
}

# @arg $1 binary to test
function bin_in_path {
    command -v $1
}

# @arg $1 apt package to test
function apt_installed {
    dpkg --status $1 >/dev/null
}

function update {
    sudo apt-get update -qq
}

# @arg $1 apt package to install if not present
function install {
    if ! apt_installed $1; then
        sudo apt-get install -qq $1
    fi
}

# Add apt repository
# @arg $1 JSON object containing the following keys
#   * key        - entry key
#   * repository - apt repository
#   * signingKey - gpg signing key url
#   * components - apt components
function add_repository {
    key=$(jq -r ".key" <<<"$1")
    echo "Updating apt repository ${key}..."

    signingKey=$(jq -r ".signingKey" <<<"$1")
    repository=$(jq -r ".repository" <<<"$1")
    components=$(jq -r ".components" <<<"$1")

    signingKeyPath="/etc/apt/keyrings/${key}.gpg"
    sourcesListPath="/etc/apt/sources.list.d/${key}.list"
    source="deb [signed-by=${signingKeyPath} arch=${ARCH}] ${repository} ${components}"

    sudo mkdir -p /etc/apt/keyrings
    sudo mkdir -p /etc/apt/sources.list.d

    echo "$source" | sudo tee "$sourcesListPath" >/dev/null
    wget -O- "$signingKey" |
        gpg --dearmor |
        sudo tee "$signingKeyPath" >/dev/null
}

# @arg $1 package list file to install
function install_file {
    sudo apt-get install -qqf $(cat $1)
}

# @arg $1 JSON object containing the following keys
#   * name - apt repository
#   * target - gpg signing key url
function stow_package {
    name=$(jq -r ".name" <<<"$1")
    target=$(jq -r ".target" <<<"$1")

    case $target in
    HOME)
        rm -f $HOME/.bashrc
        rm -f $HOME/.profile
        target=$HOME
        ;;
    CONFIG)
        mkdir -p $HOME/.config
        target=$HOME/.config
        ;;
    SSH)
        mkdir -p $HOME/.ssh
        target=$HOME/.ssh
        ;;
    *) ;;

    esac

    echo "Stowing $ABS_DIR/files/$name to $target"
    sudo stow --dir="$ABS_DIR/files" --target=$target $name
}
