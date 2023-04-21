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

echo "ПРОДОЛЖАЕМ..."
echo " "
echo " "
echo 'УСТАНАВЛИВАЕМ НЕОБХОДИМОЕ ПО'
echo " "
echo " "
cd $HOME/
#Обновляем сервер:
sudo apt update && sudo apt upgrade -y

#Устанавливаем необходимые пакеты:
sudo apt install curl git python3-pip build-essential libssl-dev libffi-dev python3-dev libgmp-dev  pkg-config  -y
pip3 install fastecdsa

#Ставим Rust:
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y

#Обновляем Rust:
sudo apt install cargo -y
source $HOME/.cargo/env
rustup update stable

#python 3.10
sudo apt update && sudo apt upgrade -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install python3.10 python3.10-venv python3.10-dev -y
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 3

#клонируем репозиторий с github:
git clone --branch v0.5.3 https://github.com/eqlabs/pathfinder.git

#создаем виртуальную среду:
cd pathfinder/py
python3 -m venv .venv
source .venv/bin/activate

PIP_REQUIRE_VIRTUALENV=true pip install --upgrade pip
PIP_REQUIRE_VIRTUALENV=true pip install -e .[dev]

#собираем ноду:
cargo build --release --bin pathfinder

#Создаем сервис файл
sudo tee /etc/systemd/system/starknetd.service > /dev/null <<EOF
[Unit]
Description=StarkNet
After=network.target
[Service]
Type=simple
User=root
WorkingDirectory=$HOME/pathfinder/py
ExecStart=/bin/bash -c 'source $HOME/pathfinder/py/.venv/bin/activate && $HOME/.cargo/bin/cargo run --release --bin pathfinder -- --ethereum.url https://eth-mainnet.alchemyapi.io/v2/$ALCHEMY'
Restart=always
RestartSec=10
Environment=RUST_BACKTRACE=1
[Install]
WantedBy=multi-user.target
EOF

#Запускаем сервис:
sudo systemctl daemon-reload
sudo systemctl enable starknetd
sudo systemctl start starknetd 
journalctl -u starknetd -f -o cat

echo "==================================================="
echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 1
if [[ `service starknetd status | grep active` =~ "running" ]]; then
  echo -e "Your StarkNet node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice starknetd status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your StarkNet node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
