# curl_cffi_ci

## ?

Build curl-impersonate & curl_cffi on OpenBSD (CI)  
ref:  
https://github.com/lexiforest/curl-impersonate/blob/main/.github/workflows/build.yml  
https://github.com/libressl/portable/blob/master/.github/workflows/rust-openssl.yml

## Notes

x86_64 should work, and aarch64 probably works as well. I don't know whether riscv64 works.  
I haven't verified whether it works on -current, as the CI uses release versions of OpenBSD.  
I put together a rough Makefile, so you should probably be able to build it simply by running make from the shell.  
It's pretty rough, though, so I'm not sure if it actually works.  
Related project: [openbsd_ports/www at main - c2qd/openbsd_ports - Codeberg.org](https://codeberg.org/c2qd/openbsd_ports/src/branch/main/www)

## Use

Example: curl_cffi with yt-dlp

```sh
doas pkg_add python%3
python3 -m venv .venv
. .venv/bin/activate
python3 -m pip install yt-dlp
python3 -m pip install ./file.whl
```

## Credits

[curl-impersonate](https://github.com/lexiforest/curl-impersonate): [MIT License](https://github.com/lexiforest/curl-impersonate/blob/main/LICENSE)  
[curl_cffi](https://github.com/lexiforest/curl_cffi): [MIT License](https://github.com/lexiforest/curl_cffi/blob/main/LICENSE)

## License

Artifacts: original source's license  
Other files are licensed under [The Unlicense](UNLICENSE)
