# coding: utf-8

require "twitter"
require "sqlite3"
require "yaml"
require "./markov.rb"

class Account
	def initialize(keys)
		@keys = keys
		@data = File.expand_path("../data", __FILE__)
		@accounts = []
		@rest = Twitter::REST::Client.new(keys[0]);@accounts<<@rest #メインアカウント
		@keys[1..-2].each{|key|@accounts<<Twitter::REST::Client.new(key)} #規制用アカウント
		@twerr = Twitter::REST::Client.new(@keys.last) #エラー報告用アカウント
		@stream = Twitter::Streaming::Client.new(keys[0])
		@markov = Markov.new
		@db = SQLite3::Database.open(@data+"/nkroid.db")
		@callbacks = {}
		@limited = 0
	end

	def on_event(event, &blk)
		@callbacks[event] ||= []
		@callbacks[event] << blk
	end

	def callback(event, obj)
		if @callbacks.key?(event)
			@callbacks[event].each do |c|
				c.call(obj)
			end
		end
	end
	
	def screen_name
		/nkroid\w*/
	end
		
	def fallback(*args)
		Thread.new{n=@limited;sleep(600);@limited=n}
		if args.empty?
			@limited += 1
			@limited = 0 if @limited < 3
		else
			args[0] =~ /nkroid(.*)/
			mark = $1
			@limited = case mark
				when "" then 0
				when /2/ then 1
				when /3/ then 2
				when /4/ then 3
				else 0
				end
		end
	end

	def twitter
		@accounts[@limited]
	end
	
	def post(text)
		twitter.update(text)
	rescue Twitter::Error::Forbidden
		fallback
		retry
	end
	
	def mention(obj,texts)
		texts.scan(/.{1,#{120}}/m).each do |text|
			twitter.update("@#{obj.user.screen_name} #{text}",:in_reply_to_status_id => obj.id)
		end
	rescue Twitter::Error::Forbidden
		fallback
		retry
	end

	def start
		Thread.new{loop{sleep 20;GC.start}}
		@stream.user do |obj|
			extract_obj(obj)
		end
	rescue => e
		@twerr.update e.message
		t=Thread.new{start};t.join
	end
	
	def extract_obj(obj)
		case obj
		when Twitter::Tweet
			return if obj.user.screen_name =~ screen_name
			return if obj.text =~ /@null|定期|自動/
			Thread.new{callback(:tweet, obj)}
		when Twitter::Streaming::Event
			callback(:event, obj)
		when Twitter::Streaming::FriendList
			puts "System -> Start streaming of @nkroid..."
		when Twitter::Streaming::DeletedTweet
			callback(:delete, obj)
		when Twitter::DirectMessage
			callback(:dm, obj)
		end
	rescue Twitter::Error::Forbidden
		fallback
		retry
	rescue Twitter::Error::TooManyRequests => e
		n = e.rate_limit.reset_in
		sleep n
		t=Thread.new{start};t.join
	rescue SQLite3::BusyException
		retry
	rescue Twitter::Error::NotFound,SQLite3::SQLException
		return
	rescue => e
		@twerr.update "Error -> #{e.class}\n#{Time.now}"
		if e.message =~ /limit/i
			fallback
			retry
		else
			retry
		end
	end
end