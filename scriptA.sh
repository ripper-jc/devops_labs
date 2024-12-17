#!/bin/bash

# Function to launch a container and pin it to a specific CPU core
launch_container() {
  container_name=$1
  cpu_core=$2
  if docker ps -a --format '{{.Names}}' | grep -q "$container_name"; then
    if ! docker ps --format '{{.Names}}' | grep -q "$container_name"; then
      docker rm "$container_name"
    else
      echo "Container $container_name is already running."
      return
    fi
  fi
  echo "Launching $container_name on core $cpu_core..."
  docker run -d --name "$container_name" --cpuset-cpus="$cpu_core" rpjc/optimaserver
  sleep 10  # Give the container time to start
}

# Function to check container CPU usage
get_cpu_usage() {
  container_name=$1
  docker stats "$container_name" --no-stream --format "{{.CPUPerc}}" | sed 's/%//'
}

# Function to update all running containers
update_containers() {
  echo "Pulling the latest image..."
  docker pull rpjc/optimaserver

  declare -A container_cores=( ["srv1"]=0 ["srv2"]=1 ["srv3"]=2 )

  for container_name in srv1 srv2 srv3; do
    if docker ps --format '{{.Names}}' | grep -q "$container_name"; then
      echo "Stopping $container_name for update..."
      docker stop "$container_name"
      docker rm "$container_name"
      echo "Restarting $container_name..."
      launch_container "$container_name" "${container_cores[$container_name]}"
    fi
  done
}

# Main logic loop
last_update_check=$(date +%s)
while true; do
  # Check srv1
  launch_container srv1 0
  echo "Checking srv1..."
  if docker ps --format '{{.Names}}' | grep -q srv1; then
    usage1=$(get_cpu_usage srv1)
    sleep 60
    usage2=$(get_cpu_usage srv1)
    if (( $(echo "$usage1 > 80" | bc -l) && $(echo "$usage2 > 80" | bc -l) )); then
      echo "srv1 is busy for 2 consecutive minutes. Checking for srv2..."
      if ! docker ps --format '{{.Names}}' | grep -q srv2; then
        launch_container srv2 1
      fi
    fi
  fi

  # Check srv2
  if docker ps --format '{{.Names}}' | grep -q srv2; then
    usage1=$(get_cpu_usage srv2)
    sleep 60
    usage2=$(get_cpu_usage srv2)
    if (( $(echo "$usage1 > 80" | bc -l) && $(echo "$usage2 > 80" | bc -l) )); then
      echo "srv2 is busy for 2 consecutive minutes. Checking for srv3..."
      if ! docker ps --format '{{.Names}}' | grep -q srv3; then
        launch_container srv3 2
      fi
    elif (( $(echo "$usage1 < 10" | bc -l) && $(echo "$usage2 < 10" | bc -l) )); then
      echo "srv2 is idle for 2 consecutive minutes. Stopping it..."
      docker stop srv2
      docker rm srv2
    fi
  fi

  # Check srv3
  if docker ps --format '{{.Names}}' | grep -q srv3; then
    usage1=$(get_cpu_usage srv3)
    sleep 60
    usage2=$(get_cpu_usage srv3)
    if (( $(echo "$usage1 < 10" | bc -l) && $(echo "$usage2 < 10" | bc -l) )); then
      echo "srv3 is idle for 2 consecutive minutes. Stopping it..."
      docker stop srv3
      docker rm srv3
    fi
  fi

  # Check for new version of the container every 10 minutes
  current_time=$(date +%s)
  if (( current_time - last_update_check >= 40 )); then
    echo "Checking for new version of the container..."
    if docker pull rpjc/optimaserver | grep -q 'Downloaded newer image'; then
      echo "New image version available. Updating containers..."
      declare -A container_cores=( ["srv1"]=0 ["srv2"]=1 ["srv3"]=2 )
      for container_name in srv1 srv2 srv3; do
        if docker ps --format '{{.Names}}' | grep -q "$container_name"; then
          echo "Updating $container_name..."
          docker stop "$container_name"
          docker rm "$container_name"
          launch_container "$container_name" "${container_cores[$container_name]}"
          sleep 10  # Ensure at least one container is running before updating the next
        fi
      done
    fi
    last_update_check=$current_time
  fi

  sleep 20
done