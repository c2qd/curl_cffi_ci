# curl_cffi_ci

## ?

Build curl-impersonate & curl_cffi on OpenBSD (CI)  
ref:  
https://github.com/lexiforest/curl-impersonate/blob/main/.github/workflows/build.yml

## Notes

x86_64 should work, and aarch64 probably works as well. I don't know whether riscv64 works.  
I haven't verified whether it works on -current, as the CI uses release versions of OpenBSD.  
I put together a rough Makefile, so you should probably be able to build it simply by running make from the shell.  
It's pretty rough, though, so I'm not sure if it actually works.  
Related project: [openbsd_ports/www at main - c2qd/openbsd_ports - Codeberg.org](https://codeberg.org/c2qd/openbsd_ports/src/branch/main/www)

## Use

### Pre-built binary

(lib)curl-impersonate: extract  
dep: `bash` (Required by the wrapper scripts)  
curl_cffi: install into a venv  
dep: `python%3`

### Building from source

```sh
doas pkg_add cmake ninja gmake python%3
make
```

Disable curl_cffi build: `env DISABLE_CURL_CFFI=Yes make`

## Credits

[curl-impersonate](https://github.com/lexiforest/curl-impersonate): [MIT License](https://github.com/lexiforest/curl-impersonate/blob/main/LICENSE)  
[curl_cffi](https://github.com/lexiforest/curl_cffi): [MIT License](https://github.com/lexiforest/curl_cffi/blob/main/LICENSE)

## License

Artifacts: original source's license  
Other files are licensed under [The Unlicense](UNLICENSE)
