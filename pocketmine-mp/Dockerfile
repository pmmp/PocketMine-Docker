# Let's test for build-args to get errors out asap
FROM ubuntu:bionic
ARG PMMP_TAG
RUN test ! -z ${PMMP_TAG} || (echo "Missing build-arg PMMP_TAG" && false)

# Build stage for PHP compilation. Build tools like g++ will not be copied into the final stage to reduce image size.
FROM ubuntu:bionic AS php-build
ARG BUILD_SCRIPTS_BRANCH

RUN apt-get update && apt-get install --no-install-recommends -y curl ca-certificates build-essential m4 gzip bzip2 bison git cmake autoconf automake pkg-config libtool libtool-bin

RUN mkdir /build
WORKDIR /build
RUN curl -LO https://github.com/pmmp/php-build-scripts/raw/${BUILD_SCRIPTS_BRANCH:-master}/compile.sh
RUN chmod u+x compile.sh
RUN ./compile.sh -t linux64 -j ${THREADS:-$(grep -E ^processor /proc/cpuinfo | wc -l)} -f -u -g -l

# Build stage for PocketMine-MP.phar compilation. Build tools like composer will not be copied into the final stage.
FROM ubuntu:bionic AS phar-build
ARG PMMP_TAG

RUN apt-get update && apt-get install --no-install-recommends -y curl git ca-certificates cpp
COPY --from=php-build /build/bin/php7 /php
RUN ln -s /php/bin/php /usr/bin/php
ADD inject-metadata.php /usr/bin/inject-metadata

RUN mkdir /build
WORKDIR /build
RUN curl -L https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer

RUN git clone https://github.com/pmmp/PocketMine-MP.git -b ${PMMP_TAG} --recursive .
RUN composer install --classmap-authoritative --no-dev --prefer-source
RUN php build/preprocessor/PreProcessor.php --path=src --multisize
RUN php $(test -d resources || echo -n src/pocketmine/)resources/vanilla/.minify_json.php
RUN php -dphar.readonly=0 tests/plugins/PocketMine-DevTools/src/DevTools/ConsoleScript.php \
	--make=src,vendor$(test -d resources && echo -n ,resources) --relative=./ --entry=src/$(test -d src/pocketmine && echo -n pocketmine/)PocketMine.php --out=PocketMine-MP.phar
# Just to make sure DevTools didn't false-positive-exit
RUN test -f /build/PocketMine-MP.phar
RUN inject-metadata PocketMine-MP.phar git $(git rev-parse HEAD)

FROM ubuntu:bionic
MAINTAINER PMMP Team <team@pmmp.io>

RUN apt-get update && apt-get --no-install-recommends -y install \
	ca-certificates \
	curl \
	wget \
	vim
# I almost always need some handy text editors for debugging. Sorry...

RUN groupadd -g 1000 pocketmine
RUN useradd -r -d /pocketmine -p "" -u 1000 -m -g pocketmine pocketmine

WORKDIR /pocketmine
COPY --from=php-build /build/bin/php7 /usr/php
RUN ln -s /usr/php/bin/php /usr/bin/php
COPY --from=phar-build /build/PocketMine-MP.phar PocketMine-MP.phar
ADD start.sh /usr/bin/start-pocketmine

RUN mkdir /plugins /data
RUN chown 1000:1000 /plugins /data . -R
RUN chmod o+x /usr/bin/php

USER pocketmine

ENV TERM=xterm

EXPOSE 19132/tcp
EXPOSE 19132/udp

VOLUME ["/data", "/plugins"]

CMD start-pocketmine
