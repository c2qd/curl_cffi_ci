#!/bin/sh

# 2.2.2
COMMIT=0b65567f14ee37a1a7b644b13cf9c860e1ddf075
CURL=8_22_0

git remote add curl-src https://github.com/curl/curl.git
git fetch curl-src tag curl-${CURL}
git clone --branch v2.2.2 --depth 1 https://github.com/lexiforest/curl-impersonate.git
git diff curl-${CURL} 
