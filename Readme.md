# Настройка автообновления бота и кабинета
### 1. Откройте crontab для редактирования:
```bash
crontab -e
```
### 2. Добавьте строку для еженедельного запуска:
```bash
# Запуск обновления каждое воскресенье в 3:00 ночи
0 3 * * 0 bash <(curl -Ls https://raw.githubusercontent.com/DanielZubov/bedolaga-update/refs/heads/main/bedolaga-update.sh) >> /var/log/bedolaga-update.log 2>&1
```
### 3. Сохраните и выйдите (в nano: Ctrl+X, затем Y, затем Enter)

## Ручной запуск
```bash
bash <(curl -Ls https://raw.githubusercontent.com/DanielZubov/bedolaga-update/refs/heads/main/bedolaga-update.sh)
```
