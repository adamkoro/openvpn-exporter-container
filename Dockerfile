FROM harbor.adamkoro.com/bci/bci-base:15.4
WORKDIR /build
RUN zypper ref && zypper -n in wget
RUN wget https://github.com/patrickjahns/openvpn_exporter/releases/download/v1.1.2/openvpn_exporter-linux-amd64 && wget https://github.com/patrickjahns/openvpn_exporter/releases/download/v1.1.2/openvpn_exporter-linux-amd64.sha256
RUN sha256sum -c openvpn_exporter-linux-amd64.sha256

FROM harbor.adamkoro.com/bci/bci-micro:15.4
WORKDIR /home/user
COPY --from=0 /build/openvpn_exporter-linux-amd64 /home/user/openvpn_exporter
ENV STATUS_FILE="/var/log/openvpn.status" \
    LISTEN_ADDRESS="9176" \
    METRICS_PATH="/metrics" \
    DISABLE_CLIENT_METRICS="false" \
    enable_golang_metrics="false" \
    LOG_LEVEL="info"
RUN echo "user:x:10000:10000:user:/home/user:/bin/bash" >> /etc/passwd && chown -R user /home/user/ && chmod +x openvpn_exporter
USER user
EXPOSE ${LISTEN_ADDRESS}
ENTRYPOINT ["/home/user/openvpn_exporter", "--status-file", "${STATUS_FILE}", "--web.address", "${LISTEN_ADDRESS}", "--web.path", "${METRICS_PATH}", "--disable-client-metrics", "${DISABLE_CLIENT_METRICS}", "--enable-golang-metrics", "${enable_golang_metrics}", "--log.level", "${LOG_LEVEL}"]