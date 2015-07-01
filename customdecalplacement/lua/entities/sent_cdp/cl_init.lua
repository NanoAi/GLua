include("shared.lua")

local dimg = {}
local tab = {}
local p = {}

function ENT:Initialize()
	dimg = {}
	tab = {}
	p = {}
	
	function self.Generate( url )
		hook.Add("RenderScreenspaceEffects", dimg.id .. "__CDP_3DHTMLSign", function()
			if dimg.pos:Distance(LocalPlayer():GetPos()) <= 1950 then
				if dimg.err != "ERROR_END_BREAK" then
					dimg.ang = self:GetAngles()
					dimg.pos = self:GetPos()
					cam.Start3D(EyePos(), EyeAngles())
						cam.Start3D2D(dimg.pos, dimg.ang, dimg.scale)
							dimg.status, dimg.err = pcall(dimg.DrawSign)
						cam.End3D2D()
						if not dimg.status then Error(dimg.err)		dimg.err = "ERROR_END_BREAK" end
					cam.End3D()
				end
			else
				dimg.err = nil
			end
		end)
	end
end

function ENT:OnRemove()
	if ( timer.Exists( "cdp_delay" ) ) then timer.Destroy( "cdp_delay" ) end
	hook.Remove("RenderScreenspaceEffects", self:EntIndex() .. "__CDP_3DHTMLSign")
	if dimg.browser then dimg.browser:Remove() end
	if p then 
		if p.OPanel then
			p.OPanel:Remove()
		end
		p = nil
	end
end

function ENT:Draw()
	render.SetMaterial(Material("sprites/sent_ball"))
	render.DrawSprite( self:GetPos(), 40, 40, self:GetColor() )
	
	self:SetMaterial("models/wireframe")
	self:DrawModel()
end

