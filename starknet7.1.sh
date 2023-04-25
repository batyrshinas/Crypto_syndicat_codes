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
echo "ВВЕДИТЕ КЛЮЧ ДОСТУПА К НОДЕ:"
read key

response=$(curl -s -o /dev/null -w "%{http_code}" "https://cryptosyndicate.vc/api/user/nodes/activation-code/$key")

if [ $response -eq 200 ]; then
  echo "ДОСТУП РАЗРЕШЕН"
else
  echo "ДОСТУП ЗАПРЕЩЕН"
  exit 1
fi
echo " "
echo " "
#echo -n " УСТАНАВЛИВАЕМ НОДУ STARKNET НА ВАШ СЕРВЕР?"
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
echo " "
# Ask if the user has an Alchemy account
read -p "У ВАС ЕСТЬ АККАУНТ Alchemy? ССЫЛКА ДЛЯ РЕГИСТРАЦИИ: https://alchemy.com/?r=6aff3a94e7bae9bd. ВВЕДИТЕ y ЕСЛИ ДА, n - НЕТ) " has_alchemy_account

if [ "$has_alchemy_account" = "y" ]; then
  # Prompt the user for the URL and validate it
  read -p "ПОЖАЛУЙСТА, ВВЕДИТЕ СВОЙ URL-АДРЕС Alchemy(СКОПИРОВАТЬ С dashboard.alchemy.com/apps --- VIEW KEY): " ALCHEMY
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
echo "ВЫПОЛНЕНИЕ СКРИПТА..."
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

#Обновляем сервер:
sudo apt update && sudo apt upgrade -y
sudo apt install wget pip git systemctl cargo  -y

sudo apt update -y
sudo apt install build-essential libssl-dev libffi-dev python3-dev screen git python3-pip python3.*-venv -y
sudo apt-get install libgmp-dev -y
pip3 install fastecdsa
sudo apt-get install -y pkg-config
#curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_rust.sh | bash
rustup default nightly
source $HOME/.cargo/env
sleep 1
echo "НЕОБХОДИМОЕ ПО УСТАНОВЛЕНО"
echo " "
echo " "
echo "СОБИРАЕМ НОДУ"
echo " "
echo " "
git clone --branch v0.5.3 https://github.com/eqlabs/pathfinder.git
cd pathfinder/py
python3 -m venv .venv
source .venv/bin/activate
PIP_REQUIRE_VIRTUALENV=true pip install --upgrade pip
PIP_REQUIRE_VIRTUALENV=true pip install -r requirements-dev.txt
cargo build --release --bin pathfinder
sleep 2
source $HOME/.bash_profile
echo " "
echo " "
echo "СБОРКА НОДЫ ЗАВЕРШЕНА"
echo " "
echo " "
echo "СОЗДАНИЕ СЕРВИСНЫХ ФАЙЛОВ"
echo " "
echo " "
sudo tee <<EOF /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF /etc/systemd/system/starknet.service
[Unit]
Description=StarkNet Node
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/pathfinder/py
Environment=PATH="$HOME/pathfinder/py/.venv/bin:\$PATH"
ExecStart=$HOME/pathfinder/target/release/pathfinder --ethereum.url $ALCHEMY
Restart=always
RestartSec=10
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
EOF
echo " "
echo " "
echo "СЕРВИСНЫЕ ФАЙЛЫ СОЗДАНЫ"
echo " "
echo " "
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable starknet
sudo systemctl restart starknet
echo " "
echo " "
echo "НОДА ДОБАВЛЕНА В АВТОЗАГРУЗКУ НА СЕРВЕРЕ И ЗАПУЩЕНА"
echo " "
echo " "
