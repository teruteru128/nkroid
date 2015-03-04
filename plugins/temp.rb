def temp_io(io)
	bin = File.binread(io)
	file_name = Time.now.strftime("%s.png")
	file = "/tmp/updater/#{file_name}"
	File.binwrite(file, bin)
	return file
end