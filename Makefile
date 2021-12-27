GITHUB_USER ?= marcelocorreia
GIT_REPO_NAME ?= figlet4go
SEMVER_BIN ?= semver
RELEASE_TYPE ?= minor


wrap-up:
	go mod tidy
	go mod vendor




snapshot:
	@$(info - Releasing $(PROJECT_NAME)-snapshot)
	@goreleaser release --snapshot --skip-publish --rm-dist

release-zero: ;$(info Creating initial release)
	@git tag 0.0.0
	@git push $(GIT_REMOTE) --tags

release: _setup-versions
	@git add .
	@git commit -m "release"
	@git push
	@git tag $(NEXT_VERSION)
	@git push $(GIT_REMOTE) --tags
	@$(info - Releasing...)
	@goreleaser release --rm-dist


all-versions:
	@git ls-remote --tags $(GIT_REMOTE)

current-version: _setup-versions
	@echo $(CURRENT_VERSION)

next-version: _setup-versions
	@echo $(NEXT_VERSION)

_setup-versions:
	$(eval export CURRENT_VERSION=$(shell git ls-remote --tags $(GIT_REMOTE) | grep -v latest | awk '{ print $$2}'|grep -v 'stable'| sort -r --version-sort | head -n1|sed 's/refs\/tags\///g'))
	$(eval export NEXT_VERSION=$(shell $(SEMVER_BIN) -c -i $(RELEASE_TYPE) $(CURRENT_VERSION)))



define git_push
	-git add .
	-git commit -m "$1"
	-git push
endef