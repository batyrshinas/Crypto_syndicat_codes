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

# Ask if the user has an Alchemy account
#read -p "У ВАС ЕСТЬ АККАУНТ Alchemy? ССЫЛКА ДЛЯ РЕГИСТРАЦИИ: https://alchemy.com/?r=6aff3a94e7bae9bd. ВВЕДИТЕ y ЕСЛИ ДА, n - НЕТ) " has_alchemy_account

#if [ "$has_alchemy_account" = "y" ]; then
  # Prompt the user for the URL and validate it
#  read -p "ПОЖАЛУЙСТА, ВВЕДИТЕ СВОЙ URL-АДРЕС Alchemy: " ALCHEMY
#  if [[ $ALCHEMY =~ ^https?:// ]]; then
#    echo "ВАШ URL-АДРЕС Alchemy: $ALCHEMY"
#  else
#    echo "ОШИБКА: $ALCHEMY ЭТО НЕВАЛИДНЫЙ URL-АДРЕС."
#    exit 1
#  fi

  # Export the Alchemy URL to the bash profile
#  echo "export ALCHEMY=$ALCHEMY" >> "$HOME/.bash_profile"
#fi

read -p "ВВЕДИТЕ ВАШ ALCHEMY API KEY (МОЖНО НАЙТИ НАЖАВ на VIEW KEY НА САЙТЕ https://dashboard.alchemy.com/apps): " API && sleep 2
ALCHEMY=https://eth-goerli.alchemyapi.io/v2/$API
echo 'export ALCHEMY='$ALCHEMY >> $HOME/.bash_profile

echo " "
echo " "
echo "УСТАНОВКА НОДЫ..."
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
echo "УСТАНОВКА НЕОБХОДИМЫХ ПАКЕТОВ"
echo " "
echo " "
sudo apt update && sudo apt upgrade -y
sudo apt install wget curl nano htop net-tools pip git systemctl cargo  -y

sudo apt update && sudo apt install software-properties-common -y

sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update && sudo apt install screen tmux python3.10 python3.10-venv python3.10-dev build-essential libgmp-dev pkg-config libssl-dev -y
pip3 install fastecdsa
sudo apt install -y pkg-config

curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
rustup update stable --force
cd $HOME

echo " "
echo " "
echo "УСТАНОВКА НЕОБХОДИМЫХ ПАКЕТОВ ЗАВРШЕНО"
echo " "
echo " "
echo "СОБИРАЕМ НОДУ"
echo " "
echo " "
git clone -b v0.5.3 https://github.com/eqlabs/pathfinder.git
cd pathfinder/py
python3.10 -m venv .venv
source .venv/bin/activate
PIP_REQUIRE_VIRTUALENV=true pip install --upgrade pip
PIP_REQUIRE_VIRTUALENV=true pip install -e .[dev]
pytest

cd $HOME/pathfinder/
cargo build --release --bin pathfinder
sleep 2

#read -p "ВВЕДИТЕ ВАШ ALCHEMY API KEY (МОЖНО НАЙТИ НАЖАВ на VIEW KEY НА САЙТЕ https://dashboard.alchemy.com/apps): " API && sleep 2
#ALCHEMY=https://eth-goerli.alchemyapi.io/v2/$API
#echo 'export ALCHEMY='$ALCHEMY >> $HOME/.bash_profile

echo " "
echo " "
echo "СБОРКА НОДЫ ЗАВЕРШЕНА"
echo " "
echo " "
echo "СОЗДАНИЕ СЕРВИСНЫХ ФАЙЛОВ"
echo " "
echo " "
source $HOME/.bash_profile
mv ~/pathfinder/target/release/pathfinder /usr/local/bin/ || exit

echo "[Unit]
Description=StarkNet
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/pathfinder/py
ExecStart=/bin/bash -c \"source $HOME/pathfinder/py/.venv/bin/activate && /usr/local/bin/pathfinder --http-rpc=\"0.0.0.0:9545\" --ethereum.url $ALCHEMY\"
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/starknetd.service
mv $HOME/starknetd.service /etc/systemd/system/

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
