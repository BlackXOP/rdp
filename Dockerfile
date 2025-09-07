FROM ubuntu:22.04

# Set non-interactive for apt
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

COPY install.sh /install.sh
RUN chmod +x /install.sh

CMD ["/install.sh"]
