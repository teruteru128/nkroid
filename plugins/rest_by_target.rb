def rest_by(target)
	case target
	when "nkroid"
		@rest
	when /nkroid2/
		@fallback
	when /nkroid3/
		@fallback2
	when /nkroid4/
		@fallback3
	else
		return @rest
	end
end
