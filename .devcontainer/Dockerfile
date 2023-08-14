FROM mcr.microsoft.com/devcontainers/dotnet:0-7.0

# Install SQL Tools: SQLPackage and sqlcmd
COPY mssql/installSQLtools.sh installSQLtools.sh
RUN bash ./installSQLtools.sh \
     && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts \ 
     && dotnet build /workspaces/ecomm-order-processor/src/OrderProcessor/OrderProcessor.csproj
