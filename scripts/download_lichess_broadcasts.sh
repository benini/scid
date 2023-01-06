#!/bin/bash

# Download the list of the last 10000 broadcast from lichess
wget https://lichess.org/api/broadcast?nb=10000 -O broadcast_list.json

# Extract the broadcast's ids and use them to create the corresponding urls
sed 's/^{"tour":{"id":"/https:\/\/lichess.org\/api\/broadcast\//g; s/".*/.pgn/g' broadcast_list.json > urls.txt

# Download the PGN files
wget -i urls.txt