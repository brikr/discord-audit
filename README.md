# Discord Audit Bot

This bot keeps track of a pre-defined number of recent messages, and if any are edited/deleted, it posts a log of the change to a channel in the same server named `#audit_log`

# Running the bot

*Coming soon: adding this bot to your server without running it yourself.*  
You will need to create a bot from Discord Developers and acquire it's token. You can do that [here](https://discordapp.com/developers/applications/me).  
The bot is configured to run on Google App Engine. 
```
# token file should contain your bot token on a single line and nothing else
$ vi token
$ gcloud init
$ gcloud app deploy
```
