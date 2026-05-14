#!/bin/sh

# Percorso del file dove salveremo le chiavi in modo persistente
CONFIG_FILE=/app/data/umbrel_secrets.env

# Se il file non esiste, è il primo avvio e dobbiamo generare le chiavi
if [ ! -f "$CONFIG_FILE" ]; then
    echo "🚀 Primo avvio di Wealthfolio rilevato. Generazione delle chiavi segrete..."

    # 1. Genera WF_SECRET_KEY (32 byte in base64)
    WF_SECRET_KEY=$(openssl rand -base64 32)

    # 2. Genera una password casuale per l'utente (16 caratteri)
    GENERATED_PASSWORD=$(openssl rand -base64 12)

    # 3. Genera l'hash Argon2id per la password
    SALT=$(openssl rand -base64 8)
    # Il comando argon2 in Alpine richiede il sale come argomento posizionale
    WF_AUTH_PASSWORD_HASH=$(echo -n "$GENERATED_PASSWORD" | argon2 "$SALT" -id -t 3 -m 65536 -p 4 -l 32 -e)

    # Salva tutto nel file persistente
    echo "WF_SECRET_KEY=$WF_SECRET_KEY" > "$CONFIG_FILE"
    echo "WF_AUTH_PASSWORD_HASH=$WF_AUTH_PASSWORD_HASH" >> "$CONFIG_FILE"
    echo "GENERATED_PASSWORD=$GENERATED_PASSWORD" >> "$CONFIG_FILE"

    # Stampa un messaggio ben visibile nei log di Umbrel
    echo "========================================================"
    echo "✅ SETUP COMPLETATO!"
    echo "🔑 La tua password temporanea per il primo login è:"
    echo ""
    echo "   $GENERATED_PASSWORD"
    echo ""
    echo "⚠️  Per favore, fai il login e cambiala subito dalle impostazioni."
    echo "    Puoi recuperare questa password cliccando su 'Logs' nell'app Umbrel."
    echo "========================================================"
else
    echo "✅ Chiavi segrete esistenti trovate. Avvio normale."
fi

# Carica le variabili dal file (sia se appena creato, sia se esisteva già)
source "$CONFIG_FILE"

# Esporta le variabili d'ambiente affinché il processo principale di Wealthfolio possa leggerle
export WF_SECRET_KEY
export WF_AUTH_PASSWORD_HASH
export WF_PORT=8088
export WF_HOST=0.0.0.0
export WF_DATABASE_URL=file:/app/data/wealthfolio.db

# Avvia l'applicazione originale di Wealthfolio
# Nota: il binario dell'app ufficiale si trova in /app/wealthfolio
exec /app/wealthfolio
