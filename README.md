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
python3 -m pip install ./example.whl
```

## Credits

[curl-impersonate](https://github.com/lexiforest/curl-impersonate): [MIT License](https://github.com/lexiforest/curl-impersonate/blob/main/LICENSE)  
[curl_cffi](https://github.com/lexiforest/curl_cffi): [MIT License](https://github.com/lexiforest/curl_cffi/blob/main/LICENSE)

## License

Artifacts: original source's license  
Other files are licensed under [The Unlicense](UNLICENSE)
