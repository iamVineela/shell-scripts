#!/bin/bash

jq --version >/dev/null

if [ $? -ne 0 ]; then
    echo "jq is not installed. Please install jq to execute"
    exit 1
fi

BASE_URL="https://api.coingecko.com/api/v3/simple/price"

#Taking inputs from the user for currency and coin type

read -p "Enter currency: " CURRENCY
read -p "Enter Coin: " COIN

# Converting user inputs to lower case as coingecko wont support uppercase
CURRENCY=$(echo "$CURRENCY" | tr '[:upper:]' '[:lower:]')
COIN=$(echo "$COIN" | tr '[:upper:]' '[:lower:]')

# Checking whether input is provided or not.
if [ -z "$CURRENCY" ]; then
    echo "Error: Please provide currency"
    exit 1
fi

if [ -z "$COIN" ]; then
    echo "Error: Please provide coin"
    exit 1
fi

# Forming url with ids, currency and last updated

API_URL="$BASE_URL?ids=$COIN&vs_currencies=$CURRENCY&include_last_updated_at=true"

# Getting response from api

RESPONSE=$(curl -s  "$API_URL")

# if response is not successful exit the script
if [ $? -ne 0 ]; then
    echo "Error: Failed connecting to API"
    exit 1
fi

# fetching last updated at value from response

LAST_UPDATED=$(echo "$RESPONSE" | jq -r '."'$COIN'".last_updated_at')

#if last updates is null exiting

if [ -z "$LAST_UPDATED" ] || [ "$LAST_UPDATED" == "null" ] ; then
        echo "Error: Unable to fetch updated time"
        exit 1
fi

# Getting the currency rate from the api response

RATE=$(echo "$RESPONSE" | jq -r '."'$COIN'"."'$CURRENCY'" ')

# if rate value is null exiting

if [ -z "$RATE" ] || [ "$RATE" == "null" ] ; then
        echo "Error: Unable to fetch rate. Please provide valid inputs"
        exit 1
fi

# Display output

echo "===== Cryptocurrency Exchange Rate ====="
echo "Coin: $COIN"
echo "Currency: $CURRENCY"
echo "Exchange Rate: $RATE"
echo "Last Updated: $LAST_UPDATED"
echo "========================================"

exit 0
