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
echo "НАЧИНАЕМ УСТАНОВКУ НОДЫ CASCADIA"
echo " "
echo " "
# add username
read -p "ПРИДУМАЙТЕ НАЗВАНИЕ НОДЫ:  " node_name
echo " "
echo " "
cd $HOME
echo " "
echo " "
echo "ДОБАВЛЕНИЕ РАЗРЕШАЮЩИХ ПРАВИЛ В ФАЙЕРВОЛЫ"
echo " "
echo " "
sudo ufw allow 22
sudo ufw allow 26658 
sudo ufw allow 26657
sudo ufw allow 6060
sudo ufw allow 26656
sudo ufw allow 26660
sudo ufw allow 9090
sudo ufw allow 9091
sudo ufw allow 1317
sudo iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 26658 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 26657 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 6060 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 26656 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 26660 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 9090 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 9091 -j ACCEPT
sudo iptables -t filter -A INPUT -p tcp --dport 1317 -j ACCEPT
echo " "
echo " "
echo "УСТАНОВКА НЕОБХОДИМЫХ ПАКЕТОВ"
echo " "
echo " "
sudo apt update && sudo apt upgrade -y
sudo apt install curl wget git systemctl cargo pip -y

#Step 1: Install prerequisites
sudo apt update && sudo apt upgrade -y
sudo apt install make build-essential gcc git

#Step 2: Install Go
wget https://golang.org/dl/go1.19.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.19.2.linux-amd64.tar.gz

#Step 3: Export
GOROOT=/usr/local/go
GOPATH=$HOME/go
GO111MODULE=on
PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

#Step 4: Update your ~/.profile
source ~/.profile

#Step 5: Build Cascadia from source
curl -L https://github.com/CascadiaFoundation/cascadia/releases/download/v0.1.2/cascadiad-v0.1.2-linux-amd64 -o cascadiad
sudo chmod u+x cascadiad
sudo cp cascadiad /usr/local/bin/cascadiad
sudo chown $USER /usr/local/bin/cascadiad

#Step 6: To confirm that the installation has succeeded, run
cascadiad version

#Step 7: Initialize the chain
cascadiad init $node_name --chain-id cascadia_6102-1

#Step 8: Download the genesis file
curl -LO https://github.com/CascadiaFoundation/chain-configuration/raw/master/testnet/genesis.json.gz
gunzip genesis.json.gz
cp genesis.json ~/.cascadiad/config/

#Step 9: Set persistent peers
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$(curl  https://raw.githubusercontent.com/CascadiaFoundation/chain-configuration/master/testnet/persistent_peers.txt)\"/" ~/.cascadiad/config/config.toml

#Step 10: Set minimum gas price
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025aCC\"/" ~/.cascadiad/config/app.toml
echo " "
echo " "
echo "СОЗДАНИЕ СЕРВИСНОГО ФАЙЛА"
echo " "
echo " "
#Step 11: Create systemd service file
#sudo nano /etc/systemd/system/cascadiad.service
sudo tee <<EOF >/dev/null /etc/systemd/system/cascadiad.service
[Unit]
Description=Cascadia Node
After=network.target
 
[Service]
Type=simple
User=$USER
WorkingDirectory=/usr/local/bin
ExecStart=/usr/local/bin/cascadiad start --trace --log_level info --json-rpc.api eth,txpool,personal,net,debug,web3 --api.enable
Restart=on-failure
StartLimitInterval=0
RestartSec=3
LimitNOFILE=65535
LimitMEMLOCK=209715200
 
[Install]
WantedBy=multi-user.target
EOF
echo "СЕРВИСНЫЙ ФАЙЛ УСПЕШНО СОЗДАН"
echo " "
echo " "

echo "УСКОРЕНИЕ СИНХРОНИЗАЦИИ"
sudo apt  install jq  # version 1.6-2.1ubuntu3 -y
sleep 10
peers="893b6d4be8b527b0eb1ab4c1b2f0128945f5b241@185.213.27.91:36656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.cascadiad/config/config.toml

SNAP_RPC=185.213.27.91:36657

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" $HOME/.cascadiad/config/config.toml

echo " "
echo " "
echo "ЗАПУСК НОДЫ"
echo " "
echo " "
#Step 13: Start your Node

# reload service files
sudo systemctl daemon-reload

# create the symlink
sudo systemctl enable cascadiad.service

# start the node
sudo systemctl start cascadiad.service
echo " "
echo " "
echo "ЛОГИ НОДЫ"
echo " "
echo " "
# show logs
journalctl -u cascadiad -f
