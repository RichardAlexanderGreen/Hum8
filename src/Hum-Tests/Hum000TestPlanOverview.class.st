"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BIG TEST PLAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
         1         2         3         4         5         6         7         8         9        10 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

USER INTERFACE TEST PLAN    (plan is WBS agenda, not a sequence)

Assemble user interface from components   
=======================================

A. Scribe interprets keyboard, mouse, and menu gestures.
   1. Keyboard has control or command or option pressed.
      a) Conventional commands 
           (copy, cut, paste, un-do, save, open, print, close window, quit application).
      b) Commands defined by the user, menu, or application default preferences.
   2. Mouse actions
      a) Mouse over. (May cause display.)
      b) Mouse button pressed. 
      c) Mouse moved.
      d) Mouse button released. (Buttons invoke commands.)
   3. User selects action from menu.
      a) Create menu | submenu | toolbar.
      b) Respond to user navigation.
      c) Send (user-selected) command.

B. Painter creates 2-D objects in the user’s viewport.
   1. Create billboard in anchored location
   2. Create floating billboard in front of camera. (or near mouse cursor).
   3. Create window (viewport).
   4. Move billboard’s text-cursor (left, right, up, down, jump to).
   5. Move billboard to a new anchored location.
   6. Draw text on billboard at cursor.           (Side-effect: Cursor moves to end of text).
   7. Draw lines and shapes on billboard.           (A diagram may direct the painter.) 
C. Sculptor creates 3-D objects in the user’s viewport.
   1. Create 3-D shapes via
      a) rotations. 
      b) extrusion.
      c) cut.
      d) fill with material.
      e) cover with texture.
   2. Common tasks (scripts / macros / routines)
      a) Create deck, wall, door, window.
      b) Create light.
      c) Create room.
      d) Place billboard on wall.
   3. Create, move, animate avatar.
      a) Create avatar.
      b) Move avatar.
      c) Animate avatar.

D. Viewport actions affect a window (viewport).
   1. Slide, pan, and zoom viewport.
      a) Slice actions are like document-centric scrolling.
      b) Pan actions are like rotating a camera up-down, left-right.
      c) Zoom actions are like a zoom lens widening or narrowing the field of view 
            (as if the camera moved, but the camera does not move).
   2. Move viewport to a new place in virtual world.
      a) Rotate camera (same as pan actions).
      b) Step forward | backward.
      c) Side-step left | right.
      d) Step-Turn left | right.
      e) Step up (rise) | down (descend).
      f) Move viewport to floor location under cursor.
      g) Move viewport to face wall under cursor.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
II. Programmer Assistant (PA) User-Dialogs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A. Ontology Actions
   1. New ontology.
   2. Save ontology on file. (Save As on new file)
   3. Load ontology from file
   4. Merge ontology from (TBD: file or another PA).
   5. Test run ontology.
   6. Deploy ontology?  (??? What does ‘deploy’ portend ???)

B. Frame Editor Actions
   1. Usual text edit actions:
      a) commands: (copy, cut, paste, un-do, save, open, print, close window)
      b) cursor moves: (up, down, left, right, top, bottom, . . .)
   2. PA-specific actions:
      a) [Line updated] event causes the logical-line and frame to be checked.
         (1) The logical-line is rendered. 
             Keywords and nouns are emphasized. Nouns have links. 
         (2) If the logical-line is not understood (no definition in ontology or DSL), 
             the line is flagged (with a question-mark).
         (3) If a noun lacks an antecedent in the frame, the noun is flagged (color code).
      b) [Insert/Append Instruction] - Instructions are indented.
         (1) In an action frame, 
               the automatic indent matches the preceding statement’s indent 
               unless it was a control statement (ending with a colon). 
                  And then, the indentation is increased by one.
         (2) In plan and dialog frames, 
               instructions have only one level of indent 
               because control statements are not allowed in those contexts.
         (3) In dialog frames, 
               the user indicates an instruction by starting the line with dot [tab].
      c) [Submit frame] command causes the ontology to be 
         (1) updated.
         (2) versioned.
         (3) re-evaluated. (problems flagged)
         (4) re-displayed. (all views rebuilt)
      d) [Test Dialog] - in dialog run-time with mock agents. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
