require_relative "lib/em"
require_relative "lib/console"
require_relative "lib/twitter"
Bot.console.info "lib loaded."

Dir.glob("plugin/*.rb").each{|plugin|require_relative plugin}
Bot.console.info "plugin load complete."

module Bot
  def self.run
    @console.info "started."

    EM.run do
      @accounts.each do |id, account|
        EM.defer do
          @console.info "@#{id} Streaming started."
          account.stream.user(replies: 'all') do |obj|
            extract obj, id
          end
        end
      end
    end
  end
end
