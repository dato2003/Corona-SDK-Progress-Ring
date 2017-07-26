-- progressRing Module for Corona SDK
-- Copyright (c) 2017 
-- Author: Arjorie Sotelo
-- http://www.mobitutz.com

------------------------------
-- HOW TO USE IT
------------------------------

local progressRing = require("progressRing") -- require the module

local loadingRing = progressRing.new({			
	-- label object 
	label = "Loading...", -- the text for the label
	font = native.systemFont, -- font of the label
	fontSize = 40, -- font size of the label
	syncLabelToProgress = true, -- updates the label with the progress of the ring
	-- ring object
	radius = 180, -- Value Integer (any value from 50px to 800px); radius of the progress ring
	bgColor = {0.23, 0.09, 0.43}, -- Value RGBA;  background color of the ring
	ringColor = {0.23, 0.24, 0.43}, -- Value RGBA;  progress ring color
	foregroundColor = {0.3, 0.23, 0.8}, -- Value RGBA;  center circle color; (depth color)
	strokeColor = {0.3, 0.23, 0.8}, -- Value RGBA; stroke color
	strokeWidth = 40, -- Value integer; stroke width
	ringDepth = 0.8, -- Value: 0-1; ring depth; the size of the circle in the center
	position = 0.5 -- Value: 0-1; the position of the progress by percent; example: 50% is 0.5 and 0% is 0;
	})
loadingRing.x = display.contentCenterX
loadingRing.y = display.contentCenterY - 400

function loadingRing:touch( e )
	if (e.phase == "began") then
		if (self.isPaused) then
			self:resume() -- resume method; resumes the animation 
			self.isPaused = nil
		else 
			self:pause() -- pause method; pause the animation
			self.isPaused = true
		end
	end
	return true
end
loadingRing:addEventListener( "touch", loadingRing )

local function removeRing(  )
	print( "Complete!" )
	loadingRing:removeSelf( ) -- removes the progress ring object
end

local function rollBack(  )
	print( "Rolling back!" )
	loadingRing:setSyncLabelToProgress( false ) -- disable the update of the label with the progress percentage
	local label = loadingRing:getLabel( ) -- returns the label text
	print( label )
	loadingRing:setLabel( "Rolling Back!" ) -- updates the label of the progress ring
	loadingRing:reset() -- resets to the initial state
	loadingRing:progress(0, {onComplete = removeRing}) -- animates the progress ring
end

loadingRing:progress(0, {onComplete = rollBack}) -- animates the progress ring

-- loadingRing:progress(progress, {onComplete}) -- animates the progress ring
-- accepts the following 
	-- progress - accepts 0 - 1 value; the position of the progress ring 
	-- onComplete - a callback function called when the animation is complete 


---------------------------------------
-- no circle inside
---------------------------------------
local pr = progressRing.new({
	-- ring object
	radius = 480, 
	bgColor = {0.83, 0.09, 0.3}, 
	ringColor = {0.93, 0.19, 0.4}, 
	position = 0
	})
pr.x = loadingRing.x
pr.y = loadingRing.y + 600

pr:progress(1)

function pr:touch( e )
	if (e.phase == "began") then
		if (self.reverse) then
			pr:progress(1)
			self.reverse = nil
		else 
			pr:progress(0)
			self.reverse = true
		end
	end
	return true
end
pr:addEventListener( "touch", pr )