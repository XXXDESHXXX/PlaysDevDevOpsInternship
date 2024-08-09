#!/bin/bash

install_aws_cli_debian() {
    echo "Ubuntu/Debian"
    sudo apt update
    sudo apt install -y unzip curl
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws/
    echo "AWS CLI установлена!"
}

install_aws_cli_redhat() {
    echo "CentOS/RedHat"
    sudo yum install -y unzip curl
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws/
    echo "AWS CLI установлена!"
}

install_aws_cli_macos() {
    echo "MacOS
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg AWSCLIV2.pkg -target /
    rm AWSCLIV2.pkg
    echo "AWS CLI установлена!"
}

install_aws_cli_windows() {
    echo "Windows"
    powerShell "msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi "
    echo "AWS CLI установлена!"
}

configure_aws_cli() {
    echo "Настройка AWS CLI..."
    read -p "Введите ваш AWS Access Key ID: " aws_access_key_id
    read -p "Введите ваш AWS Secret Access Key: " aws_secret_access_key
    read -p "Введите регион по умолчанию (например, us-east-1): " aws_region
    read -p "Введите формат вывода по умолчанию (например, json): " aws_output_format

    aws configure set aws_access_key_id "$aws_access_key_id"
    aws configure set aws_secret_access_key "$aws_secret_access_key"
    aws configure set default.region "$aws_region"
    aws configure set default.output "$aws_output_format"
    echo "AWS CLI настроен!"
}

OS=$(uname -s)

case "$OS" in
    Linux)
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$ID
        fi
        case "$DISTRO" in
            ubuntu|debian)
                install_aws_cli_debian
                ;;
            centos|rhel)
                install_aws_cli_redhat
                ;;
            *)
                ;;
        esac
        ;;
    Darwin)
        install_aws_cli_macos
        ;;
    MINGW*|MSYS*|CYGWIN*)
        install_aws_cli_windows
        ;;
    *)
        ;;
esac

configure_aws_cli

