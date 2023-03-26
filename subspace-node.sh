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
echo "Устанавливаем ноду SubSpace"
echo " "
echo "Завели криптокошелек SubWallet или Polkadot.js?"
echo "если да, то введите в англ.раскл. букву «y»"
echo "если нет, то введите в англ.раскл. букву «n»"
echo "Введите ответ:"
read item
case "$item" in
    y|Y) echo "Вы ввели «y», продолжаем..."
        ;;
    n|N) echo "Вы ввели «n», необходимо перейти на сайт https://subwallet.app/ или https://polkadot.js.org и завести криптокошелек SubWallet или Polkadot.js. Затем необходимо запустить установку заново..."
        exit 0
        ;;
    *) echo "Вы ничего не ввели. Выполняем действие по умолчанию..."
        ;;
esac
echo " "
cd $HOME
mkdir subcpace
cd $HOME/subcpace
sudo apt update && sudo apt upgrade -y
sudo apt install ocl-icd-libopencl1 libgomp1 wget -y
sudo wget https://github.com/subspace/subspace-cli/releases/download/v0.1.10-alpha/subspace-cli-ubuntu-x86_64-v3-v0.1.10-alpha
speep 15
sudo chmod +x subspace-cli-ubuntu-x86_64-v3-v0.1.10-alpha

sudo mv subspace-cli-ubuntu-x86_64-v3-v0.1.10-alpha /usr/local/bin/
sudo rm -rf $HOME/.config/subspace-cli-ubuntu-x86_64-v3-v0.1.10-alpha
echo "Необходимо ввести в следующем дилоговом окне адрес криптокошелька SubWallet или Polkadot.js, затем придумать имя ноды. Остальные шаги можно оставить по умолчанию (просто нажимаем кнопку «Enter»"
/usr/local/bin/subspace-cli-ubuntu-x86_64-v3-v0.1.10-alpha init
#systemctl stop subspaced subspaced-farmer &>/dev/null
#rm -rf ~/.local/share/subspace*

#source ~/.bash_profile
sleep 1

echo "[Unit]
Description=Subspace Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/subspace-cli-ubuntu-x86_64-v3-v0.1.10-alpha farm --verbose
Restart=on-failure
LimitNOFILE=1024000

[Install]
WantedBy=multi-user.target" > $HOME/subspaced.service

mv $HOME/subspaced.service /etc/systemd/system/
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspaced
sudo systemctl restart subspaced

echo "==================================================="
echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 5
if [[ `service subspaced status | grep active` =~ "running" ]]; then
  echo -e "Your Subspace node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice subspaced status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your Subspace node \e[31mwas not installed correctly\e[39m, please reinstall."
fi

