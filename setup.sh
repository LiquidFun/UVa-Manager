#!/bin/bash

source $(dirname $0)/color.sh

# Set the path to your config.sh here
CONFIG="./config.sh"

# Check for existing $CONFIG
if [[ -f $CONFIG ]]; then
    printf "You already have a $CONFIG. Do you want to overwrite it? [y/N] "
    read overwrite

    if [[ "$overwrite" =~ y|Y|yes|Yes ]]; then
        rm -f $CONFIG
        exec $0  # restart the script
    else
        exit 1
    fi
else
    cp config.sh.example $CONFIG
fi

# Preparation
echo "Setting execute permissions on ./uva"
chmod +x ./uva

echo "Installing lxml via pip3"
pip3 install lxml --user

echo "Trying to identify your system to install colordiff"
if [[ -f /etc/os-release ]]; then
    . /etc/os-release

    if [[ -z "$ID_LIKE" ]]; then
        ID_LIKE=$ID
    fi

    case $ID_LIKE in
        debian)
            sudo apt update && sudo apt install -y colordiff ;;
        arch)
            sudo pacman -Sy --noconfirm colordiff ;;
        *)
            echo "Unknown distribution, please install colordiff manually." ;;
        # TODO: Support more package managers
    esac

else
    echo "Failed to identify your system, please install colordiff manually."
fi

# Interactive configuration
echo "--- Configuring $CONFIG ---"
echo "You can always edit your $CONFIG after this installation."

# TODO: show this proposed solutions folder and ask if its correct
# proposed="$(\find ~ -name solutions -print -quit)"
# if [[ -n "$proposed" ]]; then
#     echo ""
# fi

printf "Enter the path to your solutions folder: "
read -e solutionspath
sed -i "s!UVA_HOME=.*\$!UVA_HOME=$solutionspath!" "$CONFIG" 

printf "Enter your Kürzel (or whatever you use as folder name in the problem directories): "
read kuerzel
sed -i "s/KUERZEL=.*\$/KUERZEL=$kuerzel/" "$CONFIG"


echo "Now the script will ask you to enter your onlinejudge.org username and password, \
these will be used if you want to use the submit command.
If you do not want to enter these just leave them empty and press enter on the prompt.
Do note that the password will be saved in plaintext."

printf "Enter your onlinejudge.org username: "
read username
sed -i "s/UVA_JUDGE_NICKNAME=.*\$/UVA_JUDGE_NICKNAME=$username/" "$CONFIG" 

printf "Enter your onlinejudge.org password: "
read password
sed -i "s/UVA_JUDGE_PASSWORD=.*\$/UVA_JUDGE_PASSWORD=$password/" "$CONFIG" 


echo "--- Make uva runnable from anywhere ---"

printf "Should I add uva to ~/.local/bin? [y/N]: "
read response
if [[ "$response" =~ y|Y|yes|Yes ]]; then
    ln -s "$PWD/uva" ~/.local/bin/uva
    echo "Added uva to ~/.local/bin"
fi
unset response

if [[ :$PATH: != *.local/bin:* ]]; then
    echo -e 'It seems like ~/.local/bin is not in your $PATH variable.'
    if [[ $SHELL == '/bin/bash' ]]; then
        printf 'Should I add ~/.local/bin to your $PATH in your ~/.bashrc? [y/N] '
        read response

        if [[ $response == "y" ]] && [[ -f ~/.bashrc ]]; then
            echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc
        else 
            echo "ERROR: ~/.bashrc doesn't exist"
        fi

        unset response
    else
        echo 'Please add this line to your shell config file:'
        echo 'export PATH=~/.local/bin:$PATH'
    fi
fi

echo "Setup finished! Try running uva --help."
