-- Chrome Web Element Real Clicker
-- Gets coordinates of web elements and performs real system clicks

-- Configuration - Edit these values as needed
-- Simple list of CSS selectors
property selectorList : {"#btn1", "#btn2"}

-- Global settings
property repeatCycles : 3 -- How many times to repeat the entire sequence
property minWait : 0 -- Minimum wait time (seconds) - back to 0
property maxWait : 5 -- Maximum wait time (seconds)
property showLogs : true -- Set to false to disable logging
property logToFile : true -- Set to true for file logging, false for notifications
property showConsoleOutput : true -- Set to true for real-time console output
property logFilePath : (path to me as string) & "chrome_clicker_log.txt"

-- Function to get element position from Chrome
on getElementPosition(selector)
	tell application "Google Chrome"
		tell active tab of front window
			-- JavaScript to get element center coordinates relative to viewport
			set jsCode to "
				(function() {
					var element = document.querySelector('" & selector & "');
					if (!element) return 'null';
					
					var rect = element.getBoundingClientRect();
					var x = Math.round(rect.left + rect.width / 2);
					var y = Math.round(rect.top + rect.height / 2);
					var visible = rect.width > 0 && rect.height > 0;
					
					return x + ',' + y + ',' + visible;
				})();
			"
			
			set result to execute javascript jsCode
			return result
		end tell
	end tell
end getElementPosition

-- Function to get Chrome window content area position
on getChromeContentOffset()
	tell application "Google Chrome"
		tell front window
			set windowBounds to bounds
			-- Chrome window bounds: {left, top, right, bottom}
			set windowLeft to item 1 of windowBounds
			set windowTop to item 2 of windowBounds
			
			-- Chrome content area offset (approximate)
			-- Adjust these values if needed based on your Chrome setup
			set toolbarHeight to 125 -- Height of address bar, bookmarks, etc. (reduced by ~20)
			set contentLeft to windowLeft
			set contentTop to windowTop + toolbarHeight
			
			return {contentLeft, contentTop}
		end tell
	end tell
end getChromeContentOffset

-- Function to clear log file
on clearLogFile()
	if logToFile then
		try
			set logFile to open for access file logFilePath with write permission
			set eof of logFile to 0
			close access logFile
		on error
			try
				close access file logFilePath
			end try
		end try
	end if
end clearLogFile

-- Function to log messages
on logMessage(message)
	if showLogs then
		set timestamp to (current date) as string
		set logEntry to timestamp & " - " & message
		
		-- Real-time console output
		if showConsoleOutput then
			log message
		end if
		
		if logToFile then
			try
				-- Append to log file
				set logFile to open for access file logFilePath with write permission
				write (logEntry & return) to logFile starting at eof
				close access logFile
			on error
				try
					close access file logFilePath
				end try
				-- Create new file if it doesn't exist
				try
					set logFile to open for access file logFilePath with write permission
					write (logEntry & return) to logFile
					close access logFile
				end try
			end try
		else
			-- Use notifications as fallback
			display notification message with title "Debug"
		end if
		
		-- Always log full entry to Script Editor console
		log logEntry
	end if
end logMessage
on performRealClick(screenX, screenY)
	tell application "System Events"
		-- Move mouse to position and click
		set mouse_position to {screenX, screenY}
		-- Perform the click at the calculated position
		click at mouse_position
	end tell
end performRealClick

-- Function to perform real click with verification
on performRealClickWithVerification(screenX, screenY, webX, webY)
	performRealClick(screenX, screenY)
end performRealClickWithVerification

-- Function to get Chrome content area position

-- Make sure Chrome is active and frontmost
tell application "Google Chrome"
	activate
	delay 0.5
end tell

-- Get Chrome content area offset
set contentOffset to getChromeContentOffset()
set contentLeft to item 1 of contentOffset
set contentTop to item 2 of contentOffset

logMessage("Chrome window offset - Left: " & contentLeft & ", Top: " & contentTop)

-- Repeat the entire sequence
repeat with cycle from 1 to repeatCycles
	logMessage("=== Starting cycle " & cycle & " of " & repeatCycles & " ===")
	
	-- Process each selector in order
	repeat with i from 1 to count of selectorList
		set elementSelector to item i of selectorList
		
		logMessage("Processing selector " & i & ": " & elementSelector)
		
		try
			-- Get current element position
			set elementPos to getElementPosition(elementSelector)
			
			logMessage("Raw element position result: " & elementPos)
			
			if elementPos is "null" or elementPos is missing value then
				logMessage("✗ Element NOT FOUND: " & elementSelector)
				-- Continue to next selector instead of skipping
			else
				-- Parse coordinates from comma-separated string
				set AppleScript's text item delimiters to ","
				set coordParts to text items of elementPos
				set webX to item 1 of coordParts as integer
				set webY to item 2 of coordParts as integer
				set isVisible to item 3 of coordParts as string
				set AppleScript's text item delimiters to ""
				
				logMessage("Web coords - X: " & webX & ", Y: " & webY & ", Visible: " & isVisible)
				
				if isVisible is "true" then
					-- Convert to screen coordinates
					set screenX to contentLeft + webX
					set screenY to contentTop + webY - 5 -- Subtract 5 from all Y coordinates
					
					logMessage("Screen coords - X: " & screenX & ", Y: " & screenY)
					
					-- Perform the real click with verification
					performRealClickWithVerification(screenX, screenY, webX, webY)
					
					logMessage("✓ Click performed!")
					
					-- Mandatory small delay after click to let page respond
					delay 0.5
				else
					logMessage("⚠ Element exists but not visible: " & elementSelector)
				end if
			end if
			
		on error errorMessage
			logMessage("✗ Error with " & elementSelector & ": " & errorMessage)
		end try
		
		-- Random wait after each selector (0-5 seconds)
		set randomWait to (random number from minWait to maxWait)
		logMessage("Waiting " & (round (randomWait * 100) / 100) & " seconds...")
		delay randomWait
		
	end repeat
	
	if cycle < repeatCycles then
		logMessage("=== Cycle " & cycle & " completed, starting next cycle ===")
	end if
	
end repeat

logMessage("Script completed")