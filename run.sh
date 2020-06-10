#!/bin/bash
#
# сценарий автоматической установки локального http-репозитория с пакетом peervpn (https://github.com/peervpn/peervpn.git)
# запуск с правами суперпользователя
# тестировалось на Ubuntu 16.04.6 LTS Xenial
# перед запуском необходимо прописать верный ip-адрес хоста в нижней строке скрипта (your_host), на клиентах необходимо обновить sources.list
#
# обновляем список пакетов
apt update
# устанавливаем необходимые пакеты
apt install checkinstall build-essential automake autoconf libtool pkg-config libcurl4-openssl-dev intltool libxml2-dev libgtk2.0-dev libnotify-dev libglib2.0-dev libevent-dev libssl-dev dpkg-dev apache2 -y
# создание директорий
mkdir /var/www/html/ubuntu /usr/local/bin
# клонируем необходимый репозиторий
git clone https://github.com/peervpn/peervpn.git /var/www/html/ubuntu/peervpn/
# меняем путь для установки и компилируем
sed -i 's/sbin/bin/g' /var/www/html/ubuntu/peervpn/Makefile && cd /var/www/html/ubuntu/peervpn && make
# собираем пакет deb
cd /var/www/html/ubuntu/peervpn && echo "n" | checkinstall
# перенос пакета в репозиторий
cp /var/www/html/ubuntu/peervpn/*.deb /var/www/html/ubuntu/
# чистим сборочную директорию
rm -rf /var/www/html/ubuntu/peervpn/
# обновляем пакеты в репозитории
cd /var/www/html/ubuntu/ && dpkg-scanpackages . | gzip -c9  > Packages.gz
# обновляем локальный sources.list
echo "deb [trusted=yes] http://your_host/ubuntu ./" | tee -a /etc/apt/sources.list > /dev/null