III. Run-Time Test Cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A. Messenger
   1. The actors (agents) communicate via the Messenger.
   2. Messenger is addressed via a URI.
   3. Messenger records each message in a log file.
   4. In test mode, 
         the messenger can replay the messages 
         that were sent to an actor during some period of time. 
         (This capability enables simulations.)
   5. In test mode, 
         messages can only be communicated 
         between actors that are also in test mode.

B. Resource Manager (RM) - assigns tasks to actors.
   1. Actor checks-in (announces availability to perform specific roles).
   2. Assign task (action-statement) to actor.
      a) Job-ticket contains action-statement, noun-values, 
            request context (requesting actor, and instruction-pointer).
      b) The RM assigns an available actor.
      c) The RM sends the job-ticket to the assigned actor. 
            (via Messenger)
   3. Actor has completed task.
      a) The resources consumed (actor’s time, etc) are recorded on the job ticket.
      b) Any computed results are added to the job-ticket.
            (Convention: Actions results have a ‘giving’ clause.)
      c) RM sends resource consumption data to Bookkeeper.
      d) Task complete notice (with job-ticket) is sent to requester.
            (The requester resumes execution of the plan.)
C. Bookkeeper - tracks resource consumption
   1. Job-ticket resource consumption is recorded.
   2. Resource dimensions include job, resource, 
         provider (actor, role), consumer (actor, role), and date-time.
   3. Actors may decrement, increment inventories.
   4. Actors may set inventory level (initialization, audit).

D. Supervisor - controls execution of plans and dialogs.
   1. Delegate task.
         (The current actor has delegated a task to another role.)
      a) Send delegated task to Resource Manager. (RM)
         (The RM will assign the task to an available actor.) 
   2. Resume suspended action.
         (When a task is delegated to another role, 
            the current task execution is suspended.)
"
Class {
	#name : #Hum000TestPlanOverview,
	#superclass : #Object,
	#category : #'Hum-Tests'
}

