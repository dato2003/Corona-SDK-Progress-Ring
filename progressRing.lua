-- progressRing Module for Corona SDK
-- Copyright (c) 2017 
-- Author: Arjorie Sotelo
-- http://www.mobitutz.com

local M = {}
local floor = math.floor
local ceil = math.ceil
local random = math.random
local abs = math.abs
local round = math.round
local unpack = unpack
math.randomseed( os.time() )
 
-- These files are high-resolution images which may affect performance if loaded normally
local filenames = {
    "circle_50",
    "circle_100",
    "circle_200",
    "circle_300",
    "circle_400",
    "circle_500",
    "circle_600",
    "circle_700",
    "circle_800",
}
 
-- Pre-load textures to memory
local textures = {}
for i = 1,#filenames do
    textures[filenames[i]] = graphics.newTexture(
        {
            type = "image",
            filename = "ringSrc/"..filenames[i]..".png",
            baseDir = system.ResourceDirectory
        })
    textures[filenames[i]]:preload()
end

-- tagname for transitions
M.tagName = "ringProgress_"

-- tagname counter
M.tagNameCounter = 1

M.new = function ( params )
	local group = display.newGroup( ); group.anchorChildren = true
	-- params and defaults
	local params = params or {}
	-- for label
	local label = params.label or ""
	local font = params.font or native.systemFont
	local fontSize = params.fontSize or 40
	local syncLabelToProgress = params.syncLabelToProgress
	-- for ring object
	local radius = params.radius or 200; 
	local depth = params.ringDepth or 0; 
	local position = params.position or 0; 
	local ringColor = params.ringColor or {1, 1, 1, 1}
	local bgColor = params.bgColor or {0.5, 0.5, 0.5, 1}
	local foregroundColor = params.foregroundColor or {0.3, 0.3, 0.3, 1}
	local strokeColor = params.strokeColor or bgColor
	local strokeWidth = params.strokeWidth
	local tmr
	local tmrDelay
	-- for transition tag name
	M.tagNameCounter = M.tagNameCounter + 1
	local tagName = M.tagName..M.tagNameCounter
	--------------------------------
	-- constants
	local revolution = 361 -- number of slices that creates the ring
	local maxSize = 800
	local minSize = 50
	-- other references
	local size = radius * 2;
	local depthSize = size * depth;
	-- restrictions
	if (position > 1) then position = 1 elseif (position < 0) then position = 0 end;
	if (depth > 1) then depth = 1 elseif (depth <= 0) then depth = 0.01 end; 
	if size > maxSize then size = maxSize elseif size < minSize then size = minSize end
	if depthSize > maxSize then depthSize = maxSize elseif depthSize < minSize then depthSize = minSize end
	-- back up reference
	local endPosition = ceil(revolution * position) + 1
	local origPosition = position
	local ringProgress = position
	local origEndPosition = endPosition
	local origLabel = label
	-- visual references
	local sliceGroup = display.newGroup( )
	local ring
	local ringBg 
	local ringDepth
	local ringSlices = {}
	local ringStroke
	local ringFilename
	local maskFilename
	local scaledSize
	local ringBaseDir
	local depthFilename
	local maskObject
	local labelText 
	--------------------------------
	--
	-- Functions
	--
	--------------------------------
	local setSlices
	local getFilename
	-- choose the circle image to display by size
	getFilename = function ( SIZE )
		local ringFilename = ""
		local maskFilename = ""
		local tempSize = ""
		local maskBaseDir = system.ResourceDirectory
		local ringBaseDir = system.ResourceDirectory
		local SIZE = round(SIZE)
		local strSize = tostring(SIZE)
		if (SIZE >= maxSize) then
			ringFilename = textures["circle_"..maxSize].filename
			ringBaseDir = textures["circle_"..maxSize].baseDir
			maskFilename = "ringSrc/mask_"..maxSize..".png"
		elseif (SIZE <= minSize) then
			ringFilename = textures["circle_"..minSize].filename
			ringBaseDir = textures["circle_"..minSize].baseDir
			maskFilename = "ringSrc/mask_"..minSize..".png"
		else 
			if (SIZE >= 100) then
				for i=1,#strSize do
					if (i>1) then
						tempSize = tempSize..0
					else
						tempSize = strSize:sub(i,i)
					end
				end
			elseif (SIZE < 100 and SIZE >= 80) then
				tempSize = 100
			elseif (SIZE < 80) then
				tempSize = 50
			end
			strSize = tempSize
			ringFilename = textures["circle_"..strSize].filename
			ringBaseDir = textures["circle_"..strSize].baseDir
			maskFilename = "ringSrc/mask_"..strSize..".png"
		end
		tempSize = tonumber( tempSize ) or SIZE
		return ringFilename, maskFilename, tempSize, ringBaseDir
	end

	-- show and set slices
	setSlices = function(  )
		for i=1,revolution do
			if (i < endPosition) then
				ringSlices[i].alpha = 1
				if (i < endPosition - 1) then
					ringSlices[i].path.x4 = 5
					ringSlices[i].path.y4 = 5
				else
					ringSlices[i].path.x4 = 0
					ringSlices[i].path.y4 = 0
				end
			else
				ringSlices[i].alpha = 0
			end
		end
	end
	--------------------------------
	--
	-- visuals
	--
	--------------------------------

	-- get filenames, baseDir and sizes
	ringFilename, maskFilename, scaledSize, ringBaseDir = getFilename(size)
	depthFilename = getFilename(depthSize) 
	maskObject = graphics.newMask( maskFilename )

	-- stroke ring
	if (strokeWidth) then
		ringStroke = display.newImageRect( group, ringFilename, ringBaseDir, size + strokeWidth, size + strokeWidth )
		ringStroke:setFillColor( unpack(strokeColor) )
	end

	-- background ring
	ringBg = display.newImageRect( group, ringFilename, ringBaseDir, size, size )
	ringBg:setFillColor( unpack(bgColor) )

	-- slices 
	for i=1,revolution do
		ringSlices[i] = display.newRect( sliceGroup, 0, 0, 5, radius + 10 )
		ringSlices[i]:setFillColor( unpack(ringColor) )
		ringSlices[i].anchorY = 1
		ringSlices[i].rotation = (i -1)
		ringSlices[i].alpha = 0
	end
	sliceGroup.x = ringBg.x
	sliceGroup.y = ringBg.y
	sliceGroup:setMask( maskObject )

	-- get scale factor and set the mask to match the slices view to the ring bg
	local scale = size / scaledSize
	sliceGroup.maskScaleX = sliceGroup.maskScaleX * (scale)
	sliceGroup.maskScaleY = sliceGroup.maskScaleY * (scale)
	group:insert(sliceGroup)

	-- ring depth; center circle
	ringDepth = display.newImageRect( group, depthFilename, ringBaseDir, depthSize, depthSize )
	ringDepth:setFillColor( unpack(foregroundColor) )
	if (depth <= 0.01) then ringDepth.isVisible = false end

	-- label of the progress ring
	labelText = display.newText( {
		parent = group,
		text = label,
		width = ringDepth.width - 40,
		align = "center",
		font = font,
		fontSize = fontSize,
		x = ringDepth.x,
		y = ringDepth.y
	} )


	-- set and show the slices 
	setSlices()
	--------------------------------
	--
	-- Methods
	--
	--------------------------------
	-- progress animation of the ring
	local customTime = 0
	function group:progress( progress, params )
		-- params
		local params = params or {}
		local time = params.time or 1000
		local delay = params.delay or 0
		local onComplete = params.onComplete or function(e) end
		local progress = progress; if progress < 0 then progress = 0 elseif progress > 1 then progress = 1 end
		local progressPosition = ceil(revolution * progress); if (progress ~= 0) then progressPosition = progressPosition end
		local range = abs(progressPosition - endPosition)
		-- local customTime = round(time/range) -- Im having problem with time for transitions
		-- local customTime = 1000
		local increment = 1 -- progressing

		-- rolling back
		if (endPosition > progressPosition) then
			increment = -1
			endPosition = endPosition - 1
		end

		local function animate(  )
			local customTime = 0
			local obj = ringSlices[endPosition]
			if (obj) then
				if (obj.alpha == 1) then
					transition.to(obj.path, {x4 = 5, y4 = 5, time = customTime, tag = tagName})
					transition.to(obj, {alpha = 0, time = customTime, tag = tagName})

				-- hiding a slice
				else
					transition.to(obj.path, {x4 = 0, y4 = 0, time = customTime, tag = tagName})
					transition.to(obj, {alpha = 1, time = customTime, tag = tagName})
				end

			end
			setSlices() -- set slices

			-- check if position got reached the progress position
			if (endPosition == progressPosition) then
				-- if clockwise
				if (increment == 1) then
					if (ringSlices[endPosition - 1]) then
						ringSlices[endPosition - 1].path.x4 = 5
						ringSlices[endPosition - 1].path.y4 = 5
					end
				-- if counter-clockwise
				else
					if (ringSlices[endPosition + 1]) then
						ringSlices[endPosition + 1].path.x4 = 0
						ringSlices[endPosition + 1].path.y4 = 0
					end
					if (ringSlices[endPosition - 1]) then
						ringSlices[endPosition - 1].path.x4 = 5
						ringSlices[endPosition - 1].path.y4 = 5
					end
				end
				-- call external function
				onComplete()
				-- cancel timer
				if (tmr) then
					timer.cancel( tmr )
					tmr = nil
				end
				return true
			end
			-- increment position
			endPosition = endPosition + increment
			-- update ring progress
			if (syncLabelToProgress) then
				local floatProgress = (endPosition / revolution) * 100
				ringProgress = string.format( "%1.0f", floatProgress ).."%"
				group:setLabel(ringProgress)
			end
		end

		-- start animation if the end position and progress position are not the same
		if (endPosition ~= progressPosition) then
			-- stop the animation if already animating
			group:stop()
			-- start new animation
			tmrDelay = timer.performWithDelay( delay, function (  )
				if (tmrDelay) then
					timer.cancel( tmrDelay )
					tmrDelay = nil
				end
				tmr = timer.performWithDelay( 1, function(  )
					-- i use a loop to make the animation much faster though I'm aware that there is something wrong with my code
					-- for i=1,4 do
						local result = animate()
						-- if (result) then
							-- break;
						-- end
					-- end
				end, -1 )
			end )
		end
	end

	function group:setSyncLabelToProgress( val )
		if (tostring(val) == true) then
			syncLabelToProgress = true
		elseif (not val) then
			syncLabelToProgress = false
		else
			syncLabelToProgress = false
		end
	end

	-- set a new value for the label text
	function group:setLabel( val )
		labelText.text = tostring(val)
	end

	-- returns the value of the label text
	function group:getLabel(  )
		return labelText.text	
	end

	-- returns the progress of the ring
	function group:getProgress(  )
		return labelText.text	
	end

	-- pause the animation of the ring
	function group:pause(  )
		setSlices()
		transition.pause( tagName )
		-- pause timer
		if (tmr) then
			timer.pause( tmr )
		end
		-- pause timer
		if (tmrDelay) then
			timer.pause( tmrDelay )
		end
	end

	-- stop the animation of the ring
	function group:stop(  )
		setSlices()
		transition.cancel( tagName )
		-- cancel timer
		if (tmr) then
			timer.cancel( tmr )
		end
		-- cancel timer
		if (tmrDelay) then
			timer.cancel( tmrDelay )
		end
	end

	-- resume the animation of the ring
	function group:resume(  )
		setSlices()
		transition.resume( tagName )
		-- resume timer
		if (tmr) then
			timer.resume( tmr )
		end
		-- resume timer
		if (tmrDelay) then
			timer.resume( tmrDelay )
		end
	end

	-- reset the animation of the ring
	function group:reset(  )
		transition.cancel( tagName )
		-- cancel timer
		if (tmr) then
			timer.cancel( tmr )
			tmr = nil
		end
		-- cancel timer
		if (tmrDelay) then
			timer.cancel( tmrDelay )
			tmrDelay = nil
		end
		position = origPosition
		endPosition = origEndPosition
		label = origLabel
		labelText.text = label
		setSlices()
	end

	-- remove all display objects
	function group:removeSelf( )
		-- stop transitions and reset
		group:stop()
		-- remove mask
		sliceGroup:setMask(nil)
		maskObject = nil
		-- remove progress ring visuals
		if (ringStroke) then
			ringStroke:removeSelf( ); ringStroke = nil;
		end
		labelText:removeSelf( ); labelText = nil;
		ringBg:removeSelf( ); ringBg = nil;
		ringDepth:removeSelf( ); ringDepth = nil;
		for i=1,#ringSlices do
			ringSlices[i]:removeSelf( ); ringSlices[i] = nil;
		end
	end

	return group 
end

return M