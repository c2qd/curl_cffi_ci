CURL_IMPERSONATE_VERSION =			2.2.2
CURL_CFFI_VERSION =					0.16.3
PYTHON_BIN =						/usr/local/bin/python3
PYTHON_VENV =						.venv/bin/python3

.if !defined(JOBS)
JOBS !!= sysctl -n hw.ncpuonline
.endif

WRKDIR ?=							${.CURDIR}/work

CURL_IMPERSONATE_DEST =				${WRKDIR}/curl-impersonate-${CURL_IMPERSONATE_VERSION}
CURL_CFFI_DEST =					${WRKDIR}/curl_cffi-${CURL_CFFI_VERSION}

CURL_IMPERSONATE_BUILD_DIR =		${CURL_IMPERSONATE_DEST}/build
CURL_IMPERSONATE_INSTALL_DIR =		${CURL_IMPERSONATE_DEST}/install

CURL_IMPERSONATE_CONFIGURE_ARGS +=	-G Ninja \
									-DCMAKE_INSTALL_PREFIX=${CURL_IMPERSONATE_INSTALL_DIR} \
									-DCURL_IMPERSONATE_CXX_RUNTIME_LIBRARY=c++abi\;pthread

CURL_IMPERSONATE_MAKE_ENV +=		JOBS=${JOBS} \
									BUILD_DIR=${CURL_IMPERSONATE_BUILD_DIR} \
									CMAKE_CONFIGURE_ARGS="${CURL_IMPERSONATE_CONFIGURE_ARGS}"

CURL_CFFI_MAKE_ENV +=				IMPERSONATE_BUILD_DIR=${CURL_IMPERSONATE_INSTALL_DIR}/lib \
									CFLAGS=-I${CURL_IMPERSONATE_INSTALL_DIR}/lib/include

_CURL_IMPERSONATE_DEPS_LIBS =		libz.a libzstd.a libbrotlidec.a libbrotlicommon.a libbrotlienc.a \
									libnghttp2.a libnghttp3.a libngtcp2.a libngtcp2_crypto_boringssl.a \
									libssl.a libcrypto.a

_INIT_COOKIE = ${WRKDIR}/.init_done
_CHECK_DEPENDS_COOKIE = ${WRKDIR}/.check-depends_done
_FETCH_COOKIE = ${WRKDIR}/.fetch_done
_EXTRACT_COOKIE = ${WRKDIR}/.extract_done
_PATCH_COOKIE = ${WRKDIR}/.patch_done
_CONFIGURE_COOKIE = ${WRKDIR}/.configure_done
_BUILD_COOKIE = ${WRKDIR}/.build_done

all: build
init: ${_INIT_COOKIE}
check-depends: ${_CHECK_DEPENDS_COOKIE}
fetch: ${_FETCH_COOKIE}
extract: ${_EXTRACT_COOKIE}
patch: ${_PATCH_COOKIE}
configure: ${_CONFIGURE_COOKIE}
build: ${_BUILD_COOKIE}
clean:
	rm -rf ${WRKDIR}

.PHONY: all init check-depends fetch extract patch configure build clean

${_INIT_COOKIE}:
	@mkdir ${WRKDIR}
	@touch $@

${_CHECK_DEPENDS_COOKIE}: ${_INIT_COOKIE}
.for pkg in cmake ninja gmake python-3
	@if ! pkg_info | grep -q ${pkg}; then \
		echo "Please install ${pkg:S/python-/python%/} package before build" && exit 1; \
	fi
.endfor
	@touch $@

${_FETCH_COOKIE}: ${_CHECK_DEPENDS_COOKIE}
	@ftp -V -o ${WRKDIR}/curl-impersonate-${CURL_IMPERSONATE_VERSION}.tar.gz https://github.com/lexiforest/curl-impersonate/archive/refs/tags/v${CURL_IMPERSONATE_VERSION}.tar.gz
	@ftp -V -o ${WRKDIR}/curl_cffi-${CURL_CFFI_VERSION}.tar.gz https://github.com/lexiforest/curl_cffi/releases/download/v${CURL_CFFI_VERSION}/curl_cffi-${CURL_CFFI_VERSION}.tar.gz
	@touch $@

${_EXTRACT_COOKIE}: ${_FETCH_COOKIE}
	@tar xzf ${WRKDIR}/curl-impersonate-${CURL_IMPERSONATE_VERSION}.tar.gz -C ${WRKDIR}
	@tar xzf ${WRKDIR}/curl_cffi-${CURL_CFFI_VERSION}.tar.gz -C ${WRKDIR}
	@touch $@

${_PATCH_COOKIE}: ${_EXTRACT_COOKIE}
	@cd ${CURL_IMPERSONATE_DEST} && \
		patch < ${.CURDIR}/curl-impersonate.patch
	@cd ${CURL_CFFI_DEST} && \
		patch < ${.CURDIR}/curl_cffi.patch
	@touch $@

${_CONFIGURE_COOKIE}: ${_PATCH_COOKIE}
	@cd ${CURL_IMPERSONATE_DEST} && \
		env ${CURL_IMPERSONATE_MAKE_ENV} gmake configure
	@cd ${CURL_CFFI_DEST} && \
		${PYTHON_BIN} -m venv .venv && \
		${PYTHON_VENV} -m pip install --upgrade pip && \
		${PYTHON_VENV} -m pip install build
	@touch $@

${_BUILD_COOKIE}: ${_CONFIGURE_COOKIE}
	@cd ${CURL_IMPERSONATE_DEST} && \
		env ${CURL_IMPERSONATE_MAKE_ENV} gmake build && \
        env ${CURL_IMPERSONATE_MAKE_ENV} gmake checkbuild && \
		env ${CURL_IMPERSONATE_MAKE_ENV} gmake install-strip && \
		for lib in ${_CURL_IMPERSONATE_DEPS_LIBS}; do \
			cp "${CURL_IMPERSONATE_BUILD_DIR}/deps/install/lib/$${lib}" "${CURL_IMPERSONATE_INSTALL_DIR}/lib"; \
		done && \
		cd "${CURL_IMPERSONATE_INSTALL_DIR}/lib" && \
		if ! ar t libcurl-impersonate.a | grep -q libcurl-impersonate.full.o; then \
			mv libcurl-impersonate.a libcurl-impersonate.orig.a && \
			cc -r -o libcurl-impersonate.full.o -Wl,--whole-archive libcurl-impersonate.orig.a ${_CURL_IMPERSONATE_DEPS_LIBS} -Wl,--no-whole-archive && \
			ar rcs libcurl-impersonate.a libcurl-impersonate.full.o && \
			rm -f libcurl-impersonate.full.o ${_CURL_IMPERSONATE_DEPS_LIBS} libcurl-impersonate.orig.a; \
		fi
	@cd ${CURL_CFFI_DEST} && \
		env ${CURL_CFFI_MAKE_ENV} ${PYTHON_VENV} -m build -w
	@echo "[Info] curl-impersonate: ${CURL_IMPERSONATE_INSTALL_DIR}"
	@echo "[Info] curl_cffi: ${CURL_CFFI_DEST}/dist/"
	@touch $@
