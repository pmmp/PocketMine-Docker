FROM ubuntu:bionic
MAINTAINER PMMP Team <team@pmmp.io>

EXPOSE 19132/tcp
EXPOSE 19132/udp

RUN apt-get update && apt-get --no-install-recommends -y install \
	sudo \
	ca-certificates \
	jq \
	curl \
	unzip

RUN groupadd -g 1000 pocketmine
RUN useradd -r -d /pocketmine -p "" -u 1000 -m -g pocketmine -g sudo pocketmine

WORKDIR /pocketmine
ADD bin /pocketmine/bin
ADD PocketMine-MP.phar /pocketmine/PocketMine-MP.phar
ADD start.sh /pocketmine/start.sh
RUN chown -R pocketmine:1000 .

USER pocketmine
RUN chmod +x bin/php7/bin/php start.sh

ENV TERM=xterm

VOLUME ["/data", "/plugins"]
CMD bash -c 'sudo chown 1000 /data /plugins -R && ./start.sh --no-wizard --enable-ansi --data=/data --plugins=/plugins'
