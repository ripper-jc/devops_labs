#!/bin/bash

# Function to make an HTTP request
make_request() {
  curl -i -X GET 127.0.0.1/compute &
}

# Loop to make requests every random 5 to 10 seconds
while true; do
  make_request
  sleep $((RANDOM % 6 + 5))
done
