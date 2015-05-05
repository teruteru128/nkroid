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

	def fallback
		@limited > 3 ? @limited = 0 : @limited += 1
	end
	
	def screen_name
		/nkroid.*/
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
	
	def mention(obj,texts,opt=false)
		pre = opt ? "." : ""
		texts.scan(/.{1,#{120}}/m).each do |text|
			twitter.update("#{pre}@#{obj.user.screen_name} #{text}",:in_reply_to_status_id => obj.id)
		end
	rescue Twitter::Error::Forbidden
		fallback
		retry
	end
	
	def startup
		Thread.new{loop{sleep 60*5;@limited=0}}
		Thread.new{loop{sleep 20;GC.start}}
	end

	def start
		startup
		@stream.user(:replies => "all") do |obj|
			extract_obj(obj)
		end
	rescue => e
		@twerr.update e.message
		$stderr.puts e.message
		retry
	end
	
	def extract_obj(obj)
		case obj
		when Twitter::Tweet
			return if obj.user.screen_name =~ screen_name
			return if obj.text =~ /@null|定期|自動/
			return if obj.text =~ /^RT/
			Thread.start{callback(:tweet, obj)}
	when Twitter::Streaming::Event
			callback(:event, obj)
		when Twitter::Streaming::FriendList
			puts "System -> Start streaming of @#{screen_name}..."
		when Twitter::Streaming::DeletedTweet
			callback(:delete, obj)
		when Twitter::DirectMessage
			Thread.new{callback(:dm, obj)}
		end
	rescue Twitter::Error::Forbidden
		fallback
		retry
	rescue Twitter::Error::TooManyRequests => e
		n = e.rate_limit.reset_in
		sleep n
		t=Thread.new{start};t.join
	rescue Twitter::Error::NotFound,SQLite3::SQLException,SQLite3::BusyException
		return
	rescue Twitter::Error
		retry
	rescue => e
		@twerr.update "Error -> #{e.class}\n#{e.message}\n#{Time.now}"
		puts e.backtrace
		retry
	end
end