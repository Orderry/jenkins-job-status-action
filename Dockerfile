FROM cfmanteiga/alpine-bash-curl-jq:latest

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
