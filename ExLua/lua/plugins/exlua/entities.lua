AddCSLuaFile()
if not ExLua then return end
setfenv(1, ExLua) -- Now time to get fancy.

function CreateEntity(class, callback) -- Taken from EasyLua.
	local this, mdl = Entity(0), "error.mdl"

	if IsEntity(class) and class:IsValid() then
		this = class
	elseif class:find(".mdl", nil, true) then
		mdl = class
		class = "prop_physics"

		this = ents.Create(class)
		this:SetModel(mdl)
	else
		this = ents.Create(class)
		if this and this.Model then 
			this:SetModel(this.Model) 
		end
	end

	if callback and type(callback) == 'function' then
		callback(this);
	end

	this:Spawn()
	this:SetPos(futil.here() + Vector(0,0,this:BoundingRadius() * 2))
	this:DropToFloor()
	this:PhysWake()

	if this and this.Initialize then this:Initialize() end

	undo.Create(" "..class) -- For some reason we need a space here now.
		undo.SetPlayer(futil.me())
		undo.AddEntity(this)
	undo.Finish()
	
	util.me.mark = this
	return this
end
function cent(class, callback) return CreateEntity(class, callback) end

bent = {}

function bent.start(class, model) 
	ENT = {}
	ENT.ClassName = ENT.ClassName or class or "no_ent_name_" .. util.me:Nick() .. "_" .. util.me:UniqueID()
	ENT.Model = model and Model(tostring(model)) or Model("models/props_borealis/bluebarrel001.mdl")
	---
	ULib.tsayColor( futil.me(), nil, Color( 0, 170, 255 ), "ExLua:Note: Entity builder started, please do not remove the \"ENT\" variable!" )
end

function bent.fin(callback, base, ctype)
	if not (ENT and type(ENT) == "table") then 
		ULib.tsayError( futil.me(), "ExLua:1: Entity builder has not been started call bent.start(class, model) first!", nil, true )
		return  
	end

	if callback and type(callback) ~= "function" then
		local cb = tostring(callback)
		if cb == "phys" then
			function callback(self) 
				self:PhysicsInit( SOLID_VPHYSICS )		-- Make us work with physics,
				self:SetMoveType( MOVETYPE_VPHYSICS )	-- after all, gmod is a physics
				self:SetSolid( SOLID_VPHYSICS )			-- Toolbox
			end
		else
			function callback() end
		end
	end

	local class = ENT.ClassName
	ENT.Base = ENT.Base or base -- Import the base.
	if not ENT.Base then -- there can be Base without Type but no Type without base without redefining every function so um...
		ENT.Base = "base_anim"
		ENT.Type = ENT.Type or ctype or "anim"
	end
	
	scripted_ents.Register(ENT, ENT.ClassName, true)

	for key, entity in pairs(ents.FindByClass(ENT.ClassName)) do
		table.Merge(entity:GetTable(), ENT)
		if reinit then
			if callback and type(callback) == "function" then
				callback(entity)
			end
			entity:Initialize()
		end
	end

	ENT = nil
	return CreateEntity(class, callback)
end

-----------

function buildent(base, ctype, class, model, ctable, callback, reinit)
	local ENT = {}

	if ctable then
		if tostring(ctable) == "phys" then
			local cb = callback or function() return end
			function callback(self) 
				self:PhysicsInit( SOLID_VPHYSICS )		-- Make us work with physics,
				self:SetMoveType( MOVETYPE_VPHYSICS )	-- after all, gmod is a physics
				self:SetSolid( SOLID_VPHYSICS )			-- Toolbox
				return cb(self)
			end
		elseif type(ctable) == "table" then
			if #ctable > 0 then table.Inherit( ENT, ctable ) end;
			ctable = nil;
		end
	end

	ENT.ClassName = ENT.ClassName or class or "no_ent_name_" .. util.me:Nick() .. "_" .. util.me:UniqueID()
	ENT.Model = ENT.Model or (model and Model(tostring(model))) or Model("models/props_borealis/bluebarrel001.mdl")
	
	if not ENT.Base then -- there can be Base without Type but no Type without base without redefining every function so um...
		ENT.Base = "base_anim"
		ENT.Type = ENT.Type or ctype or "anim"
	end
	
	scripted_ents.Register(ENT, ENT.ClassName, true)

	for key, entity in pairs(ents.FindByClass(ENT.ClassName)) do
		table.Merge(entity:GetTable(), ENT)
		if reinit then
			if callback and type(callback) == "function" then
				callback(entity)
			end
			entity:Initialize()
		end
	end

	return CreateEntity(class, callback) 
end

setfenv(1, _G) -- Back to the global. (Just in case.)