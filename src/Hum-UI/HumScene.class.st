"
Scene attributes include sky, solids, cameras, layers.

In a model-view-controller (MVC) context, a Scene is a model.
We use a ViewPort Widget to visualize the content as seen by a Camera in the Scene.

Data Flow:

Scene entities include solids, assemblies, cameras.

A user interface layout is controlled by Panes.
A Pane may contain Widgets.
A ViewPort Widget is a viewer-controller connected to a Camera in a Scene.

I have found the Morph API and OpenGL API to be much too raster-oriented.
Too much of the backend technology bleeds through into the API.
I am trying to create an architecture (and API) where the rendering technology does not bleed into the view API (to say nothing of the scene representation).
For example, the same scene could be rendered on a screen or via 3D printer.
"
Class {
	#name : #HumScene,
	#superclass : #HumAssembly,
	#category : #'Hum-UI'
}

{ #category : #'render as Three.js' }
HumScene >> asThreeJS [
	"Render the scene as ThreeJS"
	| js calc prologTemplate epilogTemplate dictionary |
	calc := HumCalculator new.
	dictionary := Dictionary new.
	dictionary at: 'sceneID' put: (self asCamelCase).
	"Prolog: Create the ThreeJS scene with appropriate attributes."
	js := self setupScene4ThreeJS.
	"Render the content (layers or objects)"
	js := js, ( self asThreeJSGeometry ).
	"Append the epilog."
	epilogTemplate := 'setupScene();'.
	js := js, ( calc fillTemplate: epilogTemplate fromDictionary: dictionary ).
	^js.
]

{ #category : #'render as Three.js' }
HumScene >> asThreeJSGeometry [
	"Render the assembly as ThreeJS geometry"
	| js |
	"Render the content (layers or objects)"
	js := ( super asThreeJS ).
	^js.
]

{ #category : #'render as Three.js' }
HumScene >> asThreeJSinHTML [
	"Wrap ThreeJS rendering with HTML5."
	| html calc js worldScript dictionary  template |
	calc := HumCalculator new.
	
	html := '<!DOCTYPE html>
<html lang="en">
	<head>
		<title>three.js webgl - orbit controls</title>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
		<style>
			body {
				color: #000;
				font-family:Monospace;
				font-size:13px;
				text-align:center;
				font-weight: bold;

				background-color: #fff;
				margin: 0px;
				overflow: hidden;
			}

			#info {
				color:#000;
				position: absolute;
				top: 0px; width: 100%;
				padding: 5px;

			}

			a {
				color: red;
			}
		</style>
	</head>

	<body>
		<div id="container"></div>
		<!--
		<div id="info">
			<a href="http://threejs.org" target="_blank">three.js</a> - orbit controls example
		</div>
		-->

		<script src="js/three.min.js"></script>

		<script src="js/OrbitControls.js"></script>

		<script src="js/Detector.js"></script>
		
		<script src="js/Stats.js"></script>


		<script>

			if ( ! Detector.webgl ) Detector.addGetWebGLMessage();

			var container, stats;

			var camera, controls, scene, renderer, myAssembly;

			var cross;

			init();
			animate();

			function init() {

				camera = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 1000 );
				camera.position.z = 500;

				controls = new THREE.OrbitControls( camera );
				controls.addEventListener( "change", render );

				scene = new THREE.Scene();
				//scene.fog = new THREE.FogExp2( 0xcccccc, 0.002 );

				// world
				
				myAssembly = buildMyAssembly();  // Function is defined in separate script tag.
				scene.add( myAssembly );
				
				// lights

				light = new THREE.DirectionalLight( 0xffffff );
				light.position.set( 1, 1, 1 );
				scene.add( light );

				light = new THREE.DirectionalLight( 0x002288 );
				light.position.set( -1, -1, -1 );
				scene.add( light );

				light = new THREE.AmbientLight( 0x222222 );
				scene.add( light );


				// renderer

				renderer = new THREE.WebGLRenderer( { antialias: false } );
				// renderer.setClearColor( scene.fog.color, 1 );
				renderer.setSize( window.innerWidth, window.innerHeight );

				container = document.getElementById( "container" );
				container.appendChild( renderer.domElement );
				
				// stats pane
				stats = new Stats();
				stats.domElement.style.position = "absolute";
				stats.domElement.style.top = "0px";
				stats.domElement.style.zIndex = 100;
				container.appendChild( stats.domElement );

				//

				window.addEventListener( "resize", onWindowResize, false );

			}

			function onWindowResize() {

				camera.aspect = window.innerWidth / window.innerHeight;
				camera.updateProjectionMatrix();

				renderer.setSize( window.innerWidth, window.innerHeight );

				render();

			}

			function animate() {

				requestAnimationFrame( animate );
				controls.update();

			}

			function render() {

				renderer.render( scene, camera );
				stats.update();

			}

		'.
		"Define a geometry named by (self asCamelCase)."
		js := (self asThreeJSGeometry ).  
		"Generate additional function to build geometry and insert it into scene."
		dictionary := Dictionary new.
		dictionary at: 'assemblyID' put: (self asCamelCase ).
		template := '
			function buildMyAssembly() {
			', js,
			'  return @assemblyID;
			}'.
		worldScript := calc fillTemplate: template fromDictionary: dictionary.
		html := html, worldScript.
		
		"Complete the HTML."
		html := html, '
		</script>

	</body>
</html>
'.
	^html.
]

{ #category : #'render as VPython' }
HumScene >> asVPython [
	"render scene and the objects in it via VPython."
	| pythonCode |
	pythonCode := self asVPythonPreamble.
	pythonCode := pythonCode, ( super asVPython ).
	^ pythonCode.
]

{ #category : #'render as VPython' }
HumScene >> asVPythonPreamble [
	| pythonCode |
	pythonCode := '
from visual import *
import Thing
from Thing import BoxThing
from Thing import PipeThing

# Set window attributes
scene.width=800
scene.height=800
scene.title="Scene Title"
scene.background = ( 0.7, 0.7, 0.7 )

# Set camera/viewport attributes
scene.autoscale = True
scene.center = ( 4*12, 13*12, 4*12 )
scene.up = ( 0, 0, 1 )'.
	^ pythonCode.
]

{ #category : #'as yet unclassified' }
HumScene >> jump: aTime [
	"TODO: Is this consistent with HumSimulator?"
	self parts do: [ :part | part jump: aTime ].
]

{ #category : #'render as Three.js' }
HumScene >> setupFloor4ThreeJS [
	"Provide boilerplate that creates a visible floor."
	| js |
	"NOTE: JavaScript must call setupScene() before setupFloor()."
	js := 'function setupFloor() {
  // Floor
  var geometry = new THREE.PlaneGeometry(2000, 2000, 20, 20);
  var material = new THREE.MeshBasicMaterial({color: 0x9db3b5, overdraw: true});
  var floor = new THREE.Mesh(geometry, material);
  // floor.rotation.x = -90 * Math.PI / 180;
  scene.add(floor);
	}.'.
	"TODO: Parameterize the size of the floor."
	^ js.


]

{ #category : #'render as Three.js' }
HumScene >> setupScene4ThreeJS [
	""
	| js |
	js := '
var camera, scene, renderer;

function setupScene() {
  document.body.style.backgroundColor = "#d7f0f7";
  setupThreeJS();

  requestAnimationFrame(function animate() {
    renderer.render(scene, camera);
    requestAnimationFrame(animate);
  });
}

function setupThreeJS() {
  scene = new THREE.Scene();

  camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 1, 10000);
  camera.position.y = 400;
  camera.position.z = 400;
  camera.rotation.x = -45 * Math.PI / 180;

  renderer = new THREE.CanvasRenderer();
  renderer.setSize(window.innerWidth, window.innerHeight);
  document.body.appendChild(renderer.domElement);
}'.
	^js, String cr.
]
