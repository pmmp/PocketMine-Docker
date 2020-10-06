# Build stage for compilation. Build tools like g++ will not be copied into the final stage to reduce image size.
FROM ubuntu:18.04
ARG PMMP_TAG
RUN test ! -z ${PMMP_TAG} || (echo "Missing build-arg PMMP_TAG" && false)

RUN apt-get update && apt-get install --no-install-recommends -y curl ca-certificates build-essential m4 gzip bzip2 bison git cmake autoconf automake pkg-config libtool libtool-bin re2c

RUN mkdir /build
WORKDIR /build
RUN git clone https://github.com/pmmp/PocketMine-MP.git -b ${PMMP_TAG} --recursive .
WORKDIR /build/build/php
RUN ./compile.sh -t linux64 -j ${THREADS:-$(grep -E ^processor /proc/cpuinfo | wc -l)} -f -u -g -l
RUN ln -s /build/build/php/bin/php7/bin/php /usr/bin/php

WORKDIR /build
RUN curl -L https://getcomposer.org/installer | php
RUN mv composer.phar /usr/bin/composer

RUN composer install --classmap-authoritative --no-dev --prefer-source
RUN php build/preprocessor/PreProcessor.php --path=src --multisize
RUN php $(test -d resources || echo -n src/pocketmine/)resources/vanilla/.minify_json.php

RUN php build/server-phar.php --git $(git rev-parse HEAD)
# Just to make sure DevTools didn't false-positive-exit
RUN test -f /build/PocketMine-MP.phar

FROM ubuntu:18.04
LABEL maintainer="PMMP Team <team@pmmp.io>"

RUN apt-get update && apt-get install --no-install-recommends -y ca-certificates wget

RUN groupadd -g 1000 pocketmine
RUN useradd -r -d /pocketmine -p "" -u 1000 -m -g pocketmine pocketmine

WORKDIR /pocketmine
COPY --from=0 /build/build/php/bin/php7 /usr/php
RUN grep -q '^extension_dir' /usr/php/bin/php.ini && \
	sed -ibak "s{^extension_dir=.*{extension_dir=\"$(find /usr/php -name *debug-zts*)\"{" /usr/php/bin/php.ini || echo "extension_dir=\"$(find /usr/php -name *debug-zts*)\"" >> /usr/php/bin/php.ini
RUN ln -s /usr/php/bin/php /usr/bin/php
COPY --from=0 /build/PocketMine-MP.phar PocketMine-MP.phar
ADD start.sh /usr/bin/start-pocketmine

RUN mkdir /plugins /data
RUN chown 1000:1000 /plugins /data . -R
RUN chmod o+x /usr/bin/php

USER pocketmine

ENV TERM=xterm

EXPOSE 19132/tcp
EXPOSE 19132/udp

VOLUME ["/data", "/plugins"]

CMD ["start-pocketmine"]
