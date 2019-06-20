# start
export DEBIAN_FRONTEND=noninteractive

# apt
sudo apt-get update
sudo apt-get upgrade -y

# brew
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
echo 'eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)' >>~/.profile
eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
sudo apt-get install build-essential
brew install gcc 

# cleanup
export DEBIAN_FRONTEND=readline
