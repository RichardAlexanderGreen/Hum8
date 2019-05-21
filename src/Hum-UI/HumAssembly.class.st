"
HumAssembly contains the methods for calculating aggregate metrics 
such as: 
- bounding box,
- total weight, 
- total floor space,
- mass centroid (center of gravity)

Assembly subtypes may provide pre-defined parameterized standard assemblies
such as 
- wall unit assemblies
- door assemblies
- deck assemblies
- posts, beams, trusses
- appliances (toilet, refrigerator, washer, dryer, water heater, furnace)
- wheels, axles
- furniture (seat, desk, counter)

""
Represents an assembly of parts.

Positions parts relative to each other.
Note: Currently no provision is made for clearances between parts.
This may cause problems with rendering / viewing.

TODO: Provide some minimal clearance between HumSolids during positioning or rendering.
- Strategy A: Add one millimeter to given positions when positioning.
- Strategy B: Subtract two millimeters from all three extents when rendering.
(Numbers would round or show centimeters for some tabular views, 
     but would be sent in millimeters for rendering.)
""


"
Class {
	#name : #HumAssembly,
	#superclass : #HumBox,
	#instVars : [
		'parts'
	],
	#category : #'Hum-UI'
}

{ #category : #accessing }
HumAssembly >> addPart: aHumBox [
	"Add the component to my parts list"
	| |
	self assert: ( aHumBox isKindOf: HumBox ).
	(self parts) add: aHumBox.
	"When the part is changed, the assembly (me myself) (e.g. scene) will be notified."
	aHumBox addDependent: self.
	aHumBox when: #changed send: #changed  to: self with: aHumBox.
]

{ #category : #accessing }
HumAssembly >> addParts: aCollection [
	"Add the component to my parts list"
	| |
	aCollection do: [ :each | self addPart: each ].
]

{ #category : #positioning }
HumAssembly >> advance: aBox by: anArray [ 
	"Move the box by the given increments.
	anArray is velocity per step.
	( velocity per second divided by steps per second )
	It`s elements have units of L^1 T^-1.
	Note: Velocity is expressed in the assembly frame, not the box`s frame.
	"
	| dEast dNorth dUp |
	dEast  := self asMeasure: (anArray at: 1).
	dNorth := self asMeasure: (anArray at: 2).
	dUp    := self asMeasure: (anArray at: 3).
	
	"Assure that aBox is in my collection. "
	( self parts ) add: aBox.
	
	"Compute edge positions to center aBox at those coordinates."
	aBox eastEdge:  ( aBox eastEdge  + dEast ).
	aBox northEdge: ( aBox northEdge + dNorth ).
	aBox topEdge:   ( aBox topEdge   + dUp ).
	
	
	
]

{ #category : #polygons }
HumAssembly >> asPolygons [
	"Return polygons for my parts."
	| assemblyPolygons |
	assemblyPolygons := OrderedCollection new.
	self exploded 
		do: [ :part | 
			| partPolygons |
			partPolygons := part asPolygons.
			assemblyPolygons addAll: partPolygons.
		 	].
	^assemblyPolygons.
]

{ #category : #polygons }
HumAssembly >> asPolygonsColorCoded [
	"Return polygons for my parts."
	| assemblyPolygons |
	assemblyPolygons := OrderedCollection new.
	self parts 
		do: [ :part | 
			| partPolygons |
			partPolygons := part asPolygonsColorCoded.
			assemblyPolygons addAll: partPolygons.
		 	].
	^assemblyPolygons.
]

{ #category : #'render as Three.js' }
HumAssembly >> asThreeJS [
	"render the parts contained in this assembly"
	| js calc dictionary prologTemplate |
	dictionary := Dictionary new.
	dictionary at: 'assemblyID' put: (self asCamelCase ).
	calc := HumCalculator new.

	"TODO: Add method to generate Three.js boiler plate."
	"Initialize geometry for this assembly."
	prologTemplate := String cr, 'var @assemblyID = new THREE.Geometry();'.
	js := calc fillTemplate: prologTemplate fromDictionary: dictionary.
	
	( self parts )
		do: [ :part | 
				| assemblyTemplate assemblyJS |
				"Create the part"
				js := js, ( part asThreeJS ).
				"Merge it into the assembly."
				assemblyTemplate := '			THREE.GeometryUtils.merge( @assemblyID, @partID );', String cr.
				dictionary at: 'partID' put: ( part asCamelCase ).
				"The template drives this, producing one line of code."
				assemblyJS := calc fillTemplate: assemblyTemplate fromDictionary: dictionary. 
				js := js, assemblyJS. 
				].
	^js.
]

{ #category : #'render as VPython' }
HumAssembly >> asVPython [
	"Render my parts via Visual Python Things"
	| pythonCode |
	"Note: Put the assembly in a scene.
	The preamble code must be generated via HumScene."
	pythonCode := String new.
	self parts do: [ :part | pythonCode := pythonCode, String cr, (part asVPython) ].
	pythonCode := pythonCode, String cr.
	^pythonCode.
	
]

{ #category : #'render as X3D' }
HumAssembly >> asX3D [
	"Return a string representing this assembly as a X3D element and scene.
	"
	|  x3d calc |
	calc := HumCalculator new.
	x3d := calc xml: 'X3D' dictionary: (self x3dBoilerPlate)
	           with: [ self x3dScene ].
	^x3d.
]

{ #category : #'aggregate metrics' }
HumAssembly >> bbBottomEdge [
	"Find my bounding box edge."
	| myEdge |
	myEdge := self bottomEdge.
	self parts 
		do: [ :part | 
				| otherEdge |
				otherEdge := (part bottomEdge).
				(otherEdge < myEdge ) ifTrue: [ myEdge := otherEdge ]
				].
	^bottomEdge := myEdge.
]

{ #category : #'aggregate metrics' }
HumAssembly >> bbDepth [
	"Depth is another name for length."
	^self bbLength.
]

{ #category : #'aggregate metrics' }
HumAssembly >> bbEastEdge [
	"Find my bounding box edge."
	| myEdge |
	myEdge :=self eastEdge.
	self parts 
		do: [ :part | 
				| otherEdge |
				otherEdge := (part eastEdge).
				( otherEdge > myEdge ) ifTrue: [ myEdge := otherEdge ]
				].
	^eastEdge := myEdge.
]

{ #category : #'aggregate metrics' }
HumAssembly >> bbHeight [
	"height of my bounding box"
	| |
	height := ((self bbTopEdge) - (self bbBottomEdge)) abs.
	^height.
]

{ #category : #'aggregate metrics' }
HumAssembly >> bbLength [
	"length of my bounding box"
	| |
	height := ((self bbNorthEdge) - (self bbSouthEdge)) abs.
	^height.
]

{ #category : #'aggregate metrics' }
HumAssembly >> bbNorthEdge [
	"Find my bounding box edge."
	| myEdge |
	myEdge :=self northEdge.
	self parts 
		do: [ :part | 
				| otherEdge |
				otherEdge := (part northEdge).
				(otherEdge > myEdge ) ifTrue: [ myEdge := otherEdge ]
				].
	^northEdge := myEdge.
]

{ #category : #'aggregate metrics' }
HumAssembly >> bbSouthEdge [
	"Find my bounding box edge."
	| myEdge |
	myEdge := self southEdge.
	self parts 
		do: [ :part | 
				| otherEdge |
				otherEdge := (part southEdge).
				(otherEdge < myEdge ) ifTrue: [ myEdge := otherEdge ]
				].
	^southEdge := myEdge.
]

{ #category : #'aggregate metrics' }
HumAssembly >> bbTopEdge [
	"Find my bounding box edge."
	| myEdge |
	myEdge := self topEdge.
	self parts 
		do: [ :part | 
				| otherEdge |
				otherEdge := (part topEdge).
				(otherEdge > myEdge ) ifTrue: [ myEdge := otherEdge ]
				].
	^topEdge := myEdge.
]

{ #category : #'aggregate metrics' }
HumAssembly >> bbWestEdge [
	"Find my bounding box edge."
	| myEdge |
	myEdge := self westEdge.
	self parts 
		do: [ :part | 
				| otherEdge |
				otherEdge := (part westEdge).
				(otherEdge < myEdge ) ifTrue: [ myEdge := otherEdge ]
				].
	^westEdge := myEdge.
]

{ #category : #'aggregate metrics' }
HumAssembly >> bbWidth [
	"width of my bounding box"
	| |
	height := ( self bbEastEdge ) - ( self bbWestEdge ).
	^height.
]

{ #category : #positioning }
HumAssembly >> center: aHumBox above: aHumBox2 [ 
	"synonym"
	self center: aHumBox onTopOf: aHumBox2 

]

{ #category : #positioning }
HumAssembly >> center: aBox at: a3Vector [ 
	"Center the part (aBox) at the given coordinates. { east. north. up. }
	Note: Those coordinates are relative to my origin."
	|  calc |
	calc := HumCalculator new.
	calc cases;
		when: [ a3Vector isKindOf: Array ] then: [ aBox centerAt: (HumVector newFrom: a3Vector). ];
		when: [ a3Vector isKindOf: HumVector ] then: [ aBox centerAt: a3Vector ];
		otherwise: [ Error signal: 'unexpected type sent to HumAssembly>>center:at:' ].

	"Make sure I have that box in my parts list."
	self addPart: aBox.
	
	
]

{ #category : #positioning }
HumAssembly >> center: boxB below: boxA [ 
  "Center boxB over boxA"
	| newCenter |
	self addParts: { boxB. boxA. }.
	newCenter := { boxA centerX. boxA centerY. ((boxA centerZ) - ((boxA height + boxB height) / 2.0 )) }.
	self center: boxB at: newCenter.
]

{ #category : #positioning }
HumAssembly >> center: boxB eastOf: boxA [ 
  "Center boxB over boxA"
	| newCenter |
	self addParts: { boxB. boxA. }.
	newCenter := { ((boxA centerX) + ( (boxA width + boxB width)/2.0) ). boxA centerY. boxA centerZ.  }.
	self center: boxB at: newCenter.
]

{ #category : #positioning }
HumAssembly >> center: boxB northOf: boxA [ 
  "Center boxB over boxA"
	| newCenter |
	self addParts: { boxB. boxA. }.
	newCenter := { boxA centerX. ((boxA centerY) + boxA length). boxA centerZ.  }.
	self center: boxB at: newCenter.
]

{ #category : #positioning }
HumAssembly >> center: boxB onTopOf: boxA [ 
  "Center boxB over boxA"
	| newCenter |
	self addParts: { boxB. boxA. }.
	newCenter := { boxA centerX. boxA centerY. ((boxA centerZ) + ((boxA height + boxB height) / 2.0 )) }.
	self center: boxB at: newCenter.
]

{ #category : #positioning }
HumAssembly >> center: aHumBox over: aHumBox2 [ 
	"synonym"
	self center: aHumBox onTopOf: aHumBox2 

]

{ #category : #positioning }
HumAssembly >> center: boxB southOf: boxA [ 
  "Center boxB over boxA"
	| newCenter |
	self addParts: { boxB. boxA. }.
	newCenter := { boxA centerX. ((boxA centerY) - boxA length). boxA centerZ.  }.
	self center: boxB at: newCenter.
]

{ #category : #positioning }
HumAssembly >> center: boxB westOf: boxA [ 
  "Center boxB over boxA"
	| newCenter |
	self addParts: { boxB. boxA. }.
	newCenter := { ((boxA centerX) - ( (boxA width + boxB width)/2.0) ). boxA centerY. boxA centerZ.  }.
	self center: boxB at: newCenter.
]

{ #category : #events }
HumAssembly >> changed [
	super changed.
	"Transcript cr; show: 'Assembly ',self id,' changed.'."
]

{ #category : #enumerating }
HumAssembly >> exploded [
	"Explode assemblies so that all the parts of parts become visible."
	| allParts |
	allParts := OrderedCollection new.
	(self parts) do: [ :subassembly |  (subassembly exploded) do: [ :each | allParts add: each ] ].
	^allParts.
]

{ #category : #accessing }
HumAssembly >> parts [
	^ parts ifNil: [ parts := Set new ].
]

{ #category : #positioning }
HumAssembly >> position: boxA above: boxB [
	"synonym"
	self position: boxA onTopOf: boxB
]

{ #category : #positioning }
HumAssembly >> position: boxA below: boxB [
	"synonym"
	self position: boxA onBottomOf: boxB
]

{ #category : #positioning }
HumAssembly >> position: boxA eastOf: boxB [
	"Position A on East edge of B."
	"Assure both are in my collection."
	self addParts: { boxA. boxB. }.

	"By convention, A`s West edge will now equal B`s East edge. (zero clearance)"
	boxA westEdge: ( boxB eastEdge ).
	"Note that up-down  and north-south edges are not affected.
	"
]

{ #category : #positioning }
HumAssembly >> position: boxA northOf: boxB [
	"Position A on North edge of B."
	"Assure both are in my collection."
	self addParts: { boxA. boxB. }.

  "By convention, A`s South edget will now equal B`s North."
	boxA southEdge: ( boxB northEdge ).
]

{ #category : #positioning }
HumAssembly >> position: boxA onBottomOf: boxB [
	"Position A on bottom of B."
  "Assure both are in my collection."
	self addParts: { boxA. boxB. }.

	"By convention, A`s top will now equal B`s bottom."
	boxA topEdge: ( boxB bottomEdge ).
]

{ #category : #positioning }
HumAssembly >> position: boxA onTopOf: boxB [
	"Position A on top of B."
  "Assure both are in my collection."
	self addParts: { boxA. boxB. }.

	"By convention, A`s bottom will now equal B`s top."
	boxA bottomEdge: ( boxB topEdge ).
]

{ #category : #positioning }
HumAssembly >> position: boxA over: boxB [
	"synonym"
	self position: boxA onTopOf: boxB
]

{ #category : #positioning }
HumAssembly >> position: boxA southOf: boxB [
	"Position A on South edge of B."
  "Assure both are in my collection."
	self addParts: { boxA. boxB. }.

	"By convention, A`s North edge will now equal B`s South. (zero clearance)"
	boxA northEdge: ( boxB southEdge ).
]

{ #category : #positioning }
HumAssembly >> position: boxA under: boxB [
	"synonym"
	self position: boxA onBottomOf: boxB
]

{ #category : #positioning }
HumAssembly >> position: boxA westOf: boxB [
	"Position A on West edge of B."
  "Assure both are in my collection."
	self addParts: { boxA. boxB. }.

	"By convention, A`s bottom will now equal B`s top."
	boxA eastEdge: ( boxB westEdge ).
]

{ #category : #events }
HumAssembly >> update:  anObject [ 
	"TBD"
	"Transcript cr; show: 'Assembly: ', self id, ' sees update of: ', anObject asString."
	self changed.
]

{ #category : #events }
HumAssembly >> update: anAspect with: anObject [ 
	"TBD"
	Transcript cr; show: 'Assembly: ', self id, ' sees update of: ', anObject asString.
	self halt.
]

{ #category : #'render as X3D' }
HumAssembly >> x3DOM [
	"TODO: Generate HTML to enable X3DOM viewing in Browser."
	| html |
	self shouldBeImplemented.
	html := '<!DOCTYPE html>
<html lang="en" style="width:100%; height:100%; border:0; margin:0; padding:0;">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="description" content="">
    <meta name="keywords" content="">
    <meta name="index" content="follow">
    <meta name="revisit-after" content="2 days">
    
    <title>Model: Landing Gear </title>
    
    <link rel="stylesheet" href="static/x3dom.css" type="text/css" charset="utf-8"></link>
    <link rel="stylesheet" type="text/css" href="static/css/jquery-ui-1.9.2.custom.css" />
    <link rel="stylesheet" type="text/css" href="static/css/ui.css"/>
    <style>
        .x3dom-logContainer { bottom: 0px; position: absolute; }
        body { width:100%; height:100%; border:0; margin:0; padding:0; }
    </style>

    <script src="static/x3dom-full.js" type="text/javascript"></script>
    
    <script type="text/javascript" src="static/js/jquery-1.9.0.min.js"></script>
    <script type="text/javascript" src="static/js/jquery-ui-1.9.2.custom.min.js"></script>
    <script type="text/javascript" src="static/js/settings.js"></script>
    <script type="text/javascript" src="static/js/ui.js"></script> 
    <script>
        // LOD LUT HACK
        //x3dom.debug.usePrecisionLevelAsTexCoord = true;
    </script>

     
</head>
<body>
<div class="container" style="width:100%; height:100%; border:0; margin:0; padding:0;">



    <div class="uiTransparent" id="statsWidget" style="right:4px; top:4px;">
        <form class="uiHalfTransparent section" >

            <!-- Statistics-->
            <div class="uiTransparent" title="Statistics">Statistics</div>
            <div id="statistics" class="uiTransparent" >

                <!-- FPS -->
                <div class="setting" id="fpsSetting" title="Frames per Second">
                    <div id="FPS" style="font-size: 1.5em; ">
                    </div>
                </div>

                <!-- rendered triangles -->
                <div class="setting" id="renderedTriangles" title="Amount of triangles currently rendered and total">
                    <div class="settingName">Rendered Triangles</div>
                    <div class="settingControlFullSize">
                        <div id="renderedTrianglesPB" class="progress triangles" ><span></span></div>
                    </div>
                </div>
                
            </div>
        </form>

        <form class="uiHalfTransparent section">
            <!-- interaction -->
            <div class="uiTransparent" title="Interaction">Interaction</div>
            <div id="interaction" class="uiTransparent" >
               
               <!-- Error Bound-->                
                <div class="setting" id="errorBoundSetting" >
                    <div class="settingName" id="ebTitle">Error Bound (Pixels): 1</div>
                    <div class="settingControlFullSize">
                        <div id="errorBoundSlider"></div>
                    </div>
                </div>
                
                <!-- Interaction Factor-->
                <div class="setting" id="interactionFactorSetting" >
                    <div class="settingName" id="ifTitle">Interaction Factor: 1</div>
                    <div class="settingControlFullSize">
                        <div id="interactionFactorSlider"></div>
                    </div>
                </div>
                
                <!-- Render Mode-->
                <div class="setting" id="renderMode" title="Render mode settings">
                    <div class="settingName" id="renderModeRadio">Render Mode</div>
                    <div class="settingControlFullSize">
                        <input type="radio" name="rendermode" id="renderPointsButton"><label for="renderPointsButton" class="roundBorders">Points</label></input>
                        <input type="radio" name="rendermode" id="renderTrianglesButton" checked><label for="renderTrianglesButton" class="roundBorders">Faces</label></input>                        
                    </div>
                </div>
             
                <div class="setting">
                    <!-- reset View -->
                    <button id="rvButton" title="reset camera to initial position">Reset View</button>
                </div>
            </div>
        </form>
    </div>

    <div id="HUDs_Div"> 
      <div id="X3DOM_AOPT_Links" class="group" style="margin:2px; margin-top:26px; padding:4px; background-color:rgba(199,202,204,.7); position:absolute; float:center; z-index:1000;"> 
        <a href="http://www.x3dom.org">X3DOM </a> output created with <a href="http://www.instantreality.org">InstantReality </a> aopt tool.
      </div>         
    </div>    
    <x3d id="x3dElement" swfpath="static/x3dom.swf" showStat="false" showLog="false" style="width:100%; height:100%; border:0; margin:0; padding:0;">
      <scene doPickPass="false">
        <navigationInfo headlight="false"></navigationInfo>
        <background skyColor="0 0 0"></background>        
        <directionalLight DEF="KEY_LIGHT"  color="0.9 0.9 1.0" direction="-0.7 -0.7 -0.3" intensity="1.0"></directionalLight>
        <directionalLight DEF="FILL_LIGHT" color="0.9 0.7 0.4" direction="0.7   0.7 -0.3" intensity="0.9"></directionalLight>
        <directionalLight DEF="BACK_LIGHT" color="1.0 0.9 0.0" direction="0.0   0.7  0.7" intensity="0.4"></directionalLight>      
        <inline DEF="MODEL" url="data/landinggear/landinggear-pop.x3d" mapDEFToID="true" nameSpaceName="model"></inline>
      </scene>
    </x3d>
    
    
    
</div>
</body>
</html>
'.
	^html.

]

{ #category : #'render as X3D' }
HumAssembly >> x3dBackground [
	"Provide (default) X3D background element (skybox)"
	| x3d |
	x3d := '
	<Background groundColor="0.7 0.7 0.7" 
                   skyAngle="0.05 1.5 1.59" 
                   skyColor="0.6 0.6 0.4  0.4 0.4 0.7  0.3 0.3 0.6  0.1 0.1 0.3"/>
  '.
	^x3d.
]

{ #category : #'render as X3D' }
HumAssembly >> x3dBoilerPlate [
	"Provide boilerplate attributes for X3D element"
	"profile='Interchange' version='3.2' 
	 xmlns:xsd='http://www.w3.org/2001/XMLSchema-instance' 
	 xsd:noNamespaceSchemaLocation='http://www.web3d.org/specifications/x3d-3.2.xsd'"
	| attributes |
	attributes := Dictionary new.
	attributes
		at: 'profile' put: 'Interchange';
		at: 'version' put: '3.2';
		at: 'xsd' put: 'http://www.w3.org/2001/XMLSchema-instance';
		at: 'xsd:noNamespaceSchemaLocation' put: 'http://www.web3d.org/specifications/x3d-3.2.xsd'.
	^attributes.
]

{ #category : #'render as X3D' }
HumAssembly >> x3dObjects [
	"Render each of the objects in my collection"
	| x3d |
	x3d := '<Group ID="', (self id asString), '" >', String cr.
	(self parts)
		do: [ :part | x3d := x3d, (part asX3D) ].
	x3d := x3d, '</Group>'.	
	^x3d.
]

{ #category : #'render as X3D' }
HumAssembly >> x3dScene [
	"Return a string representing this assembly as a X3D scene.
	"
	|  x3d calc |
	calc := HumCalculator new.
	x3d := calc xml: 'Scene' with: [ ( self x3dBackground ), ( self x3dObjects ) ].
	^x3d.
]

{ #category : #positioning }
HumAssembly >> zcenter: aBox at: anArray [ 
	"Center the part (aBox) at the given coordinates. { east. north. up. }
	Note: Those coordinates are relative to my origin."
	| eastOffset northOffset topOffset |
	eastOffset  := self asMeasure: (anArray at: 1).
	northOffset := self asMeasure: (anArray at: 2).
	topOffset   := self asMeasure: (anArray at: 3).
	
	"Assure that aBox is in my collection. "
	self addPart: aBox.
	
	"Compute edge positions to center aBox at those coordinates relative to my origin."
	aBox eastEdge:  ( eastOffset  + ( (aBox width  ) * 0.5 ) ).
	aBox northEdge: ( northOffset + ( (aBox length ) * 0.5 ) ).
	aBox topEdge:   ( topOffset   + ( (aBox height ) * 0.5 ) ).
	
	
]

{ #category : #positioning }
HumAssembly >> zcenter: boxB onTopOf: boxA [ 
  "Center boxB over boxA"
	| baseCenter raisedCenter newCenter |
	self addParts: { boxB. boxA. }.
	self position: boxB onTopOf: boxA.
	raisedCenter := boxB center.
	baseCenter := boxA center.
  "Adjust the x,y coordinates to match the bottom box`s center"
	newCenter := Array new: 3.
	newCenter at: 1 put: ( baseCenter at: 1).
	newCenter at: 2 put: ( baseCenter at: 2 ).
	"Keep the new Z."
	newCenter at: 3 put: ( raisedCenter at: 3 ).
	self center: boxB at: newCenter.
]
