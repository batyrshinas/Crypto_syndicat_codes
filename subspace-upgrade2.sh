#!/bin/bash
echo "ОСТАНАВЛИВАЕМ СЕРВИС"
echo "  "
echo "  "
systemctl stop subspaced.service
sudo rm /usr/local/bin/subspace-cli

echo "  "
echo "  "
echo "ОБНОВЛЕНИЕ БИНАРНИКА"
echo "  "
echo "  "
cd $HOME
sudo wget -O subspace-cli 'https://github.com/subspace/subspace-cli/releases/download/v0.3.3-alpha/subspace-cli-ubuntu-x86_64-v3-v0.3.3-alpha'
sleep 15
sudo chmod +x subspace-cli
sudo mv subspace-cli /usr/local/bin/
echo "  "
echo "  "
echo "ПЕРЕНАСТРОЙКА КОНФИГ ФАЙЛА"
cd $HOME/.config/subspace-cli
file=settings.toml
sed -i 's/chain = "Gemini3c"/chain = "Gemini3d"/g' $file
echo "  "
echo "  "
echo "СТАРТ СЕРВИСА"
echo "  "
echo "  "
systemctl enable subspaced.service
systemctl start subspaced.service
echo "  "
echo "  "
echo "СТАТУС СЕРВИСА"
echo "  "
echo "  "
systemctl status subspaced.service
exit

