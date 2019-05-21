"
HumSolid is used to create visible VR objects such as room walls
and the parts of avatars.
It is a subtype of HumBox in that each solid is expected to have a bounding box.
The methods of HumBox may be used for positioning.


"
Class {
	#name : #HumSolid,
	#superclass : #HumBox,
	#instVars : [
		'typeOfSolid',
		'mass',
		'density',
		'material',
		'faces',
		'wireFrameColor'
	],
	#classInstVars : [
		'materialDensity'
	],
	#category : #'Hum-UI'
}

{ #category : #'as yet unclassified' }
HumSolid class >> densityOfMaterial: aMaterial [
	"Return the average mass-density of the given material."
	| result |
	aMaterial ifNil: [ Error signal: 'No material given. Cannot lookup density.'].
	
	(( self materialDensity ) isEmpty )
		ifTrue: [ "Densities are in kilogram-mass per meter^3"
			materialDensity at: 'air' put: 1.2.
			materialDensity at: 'foam' put: 24.         "Expanded Polystyrene Insulation"
			materialDensity at: 'snow' put: 480.        "snow, compacted"
			materialDensity at: 'wood' put: 708.        "red oak (denser than most). "
			materialDensity at: 'ice' put: 919.         "solid ice"
			materialDensity at: 'water' put: 1000.
			materialDensity at: 'seawater' put: 1030.
			materialDensity at: 'fiberglass' put: 1900. "Polyester and Continuous Rovings Laminate 70% E-glass"
			materialDensity at: 'soil' put: 2082.       "picked wet sand as worst case. packed mud is 1906"
			materialDensity at: 'sheetrock' put: 2320.  
			materialDensity at: 'drywall'   put: 2320.  
			materialDensity at: 'concrete' put: 2370.
			materialDensity at: 'glass' put: 2580.      "window glass"
			materialDensity at: 'rock'  put: 2700.      "granite, limestone, marble"
			materialDensity at: 'stone' put: 2700.      "granite, limestone, marble"
			materialDensity at: 'aluminum' put: 2739.
			materialDensity at: 'titanium' put: 4500.
			materialDensity at: 'steel' put: 7849.
			materialDensity at: 'copper' put: 8900.
			materialDensity at: 'lead' put: 11300.
			].
	result := HumMeasure quantity: (materialDensity at: (self aMaterial)) units: #kilogramPerCubicMeter.
	^result.
]

{ #category : #'instance creation' }
HumSolid class >> id: anId type: aSymbol height: aHeight width: aWidth depth: aDepth [ 
	"synonym"
	^ self id: anId type: aSymbol height: aHeight width: aWidth length: aDepth. 
]

{ #category : #'instance creation' }
HumSolid class >> id: anId type: aSymbol height: aHeight width: aWidth length: aDepth [ 
"Create an instance . . ."
	| solid |
	solid := self new.
	"delegate to super"
	solid id: anId height: aHeight width: aWidth length: aDepth.
	"and add: "
	solid type: aSymbol.
	^solid
]

{ #category : #polygons }
HumSolid >> asPolygons [
	"Translate each face into a list of 3D points."
	^polygons ifNil: [ polygons := self asPolygonsColoredBy: [ self solidColor ] ].

]

{ #category : #polygons }
HumSolid >> asPolygonsColorCoded [
	"Color code the facets of the solid."
	 ^self asPolygonsColoredBy: [ self nextColor ]. 
	
]

{ #category : #polygons }
HumSolid >> asPolygonsColoredBy: aColorRule [
	"Generate polygons from the solid`s dimension. - Subtypes should over-ride."
	"Color by evaluating the given color rule block."
	"Hum coordinates are plan view. X points East. Y points North. Z points up."
	|  polygon rotatedPolygons tiltedPolygons |
	polygons notNil
		ifTrue: [ ^polygons. ]
		ifFalse: [ polygons := OrderedCollection new. ].
	"North surface "
	polygon := HumPolygon parentSolid: self fillColor: (aColorRule value). "Polygon"
	polygon "Go clockwise as seen from outside the cube looking South"
		addVertex: { westEdge.  northEdge. topEdge. };
		addVertex: { eastEdge.  northEdge. topEdge. }; "<"
		addVertex: { eastEdge.  northEdge. bottomEdge. }; "v"
		addVertex: { westEdge. northEdge. bottomEdge. }. ">"
	polygons add: polygon.
	
	"East surface"
	polygon := HumPolygon parentSolid: self fillColor: (aColorRule value).
	polygon "Go clockwise as seen from outside the cube looking West"
		addVertex: { eastEdge. northEdge. topEdge. };
		addVertex: { eastEdge. southEdge. topEdge. }; "<"
		addVertex: { eastEdge. southEdge. bottomEdge. }; "V"
		addVertex: { eastEdge. northEdge. bottomEdge. }. ">"
	polygons add: polygon copy.
	
	"West surface"
	polygon := HumPolygon parentSolid: self fillColor: (aColorRule value).
	polygon "Go clockwise as seen from outside the cube looking East"
		addVertex: { westEdge. southEdge. topEdge. };
		addVertex: { westEdge. northEdge. topEdge. }; "<"
		addVertex: { westEdge. northEdge. bottomEdge. }; "V"
		addVertex: { westEdge. southEdge. bottomEdge. }. ">"
	polygons add: polygon copy.
	
	"Bottom surface"
	polygon := HumPolygon parentSolid: self fillColor: (aColorRule value).
	polygon "Go clockwise as seen from outside the cube looking Up and North at the bottom"
		addVertex: { eastEdge. southEdge. bottomEdge. };
		addVertex: { westEdge. southEdge. bottomEdge. }; "<"
		addVertex: { westEdge. northEdge. bottomEdge. }; "V"
		addVertex: { eastEdge. northEdge. bottomEdge. }. ">"
	polygons add: polygon copy.
	
	"Top surface"
	polygon := HumPolygon parentSolid: self fillColor: (aColorRule value).
	polygon "Go clockwise as seen from outside the cube looking down and North"
		addVertex: { eastEdge. northEdge. topEdge. };  
		addVertex: { westEdge. northEdge. topEdge. }; "<"
		addVertex: { westEdge. southEdge. topEdge. }; "V"
		addVertex: { eastEdge. southEdge. topEdge. }. ">"
	polygons add: polygon copy.
	
	"South surface"
	polygon := HumPolygon parentSolid: self fillColor: (aColorRule value).
	polygon "Go clockwise as seen from outside the cube looking North"
		addVertex: { eastEdge. southEdge. topEdge. };
		addVertex: { westEdge. southEdge. topEdge. }; "<"
		addVertex: { westEdge. southEdge. bottomEdge. }; "V"
		addVertex: { eastEdge.  southEdge. bottomEdge. }. ">"
	polygons add: polygon copy.
	
	(self rotation = 0.0) 
		ifTrue: [ rotatedPolygons := polygons ]
		ifFalse: [ rotatedPolygons := self rotatePolygons: polygons ].
	(self tilt = 0.0) 
		ifTrue: [ tiltedPolygons := rotatedPolygons ]
		ifFalse: [ tiltedPolygons := self tiltPolygons: rotatedPolygons ].
	"TODO: What is meaning of polygons instance variable if we return something else here?"
	"TODO: If a canvas is attached to a face (e.g. billboard), it needs to be rendered."
	^tiltedPolygons. 
	
]

{ #category : #'render as Three.js' }
HumSolid >> asThreeJS [
	"Render this solid  as a cube via three.js"
	| js template dictionary calc|
	"Note: Caller must merge this into a scene or group geometry"
	template := '
			var @ID = new THREE.Mesh( ( new THREE.CubeGeometry( @width, @length, @height )  )
			                            , ( new THREE.MeshBasicMaterial( { color: 0x@color } )  )
			                            );
			@ID.position.set( @x, @y, @z );
	'. 
	"TODO:  *** Implement Subtypes ***"
	dictionary := Dictionary new.
	dictionary
	  at: 'ID'    put: ( self asCamelCase );
	  at: 'color' put: ( self color asHexString asLowercase ); "Color"
	
	  at: 'x' put: ( self mm: ( self centerX ) );
	  at: 'y' put: ( self mm: ( self centerY ) );
	  at: 'z' put: ( self mm: ( self centerZ ) );
	
	  at: 'width'  put: ( self mm: width  );
	  at: 'length' put: ( self mm: length );
		at: 'height' put: ( self mm: height ).
		
	calc := HumCalculator new.
	js := calc fillTemplate: template fromDictionary: dictionary.
	^js. 
	
]

{ #category : #'render via VPython' }
HumSolid >> asVPython [
	| pythonCode |
	pythonCode := self asVPythonThing.
	^pythonCode
]

{ #category : #'render via VPython' }
HumSolid >> asVPythonPosition [
	"Generate VPythgon code giving position."
	|  comma eastString northString upString centerString |
	      
  		comma := ', '.      
		eastString := ( self westEdge + ( self width / 2 )) quantity printShowingDecimalPlaces: 3.  "Number"
        northString := ( self southEdge + ( self length / 2 )) quantity printShowingDecimalPlaces: 3.
        upString := ( self bottomEdge + ( self height / 2 )) quantity printShowingDecimalPlaces: 3.
        centerString := '( ', eastString, comma, northString, comma, upString, ' )'.

	^centerString.
]

{ #category : #'render via VPython' }
HumSolid >> asVPythonThing [
	"A solid has color and is visible."
	| pythonCode |
	pythonCode := id asCamelCase uncapitalized
	                              ,' = BoxThing( label = "',id,'"'
	                              ,', length = ', ( length quantity printShowingDecimalPlaces: 3 ) "millimeter precision"
	                              ,', width = ',  ( width quantity printShowingDecimalPlaces: 3 )
	                              ,', height = ', ( height quantity printShowingDecimalPlaces: 3 )
								  ,', pos = ', ( self asVPythonPosition )
	                              ,', aColor = color.', self color name 		"eh?"
	                              ,' )'.
	^pythonCode
]

{ #category : #'render as X3D' }
HumSolid >> asX3D [
	"Return a string in X3D notation representing this box / thing.
	Caller is responsible for embedding this in a scene.
	"
	| template x3d calc dictionary |
	"TODO: Replace this with a template implementation"
	template := '
	<Transform translation="@translation">
		<Shape ID:="@ID">
			<Appearance>
				<Material diffuseColor="@diffuseColor" />
			</Appearance>
			<@type size="@boxExtent" />
		</Shape>
	</Transform>
  '.
  dictionary := (Dictionary new).
  dictionary 
		at: 'translation' put: ( self x3dCenter );
		at: 'ID' put: ( self id );
		at: 'diffuseColor' put: ( self x3dColor );
		at: 'type' put: ( typeOfSolid );
		at: 'boxExtent' put: ( self x3dExtent ).
	calc := HumCalculator new.
	x3d := calc fillTemplate: template fromDictionary: dictionary. 
	^x3d.
]

{ #category : #access }
HumSolid >> attachCanvas: aCanvas toFace: aSymbol [ 
	"Attach the  canvas to the face. -- Used for billboards. 
	Maybe someday for texture, costume, decoration?"
	( self faces ) at: aSymbol put: aCanvas.
]

{ #category : #access }
HumSolid >> color [
	^solidColor ifNil: [ solidColor := Color gray. ].
]

{ #category : #access }
HumSolid >> color: aColor [ 
	"What id the default (background) color of the surface and interior of this solid 3D object?"
	self assert: ( aColor isKindOf: Color ).
	self solidColor: aColor.
]

{ #category : #access }
HumSolid >> density [
	"Return set density otherwise lookup the density of my material."
	^ density ifNil: [ (self densityOfMaterial) ].
]

{ #category : #access }
HumSolid >> density: aMeasure [
	"What is the average density (mass per cube) of this solid?
	*** Note: Use >>densityOfMaterial when possible. ***
	*** Use this method to over-ride density given by material. ***
	*** Example: You might use this method to provide average density of an aggregate. ***
	"
	self assert: ( aMeasure isKindOf: HumMeasure ).
	"HumMeasure handles conversions to KMS units.
	See also: methods in Number under HumMeasure category .
	"
	density := aMeasure.
]

{ #category : #access }
HumSolid >> densityOfMaterial [
	| result |
	"The table is held on the class side to avoid clutter and instance bloat."
	result := self class densityOfMaterial: material.
	^result.
]

{ #category : #access }
HumSolid >> faces [
	"Hold image/canvas to be attached to a face."
	^faces ifNil: [  faces := Dictionary new. ]
]

{ #category : #access }
HumSolid >> initialize [
	super initialize.
	self type: #box.
]

{ #category : #access }
HumSolid >> mass [
	^ mass ifNil: [ mass := (self volume) * (self density)].
]

{ #category : #access }
HumSolid >> mass: aMeasure [
	"What is the mass of this object?"
	self assert: ( aMeasure isKindOf: HumMeasure ).
	"HumMeasure handles conversions to KMS units.
	See also: methods in Number under HumMeasure category .
	"
	mass := aMeasure.
]

{ #category : #access }
HumSolid >> material [
	^ material ifNil: [ Error signal: 'Material has not been set for this solid'].
]

{ #category : #access }
HumSolid >> material: aString [ 
	"See also: #densityOfMaterial for names of standard materials. "
	self assert: ( aString isKindOf: String ).
	material := aString.

]

{ #category : #access }
HumSolid >> solidColor [
	^solidColor ifNil: [ solidColor := Color gray. ]
]

{ #category : #access }
HumSolid >> type: aSymbol [ 
	"TODO: Why was this coded? 
	I would expect subtyping of HumSolid to provide 'type' information."
	self assert: ( aSymbol isKindOf: Symbol ).
	self assert: ( #( #box #rotation #elipsoid #extrusion #space ) includes: aSymbol ).
	typeOfSolid := aSymbol.
]

{ #category : #access }
HumSolid >> weight [
	"Get the Earth-bound weight of the object.  (in Newtons)."
	^ ( self mass ) * ( 1.0 gravity ).
]

{ #category : #access }
HumSolid >> wireFrameColor [
	^wireFrameColor ifNil: [ wireFrameColor := Color black ].
]

{ #category : #'render as X3D' }
HumSolid >> x3dColor [
	"Translate my Smalltalk Color to x3dColor string"
	| result sp c |
	self assert: ( solidColor isKindOf: Color ).
	c := solidColor.
	sp := String space.
	result := (c red   printShowingDecimalPlaces:2 ), sp, 
	          (c green printShowingDecimalPlaces:2 ), sp, 
	          (c blue  printShowingDecimalPlaces:2 ).
	^result.
]

{ #category : #'render as X3D' }
HumSolid >> x3dExampleJSON [
	| json |
		"Following is here to hold some useful patterns while I think over the design strategy."
	json := '
	{
  "html": {
    "-xmlns": "http://www.w3.org/1999/xhtml",
    "head": {
      "meta": [
        {
          "-http-equiv": "X-UA-Compatible",
          "-content": "chrome=1"
        },
        {
          "-http-equiv": "Content-Type",
          "-content": "text/html;charset=utf-8"
        }
      ],
      "title": "Primitives: Box, Cone, Cylinder and Sphere Primitives",
      "link": {
        "-rel": "stylesheet",
        "-type": "text/css",
        "-href": "x3dom.css"
      }
    },
    "body": {
      "h1": "Primitives: Box, Cone, Cylinder and Sphere Primitives",
      "p": [
        {
          "-class": "case",
          "X3D": {
            "-xmlns": "http://www.web3d.org/specifications/x3d-namespace",
            "-id": "boxes",
            "-showStat": "true",
            "-showLog": "false",
            "-x": "0px",
            "-y": "0px",
            "-width": "400px",
            "-height": "400px",
            "Scene": {
              "Background": { "-skyColor": "1 1 1" },
              "Transform": [
                {
                  "-DEF": "coneTrafo",
                  "-translation": "-4.5 0 0",
                  "Shape": {
                    "-DEF": "coneShape",
                    "Appearance": {
                      "-DEF": "coneApp",
                      "Material": {
                        "-diffuseColor": "0 1 0",
                        "-specularColor": ".5 .5 .5"
                      }
                    },
                    "Cone": { "-DEF": "cone" }
                  }
                },
                {
                  "-DEF": "boxTrafo",
                  "-translation": "-1.5 0 0",
                  "Shape": {
                    "-DEF": "boxShape",
                    "Appearance": {
                      "-DEF": "boxApp",
                      "Material": {
                        "-diffuseColor": "1 0 0",
                        "-specularColor": ".5 .5 .5"
                      }
                    },
                    "Box": { "-DEF": "box" }
                  }
                },
                {
                  "-DEF": "sphereTrafo",
                  "-translation": "1.5 0 0",
                  "Shape": {
                    "-DEF": "sphereShape",
                    "Appearance": {
                      "-DEF": "sphereApp",
                      "Material": {
                        "-diffuseColor": "0 0 1",
                        "-specularColor": ".5 .5 .5"
                      }
                    },
                    "Sphere": { "-DEF": "sphere" }
                  }
                },
                {
                  "-DEF": "cylinderTrafo",
                  "-translation": "4.5 0 0",
                  "Shape": {
                    "-DEF": "cylinderShape",
                    "Appearance": {
                      "-DEF": "cylinderApp",
                      "Material": {
                        "-diffuseColor": "1 1 0",
                        "-specularColor": ".5 .5 .5"
                      }
                    },
                    "Cylinder": {
                      "-DEF": "cylinder",
                      "-radius": "1.0",
                      "-height": "2.0"
                    }
                  }
                }
              ],
              "Viewpoint": {
                "-centerOfRotation": "0 0 0",
                "-position": "0 0 15",
                "-orientation": "0 1 0 0"
              }
            }
          }
        },
        {
          "-class": "case",
          "#text": "   "
        }
      ],
      "script": {
        "-type": "text/javascript",
        "-src": "x3dom.js"
      }
    }
  }
}
	'.
	^ json.
]

{ #category : #'render as X3D' }
HumSolid >> x3dExampleXML [
	"Example to aid design 
	- This example shows how X3D is embedded in an HTML page."
	| xml |
	xml := '
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
        <meta http-equiv="X-UA-Compatible" content="chrome=1" />
		<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
		<title>Primitives: Box, Cone, Cylinder and Sphere Primitives</title>
        <link rel="stylesheet" type="text/css" href="x3dom.css" /
	</head>
       
<body>

    <h1>Primitives: Box, Cone, Cylinder and Sphere Primitives</h1>
	
	<p class="case">
		<X3D xmlns="http://www.web3d.org/specifications/x3d-namespace" id="boxes" showStat="true" showLog="false" x="0px" y="0px" width="400px" height="400px">
			<Scene>
				<Background skyColor="1 1 1"" />
				
				<Transform DEF="coneTrafo" translation="-4.5 0 0">
					<Shape DEF="coneShape">
						<Appearance DEF="coneApp">
							<Material diffuseColor="0 1 0" specularColor=".5 .5 .5" />
						</Appearance>
						<Cone DEF="cone" />
					</Shape>
				</Transform>
				
				<Transform DEF="boxTrafo" translation="-1.5 0 0">
					<Shape DEF="boxShape">
						<Appearance DEF="boxApp"> 
							<Material diffuseColor="1 0 0" specularColor=".5 .5 .5" />
						</Appearance>
						<Box DEF="box" />
					</Shape>
				</Transform>
                
				<Transform DEF="sphereTrafo" translation="1.5 0 0">
					<Shape DEF="sphereShape">
						<Appearance DEF="sphereApp">
							<Material diffuseColor="0 0 1" specularColor=".5 .5 .5" />
						</Appearance>
						<Sphere DEF="sphere" />
					</Shape>
				</Transform>
				
				<Transform DEF="cylinderTrafo" translation="4.5 0 0">
					<Shape DEF="cylinderShape">
						<Appearance DEF="cylinderApp">
							<Material diffuseColor="1 1 0" specularColor=".5 .5 .5" />
						</Appearance>
						<Cylinder DEF="cylinder" radius="1.0" height="2.0" />
					</Shape>
				</Transform>
                
				<Viewpoint centerOfRotation="0 0 0" position="0 0 15" orientation="0 1 0 0" />
			</Scene>
        </X3D>
	</p>
	
	<p class="case"> &nbsp; </p>
	
	<script type="text/javascript" src="x3dom.js"></script>
   

</body>
</html>
'.
	^xml.
]

{ #category : #'render as X3D' }
HumSolid >> x3dMaterial [
	"Return X3D element for appearance/material of this color and opacity.
	"
	| x3d c |
	self assert: ( solidColor isKindOf: Color ).
	c := solidColor.
	x3d := self x3dMaterialColorRed: (c red) green: (c green) blue: (c blue) alpha: (c alpha).
	^x3d.
]

{ #category : #'render as X3D' }
HumSolid >> x3dMaterialColorRed: red green: green blue: blue alpha: alpha [ 
	"Return X3D element for appearance/material of this color and opacity."
	| x3d calc space dict |
	"All of the arguments are between zero and one."
	{ red. green. blue. alpha. } do: [ :x | self assert: ( x >= 0.0 and: [ x <= 1.0 ]) ].

	space := String space.
  calc := HumCalculator new.
  dict := Dictionary new.
  dict at: 'color' put: (red printShowingDecimalPlaces:2), space, 
                      (green printShowingDecimalPlaces:2), space, 
                       (blue printShowingDecimalPlaces:2), space, 
                      (alpha printShowingDecimalPlaces:2).
	x3d := calc xml: 'material' dictionary: dict.
	^x3d.
]

{ #category : #'render as X3D' }
HumSolid >> x3dShape [
	"Produce X3D XML shape element"
	| x3d  |
	"Check that my typeOfSolid instance variable is x3d compatible."
	self assert: ( #( #box #cone #cylinder #sphere) includes: typeOfSolid ).
	x3d := self x3dShape: (typeOfSolid asString) diffuseColor: (self x3dColor) specularColor: '0.5 0.5 0.5'.
	^x3d.
]

{ #category : #'render as X3D' }
HumSolid >> x3dShape: typeOfShape diffuseColor: diffuseColor specularColor: specularColor [
	"Produce X3D XML shape element - override instance variable color?"
	| x3d calc template parameters |
	calc := HumCalculator new.
	template := '
				<Transform translation="@position">
					<Shape>
						<Appearance>
							<Material diffuseColor="@diffuseColor" specularColor="@specularColor" />
						</Appearance>
						<@typeOfShape DEF="NONE" id="@id" size="@extent" />
					</Shape>
				</Transform>
				'.
	parameters := Dictionary new.
	parameters at: 'id' put: (self id);
						at: 'position' put: ( self x3dCenter );
	           at: 'typeOfShape' put: typeOfShape; 
             at: 'diffuseColor'  put: diffuseColor; 
             at: 'specularColor'  put: specularColor; 
             at: 'extent'   put: ( self x3dExtent ).
	x3d := calc fillTemplate: template fromDictionary: parameters.
	^x3d.
]
