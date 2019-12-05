
define msg
	@printf "\033[36m $1 \n\033[0m"
endef

define msgc
	@printf "\n\033[32m\xE2\x9c\x93 $1 \n\033[0m"
	@printf "\n"
endef

.PHONY: all
.DEFAULT_GOAL := all
all: dpush kred ## - docker build / push / deploy to k8s

.PHONY: list
list: ## - List all make targets
	@$(MAKE) -pRrn : -f $(MAKEFILE_LIST) 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$2 !~ "^[#.]") {print $$2}}' | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sort

.PHONY: help
### .DEFAULT_GOAL := help
help: ## - Show help message
	$(call msgc,"usage: make [target]")
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":*?## "}; {printf "\033[36m%-20s\033[0m \t %s\n", $$1, $$2}'

.PHONY: run
run: build   ## - Build and run server (local)
	build/server

.PHONY: build
build:  ## - local build (server+client)
	make -C ../shared/grpc all
	go $(BUILD_TARGET) $(BUILDFLAGS) -o build/server cmd/server/server.go
	go $(BUILD_TARGET) $(BUILDFLAGS) -o build/client cmd/client/client.go

.PHONY: build.linux
build-linux:  ## - Build server binary for linux (simple and multi-phase builds are very slow)
	GOOS=linux go $(BUILD_TARGET) $(BUILDFLAGS) -o docker/lbuild/server cmd/server/server.go
	GOOS=linux go $(BUILD_TARGET) $(BUILDFLAGS) -o docker/lbuild/client cmd/client/client.go

##########
# Docker #
##########

.PHONY: dbuild
dbuild:	build-linux ## - Build local - copy to docker image
	@echo Building docker image $(IMG)
	# todo: make minikube/local containers conditional
	eval $(minikube docker-env)
	docker image build --label $(NAME) --tag $(IMG) docker

.PHONY: dbuild.multi
dbuild.multi:	## - Build docker image in CI
	$(call msgc,"Building docker image...")

	# Pull the latest version of the image, in order to
	# populate the build cache:
	docker pull $(IMG_BLD) || true
	docker pull $(IMG)     || true

	# Build the compile stage:
	docker build --target builder \
		   --cache-from=$(IMG_BLD) \
		   --tag $(IMG_BLD) .

	# Build the runtime stage, using cached compile stage:
	docker build --target runtime \
		   --cache-from=$(IMG_BLD) \
		   --cache-from=$(IMG) \
		   --tag $(IMG) .
	# Push the new versions:
	docker push $(IMG_BLD)
	docker push $(IMG)

.PHONY: dbuild-no-cache
dbuild-no-cache: ## - Docker build without cache
	$(call msgc,"Building docker image without cache...")
	@export DOCKER_CONTENT_TRUST=1 && docker build --no-cache -f Dockerfile --tag  $(IMG) .

.PHONY: dimg
dimg: ## - Show $(NAME) docker image
	@echo docker image $(IMG)
	@docker image ls $(IMG)

.PHONY: drun
drun: dbuild ## - Run docker container
	$(call msgc,"Run docker container")
	@echo when running in minikube - check you DOCKER_HOST minikube docker-env
	@echo i.e. http://192.168.99.100:8080
	@echo ---
	@docker run --rm $(DAEMON) --name $(NAME) -p 8080:8080 -p 52052:52052 $(IMG)

.PHONY: dkill
dkill: ## - Kill running $(NAME) docker container
	$(call msgc,"Kill running $(NAME) container")
	@docker kill $(NAME)

.PHONY: dps
dps: ## - Show $(NAME) container status
	docker ps | grep $(NAME)

.PHONY: dpush
dpush: dbuild ## - Publish image $(IMG)
	#docker push $(IMG)
	@echo not pushing - use local images in minikube environment

.PHONY: dpull
dpull: ## - Pull image $(IMG)
	## @`aws ecr get-login --region ${REGION} --no-include-email`
	docker pull $(IMG)

.PHONY: dlogin
dlogin: ## - docker ECR login
	@`aws ecr get-login --region ${REGION} --no-include-email`

##############
# Kubernetes #
##############

.PHONY: kdep
kdep: dbuild dpush ## - Kustomize and Deploy to k8s   kustomize edit set image $(IM)=$(IMG)
	cd $(BASE) && kustomize edit set image $(IM)=$(IMG) && kustomize build . | kubectl apply -f - && cd ..
	######### testing argo cd
	#cd $(BASE) && kustomize edit set image $(IM)=$(IMG) && kustomize build . && cd ..
	#########
	#kustomize build $(OVERLAYS)/test2
	#kustomize build $(OVERLAYS)/test2 | kubectl apply -f -

.PHONY: kund
kund: ## - Undeploy from k8s
	# disable delete errors
	@set +e
	cd $(BASE) && kubectl delete -f deployment.yaml && cd ..
	#kustomize build $(OVERLAYS)/test2 | kubectl delete -f -
	@set -e

.PHONY: kred
kred: kund kdep ## - k8s redeploy

.PHONY: kpf
kpf: ## - port forwarding (grpc port 52052, rest port 8080)
	kubectl port-forward $(POD) 52052:52052 8080:8080

.PHONY: kcall
kcall: build ## - grpc client test calls after kdep
	build/client -config=client-config.yaml

.PHONY: test
test: build ## - integration testing sript (local, see test.sh)
	./test.sh

.PHONY: ktest
ktest: ## - integration testing after kdep (see ktest.sh)
	cd test && ./ktest.sh

.PHONY: kpod
kpod: ## - show $(NAME) pods
	#kubectl get pod $(shell kubectl get pod -l app=myservice -o jsonpath='{.items[*].metadata.name}')
	kubectl get pod -l app=$(NAME) -o wide

.PHONY: clone
clone: ## - clone this directory to new service with renaming
	go run cmd/clone/clone.go


