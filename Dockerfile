FROM frolvlad/alpine-glibc:alpine-3.10 as runner

ENV SEMAPHORE_VERSION="2.8.9" \
    SEMAPHORE_VERSION_MAJOR="2-8-stable"

ENV SEMAPHORE_URL="https://github.com/ansible-semaphore/semaphore/releases/download/v${SEMAPHORE_VERSION}/semaphore_${SEMAPHORE_VERSION}_linux_amd64.tar.gz" \
    WRAPPER_URL="https://raw.githubusercontent.com/ansible-semaphore/semaphore/${SEMAPHORE_VERSION_MAJOR}/deployment/docker/common/semaphore-wrapper"

RUN apk add --no-cache git curl ansible mysql-client openssh-client tini sshpass tar

RUN adduser -D -u 1001 -G root semaphore && \
    mkdir -p /tmp/semaphore && \
    mkdir -p /etc/semaphore && \
    chown -R semaphore:0 /tmp/semaphore && \
    chown -R semaphore:0 /etc/semaphore && \
    curl -L ${SEMAPHORE_URL} --output /tmp/semaphore.tar.gz && \
    curl -L ${WRAPPER_URL} --output /usr/local/bin/semaphore-wrapper && \
    chmod +x /usr/local/bin/semaphore-wrapper && \
    tar -zxf /tmp/semaphore.tar.gz -C /usr/local/bin && \
    chmod +x /usr/local/bin/semaphore && \
    rm -rf /tmp/semaphore.tar.gz && \
    chown -R semaphore:0 /usr/local/bin/semaphore-wrapper && \
    chown -R semaphore:0 /usr/local/bin/semaphore && \
    apk del tar

WORKDIR /home/semaphore
USER 1001

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/local/bin/semaphore-wrapper", "/usr/local/bin/semaphore", "--config", "/etc/semaphore/config.json"]
