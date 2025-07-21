# Airflow

- [Проект для разработки  под Apache Airflow](#проект-для-разработки--под-apache-airflow)
  - [Предварительные установки локального окружения](#предварительные-установки-локального-окружения)
  - [Настройки Airflow для разработки](#настройки-airflow-для-разработки)
    - [Для локальной установки](#для-локальной-установки)
    - [Для работы с Docker.](#для-работы-с-docker)
  - [Разработка](#разработка)

[![pipeline status](https://gitlab.askona.ru/dp-data-platform/airflow/badges/main/pipeline.svg)](https://gitlab.askona.ru/dp-data-platform/airflow/-/commits/main)
[![coverage report](https://gitlab.askona.ru/dp-data-platform/airflow/badges/main/coverage.svg)](https://gitlab.askona.ru/dp-data-platform/airflow/-/commits/main)
[![Latest Release](https://gitlab.askona.ru/dp-data-platform/airflow/-/badges/release.svg)](https://gitlab.askona.ru/dp-data-platform/airflow/-/releases)
# Проект для разработки  под Apache Airflow



Требования: Python, PyCharm

## Предварительные установки локального окружения

```shell
# airflow  нужен домашний каталог, ~/airflow задается как путь по умолчанию,
# но для своих проектов можно изменить на любую удобную,
# для Windows - опередить AIRFLOWHOME в системных переменных
export AIRFLOW_HOME=~/airflow

#сейчас 2.2.3 -  максимальная версия на 28.12.2021
AIRFLOW_VERSION=2.2.3
PYTHON_VERSION="$(python --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
# Например: 3.9
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"
# Пример запроса: https://raw.githubusercontent.com/apache/airflow/constraints-2.1.3/constraints-3.9.txt
pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"

# Можно запустить все в stanalone режиме - будет запуск
# вебсервера, воркера и предварительно будет инициализация
# базы данных, в процессе будет создан пользователь
# admin и пароль к нему
# Если надо более тонко настроить, попускаем этот шаг
airflow standalone

# Инициализация базы данных
airflow db init
# Инициализация первого пользователя - админа
# При выполнении будет запрошен пароль для нового пользователя
airflow users create \
    --username admin \
    --firstname airflow \
    --lastname airflow \
    --role Admin \
    --email airflow@askona.ru

#  Запуск веб-сервера, порт по умолчанию 8080
airflow webserver --port 8080

# Запуск веб-сервера в фоне
# airflow webserver -D --port 8080

# Запуск scheduler
# Если веб-сервер запущен не в фоне (ключ -D),
# то запуск sheduller должен быть в новом окне терминала
airflow scheduler

# Открыть http://localhost:8080
# Вход под пользователем, который создали ранее


```



## Настройки Airflow для разработки

Два варианта - установить Airflow на работчу машину, либо установить в Docker

### Для локальной установки
1. Установить Airflow 
1. Перейти в домашний каталог **$AIRFLOWHOME**
2. Открыть файл *airflow.cfg*
3. Найти секцию **[core]**
4. Отредактировать путь для дагов 
```shell
dags_folder = MY_PROJECT_FOLDER/example_dags
```
5. Отредактировать путь для плагинов
```shell
plugins_folder = MY_PROJECT_FOLDER/plugins
```


### Для работы с Docker.

Есть файл - docker-compose.yaml.
В терминале (или в IDE вызываем командой) для первого запуска
```shell
docker-compose up --build
```

Для последующих вызовов (если файл Docker, переменных и соединений не менялся)

```shell
docker-compose up
```


Будет создана папка airflow_home, в ней будет файл standalone_admin_password.txt.

![](docs/user_password_docker.png)

 В нем пароль для пользователя admin. Порт - 8080. Т.е. открываем http://localhost:8080, видим интерфейс. Папка dags автоматически мапится в контейнер.


## Разработка


```shell
.
├── app
│   ├── git_to_liquibase.py
│   └── liquibase
├── docker-compose.yml
├── Dockerfile
├── Dockerfile.liquibase
├── drivers
│   └── postgresql-42.7.6.jar
├── liquibase
├── liquibase.properties
├── logs
│   └── liquibase.log
├── Makefile
├── README.md
├── scripts
│   ├── gituser.sh
│   ├── push.sh
│   ├── source.sh
│   └── sqlinit.sh
└── source_sql
```