net.Receive("cdpSend", function()
	surface.PlaySound( "buttons/blip1.wav" )
	LocalPlayer():ConCommand("-use")
	
	local refrence = net.ReadEntity()
	local url = ""

	if p.OPanel then
		p.OPanel:SetVisible( true )
	else
		p.OPanel = vgui.Create( "DFrame" ) -- Creates the frame itself
		p.OPanel:SetPos( ScrW()/2,ScrH()/2.3 ) -- Position on the players screen
		p.OPanel:SetSize( ScrW()/8, (ScrH()/25)+240 ) -- Size of the frame
		p.OPanel:SetTitle( "Custom Decal Placement" ) -- Title of the frame
		p.OPanel:SetVisible( true )
		p.OPanel:SetDraggable( true ) -- Draggable by mouse?
		p.OPanel:ShowCloseButton( true ) -- Show the close button?
		p.OPanel:SetDeleteOnClose(false)
		p.OPanel:MakePopup()
		
		p.OLable1 = vgui.Create( "DLabel", p.OPanel )
		p.OLable1:SetPos( 5,25 )
		p.OLable1:SetText( "Enter the image URL of your choice." )
		p.OLable1:SizeToContents()
		
		local textboxsize = ScrW()/8 - 10

		p.OTextbox = vgui.Create( "DTextEntry", p.OPanel )
		p.OTextbox:SetPos(5, 40)
		p.OTextbox:SetSize(textboxsize, 35)
		p.OTextbox:SetText("Enter Image URL!") -- "Image URL"

		p.OTextboxW = vgui.Create( "DNumberWang", p.OPanel )
		p.OTextboxW:SetPos(5, 75)
		p.OTextboxW:SetSize(textboxsize/2, 35)
		p.OTextboxW:SetMinMax( 1, 17000 )
		p.OTextboxW:SetValue(1024) -- "Width"

		p.OTextboxH = vgui.Create( "DNumberWang", p.OPanel )
		p.OTextboxH:SetPos((textboxsize/2)+4, 75)
		p.OTextboxH:SetSize(textboxsize/2, 35)
		p.OTextboxH:SetMinMax( 1, 17000 )
		p.OTextboxH:SetValue( 768 ) -- "Height"
		
		p.OLable2 = vgui.Create( "DLabel", p.OPanel )
		p.OLable2:SetPos( 5+20, 112 )
		p.OLable2:SetText( "- Width -" )
		p.OLable2:SizeToContents()

		p.OLable3 = vgui.Create( "DLabel", p.OPanel )
		p.OLable3:SetPos( (textboxsize/2)+20, 112 )
		p.OLable3:SetText( "- Height -" )
		p.OLable3:SizeToContents()

		p.OLable4 = vgui.Create( "DLabel", p.OPanel )
		p.OLable4:SetPos( 5,100+70 )
		p.OLable4:SetText( "Set the rotation speed of the image." )
		p.OLable4:SizeToContents()
		
		p.OSlider = vgui.Create( "Slider", p.OPanel )
		p.OSlider:SetPos( 5, 110+70 ) 
		p.OSlider:SetWide( ScrW()/8 )
		p.OSlider:SetMin( 0 )
		p.OSlider:SetMax( 720 )
		p.OSlider:SetValue( 0 )
		p.OSlider:SetDecimals( 0 )
		p.OSlider.OnValueChanged = function( panel, value ) dimg.rotation = math.Round( value ) end
		
		p.ODButton3 = vgui.Create( "DButton", p.OPanel )
		p.ODButton3:SetPos( 5, 170+70 )
		p.ODButton3:SetText( "Save" )
		p.ODButton3:SetSize( ScrW()/8 - 10, 20 )
		p.ODButton3:SetDisabled( true )
		p.ODButton3.DoClick = function()
			p.ODButton3:SetDisabled( true )
			surface.PlaySound( "buttons/button14.wav" )
			p.OPanel:Remove()
			p = {}
			net.Start("cdpRecive")
			net.WriteEntity(refrence)
			tab = {url = dimg.url, pos = dimg.pos, ang = dimg.ang, width = dimg.width, height = dimg.height, scale = dimg.scale, rotation = dimg.rotation, plain = dimg.plain}
			net.WriteTable(tab)
			net.SendToServer()
		end
		
		p.ODButton = vgui.Create( "DButton", p.OPanel )
		p.ODButton:SetPos( 5, 150+70 )
		p.ODButton:SetText( "Apply" )
		p.ODButton:SetSize( ScrW()/8 - 10, 20 )
		p.ODButton:SetDisabled( true )
		p.ODButton.DoClick = function()
			p.ODButton:SetDisabled( true )
			refrence.Generate( url )
			p.ODButton3:SetDisabled( false )
			surface.PlaySound( "buttons/blip1.wav" )
		end
		
		p.OButton2 = vgui.Create( "DButton", p.OPanel )
		p.OButton2:SetPos( 5, 75+55 )
		p.OButton2:SetText( "Set URL" )
		p.OButton2:SetSize( ScrW()/8 - 10, 20 )
		p.OButton2.DoClick = function(self)
			self:SetDisabled( true )
			self:SetText( "Please Standby" )
			
			dimg.url = p.OTextbox:GetValue()
			dimg.pos = refrence:GetPos()
			dimg.ang = refrence:GetAngles()
			dimg.width = (p.OTextboxW:GetValue())+2
			dimg.height = (p.OTextboxH:GetValue())*2
			dimg.scale = 0.125
			dimg.rotation = math.Round( p.OSlider:GetValue() )
			dimg.status = nil
			dimg.err = nil
			dimg.browsermat = nil
			dimg.id = refrence:EntIndex()
			dimg.plain = {Vector(0, 0, 0), Vector(dimg.width, 0, 0), Vector(dimg.width, dimg.height, 0), Vector(0, dimg.height, 0)}
			--			  |							|							|								|
			--	Vertex 1 (Top left corner)  Vertex 2 (Top right corner)   Vertex 3 (Bottom right corner)	Vertex 4 (Bottom left corner)
			
			if ( timer.Exists( "cdp_delay" ) ) then timer.Destroy( "cdp_delay" ) end
			hook.Remove("RenderScreenspaceEffects", dimg.id .. "__CDP_3DHTMLSign")
			if dimg.browser then dimg.browser:Remove() end

			dimg.browser = vgui.Create("HTML")
			dimg.browser:SetPaintedManually(true)
			dimg.browser:SetSize(dimg.width, dimg.height)
			dimg.browser:SetMouseInputEnabled(false)
			dimg.browser:OpenURL(dimg.url)

			timer.Create( "cdp_delay", 1.5, 1, function() 
				dimg.browser:UpdateHTMLTexture()
				dimg.browsermat = dimg.browser:GetHTMLMaterial()

				function dimg.DrawSign()
					-- Draw the screen
					if dimg.browser then
						dimg.browser:UpdateHTMLTexture()
						if dimg.browsermat then render.SetMaterial(dimg.browsermat) end
					end
					
					render.DrawQuad(dimg.plain[1], dimg.plain[2], dimg.plain[3], dimg.plain[4])
					render.DrawQuad(dimg.plain[2], dimg.plain[1], dimg.plain[4], dimg.plain[3])
					-- render.DrawQuad(dimg.plain[1], dimg.plain[2]*-1, dimg.plain[3]*Vector(-1,1,1), dimg.plain[4])
				end
				
				refrence:SetColor(Color(0,0,255))
				surface.PlaySound( "buttons/blip1.wav" )
				self:SetText( "DONE" )
				p.ODButton:SetDisabled( false )
				timer.Simple(0.5, function() p.ODButton.DoClick() end)
			end)
		end
	end
end)