# jormungandr-out-of-sync-node-helper
A shell script which checks every 5 minutes if your cardano jormungandr node is stucked or on a wrong chain and restart it (optional)

The script uses functions of @Chris-Graffagnino (thx)
https://github.com/Chris-Graffagnino/Jormungandr-for-Newbs/blob/master/docs/jormungandr_node_setup_guide.md

I recommend to start the script like: <br/>
 <b>./node_stuck_check.sh &> stucker_running.out &</b>
 <br/>
 <br/>
 To stop, you need to kill the process.
 <br/>
 <br/>
 If you want to monitor the script just write <b>tail -f stucker_running.out</b>
 <br/>
  error logs will be written to logs/node-checker-warnings.out

<h3>If you like my work, a coffee would be great. Feel free :)</h3>
<b>DdzFFzCqrht5X4iAwmKjt4QJWdqwUAAKZ2ZodFKvKseDh5DAWX36EDNcwrc6fQ6WicH33NXQmX2QMLHhKkDjx2X65uYQQeX7E26ps9TY</b>
