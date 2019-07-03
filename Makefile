SHELL := /bin/bash

NS ?= abhinavsingh
IMAGE_NAME ?= proxy.py
VERSION ?= v0.4
LATEST_TAG := $(NS)/$(IMAGE_NAME):latest
IMAGE_TAG := $(NS)/$(IMAGE_NAME):$(VERSION)

.PHONY: all clean test package test-release release coverage flake8 container run-container release-container

all: clean test

clean:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	rm -f .coverage
	rm -rf htmlcov
	rm -rf dist

test:
	python tests.py -v

package: clean
	python setup.py sdist bdist_wheel

test-release: package
	twine upload --repository-url https://test.pypi.org/legacy/ dist/*

release: package
	twine upload dist/*

coverage:
	coverage run tests.py
	coverage html

flake8:
	flake8 --ignore=E501,W504 --builtins="unicode" proxy.py
	flake8 --ignore=E501,W504 tests.py

container:
	docker build -t $(LATEST_TAG) -t $(IMAGE_TAG) .

run-container:
	docker run -it -p 8899:8899 --rm $(LATEST_TAG)

release-container:
	docker push $(IMAGE_TAG)

start-eth0:
	nohup python3 proxy.py --host $(shell ifconfig eth0 |grep netmask |awk '{print $$2}') --port 3721 >/var/log/proxy-eth0.log 2>&1 &

start-eth1:
	nohup python3 proxy.py --host $(shell ifconfig eth1 |grep netmask |awk '{print $$2}') --port 3721 >/var/log/proxy-eth1.log 2>&1 &
