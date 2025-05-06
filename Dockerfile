# Dockerfile
# Base em Debian slim com Python 3.11
FROM python:3.11-slim

# Configurações do Python e variáveis de ambiente
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on

# Instala dependências do sistema e uv
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir uv

# Define o diretório de trabalho
WORKDIR /app

# Copia arquivos de configuração
COPY pyproject.toml uv.lock ./

# Cria e ativa o ambiente virtual, então instala as dependências
RUN uv venv /app/.venv && \
    . /app/.venv/bin/activate && \
    uv pip install --no-cache .

# Copia o código da aplicação
COPY memory_mcp ./memory_mcp
COPY tests ./tests

# Usuário não-root para segurança
RUN useradd -m -u 1000 mcp \
    && chown -R mcp:mcp /app
USER mcp

# Configura o ambiente virtual no PATH
ENV PATH="/app/.venv/bin:$PATH"

# Healthcheck para monitoramento
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT:-3000}/health || exit 1

# Comando para iniciar o servidor
CMD ["memory-mcp"]
