FROM harbor.adamkoro.com/bci/bci-base:15.4
WORKDIR /build
RUN zypper ref && zypper -n in wget
RUN wget https://github.com/patrickjahns/openvpn_exporter/releases/download/v1.1.2/openvpn_exporter-linux-amd64 && wget https://github.com/patrickjahns/openvpn_exporter/releases/download/v1.1.2/openvpn_exporter-linux-amd64.sha256
RUN sha256sum -c openvpn_exporter-linux-amd64.sha256

FROM harbor.adamkoro.com/bci/bci-micro:15.4
WORKDIR /home/user
COPY --from=0 /build/openvpn_exporter-linux-amd64 /home/user/openvpn_exporter
RUN mkdir -p /var/log/openvpn && touch /var/log/openvpn/openvpn.status && chown -R user /var/log/openvpn
ENV OPENVPN_EXPORTER_STATUS_FILE="/var/log/openvpn/openvpn.status" \
    OPENVPN_EXPORTER_WEB_ADDRESS=":9176" \
    OPENVPN_EXPORTER_WEB_PATH="/metrics" \
    OPENVPN_EXPORTER_DISABLE_CLIENT_METRICS="false" \
    OPENVPN_EXPORTER_ENABLE_GOLANG_METRICS="false" \
    OPENVPN_EXPORTER_LOG_LEVEL="info"
RUN echo "user:x:10000:10000:user:/home/user:/bin/bash" >> /etc/passwd && chown -R user /home/user/ && chmod +x openvpn_exporter
USER user
EXPOSE 9176
ENTRYPOINT ["/home/user/openvpn_exporter"]