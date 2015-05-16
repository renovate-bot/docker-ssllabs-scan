# vim: set ts=8 sw=8 ai noet:

.PHONY: all
all: runtime

clean:
	rm -f ca-certificates.crt || :
	rm -f ssllabs-scan || :
	docker rm -f scanbuild || :
	docker rmi -f scanbuild || :

static: clean
	docker build -t scanbuild -f Dockerfile.build .
	docker create --name scanbuild scanbuild true
	docker cp scanbuild:/tmp/ssllabs-scan-1.1.0/ssllabs-scan .

certfile: static
	docker cp scanbuild:/etc/ssl/certs/ca-certificates.crt .

runtime: static certfile
	docker build -t jumanjiman/ssllabs-scan -f Dockerfile.runtime .
	docker images | grep ssllabs-scan

test:
	docker images | grep ssllabs-scan
	docker run -it jumanjiman/ssllabs-scan -grade -usecache https://github.com
