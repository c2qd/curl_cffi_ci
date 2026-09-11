CURL_IMPERSONATE_VERSION =			2.2.2
CURL_CFFI_VERSION =					0.16.3
PYTHON_BIN =						/usr/local/bin/python3
PYTHON_VENV =						.venv/bin/python3

.if !defined(MAKE_JOBS)
MAKE_JOBS !!= sysctl -n hw.ncpuonline
.endif

CURL_IMPERSONATE_DEST =				${.CURDIR}/curl-impersonate-${CURL_IMPERSONATE_VERSION}
CURL_CFFI_DEST =					${.CURDIR}/curl_cffi-${CURL_CFFI_VERSION}

CURL_IMPERSONATE_BUILD_DIR ?=		${CURL_IMPERSONATE_DEST}/build
CURL_IMPERSONATE_INSTALL_DIR ?=		${CURL_IMPERSONATE_DEST}/install

CURL_IMPERSONATE_CONFIGURE_ARGS +=	-DSUBJOBS=${MAKE_JOBS} \
									-G Ninja -DCMAKE_INSTALL_PREFIX=${CURL_IMPERSONATE_INSTALL_DIR} \
									-DCURL_IMPERSONATE_CXX_RUNTIME_LIBRARY=c++abi\;pthread

CURL_IMPERSONATE_DEPS_LIBS =		libz.a libzstd.a libbrotlidec.a libbrotlicommon.a libbrotlienc.a \
									libnghttp2.a libnghttp3.a libngtcp2.a libngtcp2_crypto_boringssl.a \
									libssl.a libcrypto.a

CURL_IMPERSONATE_MAKE_FLAGS +=		BUILD_DIR=${CURL_IMPERSONATE_BUILD_DIR} CMAKE_CONFIGURE_ARGS="${CURL_IMPERSONATE_CONFIGURE_ARGS}"

CURL_CFFI_MAKE_FLAGS +=				IMPERSONATE_BUILD_DIR=${CURL_IMPERSONATE_INSTALL_DIR}/lib CFLAGS=-I${CURL_IMPERSONATE_INSTALL_DIR}/lib/include

all: build
check-depends: .check-depends-done
fetch: .fetch-done
extract: .extract-done
patch: .patch-done
configure: .configure-done
build: .build-curl_cffi-done

.check-depends-done:
.for pkg in cmake ninja gmake python-3
	@if ! pkg_info | grep -q ${pkg}; then \
		echo "Please install ${pkg:S/python-/python%/} package before build" && exit 1; \
	fi
.endfor
	@touch $@

.fetch-done: .check-depends-done
	@ftp -V -o curl-impersonate-${CURL_IMPERSONATE_VERSION}.tar.gz https://github.com/lexiforest/curl-impersonate/archive/refs/tags/v${CURL_IMPERSONATE_VERSION}.tar.gz
	@ftp -V https://github.com/lexiforest/curl_cffi/releases/download/v${CURL_CFFI_VERSION}/curl_cffi-${CURL_CFFI_VERSION}.tar.gz
	@touch $@

.extract-done: .fetch-done
	@tar xzf curl-impersonate-${CURL_IMPERSONATE_VERSION}.tar.gz
	@tar xzf curl_cffi-${CURL_CFFI_VERSION}.tar.gz
	@touch $@

.patch-done: .extract-done
	@cd ${CURL_IMPERSONATE_DEST} && \
		patch < ../curl-impersonate.patch
	@cd ${CURL_CFFI_DEST} && \
		patch < ../curl_cffi.patch
	@touch $@

.configure-done: .patch-done
	@cd ${CURL_IMPERSONATE_DEST} && \
		env ${CURL_IMPERSONATE_MAKE_FLAGS} gmake configure
	@cd ${CURL_CFFI_DEST} && \
		${PYTHON_BIN} -m venv .venv && \
		${PYTHON_VENV} -m pip install --upgrade pip && \
		${PYTHON_VENV} -m pip install build $$(${PYTHON_VENV} -c "import tomllib; print(' '.join(tomllib.load(open('pyproject.toml', 'rb'))['build-system']['requires']))")
	@touch $@

.build-curl-impersonate-done: .configure-done
	@cd curl-impersonate-${CURL_IMPERSONATE_VERSION} && \
		env ${CURL_IMPERSONATE_MAKE_FLAGS} gmake build && \
        env ${CURL_IMPERSONATE_MAKE_FLAGS} gmake checkbuild && \
		env ${CURL_IMPERSONATE_MAKE_FLAGS} gmake install-strip && \
		for lib in ${CURL_IMPERSONATE_DEPS_LIBS}; do \
			cp "${CURL_IMPERSONATE_BUILD_DIR}/deps/install/lib/$${lib}" "${CURL_IMPERSONATE_INSTALL_DIR}/lib"; \
		done && \
		cd "${CURL_IMPERSONATE_INSTALL_DIR}/lib" && \
		if ! ar t libcurl-impersonate.a | grep -q libcurl-impersonate.full.o; then \
			mv libcurl-impersonate.a libcurl-impersonate.orig.a && \
			cc -r -o libcurl-impersonate.full.o -Wl,--whole-archive libcurl-impersonate.orig.a ${CURL_IMPERSONATE_DEPS_LIBS} -Wl,--no-whole-archive && \
			ar rcs libcurl-impersonate.a libcurl-impersonate.full.o && \
			rm -f libcurl-impersonate.full.o ${CURL_IMPERSONATE_DEPS_LIBS} libcurl-impersonate.orig.a; \
		fi
	@touch $@

.build-curl_cffi-done: .build-curl-impersonate-done
	@cd curl_cffi-${CURL_CFFI_VERSION} && \
		env ${CURL_CFFI_MAKE_FLAGS} ${PYTHON_VENV} -m build -w
	@echo "[Info] curl-impersonate: ${CURL_IMPERSONATE_INSTALL_DIR}"
	@echo "[Info] curl_cffi: ${.CURDIR}/curl_cffi-${CURL_CFFI_VERSION}/dist/"
	@touch $@

clean:
	rm -rf curl-impersonate-* curl_cffi-* .*-done

.PHONY: all check-depends fetch extract patch configure build clean
