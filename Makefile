CURL_IMPERSONATE_VERSION =			2.2.2
CURL_CFFI_VERSION =					0.16.3

DISABLE_CURL_CFFI ?=				No

.if !defined(JOBS)
JOBS !!= sysctl -n hw.ncpuonline
.endif

WRKDIR ?=							${.CURDIR}/work

.if ${DISABLE_CURL_CFFI:L} == "no"
PYTHON ?=							/usr/local/bin/python3
PYTHON_VENV =						.venv/bin/python3
.endif
GMAKE ?=							/usr/local/bin/gmake

CC ?=								/usr/bin/cc
AR ?=								/usr/bin/ar

_FETCH_CMD =						/usr/bin/ftp
_PATCH_CMD =						/usr/bin/patch
_MAKE_COOKIE =						/usr/bin/touch
_SETENV =							/usr/bin/env
_ECHO_MSG =							/bin/echo
_MKDIR =							/bin/mkdir
_TAR =								/bin/tar

_INIT_COOKIE =						${WRKDIR}/.init_done
_CHECK_DEPENDS_COOKIE =				${WRKDIR}/.check-depends_done
_FETCH_COOKIE =						${WRKDIR}/.fetch_done
_EXTRACT_COOKIE =					${WRKDIR}/.extract_done
_PATCH_COOKIE =						${WRKDIR}/.patch_done
_CONFIGURE_COOKIE =					${WRKDIR}/.configure_done
_BUILD_COOKIE =						${WRKDIR}/.build_done

_CURL_IMPERSONATE_DEST =			${WRKDIR}/curl-impersonate-${CURL_IMPERSONATE_VERSION}

CURL_IMPERSONATE_BUILD_DIR =		${_CURL_IMPERSONATE_DEST}/build
CURL_IMPERSONATE_INSTALL_DIR =		${_CURL_IMPERSONATE_DEST}/install

CURL_IMPERSONATE_CXX_LIBS ?=		c++abi\;pthread

CURL_IMPERSONATE_CONFIGURE_ARGS +=	-G Ninja \
									-DCMAKE_INSTALL_PREFIX=${CURL_IMPERSONATE_INSTALL_DIR} \
									-DCURL_IMPERSONATE_CXX_RUNTIME_LIBRARY=${CURL_IMPERSONATE_CXX_LIBS}

CURL_IMPERSONATE_MAKE_ENV +=		JOBS=${JOBS} \
									BUILD_DIR=${CURL_IMPERSONATE_BUILD_DIR} \
									CMAKE_CONFIGURE_ARGS="${CURL_IMPERSONATE_CONFIGURE_ARGS}"

_CURL_IMPERSONATE_DEPS_LIBS =		libz.a libzstd.a libbrotlidec.a libbrotlicommon.a libbrotlienc.a \
									libnghttp2.a libnghttp3.a libngtcp2.a libngtcp2_crypto_boringssl.a \
									libssl.a libcrypto.a

.if ${DISABLE_CURL_CFFI:L} == "no"
_CURL_CFFI_DEST =					${WRKDIR}/curl_cffi-${CURL_CFFI_VERSION}

CURL_CFFI_MAKE_ENV +=				IMPERSONATE_BUILD_DIR=${CURL_IMPERSONATE_INSTALL_DIR}/lib \
									CFLAGS=-I${CURL_IMPERSONATE_INSTALL_DIR}/lib/include
.endif

all: build
init: ${_INIT_COOKIE}
fetch: ${_FETCH_COOKIE}
extract: ${_EXTRACT_COOKIE}
patch: ${_PATCH_COOKIE}
configure: ${_CONFIGURE_COOKIE}
build: ${_BUILD_COOKIE}
clean:
	rm -rf ${WRKDIR}

.PHONY: all init fetch extract patch configure build clean

${_INIT_COOKIE}:
	@${_MKDIR} ${WRKDIR}
	@${_MAKE_COOKIE} $@

${_FETCH_COOKIE}: ${_INIT_COOKIE}
	@${_FETCH_CMD} -V -o ${WRKDIR}/curl-impersonate-${CURL_IMPERSONATE_VERSION}.tar.gz https://github.com/lexiforest/curl-impersonate/archive/refs/tags/v${CURL_IMPERSONATE_VERSION}.tar.gz
