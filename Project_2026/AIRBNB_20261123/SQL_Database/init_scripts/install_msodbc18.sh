#!/bin/bash
# Installs Microsoft ODBC Driver 18 for SQL Server on Databricks classic cluster nodes (Ubuntu).
# Runs as root during cluster startup.
set -e

# Install the Microsoft package repo for the node's Ubuntu release
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
curl -fsSL "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list" \
  -o /etc/apt/sources.list.d/mssql-release.list

apt-get update -y
ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc unixodbc-dev

# Verify the driver is registered with unixODBC
odbcinst -q -d -n "ODBC Driver 18 for SQL Server" && echo "msodbcsql18 installed OK"