build:
	docker build -t dind-ubuntu1804-ansible .

run:
	docker run --rm -it --privileged \
		dind-ubuntu1804-ansible
