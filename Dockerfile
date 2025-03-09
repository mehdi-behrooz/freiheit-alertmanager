# syntax=docker/dockerfile:1

FROM prom/alertmanager:v0.28.1 AS alertmanager
FROM alpine:3

RUN apk update \
    && apk add --no-cache gettext-envsubst

RUN addgroup --system alertmanager && \
    adduser --system --disabled-password alertmanager --ingroup alertmanager

COPY --from=alertmanager /bin/amtool /bin/amtool
COPY --from=alertmanager /bin/alertmanager /bin/alertmanager
COPY --chmod=755 entrypoint.sh /usr/bin/entrypoint.sh
COPY alertmanager.yml.tmpl /etc/alertmanager/alertmanager.yml.tmpl
RUN chown -R alertmanager:alertmanager /etc/alertmanager/

ENV RESOLVE_TIMEOUT=5m
ENV SMTP_REQUIRE_TLS=true
ENV REPEAT_INTERVAL=24h

EXPOSE 9093

USER alertmanager
WORKDIR /home/alertmanager/

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["/bin/alertmanager", "--config.file=/etc/alertmanager/alertmanager.yml"]

HEALTHCHECK --interval=5m \
     --start-period=5m \
     --start-interval=10s \
     CMD pgrep alertmanager && nc -z localhost 9093 || exit 1
