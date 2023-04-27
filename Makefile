USER_ID := $(shell id -u)
GROUP_ID := $(shell echo 4242)
PWD := $(shell pwd)
WORKDIR := $(shell echo "/opt/app")
EXECUTE_FROM := ${EXECUTE_FROM}
EXECUTE_TILL := ${EXECUTE_TILL}

clean-db:
	@rm -rf ./storage/prod.db
	@rm -rf ./storage/test.db

clean-logs:
	@rm -rf ./storage/*.log

clean-storage: clean-db clean-logs

test:
	@docker rm -f crawler_test &> /dev/null || true
	@docker run \
		--name crawler_test \
		--env WORKDIR=$(WORKDIR) \
		--env RACK_ENV='test' \
		--mount type=bind,source=$(PWD)/src,target=/opt/app/src \
		--mount type=bind,source=$(PWD)/storage,target=/opt/app/storage \
		--privileged \
		-t \
		crawler_env:latest \
		/bin/sh -c 'cd $(WORKDIR)/src && bundle exec rspec'
	@docker rm -f crawler_test &> /dev/null || true

run:
	@docker rm -f crawler &> /dev/null || true
	@docker run \
		--name crawler \
		--env WORKDIR=$(WORKDIR) \
		--mount type=bind,source=$(PWD)/src,target=/opt/app/src \
		--mount type=bind,source=$(PWD)/storage,target=/opt/app/storage \
		--privileged \
		crawler_env:latest \
		/bin/sh -c 'cd $(WORKDIR)/src && make crawl'
	@docker rm -f crawler 2> /dev/null|| true

exec:
	@docker run -ti \
		--env WORKDIR=$(WORKDIR) \
		--mount type=bind,source=$(PWD)/src,target=/opt/app/src \
		--mount type=bind,source=$(PWD)/storage,target=/opt/app/storage \
		--privileged \
		crawler_env:latest \
		/bin/sh -c 'cd $(WORKDIR)/src; bash'

build-docker:
	@docker build \
		-t crawler_env:latest \
		--build-arg USER_ID=$(USER_ID)  \
		--build-arg GROUP_ID=$(GROUP_ID) \
		-f docker/Dockerfile . \
		&& docker create --name gemfile_tmp crawler_env \
		&& docker cp gemfile_tmp:/opt/app/Gemfile.lock ./ \
		&& docker rm -f gemfile_tmp
