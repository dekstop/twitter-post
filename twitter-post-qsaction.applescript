-- No idea what this was originally based on.
-- I doubt that I wrote this all by myself.
-- martind 2010-07-10

on str_replace(search, replace, subject)
	local search, replace, subject, ASTID
	
	set ASTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to search
	set subject to text items of subject
	
	set AppleScript's text item delimiters to replace
	set subject to "" & subject
	set AppleScript's text item delimiters to ASTID
	
	return subject
end str_replace

using terms from application "Quicksilver"
	on process text message
		try
			-- escape bash special characters
			-- cf. http://ss64.com/bash/syntax-quoting.html
			set message to str_replace("\\", "\\\\", message)
			set message to str_replace("\"", "\\\"", message)
			set message to str_replace("`", "\\`", message)
			set message to str_replace("$", "\\$", message)
			set message to str_replace("@", "\\@", message)
			do shell script "/Users/mongo/Documents/code/twitter/twitter-post.rb \"" & message & "\""
		on error x
			activate me
			display dialog x
		end try
		
		return -- nothing
	end process text
	
end using terms from
