Class {
	#name : 'P16APIMapBuilder',
	#superclass : 'HSimpleVisualizationBuilder',
	#instVars : [
		'nodes',
		'nodeStyle',
		'layers'
	],
	#category : 'P16-Rules-API-browser',
	#package : 'P16-Rules',
	#tag : 'API-browser'
}

{ #category : 'accessing' }
P16APIMapBuilder >> allNodes [

	^self mapModel entities collect: [ :fmx | self ensureNodeFromEntity: fmx ]
]

{ #category : 'building' }
P16APIMapBuilder >> build [

	rootNode  := HNode new
		addAll: self allNodes ;
		yourself.

	super build.

	self layoutNodes
]

{ #category : 'building' }
P16APIMapBuilder >> ensureNodeFromEntity: anEntity [

	anEntity removeCache: #highlightList.

	^anEntity propertyNamed: #p16APIHNode ifAbsentPut: [ HNode new
		name: anEntity fullDisplayString ;
		rawModel: anEntity ;
		style: self nodeStyle ;
		yourself ].
]

{ #category : 'accessing - attributes' }
P16APIMapBuilder >> findHLinkFrom: srcMethod to: tgtMethod [

	^srcMethod dependencies
		detect: [ :hlink |
			(hlink from = srcMethod) and:
			[ hlink to = tgtMethod ] ]
]

{ #category : 'accessing - attributes' }
P16APIMapBuilder >> highlightable [
	"this method is lazy, it executes once and then stores the RSInteraction in #highlightable"

	| nodeHighlightColor linkHighlightColor |
	nodeHighlightColor := Color yellow "fromHexString: '9DD0B3'".
	linkHighlightColor := Color red.

	^highlightable ifNil: [ 
		highlightable := RSHighlightable new
			highlightShapes: [ :shape | 
				self shapesFromFamixModels: (self mapModel highlightList: shape model rawModel) ] ;

			when: RSHighlightEvent do: [ :evt |
				highlightable
					record: evt shape
					selector: #color
					value: (evt shape isNode
						ifTrue: [ nodeHighlightColor ]
						ifFalse: [ linkHighlightColor ]) ]
			for: self ;

			when: RSUnHighlightEvent do: [ :evt | 
				highlightable
					restore: evt shape
					selector: #color ]
			for: self ;

			yourself ]
]

{ #category : 'initialization' }
P16APIMapBuilder >> initialize [ 

	super initialize.

	nodes := Dictionary new.
	layers := OrderedCollection new.
	6 timesRepeat: [ layers add: OrderedCollection new ]
]

{ #category : 'building' }
P16APIMapBuilder >> layoutNodes [

	| layout shapeLayers |

	shapeLayers := self mapModel layers collect: [ :layer |
		self container shapesFromModels: (layer collect: [:fmx | fmx propertyNamed: #p16APIHNode]) ].

	layout := RSVerticalLineLayout new
		alignCenter ;yourself.

	shapeLayers do: [ :sl | layout	on: sl ].

	RSHorizontalLineLayout new
		alignMiddle;
		horizontalGap: 250;
		on: shapeLayers
]

{ #category : 'accessing' }
P16APIMapBuilder >> nodeStyle [

	^ nodeStyle ifNil: [ nodeStyle := MiArchitecturalMapStyle new ]
]

{ #category : 'accessing' }
P16APIMapBuilder >> nodeStyle: anObject [

	nodeStyle := anObject
]

{ #category : 'building' }
P16APIMapBuilder >> renderLinesIn: aCanvas [

	self lineBuilder
		canvas: aCanvas;
		shapes: aCanvas nodes;
		connectFromAll: #dependentsFromLinks
]

{ #category : 'accessing - attributes' }
P16APIMapBuilder >> shapesFromFamixModels: famixEntities [

	^self container shapesFromModels: (famixEntities collect: [ :fmx | fmx propertyNamed: #p16APIHNode])
]
