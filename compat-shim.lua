convert_message = function(msg)	
	-- Reply converting
	if msg.reply_to_message then
		msg.reply = msg.reply_to_message
		msg.reply.to = msg.reply_to_message.chat
	end
	
	msg.action = {}
	msg.action.user = {}

	-- Service messages conversion
	if msg.new_chat_participant then
		msg.service = true
		msg.action.type = 'chat_add_user'
		msg.action.user.id = msg.new_chat_participant.id
		msg.from.id = msg.new_chat_participant.id
	end
	
	if msg.left_chat_participant then
		msg.service = true
		msg.action.type = 'chat_del_user'
		msg.action.user.id = msg.left_chat_participant.id
		msg.from.id = msg.left_chat_participant.id
	end
	
	-- ID compatibility
	target = tonumber(msg.chat.id)
	if target < -1000000000000 then
		msg.chat.id = math.abs(target) - 1000000000000
		msg.chat.type = 'channel'
	elseif target < 0 then
		msg.chat.id = math.abs(target)
		msg.chat.type = 'chat'
	else
		msg.chat.type = 'user'
	end

	target = tonumber(msg.from.id)
	if target < -1000000000000 then
		msg.from.id = math.abs(target) - 1000000000000
		msg.from.type = 'channel'
	elseif target < 0 then
		msg.from.id = math.abs(target)
		msg.from.type = 'chat'
	else
		msg.from.type = 'user'
	end

	msg.from.peer_type = msg.from.type
	msg.chat.peer_type = msg.chat.type
	msg.to = msg.chat	
	msg.from.peer_id = msg.from.id
	msg.to.peer_id = msg.to.id

	msg.from.print_name = msg.from.name
	if msg.chat.type == 'chat' or msg.chat.type == 'channel' then
		msg.chat.print_name = msg.chat.title
	else
		msg.to.print_name = msg.to.name
	end

	print('Converted msg.')
	print(' id: '..msg.to.id)
	print(' peer_id: '..msg.to.peer_id) 
	print(' type: '..msg.to.type)

	return msg
end

convert_user = function(user)
	user.peer_id = user.id
	user.print_name = user.name
	user.type = 'user'
	user.peer_type = 'user'
	user.print_name = build_name(user.first_name, user.last_name)
	return user
end

check_if_channel = function(receiver)
	if receiver ~= nil then
		if string.find(receiver, "channel#id") then
			return true
		else
			return false
		end
	else
		return false
	end
end

reverse_receiver = function(receiver)
	print(receiver)
	if receiver ~= nil then
		local real_destination
		if check_if_channel(receiver) then
			real_destination = string.gsub(receiver, 'channel#id', '')
			real_destination = (real_destination + 1000000000000) * -1
		else
			real_destination = string.gsub(receiver, 'chat#id', '')
			real_destination = string.gsub(real_destination, 'user#id', '')
		end
		print(real_destination)
		return real_destination
	end
	return nil
end

send_msg = function(destination, text, callback, extra)
	local real_destination = reverse_receiver(destination)
	if callback == nil then
		callback = fake_cb
	end
	if real_destination ~= nil then
		print(sendMessage(real_destination, text, false, nil, false))
		return callback(extra, true, true)
	end
	return callback(extra, false, true)
end

send_photo = function(destination, file_path, callback, extra)
	local real_destination = reverse_receiver(destination)
	if callback == nil then
		callback = fake_cb
	end
	if real_destination ~= nil then
		sendPhoto(real_destination, file_path, nil, nil, false)
		return callback(extra, true, true)
	end
	return callback(extra, false, true)
end

send_location = function(destination, lat, lng, callback, extra)
	local real_destination = reverse_receiver(destination)
	if callback == nil then
		callback = fake_cb
	end
	if real_destination ~= nil then
		sendLocation (real_destination, lat, lng, nil, false)
		return callback(extra, true, true)
	end
	return callback(extra, false, true)
end

chat_del_user = function(destination, user, callback, extra)
	local real_destination = reverse_receiver(destination)
	local real_user = reverse_receiver(user)
	if callback == nil then
		callback = fake_cb
	end
	if real_destination ~= nil and real_user ~= nil then
		kickChatMember(real_destination, real_user)
		return callback(extra, true, true)
	end
	return callback(extra, false, true)
end

channel_kick_user = chat_del_user

-- STUB: You cannot get chat members IDs via API calls
chat_info = function(destination, callback, extra)
	if callback == nil then
		callback = fake_cb
	end
	local fake_user_list = { { print_name = "API cannot read members", peer_id = 0 } }
	return callback(extra, true, {members_num = 1, members = fake_user_list})
end

-- STUB: You cannot get channel/group members IDs via API calls
channel_get_users = function(destination, callback, extra)
	if callback == nil then
		callback = fake_cb
	end
	local fake_user_list = { { print_name = "API cannot read members", peer_id = 0 } }
	return callback(extra, true, fake_user_list)
end

-- Gets results from an internal database as otouto does already
resolve_username = function(who, callback, extra)
	if callback == nil then
		callback = fake_cb
	end
	local user = _resolve_username(who)
	local result
	if user == nil then
	  return callback(extra, false, false)
	end
	user = convert_user(user)
	return callback(extra, true, user)
end

postpone = function(random)
end

fake_cb = function(cb_extra, success, result)
end

mark_read = function(msg)
end
