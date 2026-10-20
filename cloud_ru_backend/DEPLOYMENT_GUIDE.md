# Пошаговая инструкция развёртывания Cloud.ru Backend

## 1. Создание проекта и каталога

1. Войти в [Cloud.ru Control Panel](https://mc.cloud.ru/)
2. Создать новый проект (если нет): **IAM** → **Проекты** → **Создать**
3. Запомнить `project_id`

## 2. Создание VPC (сеть)

1. Перейти в **Compute Cloud** → **Сети**
2. Создать сеть:
   - Имя: `rooster-network`
   - CIDR: `10.0.0.0/16`
3. Создать подсеть:
   - Имя: `rooster-subnet`
   - Сеть: `rooster-network`
   - Зона: `ru-1a`
   - CIDR: `10.0.1.0/24`
4. Создать группу безопасности:
   - Имя: `rooster-vm-sg`
   - Входящие: TCP 8000 (0.0.0.0/0)
   - Исходящие: TCP 443 (0.0.0.0/0)

## 3. Создание виртуальной машины

1. Перейти в **Compute Cloud** → **Виртуальные машины**
2. Создать ВМ:
   - Имя: `rooster-backend`
   - Платформа: `standard-v3`
   - Процессор: 2 vCPU
   - Память: 4 GB
   - Диск: 20 GB (Ubuntu 22.04)
   - Сеть: `rooster-subnet`
   - Группа безопасности: `rooster-vm-sg`
   - NAT: включить
3. Запомнить внешний IP (например, `51.250.XXX.XXX`)

## 4. Настройка ВМ

Подключиться по SSH:
```bash
ssh ubuntu@51.250.XXX.XXX
```

Установить Docker и Docker Compose:
```bash
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
```

Создать директорию приложения:
```bash
mkdir -p ~/rooster-backend
cd ~/rooster-backend
```

Создать `.env` файл:
```bash
nano .env
```

Содержимое `.env`:
```env
DATABASE_URL=postgresql://rooster:PASSWORD@HOST:5432/rooster
S3_ENDPOINT=https://storage.cloud.ru
S3_ACCESS_KEY=YOUR_ACCESS_KEY
S3_SECRET_KEY=YOUR_SECRET_KEY
S3_BUCKET=rooster-media
S3_AVATARS_BUCKET=rooster-avatars
SECRET_KEY=your-secret-key-change-in-production
```

Создать `docker-compose.yml`:
```bash
nano docker-compose.yml
```

Содержимое `docker-compose.yml`:
```yaml
version: "3.8"

services:
  backend:
    build: .
    ports:
      - "8000:8000"
    env_file:
      - .env
    restart: unless-stopped
```

Создать `Dockerfile`:
```bash
nano Dockerfile
```

Содержимое `Dockerfile`:
```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app/

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Создать директорию приложения:
```bash
mkdir -p app
```

Скопировать файлы бэкенда в `app/main.py`.

Создать `requirements.txt`:
```
fastapi==0.115.0
uvicorn[standard]==0.30.0
sqlalchemy==2.0.35
psycopg2-binary==2.9.9
pydantic==2.9.0
boto3==1.35.0
python-multipart==0.0.9
pydantic-settings==2.5.0
```

Запустить:
```bash
docker compose up -d
```

Проверить:
```bash
docker compose ps
curl http://localhost:8000/docs
```

## 5. Создание PostgreSQL

1. Перейти в **Managed Service for PostgreSQL**
2. Создать кластер:
   - Имя: `rooster-postgres`
   - Версия: 15
   - Ресурсы: 2 vCPU, 4 GB RAM, 20 GB диск
   - Зона: `ru-1a`
   - Сеть: `rooster-subnet`
3. Создать базу данных:
   - Имя: `rooster`
   - Пользователь: `rooster`
   - Пароль: `ваш-сильный-пароль`
4. Запомнить FQDN хоста (например, `r1a1b2c3d4.mdb.cloud.ru`)

Обновить `.env` на ВМ:
```bash
nano .env
```

Изменить `DATABASE_URL`:
```env
DATABASE_URL=postgresql://rooster:PASSWORD@r1a1b2c3d4.mdb.cloud.ru:5432/rooster
```

Перезапустить:
```bash
docker compose down
docker compose up -d
```

## 6. Создание S3 бакетов

1. Перейти в **Object Storage** → **Бакеты**
2. Создать бакет `rooster-media`:
   - Регион: `ru-1`
   - ACL: Private
3. Создать бакет `rooster-avatars`:
   - Регион: `ru-1`
   - ACL: Private

Обновить `.env` на ВМ:
```bash
nano .env
```

Изменить `S3_ACCESS_KEY` и `S3_SECRET_KEY` (IAM ключи).

Перезапустить:
```bash
docker compose down
docker compose up -d
```

## 7. Настройка API Gateway

1. Перейти в **API Gateway**
2. Создать шлюз:
   - Имя: `rooster-api-gateway`
   - Домен: `api.rooster.cloud.ru` (или поддомен вашего домена)
3. Создать маршрут:
   - Путь: `/*`
   - Backend: `http://INTERNAL_VM_IP:8000`
   - Внутренний IP ВМ: `10.0.1.X`

## 8. Настройка DNS

1. Перейти в **DNS** → **Зоны**
2. Создать зону (если нет): `rooster.cloud.ru`
3. Добавить запись:
   - Тип: `CNAME`
   - Имя: `api`
   - Значение: `api-gateway-id.cloudru.net`

## 9. Проверка

```bash
# Проверить API Gateway
curl https://api.rooster.cloud.ru/docs

# Проверить backend напрямую
curl http://51.250.XXX.XXX:8000/docs

# Проверить PostgreSQL
psql -h r1a1b2c3d4.mdb.cloud.ru -U rooster -d rooster
```

## 10. Безопасность

1. Настроить firewall:
   - ВМ: только порты 22 (SSH) и 8000 (API)
   - PostgreSQL: только от ВМ (10.0.1.0/24)
2. Включить HTTPS через API Gateway
3. Настроить ротацию SSL-сертификатов
4. Настроить мониторинг и алерты

## 11. Стоимость

| Ресурс | Стоимость/мес |
|--------|--------------|
| ВМ (2 vCPU, 4 GB) | ~500-800₽ |
| PostgreSQL (2 vCPU, 4 GB) | ~1000-1500₽ |
| API Gateway | ~300-500₽ |
| S3 хранилище | ~100-200₽ |
| **Итого** | **~2000-3000₽** |

## 12. Масштабирование

При росте нагрузки:
1. Увеличить ресурсы ВМ (CPU/RAM)
2. Добавить реплику ВМ за балансировщиком
3. Увеличить PostgreSQL до master-replica
4. Настроить auto-scaling для ВМ
