# Snowflake
## Описание

В данной лабораторной работе реализована аналитическая модель данных **Snowflake Schema** на основе исходных данных о продажах зоомагазина.

Исходные данные представлены в виде **10 CSV файлов** (`MOCK_DATA.csv` – `MOCK_DATA (9).csv`).  
Каждый файл содержит **1000 строк**, общее количество записей:

**10000 строк.**

## Анализ исходных данных

Исходная таблица **`mock_data`** содержит данные о покупателях, продавцах, магазинах, поставщиках, товарах и продажах. Данные представлены в **денормализованном виде**.

### Проверка уникальных значений

```sql
SELECT COUNT(DISTINCT store_name) FROM mock_data;       -- 383
SELECT COUNT(DISTINCT product_name) FROM mock_data;     -- 3
SELECT COUNT(DISTINCT sale_customer_id) FROM mock_data; -- 1000
SELECT COUNT(DISTINCT customer_country) FROM mock_data; -- 204
```
### Проверка отсутствия NULL
```sql
SELECT COUNT(*)
FROM mock_data
WHERE sale_total_price IS NULL
   OR sale_date IS NULL;
-- 0
```
### Выводы
* Данные полные, без пропущенных значений.
* Таблица содержит достаточное количество уникальных покупателей и магазинов для анализа.
* Ассортимент товаров ограничен, всего 3 продукта.
* Исходные данные готовы для трансформации в Snowflake Schema с таблицами фактов и измерений.
## Структура проекта

```text
.
├ docker-compose.yml
├ scripts
│   ├ ddl.sql
│   └ dml.sql
├ исходные данные
│   ├ MOCK_DATA.csv
│   ├ MOCK_DATA (1).csv
│   ├ MOCK_DATA (2).csv
│   ├ MOCK_DATA (3).csv
│   ├ MOCK_DATA (4).csv
│   ├ MOCK_DATA (5).csv
│   ├ MOCK_DATA (6).csv
│   ├ MOCK_DATA (7).csv
│   ├ MOCK_DATA (8).csv
│   └ MOCK_DATA (9).csv
└ README.md
```
## Используемые технологии

- PostgreSQL 15  
- Docker / Docker Compose  
- DBeaver (для выполнения SQL-запросов и импорта CSV)


## Запуск базы данных

Запустить PostgreSQL через Docker:

```bash
docker compose up -d
```
После запуска база данных будет доступна со следующими параметрами подключения:

| Параметр | Значение |
|--------|--------|
| Host | localhost |
| Port | 5433 |
| Database | pet_shop_db |
| User | admin |
| Password | password |


## Импорт исходных данных

Исходные данные автоматически загружаются при запуске контейнера PostgreSQL.
Загрузка выполняется SQL-командами COPY, которые находятся в скрипте:
```bash
scripts/dml.sql
```
Файлы CSV монтируются в контейнер через Docker и загружаются в staging-таблицу mock_data.

После импорта в таблице должно быть **10000 строк**.

Проверка:

```sql
SELECT COUNT(*) FROM mock_data;
```
## Создание структуры хранилища данных

После запуска контейнера Docker автоматически выполняются SQL-скрипты:
```bash
scripts/ddl.sql
scripts/dml.sql
```
ddl.sql — создаёт таблицы Snowflake Schema
dml.sql — загружает данные и выполняет трансформацию

Создаются следующие таблицы:

- `dim_customers`
- `dim_products`
- `dim_sellers`
- `dim_stores`
- `dim_suppliers`
- `dim_locations`
- `fact_sales`

Модель данных реализована в виде **Snowflake Schema (схема "Снежинка")**.

## Проверка результата
Список таблиц:
```sql
\dt
```
Проверка количества записей в таблице фактов:

```sql
SELECT COUNT(*) FROM fact_sales;
```
Ожидаемый результат: 10000



