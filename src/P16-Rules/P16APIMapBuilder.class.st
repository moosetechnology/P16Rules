Class {
	#name : 'P16APIMapBuilder',
	#superclass : 'HSimpleVisualizationBuilder',
	#instVars : [
		'nodeStyle'
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

	self buildNodes.
	self buildDependencies.

	super build.

	self layoutNodes
]

{ #category : 'building' }
P16APIMapBuilder >> buildDependencies [

	self allNodes do: [ :hnode |
		(self mapModel relatedEntities: hnode rawModel) do: [ :related |
			(self ensureNodeFromEntity: related) dependencyTo: hnode
		]
	]
]

{ #category : 'building' }
P16APIMapBuilder >> buildNodes [

	rootNode  := HNode new
		addAll: self allNodes ;
		yourself.
]

{ #category : 'building' }
P16APIMapBuilder >> ensureNodeFromEntity: anEntity [

	^anEntity propertyNamed: #p16APIHNode ifAbsentPut: [ 
		anEntity removeCache: #highlightList.

		HNode new
			name: anEntity fullDisplayString ;
			rawModel: anEntity ;
			style: self nodeStyle ;
			yourself
	].
]

{ #category : 'accessing - attributes' }
P16APIMapBuilder >> hLinkFor: association [

	| hFrom hTo |

	hFrom := self ensureNodeFromEntity: association key.
	hTo := self ensureNodeFromEntity: association value.

	^hFrom dependencies
			detect: [ :hlink | (hlink from = hFrom) and: [ hlink to = hTo ] ]

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

{ #category : 'accessing - attributes' }
P16APIMapBuilder >> linkShapes: associations [

	| linkShapes |
	
	linkShapes := self container shapes select: #isLine.

	^associations collect: [ :assoc || shapeFrom shapeTo |
		shapeFrom := self container shapeFromModel: (self ensureNodeFromEntity: assoc key).
		shapeTo := self container shapeFromModel: (self ensureNodeFromEntity: assoc value).

		linkShapes detect: [ :link | (link from = shapeFrom) and: [ link to = shapeTo ] ]
	]
]

{ #category : 'accessing - attributes' }
P16APIMapBuilder >> nodeShapes: famixEntities [

	^self container shapesFromModels: (famixEntities collect: [ :fmx | fmx propertyNamed: #p16APIHNode])
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
	"note: both lists or sets, but we cannot use concatenation on sets :-(
	   so we make an OrderedCollection of it"

	^(self nodeShapes: (famixEntities reject: [ :fmx | fmx isAssociation ])) ,
	(self linkShapes: (famixEntities asOrderedCollection select: [ :fmx | fmx isAssociation ]))
	
]
