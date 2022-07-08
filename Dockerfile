FROM rust:slim-bullseye AS builder

# Build time options to avoid dpkg warnings and help with reproducible builds.
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    TZ=UTC \
    TERM=xterm-256color \
    CARGO_HOME="/root/.cargo" \
    USER="root"

# Create CARGO_HOME folder and don't download rust docs
RUN mkdir -pv "${CARGO_HOME}" \
    && rustup set profile minimal

RUN apt-get update \
    && apt-get install -y \
        --no-install-recommends \
        build-essential \
        pkg-config \
        openssl \
        libssl-dev \
        cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

COPY . .
RUN cargo build --release

FROM debian:bullseye-slim AS runner

WORKDIR /app

COPY --from=builder /src/target/release/service-template /usr/local/bin/service-template

CMD ["service-template"]
