# Репликация

Данный проект предназначен для автоматизации процесса репликации между двумя docker-контейнерами

# Ссылки

* [Настройка репликации PostgreSQL в контейнерах Docker](https://www.dmosk.ru/miniinstruktions.php?mi ni=postgresql-replication-docker&ysclid=m76fgdphx8968237571)

* [Работа с несколькими базами данных в Ruby on Rails приложении](https://rusrails.ru/active-record-multiple-databases#soedinenie-s-bazami-dannyh-bez-upravleniya-shemoy-i-migratsiyami)

# Запуск

Запуск двух postgresql-серверов

```docker
docker compose up -d
```

Остановка серверов

```docker
docker compose down
```

# Команды для master-сервера

Вход из под пользователя postres

```docker
docker exec -it master su - postgres
```

Внутри контейнера запускаем консольный psql

```bash
psql
```

Создаем таблицу и заполняем ее

```sql
CREATE TABLE users (id SERIAL PRIMARY KEY, name TEXT);
INSERT INTO users (name) VALUES ('Igor'), ('Ivan'), ('Sergey');
```

# Команды для slave-сервера

```docker
docker exec -it slave su - postgres
```

внутри docker-контейнера выполняем команду

```bash
./init-slave.sh
```

Внутри контейнера запускаем консольный psql

```bash
psql
```

Убеждаемся, что данные переданы из master в slave

```bash
SELECT * FROM users;
```
