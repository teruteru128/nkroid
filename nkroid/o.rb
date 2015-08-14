$dir = File.expand_path(".")
plugins = Dir.glob($dir+"/plugins/*.rb").sort
plugins.each do |plugin|
	plugin =~ /plugins\/(.+\.rb)$/
	puts plugin if (File.read(plugin)) =~ /現代/
end