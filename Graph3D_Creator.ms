-- Date: 04.04.2016+03.03.2020+04.04.2022 by galaxid3d
-- This script creates a 3D graph using a given incidence matrix.

rollout GraphCreatorRollout "Create 3D Graph v2" width:290 height:504 (
	GroupBox 'Coordinats_grp' "Coordinats random range" pos:[4,2] width:282 height:108
	spinner 'x_min_spnr' "X_min:" pos:[10,22] width:120 height:16 range:[-1e+008,1e+008,-100] type:#float scale:0.1 align:#left
	spinner 'y_min_spnr' "Y_min:" pos:[10,42] width:120 height:16 range:[-1e+008,1e+008,-100] type:#float scale:0.1 align:#left
	spinner 'z_min_spnr' "Z_min:" pos:[10,62] width:120 height:16 range:[-1e+008,1e+008,-100] type:#float scale:0.1 align:#left
	spinner 'x_max_spnr' "X_max:" pos:[148,22] width:117 height:16 range:[-1e+008,1e+008,100] type:#float scale:0.1 align:#left
	spinner 'y_max_spnr' "Y_max:" pos:[148,42] width:117 height:16 range:[-1e+008,1e+008,100] type:#float scale:0.1 align:#left
	spinner 'z_max_spnr' "Z_max:" pos:[148,62] width:117 height:16 range:[-1e+008,1e+008,100] type:#float scale:0.1 align:#left
	fn box_filter obj = classof obj == Box
	pickbutton 'Pick_Limit_Box_pckBtn' "Pick Limit Box" pos:[8,82] width:272 height:22 message:"Pick Limit box in Scene" filter:box_filter tooltip:"Select the box in scene for limit volume generation spheres" autoDisplay:true
	GroupBox 'Graph_Geometry_Parameters_grp' "Graph geometry parameters" pos:[4,110] width:280 height:73
	spinner 'Edge_thickness_spnr' "Edge_Thickness:" pos:[8,148] width:87 height:16 range:[0,1e+008,2] type:#float scale:0.1 align:#left
	spinner 'SphereSize_spnr' "Sphere_Size:" pos:[8,127] width:105 height:16 range:[0,1e+008,5] type:#float scale:0.1 align:#left
	spinner 'SphereSegments_spnr' "Sphere_Segments:" pos:[150,126] width:65 height:16 range:[4,200,16] type:#integer scale:1 align:#left
	spinner 'LoopSegments_spnr' "Loop_Segments:" pos:[150,148] width:65 height:16 range:[3,200,16] type:#integer scale:1 align:#left
	checkbox 'DeleteObjects_inScene_chk' "Delete Objects in Scene" pos:[8,165] width:133 height:16 checked:false
	checkbox 'CreateText_chk' "Create Sphere Number" pos:[147,165] width:130 height:16 checked:true
	GroupBox 'Graph_input_grp' "Graph input" pos:[4,183] width:282 height:318
	editText 'Strings_edt' "Input_string:" pos:[8,198] width:270 height:16
	listBox 'IncMatrix_lbx' "Incedent Matrix:" pos:[8,215] width:184 height:20
	button 'Add_StringToMatrix_btn' "Add" pos:[199,230] width:80 height:25
	button 'Delete_StringToMatrix_btn' "Delete" pos:[199,262] width:80 height:25
	button 'Clear_btn' "Clear" pos:[199,295] width:80 height:25
	spinner 'Count_spnr' "Count:" pos:[200,327] width:55 height:16 range:[1,1e+008,10] type:#integer scale:1 align:#left
	checkbox 'Random_Graph_chk' "Random Graph" pos:[194,347] width:90 height:20 checked:true
	spinner 'Graph_Density_spnr' "Density:" pos:[199,370] width:50 height:16 range:[0,100,50] type:#integer scale:1 align:#left
	spinner 'Random_seed_spnr' "Seed:" pos:[193,393] width:74 height:16 range:[0,1e+006,12345] type:#integer scale:1 align:#left
	button 'Create_3D_Graph_btn' "Create 3D Graph" pos:[194,412] width:90 height:85
	
	local Limit_Box = undefined
	local selSet = undefined
	local arr = #()
	
	fn findObj obj = (
		notFound = true --this construction of code is faster than return! (in MAXScript help "do not use break,return,continue...")
		result = false
		if obj != undefined then if not (isDeleted obj) then for tmp in objects do if notFound then
			if tmp == obj then (
				result = true
				notFound = false
			)
		result
	)

	fn fill_string s = (
		end_s = ""
		for i = 1 to (4-s.count) do end_s += "0"
		(end_s+s)
	)

	fn valid_int s = (
		isCorrect = true
		for i = 1 to s.count do if isCorrect then
			if (findString "0123456789" (substring s i 1)) == undefined then (
				s = 0
				isCorrect = false
			)
		s as Integer
	)

	fn UniqName name_input = (
		name_out = 0
		for s in selectionSets do
			if ((substring s.name 1 name_input.count) == name_input) then (
				name_out += 1
				if name_out != (valid_int(substring s.name (name_input.count+1) s.name.count)) then return (name_input+(fill_string(name_out as String))) )
		(name_input+(fill_string((name_out+1) as String)))
	)

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
		modPanel.addModToSelection (Linked_XForm()); tmp.modifiers[1].Control = pointA --[1] faster than [#Linked_XForm] (in MAXScript help "Cache frequently used functions and objects")
		addModifier tmp (SplineSelect()) --clearSelection
		addModifier tmp (Edit_Spline())
		subobjectLevel = 1
		setKnotSelection tmp 1 #(1)
		modPanel.addModToSelection (Linked_XForm()); tmp.modifiers[1].Control = pointB --because in steck 1 = topModifieir
		append selSet tmp
	)
	
	fn Create_3D_Graph IncMatrix_string x_min y_min z_min x_max y_max z_max SphereSize Edge_thickness = (
		clearSelection()
		seed GraphCreatorRollout.Random_seed_spnr.value
		IncMatrix = #(); selSet = #(); tmp = ""
		if GraphCreatorRollout.Random_Graph_chk.checked then (
			a = #()
			for j = 1 to GraphCreatorRollout.Count_spnr.value do (
				append IncMatrix #()
				for i = 1 to GraphCreatorRollout.Count_spnr.value do
					if (random 1 100) <= GraphCreatorRollout.Graph_Density_spnr.value then (
						append IncMatrix[j] i
						tmp += " "+(i as String)
					)
				append a tmp
				tmp = ""
			)
			GraphCreatorRollout.IncMatrix_lbx.items = a
		) else (
			for j = 1 to IncMatrix_string.count do (
				append IncMatrix #()
				for i = 1 to IncMatrix_string[j].count do (
					if (IncMatrix_string[j][i] != " ") then tmp += IncMatrix_string[j][i]
					else if tmp != "" then (
						append IncMatrix[j] tmp
						tmp = ""
					)
				)
				if tmp != "" then append IncMatrix[j] tmp
			)
		)
		if findObj Limit_Box then (GraphCreatorRollout.Pick_Limit_Box_pckBtn.caption = Limit_Box.name; tmp = Limit_Box.pivot; centerPivot Limit_Box)
			else (Limit_Box = undefined; GraphCreatorRollout.Pick_Limit_Box_pckBtn.caption = "Pick Limit Box")
		if GraphCreatorRollout.DeleteObjects_inScene_chk.checked then (for obj in objects do if obj != Limit_Box then delete obj; for a in selectionSets do deleteItem selectionSets a)
		a = #()
		a.count = IncMatrix.count
		with redraw off ( suspendEditing()
			for i = 1 to IncMatrix.count do (
				if Limit_Box == undefined then a[i] = [Random x_min x_max,Random y_min y_max,Random z_min z_max] --initialize the spheres position with use value in spinners
				else a[i] = [Random (Limit_Box.pos[1]-0.5*Limit_Box.width) (Limit_Box.pos[1]+0.5*Limit_Box.width), Random (Limit_Box.pos[2]-0.5*Limit_Box.length) (Limit_Box.pos[2]+0.5*Limit_Box.length), Random (Limit_Box.pos[3]-0.5*Limit_box.height) (Limit_Box.pos[3]+0.5*Limit_box.height)] --initialize the spheres position with use Limit_Box
				a[i] = sphere radius:SphereSize segs:GraphCreatorRollout.SphereSegments_spnr.value pos:a[i] wirecolor:(color (random 0 255) (random 0 255) (random 0 255) ); append selSet a[i]
				if GraphCreatorRollout.CreateText_chk.checked then (
					tmp=text pos:[a[i].pos.X,a[i].pos.Y,a[i].pos.Z+SphereSize] wirecolor:objects[objects.count].wirecolor size:SphereSize text:(i as string) rotate tmp (eulerangles 90 0 (Random 0 360))
					addModifier tmp (Extrude()); tmp.modifiers[1].amount=0.1*SphereSize; tmp.parent=a[i]; append selSet tmp
				)
			)
		resumeEditing() )
		if findObj Limit_Box then Limit_Box.pivot = tmp.pos
		with redraw off for j = 1 to IncMatrix.count do
			for i = 1 to IncMatrix[j].count do 
				if (j == (IncMatrix[j][i] as Integer)) then (tmp=torus pos:[a[j].pos.X+SphereSize,a[j].pos.Y+SphereSize,a[j].pos.Z] radius1:SphereSize radius2:(Edge_thickness*0.5) segs:GraphCreatorRollout.LoopSegments_spnr.value smooth:2 pivot:a[j].pos rotate tmp (eulerangles 0 0 (Random 0 360)); tmp.parent=a[j]; append selSet tmp)
				else if ((IncMatrix[j][i] as Integer)>j) and ((IncMatrix[j][i] as Integer)<=IncMatrix.count) then CreateLine a[j] a[(IncMatrix[j][i] as Integer)] Edge_thickness
		select selSet; tmp = UniqName "Graph"; selectionSets[tmp] = selection; selSet = selectionSets[tmp] --create new Selection Set (global variable selSet is need, because with it we can delete all objects in this set when change random seed spinner)
	)
	
	on Pick_Limit_Box_pckBtn picked obj do
		if obj != undefined do Limit_Box = obj
	
	on Add_StringToMatrix_btn pressed do (
		InsertItem Strings_edt.text arr (IncMatrix_lbx.selection+1)
		IncMatrix_lbx.items = arr
	)
	
	on Delete_StringToMatrix_btn pressed do
		if (arr.count>0) and (IncMatrix_lbx.selection>0) then (
			deleteItem arr IncMatrix_lbx.selection
			IncMatrix_lbx.items = arr
		)
	
	on Clear_btn pressed do (
		arr = #()
		IncMatrix_lbx.items = arr
	)
	
	on Random_seed_spnr changed val do
		if selSet != undefined then
			if not (isDeleted selSet) then with redraw off (
				delete selSet
				for obj in selSet do delete obj
				deleteItem selectionSets selSet
				arr = IncMatrix_lbx.items
				if (arr.count > 0) or Random_Graph_chk.checked then
					Create_3D_Graph arr x_min_spnr.value y_min_spnr.value z_min_spnr.value x_max_spnr.value y_max_spnr.value z_max_spnr.value SphereSize_spnr.value Edge_thickness_spnr.value
			)
	
	on Create_3D_Graph_btn pressed do with redraw off (
		GraphCreatorRollout.Random_seed_spnr.value = random 0 1e+006
		arr = IncMatrix_lbx.items
		if (arr.count > 0) or Random_Graph_chk.checked then
			Create_3D_Graph arr x_min_spnr.value y_min_spnr.value z_min_spnr.value x_max_spnr.value y_max_spnr.value z_max_spnr.value SphereSize_spnr.value Edge_thickness_spnr.value
	)
	
	on Graph_Density_spnr changed val do
		Random_seed_spnr.changed Random_seed_spnr.value
)
createDialog GraphCreatorRollout style:#(#style_minimizebox, #style_titlebar, #style_border, #style_sysmenu)