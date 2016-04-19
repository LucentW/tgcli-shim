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

	print('Converted msg.')
	print(' id: '..msg.to.id)
	print(' peer_id: '..msg.to.peer_id) 
	print(' type: '..msg.to.type)

	return msg
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

postpone = function(random)
end

fake_cb = function(cb_extra, success, result)
end

mark_read = function(msg)
end
