# tgcli-shim
A shim library based on otouto's core to convert tg-cli based bots such as TeleSeed or uzzbot to Bot API 2.0.

This library is highly experimental, and it's being actively developed.

## Setup
You _must_ have Lua (5.2+), lua-socket, lua-sec, and lua-cjson installed. To upload files, you must have curl installed. To use fortune.lua, you must have fortune installed.

Clone the repository and set the following values in `config.lua`:

 - `bot_api_key` as your bot authorization token from the BotFather.
 - `admin` as your Telegram ID.

Optionally:

 - `time_offset` as the difference, in seconds, of your system clock to UTC.
 - `lang` as the two-letter code representing your language.

When you are ready to start the bot, run `./launch.sh`. If you terminate the bot manually, you risk data loss. If you do you not want the bot to restart automatically, run it with `lua bot.lua`.

