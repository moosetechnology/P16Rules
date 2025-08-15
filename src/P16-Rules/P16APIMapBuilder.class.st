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

	^layers flatten 
]

{ #category : 'accessing - attributes' }
P16APIMapBuilder >> ancestor: hnodeAncestor highlightList: highlightList [

	| ancestorHighlights |
	ancestorHighlights := hnodeAncestor rawModel propertyNamed: #highlightList ifAbsentPut: [ Set new ].
	ancestorHighlights addAll: highlightList
	
]

{ #category : 'building' }
P16APIMapBuilder >> build [

	self mapModel links do: [ :link | self buildLink: link ].

	rootNode  := HNode new
		addAll: self allNodes ;
		yourself.

	super build.

	self layoutNodes
]

{ #category : 'building' }
P16APIMapBuilder >> buildClassParents: aClass layers: parentLayers [

	| parentPackage |
	parentPackage := self ensureNodeFor: aClass rawModel typeContainer inLayer: parentLayers first.

	parentPackage dependencyTo: aClass.
]

{ #category : 'building' }
P16APIMapBuilder >> buildLink: anAssociation [

	| src tgt |
	src := self ensureNodeFor: anAssociation source        inLayer: self srcMethodLayer.
	tgt := self ensureNodeFor: anAssociation target anyOne inLayer: self tgtMethodLayer.

	src dependencyTo: tgt.

	self buildMethodParents: src layers: { self srcClassLayer . self srcPackageLayer }.
	self buildMethodParents: tgt layers: { self tgtClassLayer . self tgtPackageLayer }.

	self highlightList: src to: tgt.

]

{ #category : 'building' }
P16APIMapBuilder >> buildMethodParents: aMethod layers: parentLayers [

	| parentClass |
	parentClass := self ensureNodeFor: aMethod rawModel parentType inLayer: parentLayers first.

	parentClass dependencyTo: aMethod.
	
	self buildClassParents: parentClass layers: parentLayers allButFirst

]

{ #category : 'building' }
P16APIMapBuilder >> buildNodeFromEntity: anEntity [

	anEntity removeCache: #highlightList.

	^anEntity propertyNamed: #p16APIHNode ifAbsentPut: [ HNode new
		name: anEntity fullDisplayString ;
		rawModel: anEntity ;
		style: self nodeStyle ;
		yourself ].
]

{ #category : 'building' }
P16APIMapBuilder >> ensureNodeFor: anEntity inLayer: aLayer [

	^aLayer
		detect: [ :hnode | hnode rawModel = anEntity ]
		ifNone: [ aLayer add: (self buildNodeFromEntity: anEntity) ]

]

{ #category : 'accessing - attributes' }
P16APIMapBuilder >> highlightList: srcMethod to: tgtMethod [
	"#highlightList property in FamixEntities contains the list of HNode and HLink that should be highlighted
	 when the mouse hover this entity"

	|  hnodeClass |

	srcMethod rawModel propertyNamed: #highlightList put: { srcMethod . tgtMethod } , (self parentDependencies: srcMethod) , (self parentDependencies: tgtMethod) .
	tgtMethod rawModel propertyNamed: #highlightList put: (srcMethod rawModel propertyNamed: #highlightList).

	hnodeClass := (self hnodeParentsFor: srcMethod) anyOne.
	self ancestor: hnodeClass highlightList: (self parentDependencies: hnodeClass).
	self ancestor: (self hnodeParentsFor: hnodeClass) anyOne highlightList: (self hnodeParentsFor: hnodeClass).

	(self hnodeParentsFor: srcMethod) do: [ :p |
	self ancestor: p highlightList: (self parentDependencies: p).
	self ancestor: (self hnodeParentsFor: p) anyOne highlightList: (self hnodeParentsFor: p).
	]
]

{ #category : 'accessing - attributes' }
P16APIMapBuilder >> highlightable [
	"this method is lazy, it only executes once and then stores the result
	 #highlightable contains the highlighting interaction for all shapes"

	| nodeHighlightColor linkHighlightColor |
	nodeHighlightColor := Color yellow "fromHexString: '9DD0B3'".
	linkHighlightColor := Color red.

	^highlightable ifNil: [ 
		highlightable := RSHighlightable new
			highlightShapes: [ :shape | 
				self shapesFromModels: (shape model rawModel propertyNamed: #highlightList) ] ;

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

{ #category : 'accessing - attributes' }
P16APIMapBuilder >> hnodeParentsFor: methodHNode [

	^(methodHNode dependencies select: [ :dep | dep to = methodHNode ])
		collect: [ :hlink | hlink from ]

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

	"self reorderLayers: { self srcPackageLayer . self srcClassLayer . self srcMethodLayer }.
	self reorderLayers: { self tgtPackageLayer . self tgtClassLayer . self tgtMethodLayer }."

	shapeLayers := layers collect: [ :layer | self container shapesFromModels: layer ].

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

{ #category : 'accessing - attributes' }
P16APIMapBuilder >> parentDependencies: hnode [

	| incomingLinks |
	incomingLinks := hnode dependencies select: [ :dep | dep to = hnode ].

	^incomingLinks
		ifEmpty: [ #() ]
		ifNotEmpty: [ | parents |
			parents := incomingLinks collect: #from.

			incomingLinks , parents , (parents flatCollect: [:p | self parentDependencies: p])
		]
]

{ #category : 'building' }
P16APIMapBuilder >> renderLinesIn: aCanvas [

	self lineBuilder
		canvas: aCanvas;
		shapes: aCanvas nodes;
		connectFromAll: #dependentsFromLinks
]

{ #category : 'accessing' }
P16APIMapBuilder >> shapesFromModels: hEntities [

	^hEntities collect: [ :each |
		(each class = HNode)
			ifTrue: [ self container shapeFromModel: each ]
			ifFalse: [ self container shapes detect: [ :sh |
					sh isLine and:
					[ (sh model key = each from) and:
					[ sh model value = each to ] ]
				]
			]
	]
]

{ #category : 'accessing' }
P16APIMapBuilder >> srcClassLayer [

	^layers second
]

{ #category : 'accessing' }
P16APIMapBuilder >> srcMethodLayer [

	^layers third
]

{ #category : 'accessing' }
P16APIMapBuilder >> srcPackageLayer [

	^layers first
]

{ #category : 'accessing' }
P16APIMapBuilder >> tgtClassLayer [

	^layers fifth
]

{ #category : 'accessing' }
P16APIMapBuilder >> tgtMethodLayer [

	^layers fourth
]

{ #category : 'accessing' }
P16APIMapBuilder >> tgtPackageLayer [

	^layers sixth
]
