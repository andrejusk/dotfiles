indent() { sed 's/^/  /'; }

# Symlink contents of source folder to target 
#
# @arg $1 source
# @arg $2 target
#
link_folder () {

    source=$1
    target=$2

    for file in $(ls -d $source)
    do
        rel_path=$(realpath --relative-to="$target" "$file")
        printf "Linking $file to $target as $rel_path...\n"
        ln -sf $target $rel_path
    done

}

# Return if specified binary is not in PATH
is_missing () {
    return ! hash $1
}

C_BLACK='\033[0;30m'
C_DGRAY='\033[1;30m'
C_RED='\033[0;31m'
C_LRED='\033[1;31m'
C_GREEN='\033[0;32m'
C_LGREEN='\033[1;32m'
C_ORANGE='\033[0;33m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_LBLUE='\033[1;34m'
C_PURPLE='\033[0;35m'
C_LPURPLE='\033[1;35m'
C_CYAN='\033[0;36m'
C_LCYAN='\033[1;36m'
C_LGRAY='\033[0;37m'
C_WHITE='\033[1;37m'
C_NC='\033[0m'
