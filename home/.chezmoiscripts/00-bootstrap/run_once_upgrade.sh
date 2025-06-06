#!/bin/bash

set -eo pipefail

# TODO: Skip if container / VM

sudo bash -c 'apt update && apt upgrade -y && apt autoremove -y && apt clean'
