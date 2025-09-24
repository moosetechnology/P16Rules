Class {
	#name : 'P16APIVisualization',
	#superclass : 'MiAbstractVisualization',
	#instVars : [
		'builder'
	],
	#category : 'P16-Rules-API-browser',
	#package : 'P16-Rules',
	#tag : 'API-browser'
}

{ #category : 'running' }
P16APIVisualization >> buildInCanvas: aCanvas [

	aCanvas @ RSCanvasController new noLegend.

	builder := P16APIMapBuilder new
		mapModel: owner specModel;
		container: aCanvas;
		yourself.
	builder build
]

{ #category : 'accessing' }
P16APIVisualization >> miSelectedItem [

	^ self canvas selectedShapes
		reject: #isLine
		thenCollect: [ :shape | shape model rawModel ]
]
