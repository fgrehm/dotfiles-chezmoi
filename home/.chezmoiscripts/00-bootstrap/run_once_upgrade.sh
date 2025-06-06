#!/bin/bash

set -eo pipefail

sudo bash -c 'apt update && aptt upgrade -y && apt autoremove -y && apt clean'
