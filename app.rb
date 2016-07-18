require_relative "Bot"

module Bot
  Dir.glob("plugin/**/*.rb").each do |plugin|
    @console.info "loaded #{plugin}"
    require_relative plugin
  end
  @console.info "Initialized."

  EM.run do
    @accounts.each do |account|
      next unless account.streaming
      begin
        EM.defer do
          account.stream.user(replies: 'all', include_followings_activity: 'true') do |obj|
            extract obj, account
          end
        end
      rescue
        report $!
        sleep 5
        retry
      end
    end
  end
end
