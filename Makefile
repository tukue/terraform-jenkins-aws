LOCAL_COMPOSE := docker compose -f docker-compose.local.yaml
REPO_ROOT := $(CURDIR)
BACKSTAGE_APP_DIR := $(REPO_ROOT)/backstage-app
TFSCAN ?= tfsec

.PHONY: local-up local-down local-ps local-logs local-health backstage-install backstage-start backstage-validate tfscan

local-up:
	$(LOCAL_COMPOSE) up -d

local-down:
	$(LOCAL_COMPOSE) down

local-ps:
	$(LOCAL_COMPOSE) ps

local-logs:
	$(LOCAL_COMPOSE) logs --tail=100

local-health:
	@echo "Backstage:   http://localhost:$${BACKSTAGE_PORT:-7000}"
	@echo "Backend:     http://localhost:$${BACKSTAGE_BACKEND_PORT:-7007}"
	@echo "Grafana:     http://localhost:$${GRAFANA_PORT:-3001}"
	@echo "Prometheus:  http://localhost:$${PROMETHEUS_PORT:-9090}"
	@echo "Vault:       http://localhost:$${VAULT_PORT:-8200}"

backstage-install:
	cd $(BACKSTAGE_APP_DIR) && yarn install

backstage-start:
	cd $(BACKSTAGE_APP_DIR) && REPO_ROOT=$(REPO_ROOT) yarn start

backstage-validate:
	node backstage-local-test/test-catalog.js

tfscan:
	$(TFSCAN) . --exclude-downloaded-modules
