.ifmake !clean
.poison empty(CURL_IMPERSONATE_DIR)
.poison empty(CURL_CFFI_VERSION)
.endif

PYTHON_BIN ?= python3
PYTHON_VENV = .venv/bin/${PYTHON_BIN}

CFLAGS += -I${CURL_IMPERSONATE_DIR}/include

all: build

prepare: .prepare-done

build: .build-done

.prepare-done:
	ftp -V https://github.com/lexiforest/curl_cffi/releases/download/v${CURL_CFFI_VERSION}/curl_cffi-${CURL_CFFI_VERSION}.tar.gz
	tar xzf curl_cffi-${CURL_CFFI_VERSION}.tar.gz
	cd curl_cffi-${CURL_CFFI_VERSION} && \
		patch < ../curl_cffi.patch && \
		${PYTHON_BIN} -m venv .venv && \
		${PYTHON_VENV} -m pip install build $$(${PYTHON_VENV} -c "import tomllib; print(' '.join(tomllib.load(open('pyproject.toml', 'rb'))['build-system']['requires']))")
	touch $@
.build-done: prepare
	export IMPERSONATE_BUILD_DIR=$$(realpath ${CURL_IMPERSONATE_DIR}) && \
		cd curl_cffi-${CURL_CFFI_VERSION} && \
		${PYTHON_VENV} -m build -w
	touch $@

clean:
	rm -rf curl_cffi-${CURL_CFFI_VERSION}* .*-done

.PHONY: all prepare build clean
