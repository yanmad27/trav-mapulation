-- Chrome Web Element Real Clicker
-- Gets coordinates of web elements and performs real system clicks

-- Configuration - Edit these values as needed
-- Selector variables for easy maintenance
property building_view : "[class~=\"buildingView\"]"
property statistics : "[class~=\"statistics\"]"
property reports : "[class~=\"reports\"]"
property mark_all_read : "[value=\"Mark all as read\"]"
property confirm_button : "[class=\"textButtonV1 grey confirm negativeAction\"]"
property messages : "[class~=\"messages\"]"
property overview_link : "[href=\"/village/statistics/overview\"]"
property warehouse_link : "[href=\"/village/statistics/resources/warehouse?c=7\"]"
property hospital_link : "[href=\"/village/statistics/troops/hospital\"]"
property troops_link : "[href=\"/village/statistics/troops\"]"
property training_link : "[href=\"/village/statistics/troops/training\"]"
property smithy_link : "[href=\"/village/statistics/troops/smithy\"]"
property resources_link : "[href=\"/village/statistics/resources/resources\"]"
property culture_points_link : "[href=\"/village/statistics/culturepoints\"]"
property farm_list : "[data-dragid=\"villageListQuickLinks0\"]"
property trigger_all_farm_list : "[class~=\"startAllFarmLists\"]"

-- List of selectors with individual wait times {selector, waitTime}
property selector_list : { ¬
	{building_view, 5}, ¬
	{statistics, 5}, ¬
	{reports, 5}, {mark_all_read, 1}, {confirm_button, 5}, ¬
	{messages, 5}, ¬
	{overview_link, 5}, ¬
	{warehouse_link, 5}, ¬
	{hospital_link, 5}, ¬
	{troops_link, 5}, ¬
	{training_link, 5}, ¬
	{smithy_link, 5}, ¬
	{resources_link, 5}, ¬
	{culture_points_link, 5}, ¬
	{farm_list, 5}, ¬
	{trigger_all_farm_list, 15}, ¬
	{building_view, 250}, ¬
	{statistics, 5}, ¬
	{reports, 5}, {mark_all_read, 1}, {confirm_button, 5}, ¬
	{messages, 5}, ¬
	{overview_link, 5}, ¬
	{warehouse_link, 5}, ¬
	{hospital_link, 5}, ¬
	{troops_link, 5}, ¬
	{training_link, 5}, ¬
	{smithy_link, 5}, ¬
	{resources_link, 5}, ¬
	{culture_points_link, 5}, ¬
	{farm_list, 5}, ¬
	{trigger_all_farm_list, 15}, ¬
	{building_view, 250} ¬
}

-- Global settings
property repeatCycles : 10000 -- How many times to repeat the entire sequence
property minWait : 5 -- Minimum wait time (seconds) - back to 0
property maxWait : 10 -- Maximum wait time (seconds)
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

-- Function to add click listeners for verification
on addClickListeners()
	tell application "Google Chrome"
		tell active tab of front window
			set jsCode to "
				if (!window.clickListenersAdded) {
					document.addEventListener('click', function(e) {
						// Silent click detection
					}, true);
					window.clickListenersAdded = true;
				}
			"
			execute javascript jsCode
		end tell
	end tell
end addClickListeners

-- Function to check element visibility and position
on checkElementDetails(selector)
	tell application "Google Chrome"
		tell active tab of front window
			set jsCode to "
				(function() {
					var element = document.querySelector('" & selector & "');
					if (!element) return 'Element not found';
					var rect = element.getBoundingClientRect();
					var style = window.getComputedStyle(element);
					return 'Element: ' + element.tagName + '#' + element.id + 
					       ', Rect: ' + Math.round(rect.left) + ',' + Math.round(rect.top) + ',' + Math.round(rect.width) + ',' + Math.round(rect.height) +
					       ', Visible: ' + (rect.width > 0 && rect.height > 0) + 
					       ', Display: ' + style.display + 
					       ', Visibility: ' + style.visibility;
				})();
			"
			set result to execute javascript jsCode
			return result
		end tell
	end tell
end checkElementDetails

-- Function to log click attempt
on logClickAttempt(selector, screenX, screenY, webX, webY)
	tell application "Google Chrome"
		tell active tab of front window
			set jsCode to "
				var element = document.querySelector('" & selector & "');
				if (element) {
					// Dispatch a synthetic click event
					var event = new MouseEvent('click', {
						view: window,
						bubbles: true,
						cancelable: true,
						clientX: " & webX & ",
						clientY: " & webY & "
					});
					element.dispatchEvent(event);
				}
			"
			execute javascript jsCode
		end tell
	end tell
end logClickAttempt

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

-- Add click listeners for verification
addClickListeners()

-- Get Chrome content area offset
set contentOffset to getChromeContentOffset()
set contentLeft to item 1 of contentOffset
set contentTop to item 2 of contentOffset

logMessage("Chrome window offset - Left: " & contentLeft & ", Top: " & contentTop)

-- Repeat the entire sequence
repeat with cycle from 1 to repeatCycles
	logMessage("=== Starting cycle " & cycle & " of " & repeatCycles & " ===")
	
	-- Process each selector in order
	repeat with i from 1 to count of selector_list
		set selectorData to item i of selector_list
		set elementSelector to item 1 of selectorData
		set waitTime to item 2 of selectorData
		
		logMessage("Processing selector " & i & ": " & elementSelector & " (wait: " & waitTime & "s)")
		
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
					
					-- Log the click attempt with JavaScript
					logClickAttempt(elementSelector, screenX, screenY, webX, webY)
					
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
		
		-- Calculate random wait time (minWait to maxWait) plus selector wait
		set randomWait to (random number from minWait to maxWait)
		set totalWait to randomWait + waitTime
		logMessage("Waiting " & totalWait & " seconds (random: " & randomWait & " + selector: " & waitTime & ")...")
		delay totalWait
		
	end repeat
	
	if cycle < repeatCycles then
		logMessage("=== Cycle " & cycle & " completed, starting next cycle ===")
	end if
	
end repeat

logMessage("Script completed")