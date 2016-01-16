AntiCrashCMDTable = {
	-- Notifications --
	EchoFreeze 		= {0, "Tell players when a entity is frozen."},
	EchoRemove 		= {1, "Tell players when a entity is removed."},
	-- Speed --
	FreezeSpeed 	= {2000, "Velocity ragdoll is frozen at; make greater than RemoveSpeed if you want to disable freezing."},
	RemoveSpeed 	= {4000, "Velocity ragdoll is removed at."},
	-- Delays --
	FreezeTime 		= {1, "Time body is frozen for."},
	ThinkDelay 		= {0.5, "How often the server should check for bad ragdolls; change to 0 to run every Think."},
	-- Check For --
	EffectPlayers		= {0, "Check player velocity."},
	VelocityHook 		= {1, "Check entities for unreasonable velocity."},
	UnreasonableHook 	= {1, "Check entities for unreasonable angles/positions."},
	NaNCheck 			= {0, "Check and attempt to remove any ragdolls that have NaN/inf positions."}
}
-- End config

for k,v in next, AntiCrashCMDTable do -- Build Cvars.
	AntiCrashCMDTable[k] = CreateConVar(string.lower("apa_anticrash_"..tostring(k)), v[1], {FCVAR_DEMO, FCVAR_GAMEDLL, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY}, v[2])
end