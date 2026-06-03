LOCAL_COMPOSE := docker compose -f docker-compose.local.yaml
REPO_ROOT := $(CURDIR)
BACKSTAGE_APP_DIR := $(REPO_ROOT)/backstage-app
TF_PLAN ?= tfplan.json
TF_ENV ?= dev

.PHONY: help local-up local-down local-ps local-logs local-health backstage-install backstage-start backstage-validate fmt validate lint security policy quality tfsec provision bootstrap scaffold dev-up

help:
	@printf "%s\n" \
		"provision             Quickstart: init + validate + plan for TF_ENV=$(TF_ENV)" \
		"bootstrap             Install pre-commit hooks and tooling" \
		"scaffold              List available Backstage scaffolder templates" \
		"dev-up                Start full local dev environment" \
		"local-up              Start the local platform stack" \
		"local-down            Stop the local platform stack" \
		"backstage-validate    Validate Backstage catalog wiring" \
		"fmt                   Check Terraform formatting" \
		"validate              Validate Terraform without a backend" \
		"lint                  Run TFLint recursively" \
		"security              Run tfsec and Checkov scans" \
		"policy                Run Conftest against TF_PLAN=$(TF_PLAN)" \
		"quality               Run fmt, validate, lint, and security"

bootstrap:
	@echo "==> Installing pre-commit hooks"
	@command -v pre-commit >/dev/null 2>&1 && pre-commit install || echo "Install pre-commit: pip install pre-commit"
	@echo "==> Initializing TFLint"
	@command -v tflint >/dev/null 2>&1 && tflint --init || echo "Install TFLint: https://github.com/terraform-linters/tflint"
	@echo "==> Done. Run 'make quality' to validate everything."

provision:
	@echo "==> Provisioning $(TF_ENV) environment"
	terraform init -backend-config=backend-config-$(TF_ENV).hcl
	terraform fmt -check -recursive
	terraform validate
	terraform plan -var-file=terraform.$(TF_ENV).tfvars -out=tfplan-$(TF_ENV)

scaffold:
	@echo "Available Backstage scaffolder templates:"
	@for f in templates/*.yaml; do \
		name=$$(grep -m1 'name:' "$$f" 2>/dev/null | head -1 | sed 's/.*name:[[:space:]]*//'); \
		desc=$$(grep -m1 'description:' "$$f" 2>/dev/null | head -1 | sed 's/.*description:[[:space:]]*//'); \
		printf "  %-45s %s\n" "$$name" "$$desc"; \
	done

dev-up:
	@echo "==> Starting full local dev environment"
	$(LOCAL_COMPOSE) up -d
	@echo "==> Services starting..."
	$(MAKE) local-health

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

fmt:
	terraform fmt -check -recursive

validate:
	terraform init -backend=false
	terraform validate

lint:
	tflint --init
	tflint --recursive

security: tfsec
	checkov --directory . --framework terraform

policy:
	conftest test $(TF_PLAN) --policy policies/terraform

quality: fmt validate lint security

tfsec:
	tfsec . --exclude-downloaded-modules
