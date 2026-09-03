# curl_cffi_ci

## ?

Build curl-impersonate & curl_cffi on OpenBSD (CI)  
ref:  
https://github.com/lexiforest/curl-impersonate/blob/main/.github/workflows/build.yml

## Notes

I occasionally run the amd64 build through yt-dlp, and I have also run the arm64 build on real hardware once.  
However, I have absolutely no idea whether riscv64actually work.  
That's why I tried adding pytest unit tests, although the way I've set it up is admittedly quite ad hoc.

## Use

Example: curl_cffi with yt-dlp

```sh
doas pkg_add python%3
python3 -m venv .venv
. .venv/bin/activate
python3 -m pip install cffi certifi yt-dlp
python3 -m pip install ./example.whl
```

## Related

[openbsd_ports/www at main - c2qd/openbsd_ports - Codeberg.org](https://codeberg.org/c2qd/openbsd_ports/src/branch/main/www)

## Credits

[curl-impersonate](https://github.com/lexiforest/curl-impersonate): [MIT License](https://github.com/lexiforest/curl-impersonate/blob/main/LICENSE)  
[curl_cffi](https://github.com/lexiforest/curl_cffi): [MIT License](https://github.com/lexiforest/curl_cffi/blob/main/LICENSE)

## License

Artifacts: original source's license  
Other files are licensed under [The Unlicense](UNLICENSE)
