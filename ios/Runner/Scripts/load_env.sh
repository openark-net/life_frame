#!/bin/bash

# Load environment variables from .env file
ENV_FILE="${SRCROOT}/../../.env"

if [ -f "$ENV_FILE" ]; then
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        if [[ $key =~ ^[[:space:]]*# ]] || [[ -z $key ]]; then
            continue
        fi
        
        # Remove quotes from value if present
        value=$(echo "$value" | sed 's/^["'\'']\|["'\'']$//g')
        
        # Export the variable
        export "$key"="$value"
        
        # Write to xcconfig file for use in Info.plist
        echo "$key = $value" >> "${SRCROOT}/Runner/Generated.xcconfig"
    done < "$ENV_FILE"
else
    echo "Warning: .env file not found at $ENV_FILE"
fi