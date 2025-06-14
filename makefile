# Define the Docker Compose file
COMPOSE_FILE :=
ENV_FILE :=
THIS_FILE := $(lastword $(MAKEFILE_LIST))

# Check if "db" is present in the APPS
ifeq (, $(filter , $(APPS)))
	APPS := db admin api event
endif

# Concatenate all values in ENV to COMPOSE_FILE and ENV_FILE
COMPOSE_FILE += $(foreach t, $(APPS), -f ./local-dev/docker-compose.$(t).yaml)
ENV_FILE += $(foreach t, $(APPS), --env-file ./local-dev/.env.$(t))

# Define the Docker Compose command with the necessary flags
COMPOSE_CMD := DOCKER_BUILDKIT=1 docker compose $(COMPOSE_FILE) $(ENV_FILE)

.PHONY: up

# Target to start the services
up:
	@$(COMPOSE_CMD) $@ -d

# Target to start up and attach to the services
run:
	@$(COMPOSE_CMD) up

# Target to stop the services
down:
	@$(COMPOSE_CMD) $@

# Target to rebuild the services
build:
	@$(COMPOSE_CMD) $@

# Target to rebuild the services
restart:
	@$(MAKE) $(THIS_FILE) down
	@$(MAKE) $(THIS_FILE) build
	@$(MAKE) $(THIS_FILE) up -d

# Target to rebuild the services
rebuild:
	@$(COMPOSE_CMD) build --no-cache

# Target to stop and remove volumes
clean-destroy:
	@$(COMPOSE_CMD) down -v
