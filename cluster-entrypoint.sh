#!/bin/bash

set -e

# Start RMQ from entry point.
# This will ensure that environment variables passed
# will be honored
/usr/local/bin/docker-entrypoint.sh rabbitmq-server -detached

# Do the cluster dance
rabbitmqctl stop_app
rabbitmqctl join_cluster rabbit@rabbitmq1

#this command requires the 'rabbit' app to be running on the target node.
#Start it with 'rabbitmqctl start_app'.
rabbitmqctl start_app

#Ex: Policy where queues whose names begin with "ha." are mirrored to all nodes 
#in the cluster: $ rabbitmqctl set_policy ha-all "^ha\." '{"ha-mode":"all"}'
rabbitmqctl set_policy ha-all "" '{"ha-mode":"all","ha-sync-mode":"automatic"}'

# Stop the entire RMQ server. This is done so that we
# can attach to it again, but without the -detached flag
# making it run in the forground
rabbitmqctl stop

# Wait a while for the app to really stop
sleep 2s

# Start it
rabbitmq-server