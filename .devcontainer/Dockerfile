FROM ruby:4.0.9-slim
ENV LANG=C.UTF-8
ENV BINDING="0.0.0.0"

# Install Node.js for ExecJS
RUN apt-get update -qq && \
    apt-get install -y curl gnupg && \
    curl -sL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    nodejs ca-certificates unzip build-essential vim libvips42 fontconfig sqlite3 libsqlite3-dev libyaml-dev git fonts-liberation fonts-noto-cjk openssh-client pkg-config less

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
 && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash \
 && apt-get update -qq && apt-get install -y sudo \
 && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
 && chmod 0440 /etc/sudoers.d/$USERNAME

CMD ["/bin/bash"]
