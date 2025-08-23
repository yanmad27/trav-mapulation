-- Chrome Web Element Real Clicker - Farm List Automation
-- Gets coordinates of web elements and performs real system clicks

-- Global settings
property repeatCycles : 10000000 -- How many times to repeat the entire sequence
property showLogs : false -- Set to false to disable logging
property logToFile : false -- Set to true for file logging, false for notifications
property showConsoleOutput : false -- Set to true for real-time console output
property logFilePath : (path to me as string) & "farm_automation_log.txt"

-- Position cache settings
property positionCache : {}
property cacheTimeout : 1800 -- Cache timeout in seconds (30 minutes)
property useJSRatio : 30 -- 30% chance to call JS, 70% to use cache

-- Configuration - Browser selection 
-- Change to "Google Chrome" to use Opera browser instead of Chrome
-- Configuration - Last farm interval for adaptive timing
property lastFarmInterval : 0

-- Configuration - Selectors for various elements
property btn1 : "#btn1"
property btn2 : "#btn2"
property btn3 : "#btn3"
property building_view : "[class~=\"buildingView\"]"
property statistics : "[class~=\"statistics\"]"
property reports : "[class~=\"reports\"]"
property mark_all_read : "[value=\"Mark all as read\"]"
property confirm_button : "[class=\"textButtonV1 grey confirm negativeAction\"]"
property reports_check_element : "[class=\"messageStatus messageStatusUnread\"]"
property messages : "[class~=\"messages\"]"
property overview_link : "[href=\"/village/statistics/overview\"]"
property warehouse_link : "[href=\"/village/statistics/resources/warehouse?c=7\"]"
property hospital_link : "[href=\"/village/statistics/troops/hospital\"]"
property troops_link : "[href=\"/village/statistics/troops\"]"
property training_link : "[href=\"/village/statistics/troops/training\"]"
property smithy_link : "[href=\"/village/statistics/troops/smithy\"]"
property resources_link : "[href=\"/village/statistics/resources/resources\"]"
property culture_points_link : "[href=\"/village/statistics/culturepoints\"]"
property alliance_link : "[href=\"/alliance\"]"

property quickLink1 : "[data-dragid=\"villageListQuickLinks1\"]"
property quickLink2 : "[data-dragid=\"villageListQuickLinks2\"]"
property quickLink3 : "[data-dragid=\"villageListQuickLinks3\"]"
property quickLink4 : "[data-dragid=\"villageListQuickLinks4\"]"

property farm_list : "[data-dragid=\"villageListQuickLinks0\"]"
property trigger_all_farm_list : "[class~=\"startAllFarmLists\"]"

property n1 : "[data-did=\"42170\"]"
property cap : "[data-did=\"43231\"]"
property w1 : "[data-did=\"44812\"]"
property w2 : "[data-did=\"45786\"]"
property o1 : "[data-did=\"29561\"]"
property f1 : "[data-did=\"31324\"]"
property f2 : "[data-did=\"33344\"]"
property f3 : "[data-did=\"34922\"]"
property f4 : "[data-did=\"36334\"]"
property s1 : "[data-did=\"28791\"]"
property s2 : "[data-did=\"38304\"]"

-- List of random selectors to click between farm list triggers for human-like behavior
property random_selectors : {statistics, reports, messages, warehouse_link, overview_link, troops_link, hospital_link, smithy_link, training_link, resources_link, culture_points_link, building_view, alliance_link, quickLink1, quickLink2, quickLink3, quickLink4, cap, w1, w2}
-- Property to track the last farm interval for adaptive timing

-- Function to get random farm interval with adaptive timing based on last result
on getRandomFarmInterval()
	set baseMin to 150
	set baseMax to 280
	set baseMiddle to (baseMin + baseMax) / 2
	set range to 20

	if lastFarmInterval = 0 then
		set newInterval to random number from baseMin to baseMax
	else if lastFarmInterval > (baseMiddle + range) then
		set newInterval to random number from baseMin to baseMiddle
	else if lastFarmInterval < (baseMiddle - range) then
		set newInterval to random number from baseMiddle to baseMax
	else
		set newInterval to random number from baseMin to baseMax
	end if

	set lastFarmInterval to newInterval
	return newInterval
