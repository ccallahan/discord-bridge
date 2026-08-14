FROM dock.mau.dev/mautrix/discord:latest

USER root

# Copy entrypoint script into image
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
