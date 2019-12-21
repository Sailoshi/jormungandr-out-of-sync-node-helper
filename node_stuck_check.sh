#!/bin/bash
while true
do
 RED='\033[0;31m'
 GREEN='\033[0;32m'
 NC='\033[0m' # No Color
 . ~/.bash_profile

 lastBlockHash=`stats | head -n 6 | tail -n 1 | awk '{print $2}'` 
 lastBlockCount=`stats | head -n 7 | tail -n 1 | awk '{print $2}' | tr -d \"`
 sleep 5
 tries=10
 deltaMax=10
 counter=0

 while [[ $counter -le $tries ]]
 do
      shelleyExplorerJson=`curl -X POST -H "Content-Type: application/json" --data '{"query": " query {   allBlocks (last: 3) {    pageInfo { hasNextPage hasPreviousPage startCursor endCursor  }  totalCount  edges {    node {     id  date { slot epoch {  id  firstBlock { id  }  lastBlock { id  }  totalBlocks }  }  transactions { totalCount edges {   node {    id  block { id date {   slot   epoch {    id  firstBlock { id  }  lastBlock { id  }  totalBlocks   } } leader {   __typename   ... on Pool {    id  blocks { totalCount  }  registration { startValidity managementThreshold owners operators rewards {   fixed   ratio {  numerator  denominator   }   maxLimit } rewardAccount {   id }  }   } }  }  inputs { amount address {   id }  }  outputs { amount address {   id }  }   }   cursor }  }  previousBlock { id  }  chainLength  leader { __typename ... on Pool {  id  blocks { totalCount  }  registration { startValidity managementThreshold owners operators rewards {   fixed   ratio {  numerator  denominator   }   maxLimit } rewardAccount {   id }  } }  }    }    cursor  }   } }  "}' https://explorer.incentivized-testnet.iohkdev.io/explorer/graphql 2> /dev/null`
      shelleyLastBlockCount=`echo $shelleyExplorerJson | grep -m 1 -o '"chainLength":"[^"]*' | cut -d'"' -f4 | awk '{print $NF}'`
      shelleyLastBlockCount=`echo $shelleyLastBlockCount|cut -d ' ' -f3`
      deltaBlockCount=`echo $(($shelleyLastBlockCount-$lastBlockCount))`
      if [[ ! -z $shelleyLastBlockCount ]]; then
         break
      fi
      counter=$(($counter+1))
      echo "INVALID RESULT. RETRYING..."
      sleep 3
 done  

 echo "LastBlockCount: " $lastBlockCount
 echo "LastShelleyBlock: " $shelleyLastBlockCount
 echo "DeltaCount: " $deltaBlockCount

 if [[ $(echo $shelleyExplorerJson | grep -o '"message":"[^"]*' | cut -d'"' -f4) == *"Couldn't find block's contents in explorer"* || $deltaBlockCount -gt $deltaMax ]]; then
     now=$(date +"%r")
     echo -e ${RED}$now": Block was not found within main chain. Your node will be automatically restarted."${NC}
     echo $now": Your node was out of sync at block $lastBlockCount. Trying to restart." >> logs/node-checker-warnings.out
     echo $now": Trying to restart the node..."
     stop
     rm -r mnt
     start_leader     
     sleep 180
     lastBlockHash=`stats | head -n 6 | tail -n 1 | awk '{print $2}'`
     now=$(date +"%r")
     if [[ ! -z $lastBlockHash ]]; then
        echo -e ${GREEN}"$now: Old storage files were removed and node was restarted successfully. Next check in 15 minutes again"${NC}
        echo -e ${GREEN}"$now: Your node was restarted successfully." >> logs/node-checker-warnings.out${NC}
     fi
 else
     echo -e ${GREEN}$now": Last check was good. Next check in 15 minutes again"${NC}
 fi
 
 sleep 900
done
