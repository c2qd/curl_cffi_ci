CURL_IMPERSONATE_VERSION = 2.2.2
CURL_CFFI_VERSION = 0.16.3
PYTHON_BIN ?= python3
PYTHON_VENV = .venv/bin/${PYTHON_BIN}

all: build
check-depends: .check-depends-done
prepare: .prepare-done
build: .build-curl-impersonate-done .build-curl_cffi-done

.check-depends-done:
.for pkg in cmake ninja gmake python-3
	@if ! pkg_info | grep -q ${pkg}; then \
		echo "Please install ${pkg:S/python-/python%/}" && exit 1; \
	fi
.endfor
	touch $@

.prepare-done: .check-depends-done
	@ftp -V -o curl-impersonate-${CURL_IMPERSONATE_VERSION}.tar.gz https://github.com/lexiforest/curl-impersonate/archive/refs/tags/v${CURL_IMPERSONATE_VERSION}.tar.gz
	@tar xzf curl-impersonate-${CURL_IMPERSONATE_VERSION}.tar.gz
	@cd curl-impersonate-${CURL_IMPERSONATE_VERSION} && \
		patch < ../curl-impersonate.patch
	@ftp -V https://github.com/lexiforest/curl_cffi/releases/download/v${CURL_CFFI_VERSION}/curl_cffi-${CURL_CFFI_VERSION}.tar.gz
	@tar xzf curl_cffi-${CURL_CFFI_VERSION}.tar.gz
	@cd curl_cffi-${CURL_CFFI_VERSION} && \
		patch < ../curl_cffi.patch && \
		${PYTHON_BIN} -m venv .venv && \
		${PYTHON_VENV} -m pip install build $$(${PYTHON_VENV} -c "import tomllib; print(' '.join(tomllib.load(open('pyproject.toml', 'rb'))['build-system']['requires']))")
	@touch $@

.build-curl-impersonate-done: prepare
	@cd curl-impersonate-${CURL_IMPERSONATE_VERSION} && \
		export install_dir="$${PWD}/install" && \
		export cmake_args="-G Ninja -DCMAKE_INSTALL_PREFIX=$${install_dir} -DCURL_IMPERSONATE_CXX_RUNTIME_LIBRARY=c++abi\;pthread" && \
		gmake configure BUILD_DIR=build CMAKE_CONFIGURE_ARGS="$${cmake_args}" && \
		gmake build BUILD_DIR=build CMAKE_CONFIGURE_ARGS="$${cmake_args}" && \
        gmake checkbuild BUILD_DIR=build && \
		gmake install-strip BUILD_DIR=build CMAKE_CONFIGURE_ARGS="$${cmake_args}" && \
        export install_lib_dir="$${install_dir}/lib" && \
        export deps_lib_dir="$${PWD}/build/deps/install/lib" && \
        export deps_libs="libz.a libzstd.a libbrotlidec.a libbrotlicommon.a libbrotlienc.a libnghttp2.a libnghttp3.a libngtcp2.a libngtcp2_crypto_boringssl.a libssl.a libcrypto.a" && \
		for lib in $${deps_libs}; do \
			cp "$${deps_lib_dir}/$${lib}" "$${install_lib_dir}"; \
		done && \
		cd "$${install_lib_dir}" && \
		if ! ar t libcurl-impersonate.a | grep -q libcurl-impersonate.full.o; then \
			mv libcurl-impersonate.a libcurl-impersonate.orig.a && \
			cc -r -o libcurl-impersonate.full.o -Wl,--whole-archive libcurl-impersonate.orig.a $${deps_libs} -Wl,--no-whole-archive && \
			ar rcs libcurl-impersonate.a libcurl-impersonate.full.o && \
			rm -f libcurl-impersonate.full.o $${deps_libs} libcurl-impersonate.orig.a; \
		fi
	@touch $@

.build-curl_cffi-done: prepare
	@export IMPERSONATE_BUILD_DIR=$$(realpath curl-impersonate-${CURL_IMPERSONATE_VERSION}/install)/lib && \
		export CFLAGS=-I${IMPERSONATE_BUILD_DIR}/include && \
		cd curl_cffi-${CURL_CFFI_VERSION} && \
		${PYTHON_VENV} -m build -w
	@touch $@

clean:
	rm -rf curl-impersonate-* curl_cffi-* .*-done

.PHONY: all check-depends prepare build clean
