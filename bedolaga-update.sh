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

echo "[2/8] Скачиваем образ кабинета..."
docker pull ghcr.io/bedolaga-dev/bedolaga-cabinet:latest

echo "[3/8] Создание временного контейнера..."
docker create --name tmp_cabinet ghcr.io/bedolaga-dev/bedolaga-cabinet:latest

echo "[4/8] Очистка старых файлов кабинета..."
rm -rf /opt/cabinet/*

echo "[5/8] Копирование новых файлов..."
docker cp tmp_cabinet:/usr/share/nginx/html/. /opt/cabinet/
docker rm -f tmp_cabinet

echo "[6/8] Очистка перед сборкой..."
docker builder prune -a -f 2>/dev/null || true
docker image prune -f 2>/dev/null || true

echo "[7/8] Перезапуск сервисов..."
docker compose down
docker compose up -d --build

echo "[8/8] Перезапуск Caddy..."
caddy reload --config /etc/caddy/Caddyfile 2>/dev/null || systemctl reload caddy
# Проверяем статус Caddy
if systemctl is-active --quiet caddy; then
    echo "Caddy успешно перезапущен"
else
    echo "ОШИБКА: Caddy не запустился! Проверьте: systemctl status caddy"
    exit 1
fi

echo "--- Обновление успешно завершено: $(date) ---"
