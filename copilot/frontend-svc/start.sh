#!/bin/bash
crond &
nginx -g "daemon off;";
rc-service crond start && rc-update add crond
crond -f

