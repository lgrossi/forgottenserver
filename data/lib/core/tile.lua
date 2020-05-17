function Tile.isCreature(self)
	return false
end

function Tile.isItem(self)
	return false
end

function Tile.isTile(self)
	return true
end

function Tile.isContainer(self)
	return false
end

function Tile.relocateTo(self, toPosition)
	if self:getPosition() == toPosition or not Tile(toPosition) then
		return false
	end

	for i = self:getThingCount() - 1, 0, -1 do
		local thing = self:getThing(i)
		if thing then
			if thing:isItem() then
				if thing:getFluidType() ~= 0 then
					thing:remove()
				elseif ItemType(thing:getId()):isMovable() then
					thing:moveTo(toPosition)
				end
			elseif thing:isCreature() then
				thing:teleportTo(toPosition)
			end
		end
	end

	return true
end

function Tile:hasGround()
	return not self:getGround() and true or false
end

function Tile:hasAnyProperty(properties)
	for _,v in ipairs(properties) do
		if self:hasProperty(v) then
			return true
		end
	end
	return false
end

function Tile:hasAnyFlag(flags)
	for _,v in ipairs(flags) do
		if self:hasFlag(v) then
			return true
		end
	end
	return false
end

function Tile:isWalkable(pz, floorchange, block, creature)
	if self:hasGround() then return false end
	if creature and self:getCreatureCount() > 0 then return false end

	if self:hasAnyProperty({CONST_PROP_BLOCKSOLID, CONST_PROP_BLOCKPROJECTILE}) then 
		return false 
	end

	if pz and self:hasAnyFlag({TILESTATE_HOUSE, TILESTATE_PROTECTIONZONE}) then 
		return false
	end

	if floorchange and self:hasAnyFlag({TILESTATE_FLOORCHANGE}) then 
		return false
	end

	if block then
		local topStackItem = self:getTopTopItem()
		if topStackItem and topStackItem:hasProperty(CONST_PROP_BLOCKPATH) then 
			return false 
		end
	end

	local items = self:getItems()
	for _,item in ipairs(items) do
		local itemType = item:getType()
		if itemType:getType() ~= ITEM_TYPE_MAGICFIELD 
			and not itemType:isMovable() 
			and item:hasProperty(CONST_PROP_BLOCKSOLID) 
		then 
			return false 
		end
	end

	return true
end