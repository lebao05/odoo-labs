# Odoo 19 Dockerfile
FROM python:3.12-slim

# Avoid Python output buffering issues
ENV PYTHONUNBUFFERED=1

# Set default Odoo version
ARG ODOO_VERSION=19.0

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    ca-certificates \
    curl \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install wkhtmltopdf (for PDF reports)
RUN curl -o wkhtmltopdf.deb -L https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bookworm_amd64.deb \
    && apt-get install -y ./wkhtmltopdf.deb \
    && rm wkhtmltopdf.deb \
    && rm -rf /var/lib/apt/lists/*

# Create odoo user
RUN useradd -m -u 1000 -o -s /bin/bash odoo

# Set up working directory
WORKDIR /mnt/extra-addons

# Copy requirements
COPY requirements.txt /tmp/requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Copy Odoo source (if not using official Odoo image)
COPY odoo /opt/odoo/odoo
COPY odoo-bin /usr/local/bin/odoo-bin
COPY odoo.conf /etc/odoo/odoo.conf

# Make odoo-bin executable
RUN chmod +x /usr/local/bin/odoo-bin

# Create filestore directory
RUN mkdir -p /var/lib/odoo && chown odoo:odoo /var/lib/odoo

# Copy custom addons (if any)
COPY custom_addons /mnt/extra-addons
RUN chown -R odoo:odoo /mnt/extra-addons

# Switch to odoo user
USER odoo

# Expose port
EXPOSE 8069

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8069/login || exit 1

# Run Odoo
CMD ["/usr/local/bin/odoo-bin", "-c", "/etc/odoo/odoo.conf"]
