#!/bin/sh

if [ $1 == "remove" ]; then
  stop logstash > /dev/null 2>&1 || true
fi
