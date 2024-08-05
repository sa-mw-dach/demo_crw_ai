#!/bin/sh
tempfile=$(mktemp)
sed -e "s/^shiny.*//g" /etc/passwd > $tempfile
cp $tempfile /etc/passwd
echo "shiny:x:$(id -u):$(id -g)::/tmp:/bin/bash" >> /etc/passwd
rm -f $tempfile
