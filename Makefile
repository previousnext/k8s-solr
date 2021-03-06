#!/usr/bin/make -f

export CGO_ENABLED=0

PROJECT=github.com/previousnext/k8s-solr

# Builds the project
build:
	gox -os='linux darwin' -arch='amd64' -output='bin/k8s-solr_{{.OS}}_{{.Arch}}' -ldflags='-extldflags "-static"' $(PROJECT)

# Run all lint checking with exit codes for CI
lint:
	golint -set_exit_status `go list ./... | grep -v /vendor/`

# Run tests with coverage reporting
test:
	go test -cover ./client/...
	go test -cover ./crd/...
	go test -cover ./k8s/...

IMAGE=previousnext/k8s-solr
VERSION=$(shell git describe --tags --always)

release: release-docker release-github

# Release the project Docker Hub
release-docker:
	docker build -t ${IMAGE}:${VERSION} .
	docker push ${IMAGE}:${VERSION}
	docker build -t ${IMAGE}:latest .
	docker push ${IMAGE}:latest

# Release the project to Github.
release-github: build
	ghr -u previousnext "${VERSION}" ./bin/