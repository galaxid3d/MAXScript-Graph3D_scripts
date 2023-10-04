-- Date: 2018-03-19+2018-07-19 by galaxid3d
-- This script serves for manual creation of a 3D graph: adds vertices and allows you to connect them with edges.

rollout Graph3D_Tools_rllt "Graph3D_Tools" width:180 height:174 (
	GroupBox 'Edges_grp' "Edges" pos:[4,2] width:172 height:84
	spinner 'Edge_thickness_spnr' "Edge_Thickness:" pos:[10,20] width:164 height:16 range:[0,1e+008,2] type:#float scale:0.1 align:#left
	spinner 'LoopSegments_spnr' "Loop_Segs:" pos:[10,40] width:70 height:16 range:[3,200,16] type:#integer scale:1 align:#left
	radioButtons 'TypeConnection_chk' pos:[110,41] columns:3 labels:#("", "", "") tooltip:#("Connection Each by Each", "Connection All Spheres with First Select Sphere", "Connection by Chain Spheres by Order") offsets:#([0,0], [-2,0], [-4,0])
	button 'CreateEdges_btn' "Create Edges" pos:[8,60] width:164 height:22
	GroupBox 'Shperes_grp' "Shperes" pos:[4,86] width:172 height:84
	spinner 'SphereSize_spnr' "Sphere_Size:" pos:[10,104] width:118 height:16 range:[0,1e+008,5] type:#float scale:0.1 align:#left
	spinner 'SphereSegments_spnr' "Sphere_Segments:" pos:[10,124] width:78 height:16 range:[4,200,16] type:#integer scale:1 align:#left
	checkbox 'CreateText_chk' "N" pos:[144,105] width:30 height:16 checked:true ooltip:"Create Sphere Number"
	checkbox 'isVisibleOnly_chk' "V" pos:[144,125] width:30 height:16 checked:true tooltip:"Number depend only visible Spheres"
	button 'CreateSphere_btn' "Create Shpere" pos:[8,144] width:164 height:22
	
	fn CreateLine pointA pointB thickness = (
		tmp = SplineShape pos:pointA.pos
		addNewSpline tmp
		addKnot tmp 1 #corner #line PointA.pos
		addKnot tmp 1 #corner #line PointB.pos
		updateShape tmp
		tmp.render_renderable = tmp.render_displayRenderMesh = true
		tmp.render_thickness = thickness
		select tmp; max modify mode
		subobjectLevel = 1
		setKnotSelection tmp 1 #(2)
		modPanel.addModToSelection (Linked_XForm()); tmp.modifiers[1].Control = pointA --modifiers[1] faster than modifiers[#Linked_XForm]
		addModifier tmp (SplineSelect()) --clearSelection
		addModifier tmp (Edit_Spline())
		subobjectLevel = 1
		setKnotSelection tmp 1 #(1)
		modPanel.addModToSelection (Linked_XForm()); tmp.modifiers[1].Control = pointB --because in steck 1 = topModifieir
	)
	
	on CreateEdges_btn pressed do with redraw off (
		spheres = #()
		for sph in selection do
			if (classOf sph == Sphere) then append spheres sph
		if (spheres.count == 1) then (
			tmp = torus pos:[spheres[1].pos.X+SphereSize_spnr.value,spheres[1].pos.Y+SphereSize_spnr.value,spheres[1].pos.Z] radius1:SphereSize_spnr.value radius2:(Edge_thickness_spnr.value*0.5) segs:LoopSegments_spnr.value smooth:2 pivot:spheres[1].pos rotate tmp (eulerangles 0 0 (Random 0 360))
			tmp.parent = spheres[1]
		)
		else if (TypeConnection_chk.state == 2) then
			for i = 2 to spheres.count do
				CreateLine spheres[1] spheres[i] Edge_thickness_spnr.value
		else if (TypeConnection_chk.state == 3) then
			for i = 1 to spheres.count-1 do
				CreateLine spheres[i] spheres[i+1] Edge_thickness_spnr.value
		else
			for j = 1 to spheres.count-1 do
				for i = j+1 to spheres.count do
					CreateLine spheres[j] spheres[i] Edge_thickness_spnr.value
	)
	
	on CreateText_chk changed state do isVisibleOnly_chk.enabled = CreateText_chk.checked
	
	on CreateSphere_btn pressed do with redraw off ( suspendEditing()
		sph = sphere radius:SphereSize_spnr.value segs:SphereSegments_spnr.value pos:[Random 0 SphereSize_spnr.value*10,Random 0 SphereSize_spnr.value*10,Random 0 SphereSize_spnr.value*10] wirecolor:(color (random 0 255) (random 0 255) (random 0 255) )
		if CreateText_chk.checked then (
			spheres = 0 --count of spheres
			for obj in objects do
				if (classOf obj == Sphere) then if (not isVisibleOnly_chk.checked or not obj.isHiddenInVpt) then spheres += 1
			tmp = text pos:[sph.pos.X,sph.pos.Y,sph.pos.Z+SphereSize_spnr.value] wirecolor:objects[objects.count].wirecolor size:SphereSize_spnr.value text:(spheres as string) rotate tmp (eulerangles 90 0 (Random 0 360))
			addModifier tmp (Extrude())
			tmp.modifiers[1].amount = 0.1*SphereSize_spnr.value
			tmp.parent = sph
		)
	resumeEditing() )
)
createdialog Graph3D_Tools_rllt style:#(#style_minimizebox, #style_titlebar, #style_border, #style_sysmenu)