#!/bin/bash

echo "--- Начало обновления Бота и Кабинета: $(date) ---"

# Решение проблемы с git safe.directory
git config --global --add safe.directory /opt/remnawave-bedolaga-telegram-bot 2>/dev/null || true

# Переход в директорию бота
cd /opt/remnawave-bedolaga-telegram-bot || { echo "Ошибка: директория бота не найдена"; exit 1; }

echo "[1/7] Скачиваем образ бота..."
if git pull 2>&1; then
    echo "Git pull успешно выполнен"
else
    echo "Предупреждение: git pull завершился с ошибкой, но продолжаем..."
fi

echo "[2/7] Скачиваем образ кабинета..."
docker pull ghcr.io/bedolaga-dev/bedolaga-cabinet:latest

echo "[3/7] Создание временного контейнера..."
docker create --name tmp_cabinet ghcr.io/bedolaga-dev/bedolaga-cabinet:latest

echo "[4/7] Очистка старых файлов кабинета..."
rm -rf /opt/cabinet/*

echo "[5/7] Копирование новых файлов..."
docker cp tmp_cabinet:/usr/share/nginx/html/. /opt/cabinet/
docker rm -f tmp_cabinet

echo "[6/7] Перезапуск сервисов..."
docker-compose down 2>/dev/null || docker compose down
docker-compose up -d --build 2>/dev/null || docker compose up -d --build
systemctl restart nginx

echo "[7/7] Очистка неиспользуемых образов..."
docker image prune -f

echo "--- Обновление успешно завершено: $(date) ---"
