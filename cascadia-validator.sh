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
echo "НАЧИНАЕМ УСТАНОВКУ ВАЛИДАТОРА CASCADIA ..."
echo " "
echo " "
echo "ПРОВЕРКА СОСТОЯНИЯ СИНХРОНИЗАЦИИ"
echo " "
echo " "
#Step 1: Verify that your node is fully synced
output=$(sudo cascadiad status)  # Выполняем команду и сохраняем вывод

if [[ $output == *"\"catching_up\":true"* ]]; then
  echo "Сервер находится в процессе синхронизации. Прекращение обработки скрипта."
  exit 1  # Прерываем выполнение скрипта с ненулевым кодом возврата
elif [[ $output == *"\"catching_up\":false"* ]]; then
  echo "Сервер не находится в процессе синхронизации. Продолжение обработки скрипта."
  # Добавьте дальнейшие команды для обработки, если требуется
#else
#  echo "Не удалось определить статус сервера."
#  exit 1  # Прерываем выполнение скрипта с ненулевым кодом возврата
fi

echo " "
echo " "
echo "ГЕНЕРАЦИЯ КЛЮЧЕЙ ВАЛИДАТОРА И АДРЕСА КОШЕЛЬКА"
echo " "
echo " "
#Step 2: Generate and store your validator's address and keys
read -p "ПРИДУМАЙТЕ VALIDATOR KEY И PASSPHRASE:  " key_name && sleep 2
cascadiad keys add $key_name
echo " "
echo " "
echo "СОХРАНИТЕ СЕБЕ ПОЛУЧЕННЫЕ ДАННЫЕ"

echo " "
echo " "
echo "КОНВЕРТАЦИЯ CASCADIA WALLET ADDRESS В EVM ADDRESS"
echo " "
echo " "
#Step 3: Convert your Cascadia address to an EVM address
read -p "ВВЕДИТЕ WALLET ADDRESS ПОЛУЧЕННОГО ИЗ ПРЕДЫДУЩЕГО ШАГА:  " your_wallet_address && sleep 2
cascadiad address-converter $your_wallet_address

#Step 4: Fund your validator's EVM address
echo "ПЕРЕДАЙТЕ CC ТОКЕНЫ на ВАШ EVM ADDRESS, ПОЛУЧЕННОГО ИЗ ПРЕДЫДУЩЕГО ШАГА, НА САЙТЕ https://www.cascadia.foundation/faucet"

#Step 5: Confirm receipt of CC tokens
echo "УБЕДИТЕСЬ В ПОЛУЧЕНИИ ТЕСТОВЫХ ТОКЕНОВ НА САЙТЕ https://explorer.cascadia.foundation/"
echo " "
echo " "
echo "НАСТРОЙКА VALIDATOR TX"
echo " "
echo " "
#Step 6: Create your initial validator funding tx
read -p "ПРИДУМАЙТЕ НАЗВАНИЕ ВАЛИДАТОРУ:  " validator_name && sleep 2
read -p "ДОБАВЬТЕ ОПИСАНИЕ ВАЛИДАТОРУ:  " description && sleep 2
read -p "НАПИШИТЕ НАЗВАНИЕ ВАШЕЙ ЭЛ.ПОЧТЫ:  " email_address && sleep 2

cascadiad tx staking create-validator \
--from $key_name \
--chain-id cascadia_6102-1 \
--moniker="$validator_name" \
--commission-max-change-rate=0.01 \
--commission-max-rate=1.0 \
--commission-rate=0.05 \
--details="$description" \
--security-contact="$email_address" \
--website="https://cryptosyndicate.vc" \
--pubkey $(cascadiad tendermint show-validator) \
--min-self-delegation="1" \
--amount 1000000000000000000aCC \
--gas "auto" \
--gas-adjustment=1.2 \
--gas-prices="7aCC" \
--broadcast-mode block

echo " "
echo " "
echo "ПРОВЕРЬТЕ ПРИСУТСТВИЕ ВАШЕГО ВАЛИДАТОРА НА САЙТЕ https://validator.cascadia.foundation/validators"
echo " "
echo " "
