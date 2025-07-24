name = Docker Registry

VAR :=				# Cmd arg var
NO_COLOR=\033[0m	# Color Reset
OK=\033[32;01m		# Green Ok
ERROR=\033[31;01m	# Error red
WARN=\033[33;01m	# Warning yellow
DIR := $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
ifneq (,$(wildcard .env))
    include .env
    export $(shell sed 's/=.*//' .env)
endif

all:
	@printf "Запуск конфигурации ${name}...\n"
	@docker-compose -f ./docker-compose.yml up -d

help:
	@printf "Справка по конфигурации ${name}...\n"
	@echo -e "$(OK)==== Все команды для конфигурации ${name} ===="
	@echo -e "$(WARN)- make				: Запуск конфигурации"
	@echo -e "$(WARN)- make build			: Сборка конфигурации"
	@echo -e "$(WARN)- make conn			: Подключение к ${REGISTRY_NAME}"
	@echo -e "$(WARN)- make con			: Подключение к ${REGISTRY_NAME}"
	@echo -e "$(WARN)- make condb			: Подключение к ${POSTGRES_NAME}"
	@echo -e "$(WARN)- make conui			: Подключение к ${REGUI_NAME}"
	@echo -e "$(WARN)- make down			: Остановка конфигурации"
	@echo -e "$(WARN)- make env			: Создание .env-файла"
	@echo -e "$(WARN)- make log			: Просмотреть логи ${REGISTRY_NAME}"
	@echo -e "$(WARN)- make logui			: Просмотреть логи ${REGSTGUI_NAME}"
	@echo -e "$(WARN)- make net			: Создать сеть с именем из .env"
	@echo -e "$(WARN)- make ps			: Обзор запущенной конфигурации"
	@echo -e "$(WARN)- make re			: Перезапуск всей конфигурации"
	@echo -e "$(WARN)- make redb			: Перезапуск контейнера ${POSTGRES_NAME}"
	@echo -e "$(WARN)- make rere			: Перезапуск контейнера ${REGISTRY_NAME}"
	@echo -e "$(WARN)- make reui			: Перезапуск контейнера ${REGSTGUI_NAME}"
	@echo -e "$(WARN)- make clean			: Очистка конфигурации"
	@echo -e "$(WARN)- make fclean			: Очистка кеша docker!$(NO_COLOR)"

build:
	@printf "Сборка конфигурации ${name}...\n"
	@docker-compose -f ./docker-compose.yml up -d --build

cert:
	@printf "$(YELLOW)==== Установка сертификата и ключа для ${name} ====$(NO_COLOR)\n"
	@bash scripts/certificates.sh

conn:
	@printf "$(ERROR_COLOR)==== Соединение с контейнером ${REGISTRY_NAME}... ====$(NO_COLOR)\n"
	@docker exec -it ${REGISTRY_NAME} sh

con:
	@printf "$(ERROR_COLOR)==== Соединение с контейнером ${REGISTRY_NAME}... ====$(NO_COLOR)\n"
	@docker exec -it ${REGISTRY_NAME} sh

conui:
	@printf "$(ERROR_COLOR)==== Соединение с контейнером ${REGSTGUI_NAME}... ====$(NO_COLOR)\n"
	@docker exec -it ${REGSTGUI_NAME} sh

condb:
	@printf "$(ERROR_COLOR)==== Соединение с контейнером ${POSTGRES_NAME}... ====$(NO_COLOR)\n"
	@docker exec -it ${POSTGRES_NAME} sh

down:
	@printf "Остановка конфигурации ${name}...\n"
	@docker-compose -f ./docker-compose.yml down

env:
	@printf "$(ERROR_COLOR)==== Создание файла окружения для ${name}... ====$(NO_COLOR)\n"
	@if [ -f .env ]; then \
		echo "$(ERROR_COLOR).env-файл уже существует!$(NO_COLOR)"; \
	else \
		cp .env.example .env; \
		echo "$(GREEN).env-файл успешно создан!$(NO_COLOR)"; \
	fi

git:
	@printf "$(YELLOW)==== Установка имени пользователя и почты для ${name} репозитория... ====$(NO_COLOR)\n"
	@bash scripts/gituser.sh

log:
	@printf "$(YELLOW)==== Show logs for ${REGISTRY_NAME}... ====$(NO_COLOR)\n"
	@docker logs ${REGISTRY_NAME}

logdb:
	@printf "$(YELLOW)==== Show logs for ${POSTGRES_NAME}... ====$(NO_COLOR)\n"
	@docker logs ${POSTGRES_NAME}

logui:
	@printf "$(YELLOW)==== Show logs for ${REGSTGUI_NAME}... ====$(NO_COLOR)\n"
	@docker logs ${REGSTGUI_NAME}

net:
	@printf "$(YELLOW)==== Создание сети для конфигурации ${name}... ====$(NO_COLOR)\n"
	@docker network create \
	  --driver=bridge \
	  --subnet=$(NETWORK_ADDR) \
	  --gateway=$(NETWORK_GATE) \
	  $(REGISTRY_NET)

ps:
	@printf "$(YELLOW)==== Просмотр работающих контейнеров конфигурации ${name}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml ps

push:
	@printf "$(YELLOW)==== Пуш последних изменений в ${name} репозиторий... ====$(NO_COLOR)\n"
	@bash ./scripts/push.sh

re:
	@printf "$(YELLOW)==== Перезапуск конфигурации ${name}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml down
	@docker-compose -f ./docker-compose.yml up -d --no-deps --build

redb:
	@printf "$(YELLOW)==== Перезапуск конфигурации ${POSTGRES_NAME}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml down postgres
	@docker-compose -f ./docker-compose.yml up -d --no-deps --build postgres

rere:
	@printf "$(YELLOW)==== Перезапуск конфигурации ${REGISTRY_NAME}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml down registry
	@docker-compose -f ./docker-compose.yml up -d --no-deps --build registry

reui:
	@printf "$(YELLOW)==== Перезапуск конфигурации ${REGSTGUI_NAME}... ====$(NO_COLOR)\n"
	@docker-compose -f ./docker-compose.yml down registry-ui
	@docker-compose -f ./docker-compose.yml up -d --no-deps --build registry-ui

clean: down
	@printf "Очистка конфигурации ${name}...\n"
	@yes | docker system prune -a

fclean:
	@printf "Полная очистка всех конфигураций docker\n"
#	@yes | docker system prune -a
#	@docker stop $$(docker ps -qa)
#	@docker system prune --all --force --volumes
#	@docker network prune --force
#	@docker volume prune --force

.PHONY	: all build down dump init local localbuild ps push re scripts up clean fclean
