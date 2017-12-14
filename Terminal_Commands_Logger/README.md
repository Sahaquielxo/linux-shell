Theese scripts allows you to log all the commands were entered in terminal by users.

## How doest it work:

log\_start.sh script monitoring ps aux output and looking for new sessions.
When it found a new session, log\_start.sh create a new lets.sh running script and create /tmp/bash\_log\.$$ filename where you will be able to find all the logs.

### NB.
It's customized a bit in lets.sh. **STR\_TO\_REMOVE** variable.
You needs it to avouit double $PS1 prints in log files, customize it for your $PS1 variable.
