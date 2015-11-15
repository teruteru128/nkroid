ActiveRecord::Base.establish_connection(YAML.load_file("config/database.yml")[ENV['ENV']])
