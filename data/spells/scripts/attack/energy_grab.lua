local grab_time = 350

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ENERGYAREA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ENERGY)
combat:setParameter(COMBAT_FORMULA_LEVELMAGIC, -1, -10, -1, -20, 5, 5, 1.4, 2.1)

function onTargetCreature(creature, target)
	lockCreatures(creature, target, true)
	addEvent(executeGrab, grab_time, creature:getId(), target:getId())
end

combat:setCallback(CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")

function executeGrab(cid, tid, param)
	local creature = Creature(cid)
	local target = Creature(tid)
	if not creature or not target or not creature:isPlayer() then return false end
	
	local tPos, cPos = target:getPosition(), creature:getPosition()
	tPos:sendDistanceEffect(cPos, CONST_ANI_ENERGYBALL)
	addEvent(teleport, 10 * math.pow(tPos:getDistance(cPos), 2), tPos, cPos, creature:getId(), target:getId())
end

function teleport(tPos, cPos, cid, tid)
	local creature = Creature(cid)
	local target = Creature(tid)

	local toPos = cPos:getPositionsAround()[cPos:getDirectionTo(tPos)]
	local tile = Tile(toPos)
	if not tile or not tile:isWalkable(true,true,true) then
		toPos = cPos
	end

	target:teleportTo(toPos, false)
	lockCreatures(creature, target, false)
end

function lockCreatures(creature, target, lock)
	creature:setMoveLocked(lock)
	target:setMoveLocked(lock)
end

function onCastSpell(creature, variant)
	local var = creature:setSpellTarget(variant, 20)
	return var and combat:execute(creature, var) or false
end