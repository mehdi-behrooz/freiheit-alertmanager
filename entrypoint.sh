#!/bin/sh

CONFIG=/etc/alertmanager/alertmanager.yml
TEMPLATE=/etc/alertmanager/alertmanager.yml.tmpl

envsubst <$TEMPLATE >$CONFIG

exec "$@"
