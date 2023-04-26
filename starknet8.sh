#!/bin/bash
tput reset 
tput civis 
echo -e "\033[32m████─████─██─██─████─███─████─███─██─██─█──█─████──███─████─████─███─███\e[0m"
echo -e "\033[32m█──█─█──█──███──█──█──█──█──█─█────███──██─█─█──██──█──█──█─█──█──█──█──\e[0m"
echo -e "\033[32m█────████───█───████──█──█──█─███───█───█─██─█──██──█──█────████──█──███\e[0m"
echo -e "\033[32m█──█─█─█────█───█─────█──█──█───█───█───█──█─█──██──█──█──█─█──█──█──█──\e[0m"
echo -e "\033[32m████─█─█────█───█─────█──████─███───█───█──█─████──███─████─█──█──█──███\e[0m"
echo " "
echo -e "\033[93m╔╗─╔╗╔══╗╔══╗─╔═══╗───╔══╗╔╗─╔╗╔══╗╔════╗╔══╗╔╗──╔╗──╔═══╗╔═══╗\e[0m"
echo -e "\033[93m║╚═╝║║╔╗║║╔╗╚╗║╔══╝───╚╗╔╝║╚═╝║║╔═╝╚═╗╔═╝║╔╗║║║──║║──║╔══╝║╔═╗║\e[0m"
echo -e "\033[93m║╔╗─║║║║║║║╚╗║║╚══╗────║║─║╔╗─║║╚═╗──║║──║╚╝║║║──║║──║╚══╗║╚═╝║\e[0m"
echo -e "\033[93m║║╚╗║║║║║║║─║║║╔══╝────║║─║║╚╗║╚═╗║──║║──║╔╗║║║──║║──║╔══╝║╔╗╔╝\e[0m"
echo -e "\033[93m║║─║║║╚╝║║╚═╝║║╚══╗───╔╝╚╗║║─║║╔═╝║──║║──║║║║║╚═╗║╚═╗║╚══╗║║║║─\e[0m"
echo -e "\033[93m╚╝─╚╝╚══╝╚═══╝╚═══╝───╚══╝╚╝─╚╝╚══╝──╚╝──╚╝╚╝╚══╝╚══╝╚═══╝╚╝╚╝─\e[0m"
echo " "
echo " "
#echo "ВВЕДИТЕ КЛЮЧ ДОСТУПА К НОДЕ:"
#read key

#response=$(curl -s -o /dev/null -w "%{http_code}" "https://cryptosyndicate.vc/api/user/nodes/activation-code/$key")

#if [ $response -eq 200 ]; then
#  echo "ДОСТУП РАЗРЕШЕН"
#else
#  echo "ДОСТУП ЗАПРЕЩЕН"
#  exit 1
#fi
echo " "
echo " "
#echo -n " УСТАНАВЛИВАЕМ НОДУ StarkNet НА ВАШ СЕРВЕР?"
#echo " "
#echo "ДА - y"
#echo "НЕТ - n"
#echo "ВВЕДИТЕ ОТВЕТ:"
#read item2
#case "$item2" in
#    y|Y) echo "ВЫ ВВЕЛИ «y», ПРОДОЛЖАЕМ..."
#        ;;
#    n|N) echo "ВЫ ВВЕЛИ «n», ЗАВЕРШАЕМ..."
#        exit 0
#        ;;
#    *) echo "ВЫ НИЧЕГО НЕ ВВЕЛИ. ВЫПОЛНЯЕМ ДЕЙСТВИЕ ПО УМОЛЧАНИЮ..."
#        ;;
#esac
echo " "
# Ask if the user has an Alchemy account
read -p "У ВАС ЕСТЬ АККАУНТ Alchemy? ССЫЛКА ДЛЯ РЕГИСТРАЦИИ: https://alchemy.com/?r=6aff3a94e7bae9bd. ВВЕДИТЕ y ЕСЛИ ДА, n - НЕТ) " has_alchemy_account

