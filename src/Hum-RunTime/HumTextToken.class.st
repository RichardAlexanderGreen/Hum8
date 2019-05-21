"
A text is assumed have a collection of text-lines.
Each text line is assumed to be a collection of tokens.

Each token may have parameters that affect how it is rendered.
Rendering parameters include emphasis, color, highlight, font, relative height, and behavior.
Emphasis  parameters include isBold, isItalic, isUnderlined. 
Behavior  parameters include link, edtable.

Note: This design does NOT encourage renderings that change mid-word. 

It will require some trick to underline or bold part of a word and not the whole word.
The trick could be a ""no-space"" token that serves to separate the parts of a ""word"" with partial word rendering.

"
Class {
	#name : #HumTextToken,
	#superclass : #Object,
	#category : #'Hum-RunTime'
}
