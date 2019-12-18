#!/bin/bash

while true
do
RED='\033[0;31m'
NC='\033[0m' # No Color

. ~/.bash_profile
lastBlockHash=`stats | head -n 6 | tail -n 1 | awk '{print $2}'`
lastBlockCount=`stats | head -n 7 | tail -n 1 | awk '{print $2}' | tr -d \"`
shelleyExplorerJson=`curl -X POST -H "Content-Type: application/json" --data '{"query":" query { block (id:\"'$lastBlockHash'\") { id date { slot epoch { id firstBlock { id } lastBlock { id } totalBlocks } } transactions { totalCount edges { node { id block { id date { slot epoch { id firstBlock { id } lastBlock { id } totalBlocks } } leader { __typename ... on Pool { id blocks { totalCount } registration { startValidity managementThreshold owners operators rewards { fixed ratio { numerator denominator } maxLimit } rewardAccount { id } } } } } inputs { amount address { id } } outputs { amount address { id } } } cursor } } previousBlock { id } chainLength leader { __typename ... on Pool { id blocks { totalCount } registration { startValidity managementThreshold owners operators rewards { fixed ratio { numerator denominator } maxLimit } rewardAccount { id } } } } } } "}' https://explorer.incentivized-testnet.iohkdev.io/explorer/graphql`
shelleyLastBlockCount=`echo $shelleyExplorerJson | grep -o '"chainLength":"[^"]*' | cut -d'"' -f4`

alphaBlockCount=`echo $(($shelleyLastBlockCount-$lastBlockCount))`
maximumBlockAlphaCount=2

if [[ $(echo $shelleyExplorerJson | grep -o '"message":"[^"]*' | cut -d'"' -f4) == *"Couldn't find block's contents in explorer"* || alphaBlockCount < $((-maximumBlockAlphaCount - 1)) ]]; then
 echo -e ${RED}"Block was not found within main chain. Please restart your node and remove your current chain cache."${NC}
 exit
fi

# If you want to restart your node when the blockchain is out of sync, please remove the following uncomments.
# stop
# rm -r ./mnt
# start_leader

sleep 300
done
