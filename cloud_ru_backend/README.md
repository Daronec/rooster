# Cloud.ru Backend для Rooster

FastAPI бэкенд с REST API для задач, списков, планов, материалов, профиля и команд.

## Структура

```
cloud_ru_backend/
├── app/
│   └── main.py              # FastAPI приложение
├── requirements.txt         # Python зависимости
├── Dockerfile              # Docker-образ
├── terraform/
│   ├── main.tf             # Terraform конфиг
│   └── variables.tf        # Переменные
├── DEPLOYMENT_GUIDE.md     # Инструкция по развёртыванию
└── README.md               # Этот файл
```

## API Endpoints

### Tasks
- `GET /tasks` — список задач
- `GET /tasks/{id}` — задача по ID
- `POST /tasks` — создать задачу
- `PUT /tasks/{id}` — обновить задачу
- `DELETE /tasks/{id}` — удалить задачу
- `POST /tasks/sync` — batch upsert

### Task Lists
- `GET /task-lists` — список списков
- `POST /task-lists` — создать список
- `PUT /task-lists/{id}` — обновить список
- `DELETE /task-lists/{id}` — удалить список
- `POST /task-lists/sync` — batch upsert

### Plans
- `GET /plans` — список планов
- `POST /plans` — создать план
- `PUT /plans/{id}` — обновить план
- `DELETE /plans/{id}` — удалить план
- `POST /plans/sync` — batch upsert

### Material Stock
- `GET /material-stock` — склад материалов
- `PUT /material-stock` — обновить склад

### Profile
- `GET /profile` — профиль пользователя
- `PUT /profile` — обновить профиль

### Teams
- `GET /teams` — команды пользователя
- `POST /teams` — создать команду
- `PUT /teams/{id}` — обновить команду
- `DELETE /teams/{id}` — удалить команду
- `POST /teams/invite` — пригласить участника
- `POST /teams/accept-invitation` — принять приглашение
- `POST /teams/reject-invitation` — отклонить приглашение
- `DELETE /teams/invitations` — отозвать приглашение
- `GET /teams/{id}/invitations` — список приглашений
- `PUT /teams/members/{userId}/role` — обновить роль
- `DELETE /teams/members` — удалить участника
- `DELETE /teams/leave` — покинуть команду

### Storage
- `POST /storage/presigned-upload` — presigned URL для загрузки
- `POST /storage/presigned-download` — presigned URL для скачивания

## Локальный запуск

```bash
cd cloud_ru_backend

# Создать виртуальное окружение
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate  # Windows

# Установить зависимости
pip install -r requirements.txt

# Настроить .env
cp .env.example .env
nano .env

# Запустить
uvicorn app.main:app --reload
```

Документация API: `http://localhost:8000/docs`

## Развёртывание

См. `DEPLOYMENT_GUIDE.md`

## Terraform

```bash
cd terraform

# Инициализация
terraform init

# Проверка конфига
terraform plan

# Применение
terraform apply

# Удаление
terraform destroy
```

## Зависимости

- Python 3.12+
- FastAPI 0.115+
- SQLAlchemy 2.0+
- PostgreSQL 15+
- boto3 (для S3)

## Лицензия

MIT
