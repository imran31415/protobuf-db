!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if GOPATH is set, otherwise set it to the default
if [ -z "$GOPATH" ]; then
  echo "GOPATH is not set. Using default: $HOME/go"
  export GOPATH=$HOME/go
else
  echo "Using GOPATH: $GOPATH"
fi

# Ensure Go binary path is in PATH
if [[ ":$PATH:" != *":$GOPATH/bin:"* ]]; then
  export PATH="$GOPATH/bin:$PATH"
  echo "Added GOPATH/bin to PATH: $GOPATH/bin"
fi

# Check if protoc-gen-go is installed
if ! command -v protoc-gen-go &> /dev/null; then
  echo "protoc-gen-go is not installed. Installing it now..."
  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
fi

protoc -I ./proto \
       --go_out=./db-annotations \
       --go_opt=paths=source_relative \
       --go-grpc_out=./db-annotations \
       --go-grpc_opt=paths=source_relative \
       ./proto/database_operations.proto

echo "Protobuf generation completed successfully!"




# git add .
# git commit -m "Initial commit for proto-db-annotations"
# git branch -M main
# git remote add origin https://github.com/your-username/proto-db-annotations.git
# git push -u origin main

