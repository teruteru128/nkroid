class AccountManager
	attr_reader :accounts,:locked
	def initialize
		@accounts = []
		@limited = 0
		@locked = false
		Thread.new{loop{sleep 60*5;@limited = 0}}
	end

	def <<(account)
		@accounts << account
	end

	def fallback
		@limited += 1
		@limited = 0 if @limited > @accounts.size
	end

	def cursor
		@accounts[@limited]
	end

	def [](i)
		@accounts[i]
	end

	def lock
		@locked = true
	end

	def unlock
		@locked = false
	end 
end