#!/bin/bash

while true
do
RED='\033[0;31m'
NC='\033[0m' # No Color

. ~/.bash_profile
lastBlockHash=`stats | head -n 6 | tail -n 1 | awk '{print $2}'`
lastBlockCount=`stats | head -n 7 | tail -n 1 | awk '{print $2}' | tr -d \"`
sleep 5
tries=10
counter=0
while [[ $counter -le $tries ]]
do
	shelleyExplorerJson=`curl -X POST -H "Content-Type: application/json" --data '{"query":" query { block (id:\"'$lastBlockHash'\") { id date { slot epoch { id firstBlock { id } lastBlock { id } totalBlocks } } transactions { totalCount edges { node { id block { id date { slot epoch { id firstBlock { id } lastBlock { id } totalBlocks } } leader { __typename ... on Pool { id blocks { totalCount } registration { startValidity managementThreshold owners operators rewards { fixed ratio { numerator denominator } maxLimit } rewardAccount { id } } } } } inputs { amount address { id } } outputs { amount address { id } } } cursor } } previousBlock { id } chainLength leader { __typename ... on Pool { id blocks { totalCount } registration { startValidity managementThreshold owners operators rewards { fixed ratio { numerator denominator } maxLimit } rewardAccount { id } } } } } } "}' https://explorer.incentivized-testnet.iohkdev.io/explorer/graphql 2> /dev/null`
	shelleyLastBlockCount=`echo $shelleyExplorerJson | grep -o '"chainLength":"[^"]*' | cut -d'"' -f4`
	if [[ $shelleyLastBlockCount -ne "" ]]; then
		break
	fi
	counter=$(($counter+1))
	echo "INVALID RESULT. RETRYING..."
	sleep 3
done
shelleyExplorerJson=`curl -X POST -H "Content-Type: application/json" --data '{"query":" query { block (id:\"'$lastBlockHash'\") { id date { slot epoch { id firstBlock { id } lastBlock { id } totalBlocks } } transactions { totalCount edges { node { id block { id date { slot epoch { id firstBlock { id } lastBlock { id } totalBlocks } } leader { __typename ... on Pool { id blocks { totalCount } registration { startValidity managementThreshold owners operators rewards { fixed ratio { numerator denominator } maxLimit } rewardAccount { id } } } } } inputs { amount address { id } } outputs { amount address { id } } } cursor } } previousBlock { id } chainLength leader { __typename ... on Pool { id blocks { totalCount } registration { startValidity managementThreshold owners operators rewards { fixed ratio { numerator denominator } maxLimit } rewardAccount { id } } } } } } "}' https://explorer.incentivized-testnet.iohkdev.io/explorer/graphql`
shelleyLastBlockCount=`echo $shelleyExplorerJson | grep -o '"chainLength":"[^"]*' | cut -d'"' -f4`

deltaBlockCount=`echo $(($shelleyLastBlockCount-$lastBlockCount))`
maximumBlockDeltaCount=5

echo "LastBlockCount: " $lastBlockCount
echo "LastShelleyBlock: " $shelleyLastBlockCount
echo "DeltaCount: " $deltaBlockCount

if [[ $(echo $shelleyExplorerJson | grep -o '"message":"[^"]*' | cut -d'"' -f4) == *"Couldn't find block's contents in explorer"* || deltaBlockCount > maximumBlockDeltaCount ]]; then
 echo -e ${RED}"Block was not found within main chain. Please restart your node and remove your current chain cache."${NC}
 echo "Node was out of sync at block " $lastBlockCount >> logs/node-checker-warnings.out
 echo "Trying to restart the node..."
 stop
 rm -r mnt
 start_leader
 sleep 180
fi

sleep 900
done