{ #category : #'as yet unclassified' }
Hum000TestPlanOverview >> aReadMe [
	"See the class description for the intended (future) tests."
	^'See the class description for the intended (future) tests.'
	
]

{ #category : #'as yet unclassified' }
Hum000TestPlanOverview >> givenWhenThenInHTML [
	"HTML GivenWhenThen frames."
^'<html>
<head>
	<title>Hum PA Given-When-Then</title>
	<style type="text/css">
		pre.Reqt {font-size: Larger}
		pre.Design {font-size: Smaller}
	</style>
</head>
<body>
	
<h1>
	<center>
		Web 
		<br/>Programmers Assistant
		<br/>Given When Then
	</center>
</h1>

<h2>
	<center>
		The Programmers Assistant 
		<br/>User Interface behavior 
		<br/>is defined 
		<br/>via Given-When-Then story cards.
	</center>
</h2>

<table border=1 cellpadding=6>
<tr> <th>GIVEN WHEN THEN</th> <th>ARCHITECTURE CONSEQUENCE</th> </tr>
</pre><!-- =============== --></td></tr><tr><td><pre class="Reqt">
<b>Given:</b> User is editing a frame.
<b>When:</b> Text cursor moves off current line  
      (key return, up, down, mouse click).

<b>Then:</b> Current line is pretty-printed.
<b>Then:</b> (also)  Current frame is critiqued.
<td><pre class="Design">
Either use (CodeMirrror.js) 
  or stick with making one line at a time 
  using &lt;input&gt; text or test-area.
Comment: CodeMirror is probably the ideal solution. 
However, it may require a lot of work to get CodeMirror 
  to signal the Web-PA properly 
  and for the WebPA to interact with the code mirror.
</pre></td>
</pre><!-- =============== --></td></tr><tr><td><pre class="Reqt">
<b>Given:</b> User has navigated to a frame opening dialog.
<b>When:</b> User is entering the frame title statement.
<b>Then:</b>  Auto-completion is offered for title statements.
<b>When:</b> User has completed entering the frame title statement.
<b>Then:</b>  The code text is appropriately initialized 
     (and made visible), depending on the type of frame.
    -- Empty frame may be a template.
    -- Code frame is pretty-printed.
    -- The first line is given focus (and/or highlighted).
<td><pre class="Design">
Use JQuery auto-completion facility.
Looks easy enough.

Open a new tab-pane with the code text.</pre></td>
</pre><!-- =============== --></td></tr><tr><td><pre class="Reqt">
<b>Given:</b> User is entering an instruction.
<b>When:</b> User enters a delegated instruction.
<b>Then:</b>  Auto-Completion is offered for the given role name`s public actions.
(A role`s public actions are those preceded with the label "Action:")
<td><pre class="Design">
Use JQuery auto-completion.

PA (model of PA) should implement the query as a method.
</pre></td>
</pre><!-- =============== --></td></tr><tr><td><pre class="Reqt">
<b>Given:</b> User is inserting a delegated instruction into some frame.
<b>When:</b> The statement is a not one of that role`s current public actions.
<b>Then:</b>  Action (empty frame) is added 
    -- after user confirms intent to add a new action.
<b>When:</b> The statement currently references a private (To:) procedure.
<b>Then:</b> The procedure is converted to a public"Action:" procedure
    -- after user confirms intent to convert.
<td><pre class="Design">
Use Seaside dialog to confirm user intent.

PA modifies underlying code.

If a converted "To:" statement is currently displayed or diagrammed,
some means is needed to signal that it has changed from "To:" to "Action:".
(Brute force, we could simply tell every display to update from the model.)
</pre></td>
</pre><!-- =============== --></td></tr><tr><td><pre class="Reqt">
<b>Given:</b> User is editing a frame`s code.
<b>When:</b> User moves text cursor to a new line . . .
<b>Then:</b> New line is highlighted.
<b>Then:</b> (also)  Old line is not.
<td><pre class="Design">
This assumes we are <u>not</u> using CodeMirror.js.

It is a work-around.
</pre></td>
</pre><!-- =============== --></td></tr><tr><td><pre class="Reqt">
<b>Given:</b> User is editing a frame`s code.
<b>When:</b> User presses something other than a line-selector key [up/down] . . .
<b>Then:</b> The line under the text cursor is put into edit mode.
<b>When:</b> User presses enter or return.
<b>Then:</b>  An empty line is inserted with appropriate indentation.
<td><pre class="Design">
This assumes we are <u>not</u> using CodeMirror.js.

Otherwise CodeMirror`s normal behavior should be adequate.
</pre></td>
</pre><!-- =============== --></td></tr><tr><td><pre class="Reqt">
<b>Given:</b> User is editing a plan frame.
<b>When:</b> User enters a precondition statement.
<b>Then:</b> Auto-completion is offered  (sourced from known conditions.)
<td><pre class="Design">
Use JQuery auto-completion. 

PA will provide a suitable collection (of strings) via a method.
</pre></td>
</pre><!-- =============== --></td></tr><tr><td><pre class="Reqt">
<b>Given:</b> User is editing a plan frame.
<b>When:</b>  User enters new precondition  
     (one that does not match a known condition)
<b>Then:</b> Condition is added to conditions collection
    unless the annotation says "[assumed]."
<b>When:</b> Condition is added . . .
<b>Then:</b> an empty frame is inserted into frames.
    -- (This empty frame simplifies some things.)
<td><pre class="Design">
Q: What happens when/if the user deletes the only reference later?
A: Will think about it.  (TBD)

The UI simply tells PA>>addLine: aPlanFrameLine.
The PA then performs the rest.

</pre></td>
</pre><!-- =============== --></td></tr><tr><td><pre class="Reqt">
<b>Given:</b> Statement is in a displayed view.
<b>When:</b> Statement has no known nouns.
    -- because it is entered before nouns are defined.
    -- because (last) noun became undefined.
<b>Then:</b> Statement is highlighted with an"error" color.
    -- background / foreground is TBD
<b>Then:</b> Critique says ". . . no known nouns"
<td><pre class="Design">
Since the set of diagrams displays all of the statements,
  at least implicitly, 
  it appears that PA needs to scan all statements in the ontology 
  and update the known nouns attribute.
The WebPA may then update each display 
  that is affected by statement qualities.

This looks like a job for "Announcements" (Pharo publish/subscribe).
</pre></td>
</pre><!-- =============== --></td></tr>
<table>
'.
]

{ #category : #'as yet unclassified' }
Hum000TestPlanOverview >> progress [
	^ ' 
	01-Jan-2012:  33 test  65 implementation methods completed.
	02-Jan-2012:  37 test  76 implementation methods completed.
	03-Jan-2012:  38 test  91 implementation methods completed. -- 1079+788+188 = 2055 Lines in ST (file-out) files.
	04-Jan-2012:  39 test 111 implementation methods completed -- 1088+825+152 = 2065 Lines ( after refactoring ).
	---- Start counting assert: as indicator of number of tests instead. ---
	06-Jan-2012:   90 asserts 155 implementation methods completed -- 1189+1034+158  = 2381 Lines 
	09-Jan-2012: 101 asserts 146 implementation methods completed -- 1224+1114+162 =  2500 Lines (at 3:20 pm)
	12-Jan-2012: 164 asserts 169 implementation methods completed -- 1617+1364+169+54 = 3204 Lines (at 3:30 pm)
	15-Jan-2012: 211 asserts 186 implementation methods completed -- 1850+1518+208+54 = 3630 Lines (at 9:15 pm)
	18-Jan-2012: 247 asserts 208 implementation methods completed -- 2113+1709+230+54 = 4106 Lines (at 1:50 pm)
	--- Started work on UI ----
	20-Jan-2012: 305 asserts 259 implementation methods completed -- 2314+1722+230+54+430 = 4750 Lines (at 5:05 pm) 
	06-Feb-2012: 363 asserts 345 implementation methods completed -- 2742+1919+253+596+547 = 6057 Lines ==> ~ 5274 LoC
	28-Mar-2012: 534 asserts 402 implementation methods completed -- 254+2388+804+3892+804 = 8142 Lines ==> ~ 6500 LoC
	10-Apr-2012: 615 asserts 419 implementation methods completed -- 254+2700+804+4406+870 = 9034 Lines ==> ~ 7200 LoC 
	29-May-2012: Basically got lost trying to find ways to do 3D modeling and also surveying free design tools.
	24-July-2012: Got distracted learning Python and using Visual Python (VPython) and using it to model trailer and to visualize Game Of Life in 3D.
	28-September-2012: Got around to learning Seaside and starting to implement the IDE.
					I have a site initiated at Seaside hosting.
					Took a look at Magritte -- Decided to not use it in the browser. 
					   (too many layers and dependencies, not enough comments in the code).
					I also toyed with Pier (a content management system based on Seaside and Magritte) 
					-- It has still another wiki-mark-up.
					Pier might be worth adopting later as a wiki and book generator. 
					I am not convinced yet, 
					  but (notably) some of the Pharo/Seaside/Pier books seem to be produced via Pier.
	28-September-2012: Made sure that all of my classes have comments. 
	                  (Pet peeve about others code -- must comply myself.)
	28-September-2012: 795 asserts 533 implementation methods completed -- 12592 ==> ~ 10,000 LoC.
	17-October-2012:   658 asserts -- I removed a large number of redundant tests that had been cut and pasted into HumSeasideTests.
	17-October-2012:   658 asserts, 553 implementation methods completed-- 12173 ==> still roughly 10,000 LoC.
	*** ~5 months without a report -- Mostly working on HumSeaside but distracted with Python/Javascript. ***
	11-March-2013:     704 asserts, 584 implementation methods completed -- 13,716 * (10/12) ==> 11,430 LoC.
	*** Implementing HumDiagram, HumFuzzy, HumMeasure.
	25-April-2013:     785 asserts, 630 implementation methods completed -- 16,824 * (10/12) ==> 14,020 LoC.
	*** Miscelaneous refactoring and tinkering ***
	05-February-2014: 1033 asserts 1030 implementation methods completed -- 19,888 * (10/12) ==> 16,573 LoC.
	10-September-2014: 1181 asserts, 1163 implementation methods completed -- 28,142 * (10/12) ==> 23,451 LoC
	'
]
