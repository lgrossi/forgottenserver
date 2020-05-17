Position.directionOffset = {
	[DIRECTION_NORTH] = {x = 0, y = -1},
	[DIRECTION_EAST] = {x = 1, y = 0},
	[DIRECTION_SOUTH] = {x = 0, y = 1},
	[DIRECTION_WEST] = {x = -1, y = 0},
	[DIRECTION_SOUTHWEST] = {x = -1, y = 1},
	[DIRECTION_SOUTHEAST] = {x = 1, y = 1},
	[DIRECTION_NORTHWEST] = {x = -1, y = -1},
	[DIRECTION_NORTHEAST] = {x = 1, y = -1}
}

function Position:getNextPosition(direction, steps)
	local offset = Position.directionOffset[direction]
	if offset then
		steps = steps or 1
		self.x = self.x + offset.x * steps
		self.y = self.y + offset.y * steps
	end
end

function Position:getPosByDir(direction, steps)
	local offset = Position.directionOffset[direction]
	if offset then
		steps = steps or 1
		return Position(self.x + offset.x * steps, self.y + offset.y * steps, self.z)
	end
	return self
end

function Position:moveUpstairs()
	local swap = function (lhs, rhs)
		lhs.x, rhs.x = rhs.x, lhs.x
		lhs.y, rhs.y = rhs.y, lhs.y
		lhs.z, rhs.z = rhs.z, lhs.z
	end

	self.z = self.z - 1

	local defaultPosition = self + Position.directionOffset[DIRECTION_SOUTH]
	local toTile = Tile(defaultPosition)
	if not toTile or not toTile:isWalkable() then
		for direction = DIRECTION_NORTH, DIRECTION_NORTHEAST do
			if direction == DIRECTION_SOUTH then
				direction = DIRECTION_WEST
			end

			local position = self + Position.directionOffset[direction]
			toTile = Tile(position)
			if toTile and toTile:isWalkable() then
				swap(self, position)
				return self
			end
		end
	end
	swap(self, defaultPosition)
	return self
end

function Position:isInRange(from, to)
	-- No matter what corner from and to is, we want to make
	-- life easier by calculating north-west and south-east
	local zone = {
		nW = {
			x = (from.x < to.x and from.x or to.x),
			y = (from.y < to.y and from.y or to.y),
			z = (from.z < to.z and from.z or to.z)
		},
		sE = {
			x = (to.x > from.x and to.x or from.x),
			y = (to.y > from.y and to.y or from.y),
			z = (to.z > from.z and to.z or from.z)
		}
	}

	if  self.x >= zone.nW.x and self.x <= zone.sE.x
	and self.y >= zone.nW.y and self.y <= zone.sE.y
	and self.z >= zone.nW.z and self.z <= zone.sE.z then
		return true
	end
	return false
end

function Position:notifySummonAppear(summon)
	local spectators = Game.getSpectators(self)
	for _, spectator in ipairs(spectators) do
		if spectator:isMonster() and spectator ~= summon then
			spectator:addTarget(summon)
		end
	end
end

function Position:getPositionsAround()
	local positions = {}
	for i,v in ipairs(Position.directionOffset) do
		positions[i] = Position(self.x + v.x, self.y + v.y, self.z)
	end
	return positions
end

function Position:getDirectionTo(toPos)
	local dir = DIRECTION_NORTH
	if (self.x > toPos.x) then
		dir = DIRECTION_WEST
		if(self.y > toPos.y) then
				dir = DIRECTION_NORTHWEST
		elseif(self.y < toPos.y) then
				dir = DIRECTION_SOUTHWEST
		end
	elseif (self.x < toPos.x) then
		dir = DIRECTION_EAST
		if(self.y > toPos.y) then
				dir = DIRECTION_NORTHEAST
		elseif(self.y < toPos.y) then
				dir = DIRECTION_SOUTHEAST
		end
	else
		if (self.y > toPos.y) then
			dir = DIRECTION_NORTH
		elseif(self.y < toPos.y) then
			dir = DIRECTION_SOUTH
		end
	end
	return dir
end