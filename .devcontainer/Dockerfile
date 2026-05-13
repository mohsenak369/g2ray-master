FROM debian:bookworm-slim

ENV XRAY_USER=xray
ENV XRAY_INSTALL_DIR=/usr/local/bin
ENV XRAY_CONFIG_DIR=/etc/xray
WORKDIR /app

# 1) نصب پکیج‌های لازم
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        unzip \
        jq \
        ca-certificates \
        openssl && \
    rm -rf /var/lib/apt/lists/*

# 2) ساختن یوزر غیر-root
RUN useradd -r -s /usr/sbin/nologin ${XRAY_USER}

# 3) دانلود آخرین نسخه stable Xray + verification
RUN set -eux; \
    RELEASES_JSON="$(curl -fsSL https://api.github.com/repos/XTLS/Xray-core/releases)"; \
    XRAY_VERSION="$(echo "$RELEASES_JSON" | jq -r '[.[] | select(.prerelease == false and .draft == false)][0].tag_name')"; \
    echo "Installing Xray ${XRAY_VERSION}"; \
    ARCHIVE_NAME="Xray-linux-64.zip"; \
    BASE_URL="https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}"; \
    curl -fsSL -o /tmp/xray.zip "${BASE_URL}/${ARCHIVE_NAME}"; \
    curl -fsSL -o /tmp/sha256sums "${BASE_URL}/${ARCHIVE_NAME}.sha256sum"; \
    cd /tmp; \
    sha256sum -c /tmp/sha256sums; \
    unzip /tmp/xray.zip -d /tmp/xray; \
    install -m 0755 /tmp/xray/xray ${XRAY_INSTALL_DIR}/xray; \
    rm -rf /tmp/xray /tmp/xray.zip /tmp/sha256sums

# 4) دایرکتوری کانفیگ
RUN mkdir -p ${XRAY_CONFIG_DIR}

# 5) کپی template کانفیگ و startup
COPY config.template.json ${XRAY_CONFIG_DIR}/config.template.json
COPY startup.sh /app/startup.sh

# 6) پرمیشن‌ها
RUN chmod 0755 /app/startup.sh && \
    chown -R ${XRAY_USER}:${XRAY_USER} /app ${XRAY_CONFIG_DIR}

USER ${XRAY_USER}

# 7) healthcheck ساده
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD pgrep xray || exit 1

EXPOSE 443

CMD ["/app/startup.sh"]
