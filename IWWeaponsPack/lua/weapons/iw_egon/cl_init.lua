
include('shared.lua')
SWEP.DrawCrosshair	= false

killicon.AddFont("iw_egon", "HL2MPTypeDeath", ",", Color(255, 80, 0, 255 ))

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( ",", "HL2MPTypeDeath", x + wide/2, y + tall*0.3, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
	// Draw weapon info box
	self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )
end