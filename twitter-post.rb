#!/usr/bin/env ruby

# = twitter-post.rb
# 
# Requires growlnotify http://growl.info/documentation/growlnotify.php
# Based on http://www.hackdiary.com/src/twitter-monitor.rb
# Assumes UTF-8 encoding.
# 
# Martin Dittus 2007-06-05

require 'rexml/document'
require 'net/http'

#MAX_CHARS = 140

@prefs = {
  :user => 'your@address.com',
  :password => 'password',
  
  :userAgent => 'twitter-post.rb 1',
  :twitterUpdatePath => '/statuses/update.xml',
  
  :growlNotify => '/usr/local/bin/growlnotify'
}

def escape(s)
  s.gsub(/['`]/," ")
end

def growl(title, msg, opt='')
  `#{@prefs[:growlNotify]} -n twitter -m '#{escape(msg)}' '#{escape(title)}' #{escape(opt)}`
end


# main

if (ARGV.size == 0) then
  puts "#{__FILE__} <text>"
  exit 1
end

text = ARGV.join(' ')

# we're now letting twitter return an error instead of failing too early
# (counting tweet characters in Ruby is hard!)

# if (text.size > MAX_CHARS) then
#   growl('Twitter: message too long', "Your message contains #{text.size} characters, which is #{text.size-MAX_CHARS} characters too much!")
#   exit 1
# end

http = Net::HTTP.new('twitter.com', 80)
http.start do |http|
    req = Net::HTTP::Post.new(@prefs[:twitterUpdatePath], {'User-Agent' => @prefs[:userAgent]})
    req.basic_auth(@prefs[:user], @prefs[:password])
    req.set_form_data({'status'=>text}, ';')
    response = http.request(req)
    if (response.code =~ /2\d{2}/) then
      resp = response.body
      xml = REXML::Document.new(resp)
      status = xml.elements['status/text'].text
      growl('Twitter: Posted a new message', status)
    else
      growl('Twitter: Your message bounced!', "HTTP #{response.code}: #{response.message}", '--sticky')
      exit 1
    end
end
