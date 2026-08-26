# curl_cffi_ci

## ?

Build curl-impersonate & curl_cffi on OpenBSD (CI)  
ref:  
https://github.com/lexiforest/curl-impersonate/blob/main/.github/workflows/build.yml

## Use

Example: curl_cffi with yt-dlp

```sh
doas pkg_add python%3
python3 -m venv .venv
. .venv/bin/activate
python3 -m pip install cffi certifi yt-dlp
python3 -m pip install ./curl_cffi-X.XX.X-cpXXX-abiX-openbsd_X_X_ARCH.whl
```

### Tips

For example, suppose you download `curl_cffi-0.16.2-cp310-abi3-openbsd_7_9_amd64.whl`, but you are running -current and OpenBSD is recognized as version 8.0.  
You may get:

```
ERROR: curl_cffi-0.16.2-cp310-abi3-openbsd_7_9_amd64.whl is not a supported wheel on this platform.
```

In that case, try changing 7_9 to 8_0 (`mv curl_cffi-0.16.2-cp310-abi3-openbsd_7_9_amd64.whl curl_cffi-0.16.2-cp310-abi3-openbsd_8_0_amd64.whl`).  
It will usually work. Usually.

## Credits

[curl-impersonate](https://github.com/lexiforest/curl-impersonate): [MIT License](https://github.com/lexiforest/curl-impersonate/blob/main/LICENSE)  
[curl_cffi](https://github.com/lexiforest/curl_cffi): [MIT License](https://github.com/lexiforest/curl_cffi/blob/main/LICENSE)

## License

Artifacts: original source's license  
Other files are licensed under [The Unlicense](UNLICENSE)