end getRandomFarmInterval

-- Function to select random selector from the list
on getRandomSelector()
	set randomIndex to random number from 1 to (count of random_selectors)
	return item randomIndex of random_selectors
end getRandomSelector

-- START MOUSE
-- Set the path to cliclick
property CLICLICK_PATH : "/opt/homebrew/bin/cliclick"

-- Get current mouse position
on getCurrentMousePosition()
	set mousePos to do shell script (quoted form of CLICLICK_PATH & " p")
	set AppleScript's text item delimiters to ","
	set xPos to (text item 1 of mousePos) as number
	set yPos to (text item 2 of mousePos) as number
	set AppleScript's text item delimiters to ""
	return {xPos, yPos}
end getCurrentMousePosition

-- Smooth mouse movement function with ultra-realistic human behavior
on smoothMoveTo(target_coordinates)
	set currentPos to getCurrentMousePosition()
	set startX to item 1 of currentPos
	set startY to item 2 of currentPos
	set endX to item 1 of target_coordinates
	set endY to item 2 of target_coordinates
	
	-- Calculate movement distance and complexity
	set distance to ((endX - startX) ^ 2 + (endY - startY) ^ 2) ^ 0.5
	
	-- Human fatigue and precision factors
	set fatigueLevel to random number from 0.8 to 1.2 -- Simulates tiredness
	set precisionLevel to random number from 0.7 to 1.0 -- Hand steadiness
	
	-- Adaptive steps based on distance and complexity
	if distance < 50 then
		set steps to 8 + (random number from 1 to 6) -- Short moves: 8-14 steps
	else if distance < 200 then
		set steps to 15 + (random number from 1 to 10) -- Medium: 15-25 steps
	else
		set steps to 25 + (random number from 1 to 15) -- Long: 25-40 steps
	end if
	
	-- Base timing affected by distance and fatigue
	set baseDelay to (0.002 + (distance / 10000)) * fatigueLevel
	if baseDelay > 0.01 then set baseDelay to 0.01
	
	-- Multi-segment path (humans don't move in single curves)
	set segments to 1
	if distance > 150 then set segments to 2
	if distance > 400 then set segments to 3
	
	-- Sometimes humans overshoot and correct
	set overshoot to false
	if distance > 100 and (random number from 1 to 100) < 25 then -- 25% chance
		set overshoot to true
		if endX > startX then
			set xDirection to 1
		else
			set xDirection to -1
		end if
		if endY > startY then
			set yDirection to 1
		else
			set yDirection to -1
		end if
		set overshootX to endX + (random number from 5 to 15) * xDirection
		set overshootY to endY + (random number from 5 to 15) * yDirection
	end if
	
	-- Create waypoints for complex movements
	set waypoints to {{startX, startY}}
	
	if segments > 1 then
		repeat with seg from 1 to (segments - 1)
			set wayX to startX + ((endX - startX) * (seg / segments)) + (random number from -20 to 20)
			set wayY to startY + ((endY - startY) * (seg / segments)) + (random number from -20 to 20)
			set end of waypoints to {wayX, wayY}
		end repeat
	end if
	
	if overshoot then
		set end of waypoints to {overshootX, overshootY}
	end if
	set end of waypoints to {endX, endY}
	
	-- Move through each segment
	repeat with segIndex from 1 to (count of waypoints) - 1
		set segStart to item segIndex of waypoints
		set segEnd to item (segIndex + 1) of waypoints
		set segStartX to item 1 of segStart
		set segStartY to item 2 of segStart
		set segEndX to item 1 of segEnd
		set segEndY to item 2 of segEnd
		
		set segDistance to ((segEndX - segStartX) ^ 2 + (segEndY - segStartY) ^ 2) ^ 0.5
		set segSteps to (steps * (segDistance / distance)) as integer
		if segSteps < 3 then set segSteps to 3
		
		-- Random curve parameters for this segment
		set curveIntensity to (0.03 + (random number from 0 to 0.12)) * precisionLevel
		set curveDirection to (random number from 0 to 1) * 2 - 1
		
		-- Control point for curve
		set midX to (segStartX + segEndX) / 2
		set midY to (segStartY + segEndY) / 2
		
		if segDistance > 20 then
			set offsetX to -(segEndY - segStartY) / segDistance * segDistance * curveIntensity * curveDirection
			set offsetY to (segEndX - segStartX) / segDistance * segDistance * curveIntensity * curveDirection
			set offsetX to offsetX + (random number from -8 to 8) * (1 / precisionLevel)
			set offsetY to offsetY + (random number from -8 to 8) * (1 / precisionLevel)
			set controlX to midX + offsetX
			set controlY to midY + offsetY
		else
			set controlX to midX + (random number from -3 to 3)
			set controlY to midY + (random number from -3 to 3)
		end if
		
		-- Move through this segment
		repeat with i from 1 to segSteps
			set t to i / segSteps
			
			-- Complex easing with micro-pauses (humans don't move smoothly)
			set easeT to t * t * (3 - 2 * t)
			if (random number from 1 to 100) < 8 then -- 8% chance of micro-pause
				set easeT to easeT * 0.95 -- Slight slowdown
			end if
			
			-- Bezier curve calculation
			set oneMinusT to 1 - easeT
			set currentX to (oneMinusT ^ 2 * segStartX) + (2 * oneMinusT * easeT * controlX) + (easeT ^ 2 * segEndX)
			set currentY to (oneMinusT ^ 2 * segStartY) + (2 * oneMinusT * easeT * controlY) + (easeT ^ 2 * segEndY)
			
			-- Enhanced human tremor based on speed and fatigue
			set speedFactor to segDistance / segSteps
			set tremorIntensity to (1.5 + speedFactor / 10) * (1 / precisionLevel) * fatigueLevel
			set jitterX to (random number from 0 to tremorIntensity) - (tremorIntensity / 2)
			set jitterY to (random number from 0 to tremorIntensity) - (tremorIntensity / 2)
			set currentX to currentX + jitterX
			set currentY to currentY + jitterY
			
			set coordinates_s to "=" & (currentX as integer as string) & ",=" & (currentY as integer as string)
			do shell script (quoted form of CLICLICK_PATH & " m:" & coordinates_s)
			
			-- Variable delay with occasional hesitations
			set currentDelay to baseDelay + (random number from -1.0E-3 to 0.003)
			if (random number from 1 to 100) < 5 then -- 5% chance of brief hesitation
				set currentDelay to currentDelay + (random number from 0.005 to 0.02)
			end if
			if currentDelay < 1.0E-3 then set currentDelay to 1.0E-3
			delay currentDelay
		end repeat
		
		-- Brief pause between segments
		if segIndex < (count of waypoints) - 1 then
			delay 0.01 + (random number from 0 to 0.02)
		end if
	end repeat
	
	return target_coordinates
end smoothMoveTo

-- ClickAt function with ultra-realistic human clicking behavior
on clickAt(global_coordinates)
	-- Pre-movement behavior (humans sometimes hesitate before moving)
	if (random number from 1 to 100) < 15 then -- 15% chance
		delay 0.1 + (random number from 0 to 0.3) -- Brief hesitation
	end if
	
	-- Move to target with human-like path
	smoothMoveTo(global_coordinates)
	
	-- Arrival behavior - humans don't click immediately
	set arrivalPause to 0.02 + (random number from 0 to 0.25)
	
	-- Sometimes humans realize they're slightly off target
	if (random number from 1 to 100) < 35 then -- 35% chance of adjustment
		set adjustX to random number from -4 to 4
		set adjustY to random number from -4 to 4
		set newX to (item 1 of global_coordinates) + adjustX
		set newY to (item 2 of global_coordinates) + adjustY
		set adjust_coords to "=" & (newX as string) & ",=" & (newY as string)
		do shell script (quoted form of CLICLICK_PATH & " m:" & adjust_coords)
		delay 0.01 + (random number from 0 to 0.03)
		
		-- Sometimes a second tiny adjustment
		if (random number from 1 to 100) < 20 then
			set microAdjustX to random number from -2 to 2
			set microAdjustY to random number from -2 to 2
			set microX to newX + microAdjustX
			set microY to newY + microAdjustY
			set micro_coords to "=" & (microX as string) & ",=" & (microY as string)
			do shell script (quoted form of CLICLICK_PATH & " m:" & micro_coords)
			delay 0.005 + (random number from 0 to 0.015)
		end if
	else
		-- Even without major adjustment, slight settling
		delay arrivalPause
	end if
	
	-- Pre-click micro-movements (hand tremor while preparing to click)
	if (random number from 1 to 100) < 60 then -- 60% chance
		repeat 2 + (random number from 0 to 3) times
			set tremorX to random number from -1 to 1
			set tremorY to random number from -1 to 1
			set currentX to (item 1 of global_coordinates) + tremorX
			set currentY to (item 2 of global_coordinates) + tremorY
			set tremor_coords to "=" & (currentX as string) & ",=" & (currentY as string)
			do shell script (quoted form of CLICLICK_PATH & " m:" & tremor_coords)
			delay 0.003 + (random number from 0 to 0.007)
		end repeat
	end if
	
	-- Final positioning and click
	set coordinates_s to "=" & ((item 1 of global_coordinates) div 1 as string) & ",=" & ((item 2 of global_coordinates) div 1 as string)
	do shell script (quoted form of CLICLICK_PATH & " c:" & coordinates_s)
	
	-- Post-click behavior (sometimes humans linger briefly)
	if (random number from 1 to 100) < 25 then -- 25% chance
		delay 0.01 + (random number from 0 to 0.05)
		-- Tiny post-click movement
		set postX to (item 1 of global_coordinates) + (random number from -2 to 2)
		set postY to (item 2 of global_coordinates) + (random number from -2 to 2)
		set post_coords to "=" & (postX as string) & ",=" & (postY as string)
		do shell script (quoted form of CLICLICK_PATH & " m:" & post_coords)
	end if
	
	return global_coordinates
end clickAt

-- MouseMove function with smooth movement
on mouseMoveTo(global_coordinates)
	smoothMoveTo(global_coordinates)
	return global_coordinates
end mouseMoveTo

-- END MOUSE
-- Function to refresh Chrome page
on refreshChrome()
	tell application "Google Chrome"
		tell active tab of front window
			reload
		end tell
	end tell
end refreshChrome

-- Function to get current timestamp
on getCurrentTimestamp()
	set epoch to date "Thursday, January 1, 1970 at 12:00:00 AM"
	return (current date) - epoch
end getCurrentTimestamp

-- Function to clean expired cache entries
on cleanExpiredCache()
	set currentTime to getCurrentTimestamp()
	set newCache to {}
	repeat with cacheItem in positionCache
		set cacheTime to item 3 of cacheItem
		if (currentTime - cacheTime) < cacheTimeout then
			set end of newCache to cacheItem
		end if
	end repeat
	set positionCache to newCache
end cleanExpiredCache

-- Function to find cached position
on getCachedPosition(selector)
	cleanExpiredCache()
	repeat with cacheItem in positionCache
		if item 1 of cacheItem is selector then
			return item 2 of cacheItem
		end if
	end repeat
	return null
end getCachedPosition

-- Function to cache position
on cachePosition(selector, position)
	set currentTime to getCurrentTimestamp()
	set newCacheItem to {selector, position, currentTime}
	
	-- Remove existing cache entry for this selector
	set newCache to {}
	repeat with cacheItem in positionCache
		if item 1 of cacheItem is not selector then
			set end of newCache to cacheItem
		end if
	end repeat
	
	-- Add new cache entry
	set end of newCache to newCacheItem
	set positionCache to newCache
end cachePosition

-- Function to get element position from Chrome with caching
on getElementPosition(selector)
	-- Check if we should use cache (70% chance) or call JS (30% chance)
	set shouldUseJS to (random number from 1 to 100) <= useJSRatio
	
	-- Try to get cached position first (if not forcing JS call)
	if not shouldUseJS then
		set cachedPos to getCachedPosition(selector)
		if cachedPos is not null then
			logMessage("Using cached position for " & selector & ": " & cachedPos)
			return cachedPos
		end if
	end if
	
	-- Call JavaScript to get fresh position
	tell application "Google Chrome"
		tell active tab of front window
			-- JavaScript to get element center coordinates relative to viewport
			set jsCode to "
				(function() {
					var selector = '" & selector & "';
					var xDiff = 2;
					if (selector.includes('data-did')) xDiff = 10;
					var element = document.querySelector(selector);
					if (!element) return 'null';
					var rect = element.getBoundingClientRect();
					var x = Math.round(rect.left + rect.width / xDiff);
					var y = Math.round(rect.top + rect.height / 2);
					var visible = rect.width > 0 && rect.height > 0;

					return x + ',' + y + ',' + visible;
				})();
			"
			set result to execute javascript jsCode
			
			-- Cache the result if it's not null
			if result is not "null" then
				cachePosition(selector, result)
				logMessage("JS call for " & selector & " - cached result: " & result)
			else
				logMessage("JS call for " & selector & " - element not found")
			end if
			
			return result
		end tell
	end tell
end getElementPosition

-- Function to perform real click with verification
on performRealClickWithVerification(screenX, screenY, webX, webY)
	clickAt({screenX, screenY})
end performRealClickWithVerification

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

-- Function to click a specific element with human-like behavior
on clickElement(elementSelector)
	try
		-- Get current element position
		set elementPos to getElementPosition(elementSelector)
		
		logMessage("Element position for " & elementSelector & ": " & elementPos)
		
		if elementPos is "null" or elementPos is missing value then
			logMessage("Element NOT FOUND: " & elementSelector)
			return false
		else
			-- Parse coordinates from comma-separated string
			set AppleScript's text item delimiters to ","
			set coordParts to text items of elementPos
			set webX to item 1 of coordParts as integer
			set webY to item 2 of coordParts as integer
			set isVisible to item 3 of coordParts as string
			set AppleScript's text item delimiters to ""
			
			if isVisible is "true" then
				-- Add small random offset to avoid perfect clicks (-5 to +5 pixels)
				set randomOffsetX to (random number from -5 to 5)
				set randomOffsetY to (random number from -5 to 5)
				
				-- Convert to screen coordinates with random offset
				set contentOffset to getChromeContentOffset()
				set contentLeft to item 1 of contentOffset
				set contentTop to item 2 of contentOffset
				set screenX to contentLeft + webX + randomOffsetX
				set screenY to contentTop + webY - 5 + randomOffsetY -- Subtract 5 from all Y coordinates, add random offset
				
				-- Perform the real click
				performRealClickWithVerification(screenX, screenY, webX, webY)
				logMessage("Click performed on " & elementSelector)
				
				-- Special handling for reports - check custom element before marking all read
				if elementSelector is reports then
					delay 5 -- Wait for reports page to load
					
					-- Check if custom element exists and is visible
					set customElementPos to getElementPosition(reports_check_element)
					if customElementPos is not "null" and customElementPos is not missing value then
						-- Parse custom element coordinates to check visibility
						set AppleScript's text item delimiters to ","
						set customCoordParts to text items of customElementPos
						set customIsVisible to item 3 of customCoordParts as string
						set AppleScript's text item delimiters to ""
						
						if customIsVisible is "true" then
							logMessage("Reports check element is visible - proceeding with mark all read")
							
							-- Get mark all read position and click directly
							set markAllReadPos to getElementPosition(mark_all_read)
							if markAllReadPos is not "null" and markAllReadPos is not missing value then
								set AppleScript's text item delimiters to ","
								set markCoordParts to text items of markAllReadPos
								set markWebX to item 1 of markCoordParts as integer
								set markWebY to item 2 of markCoordParts as integer
								set AppleScript's text item delimiters to ""
								
								-- Click mark all read
								set markScreenX to contentLeft + markWebX + (random number from -3 to 3)
								set markScreenY to contentTop + markWebY - 5 + (random number from -3 to 3)
								performRealClickWithVerification(markScreenX, markScreenY, markWebX, markWebY)
								logMessage("Mark all read clicked!")
								delay 2
								
								-- Get confirm button position and click directly
								set confirmPos to getElementPosition(confirm_button)
								if confirmPos is not "null" and confirmPos is not missing value then
									set AppleScript's text item delimiters to ","
									set confirmCoordParts to text items of confirmPos
									set confirmWebX to item 1 of confirmCoordParts as integer
									set confirmWebY to item 2 of confirmCoordParts as integer
									set AppleScript's text item delimiters to ""
									
									set confirmScreenX to contentLeft + confirmWebX + (random number from -3 to 3)
									set confirmScreenY to contentTop + confirmWebY - 5 + (random number from -3 to 3)
									performRealClickWithVerification(confirmScreenX, confirmScreenY, confirmWebX, confirmWebY)
									logMessage("Confirm clicked!")
								end if
							end if
						else
							logMessage("Reports check element found but not visible - skipping mark all read")
						end if
					else
						logMessage("Reports check element not found - skipping mark all read")
					end if
				end if
				
				-- Random post-click movement (humans often move mouse after clicking)
				if (random number from 1 to 100) < 70 then -- 70% chance of post-click movement
					set moveType to random number from 1 to 3
					if moveType is 1 then
						-- Small random movement near the click area
						set randomMoveX to screenX + (random number from -30 to 30)
						set randomMoveY to screenY + (random number from -30 to 30)
					else if moveType is 2 then
						-- Move to a random area of the screen
						set randomMoveX to random number from 200 to 1200
						set randomMoveY to random number from 200 to 800
					else
						-- Move slightly away and back (hesitation behavior)
						set awayX to screenX + (random number from -50 to 50)
						set awayY to screenY + (random number from -50 to 50)
						smoothMoveTo({awayX, awayY})
						delay 0.1 + (random number from 0 to 0.3)
						set randomMoveX to screenX + (random number from -15 to 15)
						set randomMoveY to screenY + (random number from -15 to 15)
					end if
					
					-- Perform the random movement
					smoothMoveTo({randomMoveX, randomMoveY})
					logMessage("Random post-click movement to: " & randomMoveX & "," & randomMoveY)
				end if
				
				-- Small delay after click
				delay 0.5 + (random number from 0 to 1)
				return true
			else
				logMessage("Element exists but not visible: " & elementSelector)
				return false
			end if
		end if
	on error errorMessage
		logMessage("Error with " & elementSelector & ": " & errorMessage)
		return false
	end try
end clickElement

-- Make sure Chrome is active and frontmost
tell application "Google Chrome"
	activate
	delay 0.5
end tell

logMessage("=== Starting Farm List Automation ===")

-- Main automation loop
repeat with cycle from 1 to repeatCycles
	logMessage("=== Starting cycle " & cycle & " of " & repeatCycles & " ===")
	
	refreshChrome()
	delay 5 + (random number from 1 to 5)

	-- Click farm list to navigate there
	logMessage("Navigating to farm list...")
	clickElement(farm_list)
	delay 10 + (random number from 1 to 5)
	
	-- Trigger all farm lists
	logMessage("Triggering all farm lists...")
	if clickElement(trigger_all_farm_list) then
		logMessage("Farm lists triggered successfully!")
	else
		logMessage("Failed to trigger farm lists")
		refreshChrome()
		delay 5 + (random number from 1 to 5)
		if clickElement(trigger_all_farm_list) then
			logMessage("Farm lists triggered successfully!")
		else 
			logMessage("Failed to trigger farm lists")
			refreshChrome()
			delay 5 + (random number from 1 to 5)
			clickElement(trigger_all_farm_list)
		end if
	end if
	delay 1 + (random number from 0 to 2)
	
	-- Get random interval for next farm trigger (4-7 or 3-6 minutes)
	set farmInterval to getRandomFarmInterval()
	logMessage("Next farm trigger in " & farmInterval & " seconds (" & (farmInterval / 60) & " minutes)")
	
	-- Perform random clicks during the wait period
	set currentTime to 0
	set clickInterval to 15 + (random number from 5 to 25) -- Random clicks every 15-40 seconds
	
	repeat while currentTime < farmInterval
		if currentTime > 0 and (currentTime mod clickInterval) = 0 then
			-- Select random element to click
			set randomSelector to getRandomSelector()
			logMessage("Random click on: " & randomSelector)
			clickElement(randomSelector)
			-- Reset click interval for next random click
			set clickInterval to 15 + (random number from 5 to 25)
		end if
		
		-- Wait 1 second
		delay 1
		set currentTime to currentTime + 1
	end repeat
	
	if cycle < repeatCycles then
		logMessage("=== Cycle " & cycle & " completed, starting next cycle ===")
	end if
end repeat

logMessage("Farm List Automation completed")