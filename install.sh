#!/bin/bash

echo 'here we go!'
chmod +x bin/*
cp bin/* /usr/bin/ || {
  echo you gotta run this as root bro
  exit 1
}
