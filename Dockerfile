# Dockerfile
# Base em Debian slim com Python 3.11
FROM python:3.11-slim

# Variáveis de ambiente para comportamento Python
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Instala o gerenciador de dependências 'uv'
RUN pip install --upgrade pip \
    && pip install uv

# Define o diretório de trabalho
WORKDIR /app

# Copia apenas os arquivos de configuração para instalar dependências
COPY pyproject.toml uv.lock ./

# Instala o seu pacote e dependências bloqueadas
RUN uv pip install .

# Copia todo o restante do código
COPY . .

# Comando padrão: inicia o MCP via CLI
CMD ["memory-mcp"]
