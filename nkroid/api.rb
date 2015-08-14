require "sinatra"
require "rack/cache"
require "pg"
require "yaml"
require "json"
require "twitter"
set :environment, :production

$db = PG::connect(YAML.load_file("./data/database.yml")["production"])
$db.prepare("names","select * from name;")

use Rack::Cache

get "/" do
	"works"
end

get "/names" do
	JSON.generate($db.exec_prepared("names").values)
end