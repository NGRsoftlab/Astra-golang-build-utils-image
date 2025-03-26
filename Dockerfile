## Definite image args
ARG image_registry
ARG image_name=astra
ARG image_version=1.7.5

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                         Base image                          #
#             First stage, install base components            #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
FROM ${image_registry}${image_name}:${image_version}

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

## Def initial arg(will be replaced with docker build opt)
ARG version=1.0.0

## Build args
ENV \
    VERSION="${version}" \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=linux \
    TZ=Etc/UTC \
## https://devcenter.heroku.com/articles/tuning-glibc-memory-behavior
    MALLOC_ARENA_MAX=2 \
    TERM=xterm-256color

## Install build deps
# build-essential: meta-package providing gcc, g++, make, libc6-dev; essential for compiling C/C++ code
# curl: tool for transferring data over HTTP/HTTPS (used in scripts, downloads, health checks)
# git: version control system for fetching source code and submodules
# bison: parser generator (needed for some grammars in language tools or build systems)
# gcc, g++: GNU C and C++ compilers (core compilation tools)
# make: build automation tool for managing compile rules
# libc6-dev: GNU C Library headers and development libraries (required to compile most C programs)
# libseccomp-dev: headers for seccomp sandboxing (used by containers, runC, security hardening)
# python3: scripting language used in build scripts, tests, and tooling
# ca-certificates: root certificates for TLS/SSL verification (HTTPS, pip, go get, etc.)
# netbase: provides basic network-related files like /etc/services, required for net package tests
# gdb: GNU Debugger, optionally used in runtime tests for debugging crashes or stack traces
# strace: system call tracer, used in tests to verify syscalls (e.g., in net/http or syscall packages)
# gfortran: GNU Fortran compiler, needed for CGO when linking Fortran code (e.g., scientific libs)
# gfortran-multilib: enables 32-bit Fortran compilation on 64-bit systems
# libc6-dev-i386: 32-bit C library headers (required for building 32-bit binaries on x86_64)
# gcc-multilib: enables compilation of 32-bit code on 64-bit hosts (multi-architecture support)
# procps: provides utilities like ps, top, kill, uptime (used in integration tests and monitoring)
# lsof: "list open files" utility (used in tests to check file descriptor usage)
# psmisc: includes killall, fuser, pstree (misc process management tools for testing)
# libgles2-mesa-dev: OpenGL ES 2.0 development headers (required by Go's x/mobile repository)
# libopenal-dev: OpenAL development libraries (audio support in mobile/desktop apps via x/mobile)
# fonts-droid-fallback: fallback Droid font set (used by Android emulator and x/mobile rendering)
# openssh-server: SSH daemon for remote access (useful for debugging containerized builds)
# iptables: userspace tool for configuring Linux packet filtering (firewall, NAT, used in network tests)
# iproute2: modern replacement for ifconfig/route; includes ip, ss, tc (network troubleshooting)
# sudo: allows privilege escalation (useful for CI runners or multi-user containers)
# tar: archiving utility (ubiquitous in build scripts, extracting sources, packaging artifacts)
RUN --mount=type=bind,source=./scripts,target=/usr/local/sbin,readonly \
    apt-install.sh \
        build-essential \
        curl \
        git \
        bison \
        gcc \
        g++ \
        make \
        libc6-dev \
        libseccomp-dev \
        python3 \
        ca-certificates \
        netbase \
        gdb \
        strace \
        gfortran \
        gfortran-multilib \
        libc6-dev-i386 \
        gcc-multilib \
        procps \
        lsof \
        psmisc \
        libgles2-mesa-dev \
        libopenal-dev \
        fonts-droid-fallback \
        openssh-server \
        iptables \
        iproute2 \
        sudo \
        tar \
## Remove unwanted binaries
    && rm-binary.sh \
        addgroup \
        adduser \
        delgroup \
        deluser \
        passwd \
        su \
        update-passwd \
        useradd \
        userdel \
        usermod \
## Remove cache
    && apt-clean.sh \
## Prune unused files
    && { \
        find /run/ -mindepth 1 -ls -delete || :; \
    } \
    && install -d -m 01777 /run/lock \
## Deduplication cleanup
    && dedup-clean.sh /usr/ \
## Def version container
    && echo "Build Golang container version ${VERSION}" >>/etc/issue \
## Check can be preview /etc/issue
    && { \
        grep -qF 'cat /etc/issue' /etc/bash.bashrc \
        || echo 'cat /etc/issue' >> /etc/bash.bashrc; \
    }

## Set patches directory
WORKDIR /opt/patches

## Copy patches into container field
COPY init/patches/ .

## Copy init builder
COPY --chmod=755 init/go-builder.sh /usr/local/bin/go-builder

WORKDIR /build

CMD [ "bash" ]