if [ "$has_alchemy_account" = "y" ]; then
  # Prompt the user for the URL and validate it
  read -p "ПОЖАЛУЙСТА, ВВЕДИТЕ СВОЙ URL-АДРЕС Alchemy: " ALCHEMY
  if [[ $ALCHEMY =~ ^https?:// ]]; then
    echo "ВАШ URL-АДРЕС Alchemy: $ALCHEMY"
  else
    echo "ОШИБКА: $ALCHEMY ЭТО НЕВАЛИДНЫЙ URL-АДРЕС."
    exit 1
  fi

  # Export the Alchemy URL to the bash profile
  echo "export ALCHEMY=$ALCHEMY" >> "$HOME/.bash_profile"
fi
echo " "
echo " "
echo "УСТАНОВКА НОДЫ..."
#exists()
#{
#  command -v "$1" >/dev/null 2>&1
#}
#if exists curl; then
#        echo ''
#else
#  sudo apt install curl -y < "/dev/null"
#fi
echo " "
echo " "
echo "УДАЛЕНИЕ СТАРОЙ ВЕРСИИ НОДЫ"
sudo systemctl stop starknetd
sudo systemctl disable starknetd
sudo rm -rf ~/pathfinder/
sudo rm -rf /etc/systemd/system/starknetd.service
sudo rm -rf /usr/local/bin/pathfinder
echo " "
echo " "

cd $HOME/
echo "ДОБАВЛЕНИЕ РАЗРЕШАЮЩИХ ПРАВИЛ НА ФАЙЕРВОЛЫ"
sudo ufw allow ssh
sudo ufw allow 9545
sudo iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 9545 -j ACCEPT
echo " "
echo " "
echo "УСТАНОВКА НЕОБХОДИМОГО ПО"
echo " "
echo " "
sudo apt update && sudo apt upgrade -y
sudo apt install wget curl pip git systemctl cargo  -y

sudo apt update && sudo apt install software-properties-common -y
sudo apt update && sudo apt install build-essential libssl-dev libffi-dev python3-dev screen git python3-pip python3.*-venv -y
sudo apt install libgmp-dev -y

sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update && sudo apt install curl git tmux python3.10 python3.10-venv python3.10-dev build-essential libgmp-dev pkg-config libssl-dev -y
pip3 install fastecdsa
sudo apt install -y pkg-config

sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
rustup default nightly
source $HOME/.cargo/env
rustup update stable --force
sleep 1
echo " "
echo " "
echo "НЕОБХОДИМОЕ ПО УСТАНОВЛЕНО"
echo " "
echo " "
echo "СОБИРАЕМ НОДУ"
echo " "
echo " "
cd $HOME
sudo rm -rf pathfinder
sudo git clone https://github.com/eqlabs/pathfinder.git
cd pathfinder
sudo git fetch
sudo git checkout v0.5.3
git clone --branch v0.5.3 https://github.com/eqlabs/pathfinder.git
cd $HOME/pathfinder/py
sudo python3.10 -m venv .venv
sudo source .venv/bin/activate
PIP_REQUIRE_VIRTUALENV=true pip install --upgrade pip
PIP_REQUIRE_VIRTUALENV=true pip install -e .[dev]
PIP_REQUIRE_VIRTUALENV=true pip install -r requirements-dev.txt
#pip install --upgrade pip
sudo pytest
cd $HOME/pathfinder/
sudo cargo build --release --bin pathfinder
sleep 2
echo " "
echo " "
echo "СБОРКА НОДЫ ЗАВЕРШЕНА"
echo " "
echo " "
echo "СОЗДАНИЕ СЕРВИСНЫХ ФАЙЛОВ"
echo " "
echo " "
source $HOME/.bash_profile
sudo mv ~/pathfinder/target/release/pathfinder /usr/local/bin/ || exit

echo "[Unit]
Description=StarkNet
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/pathfinder/py
Environment=PATH="$HOME/pathfinder/py/.venv/bin:\$PATH"
ExecStart=/bin/bash -c \"source $HOME/pathfinder/py/.venv/bin/activate && /usr/local/bin/pathfinder --http-rpc=\"0.0.0.0:9545\" --ethereum.url $ALCHEMY\"
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/starknetd.service
sudo mv $HOME/starknetd.service /etc/systemd/system/
echo " "
echo " "
echo "СЕРВИСНЫЕ ФАЙЛЫ СОЗДАНЫ"
echo " "
echo " "
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable starknetd
sudo systemctl restart starknetd

echo "==================================================="
echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 1
if [[ `service starknetd status | grep active` =~ "running" ]]; then
  echo -e "Your StarkNet node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice starknetd status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your StarkNet node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
echo " "
echo " "
echo "НОДА ДОБАВЛЕНА В АВТОЗАГРУЗКУ НА СЕРВЕРЕ И ЗАПУЩЕНА"
echo " "
echo " "
sudo systemctl status starknetd
exit
echo " "
echo " "
