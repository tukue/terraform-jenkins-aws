.PHONY: deploy test

IMAGE_TAG ?= local
CONFIG_PATH ?= apps/sample-api/platform/app.env

test:
	python -m unittest discover -s apps/sample-api

deploy:
	powershell -ExecutionPolicy Bypass -File scripts/deploy.ps1 -ConfigPath $(CONFIG_PATH) -ImageTag $(IMAGE_TAG)
