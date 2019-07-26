HOME=$(shell pwd)
MAINVERSION=2.0
SSLMAINVERSION=1_0_2
VERSION=$(shell wget -qO- http://git.haproxy.org/git/haproxy-${MAINVERSION}.git/refs/tags/ | sed -n 's:.*>\(.*\)</a>.*:\1:p' | sed 's/^.//' | sort -rV | head -1)
ifeq ("${VERSION}","./")
        VERSION="${MAINVERSION}.0"
endif
SSLVERSION=$(shell wget -qO- https://github.com/openssl/openssl/tags | grep ${SSLMAINVERSION} | sed 's/<[^>]*>//g' | grep ${SSLMAINVERSION} | head -n1 | sed "s/ //g"
RELEASE=1

all: build

install_prereq:
	sudo yum install -y pcre-devel make gcc openssl-devel rpm-build systemd-devel wget sed

clean:
	rm -f ./SOURCES/haproxy-${VERSION}.tar.gz
	rm -f ./SOURCES/openssl-${SSLVERSION}.tar.gz
	rm -rf ./rpmbuild
	mkdir -p ./rpmbuild/SPECS/ ./rpmbuild/SOURCES/ ./rpmbuild/RPMS/ ./rpmbuild/SRPMS/

download-upstream:
	wget http://www.haproxy.org/download/${MAINVERSION}/src/haproxy-${VERSION}.tar.gz -O ./SOURCES/haproxy-${VERSION}.tar.gz

download-openssl:
	wget https://github.com/openssl/openssl/archive/${SSLMAINVERSION}.tar.gz -O /tmp/openssl-${SSLVERSION}.tar.gz
	tar zxvf /tmp/openssl-${SSLVERSION}.tar.gz
	mkdir /tmp/staticlibssl
 	cd /tmp/open*
	./config --prefix=/tmp/staticlibssl no-shared
	make
	make_sw	

build: install_prereq clean download-upstream
	cp -r ./SPECS/* ./rpmbuild/SPECS/ || true
	cp -r ./SOURCES/* ./rpmbuild/SOURCES/ || true
	rpmbuild -ba SPECS/haproxy.spec \
	--define "version ${VERSION}" \
	--define "release ${RELEASE}" \
	--define "_topdir %(pwd)/rpmbuild" \
	--define "_builddir %{_topdir}/BUILD" \
	--define "_buildroot %{_topdir}/BUILDROOT" \
	--define "_rpmdir %{_topdir}/RPMS" \
	--define "_srcrpmdir %{_topdir}/SRPMS"
