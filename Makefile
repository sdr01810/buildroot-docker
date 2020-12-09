docker_base_os           = ubuntu
docker_base_image        = ${docker_base_os}:20.04

docker_build_args_extra  = # --no-cache

docker_hub_user          = $(or ${DOCKER_HUB_USER},UNNOWN_DOCKER_HUB_USER)
#^-- override this on the make(1) command line or in the environment

container_name           = $(shell cat Docker.container.name)

image_tag                = ${docker_hub_user}/${container_name}

##

all :: build test #!#push

clean ::

clobber :: clean

build :: Dockerfile Makefile $(shell ls 2>&- *.md *.sh artifacts.d/* support/buildroot-tools/*.sh support/buildroot-tools/*.txt)
	docker build ${docker_build_args_extra} --tag "${image_tag}" .

test :: build
	docker run "${image_tag}" ls -alh -R

push ::
	docker push "${image_tag}"

##

Dockerfile : Dockerfile.in
	cat $< | perl -pe "s/[@]make:docker_base_image[@]/${docker_base_image}/" > $@

clean ::
	rm -f Dockerfile

##

