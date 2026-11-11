SHELL := /bin/bash

# ---- Настройки (можно переопределить: make up SSH_KEY=~/.ssh/other) ----
SSH_KEY         ?= $(HOME)/.ssh/k8s-learning
KUBESPRAY_IMAGE ?= quay.io/kubespray/kubespray:v2.32.0
INVENTORY       := $(CURDIR)/kubespray/inventory/k8s-lab
KUBECONFIG_FILE := $(INVENTORY)/artifacts/admin.conf
TF              := terraform -chdir=terraform

export DOCKER_DEFAULT_PLATFORM := linux/amd64

KUBESPRAY_RUN := docker run --rm \
	-v "$(INVENTORY):/inventory" \
	-v "$(SSH_KEY):/root/.ssh/id_k8s:ro" \
	-e ANSIBLE_HOST_KEY_CHECKING=False \
	$(KUBESPRAY_IMAGE)

ANSIBLE_ARGS := -i /inventory/hosts.yaml --private-key /root/.ssh/id_k8s

.PHONY: help up down infra wait cluster kubeconfig status ssh-cp

help: ## Показать список команд
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-12s %s\n", $$1, $$2}'

up: infra wait cluster kubeconfig ## Поднять всё с нуля: AWS + Kubernetes
	@echo "Кластер готов. Выполни: export KUBECONFIG=\"$(KUBECONFIG_FILE)\""

infra: ## Создать или обновить инфраструктуру в AWS
	$(TF) init -input=false
	$(TF) apply -auto-approve

wait: ## Дождаться, пока все ноды примут SSH
	$(KUBESPRAY_RUN) ansible all $(ANSIBLE_ARGS) -m wait_for_connection -a "timeout=300"

cluster: ## Установить Kubernetes через Kubespray
	set -o pipefail; \
	$(KUBESPRAY_RUN) ansible-playbook $(ANSIBLE_ARGS) --become cluster.yml 2>&1 | tee kubespray-run.log
	$(MAKE) kubeconfig

kubeconfig: ## Прописать публичный IP control plane в kubeconfig
	kubectl --kubeconfig "$(KUBECONFIG_FILE)" config set-cluster cluster.local \
		--server="https://$$($(TF) output -raw control_plane_public_ip):6443"

status: ## Показать ноды и системные поды
	kubectl --kubeconfig "$(KUBECONFIG_FILE)" get nodes -o wide
	kubectl --kubeconfig "$(KUBECONFIG_FILE)" get pods -A

ssh-cp: ## SSH на control plane
	ssh -i "$(SSH_KEY)" ubuntu@$$($(TF) output -raw control_plane_public_ip)

down: ## Удалить всё из AWS
	$(TF) destroy
	rm -rf "$(INVENTORY)/artifacts"
