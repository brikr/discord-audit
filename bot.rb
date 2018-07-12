#!/usr/bin/env ruby
require 'discordrb'
require 'discordrb/webhooks'

# use a separate token file for local testing
token_file = ENV['DISCORD_AUDIT_DEV'] == 'true' ? 'token_dev' : 'token'
token = File.read("#{File.dirname(__FILE__)}/#{token_file}").strip

bot = Discordrb::Bot.new(token: token)

bot.ready do |_event|
  bot.game = 'Super Mario 64'
end

# keep track of the last x messages on the server
MESSAGE_LIMIT = 5000
messages = {}
keys = []

bot.message do |event|
  next if event.message.author.bot_account? # ignore messages from other bots

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
    embed.title = "Message deleted in ##{message.channel.name}"
    embed.add_field(name: 'Author', value: message.author.mention)
    embed.add_field(name: 'Content', value: message.content) unless message.content.empty?
    embed.add_field(name: 'Had attachment?', value: 'Yes', inline: true) unless message.attachments.empty?
    embed.add_field(name: 'Had embed?', value: 'Yes', inline: true) unless message.embeds.empty?
    embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Originally posted')
    embed.timestamp = message.timestamp
    embed.color = 0xF03434

    puts embed.inspect
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
    embed.title = "Message edited in ##{message.channel.name}"
    embed.add_field(name: 'Author', value: message.author.mention)
    embed.add_field(name: 'Original content', value: message.content) unless message.content.empty?
    embed.add_field(name: 'New content', value: event.message.content) unless event.message.content.empty?
    embed.add_field(name: 'Has attachment?', value: 'Yes', inline: true) unless message.attachments.empty?
    embed.add_field(name: 'Has embed?', value: 'Yes', inline: true) unless message.embeds.empty?
    embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Originally posted')
    embed.timestamp = message.timestamp
    embed.color = 0xF5D76E
  end

  messages[event.message.id] = event.message
end

# easter egg
bot.mention do |event|
  event.message.create_reaction("\u{1f440}")
end

bot.run
