ARG PMMP_IMAGE
ARG PMMP_TAG
FROM ${PMMP_IMAGE:-pmmp/pocketmine-mp}:${PMMP_TAG}

USER root
RUN wget -qO /usr/bin/phpstan https://github.com/phpstan/phpstan/releases/download/0.12.2/phpstan.phar
RUN chmod o+x /usr/bin/phpstan
ADD analyze.php /usr/bin/analyze
ADD phpstan.neon /pocketmine/phpstan.neon
RUN mkdir /deps
RUN chown 1000:1000 /pocketmine/phpstan.neon /deps -R

USER pocketmine
CMD analyze -c /pocketmine/phpstan.neon