.if ${DISABLE_CURL_CFFI:L} == "no"
	@${_FETCH_CMD} -V -o ${WRKDIR}/curl_cffi-${CURL_CFFI_VERSION}.tar.gz https://github.com/lexiforest/curl_cffi/releases/download/v${CURL_CFFI_VERSION}/curl_cffi-${CURL_CFFI_VERSION}.tar.gz
.endif
	@${_MAKE_COOKIE} $@

${_EXTRACT_COOKIE}: ${_FETCH_COOKIE}
	@${_TAR} xzf ${WRKDIR}/curl-impersonate-${CURL_IMPERSONATE_VERSION}.tar.gz -C ${WRKDIR}
.if ${DISABLE_CURL_CFFI:L} == "no"
	@${_TAR} xzf ${WRKDIR}/curl_cffi-${CURL_CFFI_VERSION}.tar.gz -C ${WRKDIR}
.endif
	@${_MAKE_COOKIE} $@

${_PATCH_COOKIE}: ${_EXTRACT_COOKIE}
	@cd ${_CURL_IMPERSONATE_DEST} && \
		${_PATCH_CMD} < ${.CURDIR}/curl-impersonate.patch
.if ${DISABLE_CURL_CFFI:L} == "no"
	@cd ${_CURL_CFFI_DEST} && \
		${_PATCH_CMD} < ${.CURDIR}/curl_cffi.patch
.endif
	@${_MAKE_COOKIE} $@

${_CONFIGURE_COOKIE}: ${_PATCH_COOKIE}
	@cd ${_CURL_IMPERSONATE_DEST} && \
		${_SETENV} ${CURL_IMPERSONATE_MAKE_ENV} \
		${GMAKE} configure
.if ${DISABLE_CURL_CFFI:L} == "no"
	@cd ${_CURL_CFFI_DEST} && \
		${PYTHON} -m venv .venv && \
		${PYTHON_VENV} -m pip install --upgrade pip && \
		${PYTHON_VENV} -m pip install build
.endif
	@${_MAKE_COOKIE} $@

${_BUILD_COOKIE}: ${_CONFIGURE_COOKIE}
	@cd ${_CURL_IMPERSONATE_DEST} && \
		${_SETENV} ${CURL_IMPERSONATE_MAKE_ENV} \
		${GMAKE} build && \
        ${_SETENV} ${CURL_IMPERSONATE_MAKE_ENV} \
		${GMAKE} checkbuild && \
		${_SETENV} ${CURL_IMPERSONATE_MAKE_ENV} \
		${GMAKE} install-strip && \
		for lib in ${_CURL_IMPERSONATE_DEPS_LIBS}; do \
			cp "${CURL_IMPERSONATE_BUILD_DIR}/deps/install/lib/$${lib}" "${CURL_IMPERSONATE_INSTALL_DIR}/lib"; \
		done && \
		cd "${CURL_IMPERSONATE_INSTALL_DIR}/lib" && \
		if ! ${AR} t libcurl-impersonate.a | grep -q libcurl-impersonate.full.o; then \
			mv libcurl-impersonate.a libcurl-impersonate.orig.a && \
			${CC} -r -o libcurl-impersonate.full.o -Wl,--whole-archive libcurl-impersonate.orig.a ${_CURL_IMPERSONATE_DEPS_LIBS} -Wl,--no-whole-archive && \
			${AR} rcs libcurl-impersonate.a libcurl-impersonate.full.o && \
			rm -f libcurl-impersonate.full.o ${_CURL_IMPERSONATE_DEPS_LIBS} libcurl-impersonate.orig.a; \
		fi
.if ${DISABLE_CURL_CFFI:L} == "no"
	@cd ${_CURL_CFFI_DEST} && \
		${_SETENV} ${CURL_CFFI_MAKE_ENV} ${PYTHON_VENV} -m build -w
.endif
	@${_ECHO_MSG} "[Info] curl-impersonate: ${CURL_IMPERSONATE_INSTALL_DIR}/"
.if ${DISABLE_CURL_CFFI:L} == "no"
	@${_ECHO_MSG} "[Info] curl_cffi: ${_CURL_CFFI_DEST}/dist/*.whl"
.endif
	@${_MAKE_COOKIE} $@
