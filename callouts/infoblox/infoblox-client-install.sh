#!/usr/bin/env bash
yum install -y epel-release
yum install -y python-pip
pip install pip --upgrade
pip install requests
pip install wrapt babel rfc3986 --upgrade