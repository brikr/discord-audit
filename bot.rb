#!/usr/bin/env ruby
require 'discordrb'

token = File.read("#{File.dirname(__FILE__)}/token").strip

bot = Discordrb::Bot.new(token: token)

bot.ready do |_event|
  bot.game = 'Super Mario 64'
end

# keep track of the last x messages on the server
MESSAGE_LIMIT = 5000
messages = {}
keys = []

bot.message do |event|
  id = event.message.id
  messages[id] = event.message
  keys << id
  if (keys.length > MESSAGE_LIMIT)
    oldest = keys.shift # delete first (oldest)
    messages.delete(oldest)
  end
end

bot.message_delete do |event|
  log_channel = event.channel.server.channels.find do |channel|
    # text channel named audit_log (can be private)
    channel.name == 'audit_log' && channel.type <= 1
  end

  message = messages[event.id]

  next unless message

  attach_string = if message.attachments.empty?
                    ""
                  else
                    "*Message had attachment*\n"
                  end

  log_channel.send_embed do |embed|
    embed.title = 'Message deleted'
    embed.description = "**Author**: #{message.author.mention}\n" \
      "**Content**:\n#{message.content}\n" \
      "#{attach_string}" \
      "**Deleted at**: #{Time.now.utc}"
  end
end

bot.message_edit do |event|
  log_channel = event.channel.server.channels.find do |channel|
    # text channel named audit_log (can be private)
    channel.name == 'audit_log' && channel.type <= 1
  end

  message = messages[event.message.id]

  next unless message

  log_channel.send_embed do |embed|
    embed.title = 'Message edited'
    embed.description = "**Author**: #{message.author.mention}\n" \
      "**Original Content**:\n#{message.content}\n" \
      "**New Content**:\n#{event.message.content}\n" \
      "**Edited at**: #{Time.now.utc}"
  end

  messages[event.message.id] = event.message
end

bot.run
