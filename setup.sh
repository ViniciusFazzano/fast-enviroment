#!/bin/bash

# Verifica se as variáveis de ambiente do banco remoto estão definidas
if [ -z "$REMOTE_HOST" ]; then
    echo "Erro: A variável de ambiente REMOTE_HOST não está definida!" >&2
    exit 1
elif [ -z "$REMOTE_PORT" ]; then
    echo "Erro: A variável de ambiente REMOTE_PORT não está definida!" >&2
    exit 1
elif [ -z "$REMOTE_USER" ]; then
    echo "Erro: A variável de ambiente REMOTE_USER não está definida!" >&2
    exit 1
elif [ -z "$REMOTE_PASSWORD" ]; then
    echo "Erro: A variável de ambiente REMOTE_PASSWORD não está definida!" >&2
    exit 1
elif [ -z "$REMOTE_DB" ]; then
    echo "Erro: A variável de ambiente REMOTE_DB não está definida!" >&2
    exit 1
else
    echo "Todas as variáveis de ambiente para o banco remoto estão definidas." >&2
fi


# Verifica se as variáveis de ambiente do banco local estão definidas
if [ -z "$LOCAL_USER" ]; then
    echo "Erro: A variável de ambiente LOCAL_USER não está definida!" >&2
    exit 1
elif [ -z "$LOCAL_PASSWORD" ]; then
    echo "Erro: A variável de ambiente LOCAL_PASSWORD não está definida!" >&2
    exit 1
elif [ -z "$LOCAL_DB" ]; then
    echo "Erro: A variável de ambiente LOCAL_DB não está definida!" >&2
    exit 1
else
    echo "Todas as variáveis de ambiente para o banco local estão definidas." >&2
fi

# Arquivo temporário para o backup
BACKUP_FILE="/tmp/backup.sql"

# Exporta a senha para pg_dump
export PGPASSWORD=$REMOTE_PASSWORD

echo "Realizando backup do banco remoto..."
pg_dump -h $REMOTE_HOST -p $REMOTE_PORT -U $REMOTE_USER -d $REMOTE_DB >$BACKUP_FILE
if [ $? -ne 0 ]; then
    echo "Erro ao realizar o backup do banco remoto." >&2
    exit 1
fi
echo "Backup realizado com sucesso." >&2

# Restaurar o banco no contêiner
export PGPASSWORD=$LOCAL_PASSWORD

echo "Restaurando o banco de dados no contêiner Docker..." >&2
psql -U $LOCAL_USER -d $LOCAL_DB <$BACKUP_FILE
if [ $? -ne 0 ]; then
    echo "Erro ao restaurar o banco de dados no Docker." >&2
    exit 1
fi

echo "Restore concluído com sucesso!" >&2
