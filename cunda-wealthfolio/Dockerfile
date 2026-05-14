FROM ghcr.io/wealthfolio/wealthfolio:latest

# Installa le dipendenze necessarie per lo script di entrypoint
RUN apk add --no-cache openssl argon2

# Copia lo script di avvio personalizzato
COPY entrypoint.sh /entrypoint.sh

# Assicurati che sia eseguibile
RUN chmod +x /entrypoint.sh

# Imposta lo script come punto di ingresso
ENTRYPOINT ["/entrypoint.sh"]
