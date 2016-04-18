package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

HTTP = require('socket.http')
HTTPS = require('ssl.https')
URL = require('socket.url')
JSON = require('cjson')
require('./bot/bot') -- Load tg-cli bot

version = '3.6'

bot_init = function() -- The function run when the bot is started or reloaded.

	config = dofile('config.lua') -- Load configuration file.
	dofile('bindings.lua') -- Load Telegram bindings.
	dofile('utilities.lua') -- Load miscellaneous and cross-plugin functions.
	dofile('compat-shim.lua') -- Load tg-cli compatibility module
	
	-- Fetch bot information. Try until it succeeds.
	repeat bot = getMe() until bot
	bot = bot.result

	-- Load the "database"! ;)
	if not database then
		database = load_data(bot.username..'.db')
	end

	print('@' .. bot.username .. ', AKA ' .. bot.first_name ..' ('..bot.id..')')
	on_our_id(bot.id)

	-- Generate a random seed and "pop" the first random number. :)
	math.randomseed(os.time())
	math.random()

	last_update = last_update or 0 -- Set loop variables: Update offset,
	last_cron = last_cron or os.date('%M') -- the time of the last cron job,
	is_started = true -- and whether or not the bot should be running.
	started = true
	database.users = database.users or {} -- Table to cache userdata.
	database.users[tostring(bot.id)] = bot
	
	on_binlog_replay_end()

end

_on_msg_receive = function(msg) -- The fn run whenever a message is received.

	-- Create a user entry if it does not exist.
	if not database.users[tostring(msg.from.id)] then
		database.users[tostring(msg.from.id)] = {}
	end
	-- Clear things that no longer exist.
	database.users[tostring(msg.from.id)].username = nil
	database.users[tostring(msg.from.id)].last_name = nil
	-- Wee.
	for k,v in pairs(msg.from) do
		database.users[tostring(msg.from.id)][k] = v
	end

	if msg.date < os.time() - 5 then return end -- Do not process old messages.

	msg = enrich_message(msg)
	msg = convert_message(msg) -- Pass the message to the shim script
	
	print('Shim received message: '..msg.text)	
	on_msg_receive(msg)
	
end

bot_init() -- Actually start the script. Run the bot_init function.

while is_started do -- Start a loop while the bot should be running.

	local res = getUpdates(last_update+1) -- Get the latest updates!
	if res then
		for i,v in ipairs(res.result) do -- Go through every new message.
			last_update = v.update_id
			_on_msg_receive(v.message)
		end
	else
		print(config.errors.connection)
	end

	if last_cron ~= os.date('%M') then -- Run cron jobs every minute.
		last_cron = os.date('%M')
		save_data(bot.username..'.db', database) -- Save the database.
		for i,v in ipairs(plugins) do
			if v.cron then -- Call each plugin's cron function, if it has one.
				local res, err = pcall(function() v.cron() end)
				if not res then
					handle_exception(err, 'CRON: ' .. i)
				end
			end
		end
	end

end

 -- Save the database before exiting.
save_data(bot.username..'.db', database)
print('Halted.')
