FROM debian:trixie-slim

ARG USER_UID=1000
ARG USER_GID=1000
ARG USERNAME=development

ENV HOME="/home/$USERNAME"

ARG MISE_VERSION=v2026.9.3
# 1.98 以降は cargo-lambda 1.9.1 同梱の cargo-zigbuild 0.20.1 と組み合わせると
# aarch64 リンクで --fix-cortex-a53-843419 が拒否されるため 1.97 系に固定
ARG RUST_VERSION=1.97.1
ARG CARGO_LAMBDA_VERSION=1.9.1
ARG ZIG_VERSION=0.16.0
ARG NODE_VERSION=24.21.0
ARG NPM_VERSION=12.0.2
ARG PNPM_VERSION=12.6.0
ARG AWS_CDK_VERSION=2.1143.0

RUN apt-get update && apt-get install -y \
    curl \
    gcc \
    git \
    locales \
    make \
    perl \
    sudo \
    uuid-dev \
    wget \
    xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

RUN groupadd --gid "$USER_GID" "$USERNAME" && \
    useradd --uid "$USER_UID" --gid "$USER_GID" -m "$USERNAME" && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}"

USER "$USERNAME"
WORKDIR "$HOME"

RUN curl -fsSL https://mise.run | MISE_VERSION="$MISE_VERSION" sh && \
    printf '# For mise (https://mise.jdx.dev/)\neval "$(~/.local/bin/mise activate bash)"\n' >> ~/.bash_aliases

RUN ~/.local/bin/mise use -g "node@$NODE_VERSION" && \
    ~/.local/bin/mise use -g "npm@$NPM_VERSION" && \
    ~/.local/bin/mise use -g "pnpm@$PNPM_VERSION" && \
    ~/.local/bin/mise use -g "npm:aws-cdk@$AWS_CDK_VERSION" && \
    ~/.local/bin/mise use -g "zig@$ZIG_VERSION"

ENV PATH="$HOME/.local/share/mise/shims:$PATH"

ENV CARGO_HOME="$HOME/.cargo" \
    RUSTUP_HOME="$HOME/.rustup" \
    RUSTUP_TOOLCHAIN="$RUST_VERSION" \
    PKG_CONFIG_ALLOW_CROSS=1 \
    PATH="$HOME/.cargo/bin:$PATH"

RUN curl -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain "$RUST_VERSION" --profile minimal && \
    rustup target add aarch64-unknown-linux-musl && \
    rustup component add rustfmt clippy

RUN cargo install --locked cargo-lambda --version "$CARGO_LAMBDA_VERSION"

RUN mkdir -p /tmp/rust && \
    cd /tmp/rust && \
    cargo init && \
    cargo lambda build --release --target aarch64-unknown-linux-musl --output-format zip && \
    cd /tmp && \
    rm -rf /tmp/rust
