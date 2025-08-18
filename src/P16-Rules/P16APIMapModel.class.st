Class {
	#name : 'P16APIMapModel',
	#superclass : 'MiAbstractModel',
	#instVars : [
		'mooseModel',
		'layers',
		'allInvocations'
	],
	#category : 'P16-Rules-API-browser',
	#package : 'P16-Rules',
	#tag : 'API-browser'
}

{ #category : 'accessing' }
P16APIMapModel >> allInvocations [

	allInvocations ifNotNil: [ ^allInvocations ].
	mooseModel ifNil: [ #() ].

	^allInvocations := mooseModel allInvocations select: [ :i |
		(i sender mooseName includesSubstring: '.corese.command.') and:
		[ i candidates anyOne mooseName includesSubstring: '.corese.core.' ] ]

]

{ #category : 'dependencies' }
P16APIMapModel >> calledMethods: anEntity [

	^self tgtMethodLayer select: [ :m |
		m incomingInvocations anySatisfy: [ :invok | invok source = anEntity ]
	]
]

{ #category : 'dependencies' }
P16APIMapModel >> callingMethods: anEntity [

	^self srcMethodLayer select: [ :m |
		anEntity incomingInvocations anySatisfy: [ :invok | invok source = m ]
	]
]

{ #category : 'dependencies' }
P16APIMapModel >> classDependents: anEntity [

	| methods |
	methods := self classMethods: anEntity.
	methods copy do: [ :m | methods addAll: (self pairedMethods: m) ].

	^methods 
]

{ #category : 'dependencies' }
P16APIMapModel >> classMethods: anEntity [

	^(self srcMethodLayer select: [ :m | m parentType = anEntity ]) asSet ,
	(self tgtMethodLayer select: [ :m | m parentType = anEntity ])
	
]

{ #category : 'dependencies' }
P16APIMapModel >> classParents: anEntity [

	^{anEntity . anEntity typeContainer}
]

{ #category : 'running' }
P16APIMapModel >> entities [

	^layers
		ifNil: [ #() ]
		ifNotNil: [layers flatten]
]

{ #category : 'highlighting' }
P16APIMapModel >> entitiesHighlightList: anEntity [

	(self srcPackageLayer includes: anEntity) ifTrue: [ ^self srcPackageHighlightList: anEntity ].
	(self srcClassLayer   includes: anEntity) ifTrue: [ ^self srcClassHighlightList:   anEntity ].
	(self srcMethodLayer  includes: anEntity) ifTrue: [ ^self srcMethodHighlightList:  anEntity ].
	(self tgtMethodLayer  includes: anEntity) ifTrue: [ ^self tgtMethodHighlightList:  anEntity ].
	(self tgtClassLayer   includes: anEntity) ifTrue: [ ^self tgtClassHighlightList:   anEntity ].
	(self tgtPackageLayer includes: anEntity) ifTrue: [ ^self tgtPackageHighlightList: anEntity ].

	^#()
]

{ #category : 'highlighting' }
P16APIMapModel >> highlightList: anEntity [

	| entities |
	entities := self entitiesHighlightList: anEntity.
	entities addAll: (self linksBetween: entities).

	^entities
]

{ #category : 'running' }
P16APIMapModel >> initializeLayers [

	layers := { 1 . 2 . 3 . 4 . 5 . 6 }.

	layers at: 3 put: (self allInvocations collectAsSet: #source).
	layers at: 2 put: (self srcMethodLayer collectAsSet: #parentType).
	layers at: 1 put: (self srcClassLayer collectAsSet: #typeContainer).

	layers at: 4 put: (self allInvocations collectAsSet: [:invok | invok target anyOne]).
	layers at: 5 put: (self tgtMethodLayer collectAsSet: #parentType).
	layers at: 6 put: (self tgtClassLayer collectAsSet: #typeContainer).

]

{ #category : 'dependencies' }
P16APIMapModel >> invocationsBetween: entities [

	^(self allInvocations
		select: [ :invok |
			(entities includes: invok source) and:
			[ entities includes: invok target anyOne ]
		])
		collect: [ :invok |
			invok source -> invok target anyOne
		]
]

{ #category : 'accessing' }
P16APIMapModel >> layers [

	^ layers
]

{ #category : 'accessing' }
P16APIMapModel >> layers: anObject [

	layers := anObject
]

{ #category : 'dependencies' }
P16APIMapModel >> linksBetween: entities [

	^(self invocationsBetween: entities) , (self ownershipBetween: entities)
]

{ #category : 'dependencies' }
P16APIMapModel >> methodParents: anEntity [

	^{anEntity . anEntity parentType . anEntity parentType typeContainer}
]

{ #category : 'dependencies' }
P16APIMapModel >> methodRelatedEntities: anEntity [

	^{ anEntity parentType } , (self pairedMethods: anEntity) asOrderedCollection 
]

{ #category : 'accessing' }
P16APIMapModel >> miSelectedItem [

	^self entities
]

{ #category : 'accessing' }
P16APIMapModel >> mooseModel [

	^ mooseModel
]

{ #category : 'accessing' }
P16APIMapModel >> mooseModel: anObject [

	mooseModel := anObject.

	allInvocations := nil.
	mooseModel entities do: [ :fmx | fmx removeCache: #p16APIHNode ].

	self initializeLayers.

	browser runVisualization
]

{ #category : 'dependencies' }
P16APIMapModel >> ownershipBetween: entities [

	^entities
		collect: [ :child || childParents |
			childParents := child parents.
			entities
				detect: [ :parent | (child class ~= parent class) and: [childParents includes: parent] ]
				ifOne: [ :parent | parent -> child ]
				ifNone: [ nil ]
			]
		thenReject: #isNil
]

{ #category : 'dependencies' }
P16APIMapModel >> packageClasses: anEntity [

	^(self srcClassLayer select: [ :m | m typeContainer = anEntity ]) asSet ,
	(self tgtClassLayer select: [ :m | m typeContainer = anEntity ])
]

{ #category : 'dependencies' }
P16APIMapModel >> pairedMethods: anEntity [

	^(self srcMethodLayer includes: anEntity)
		ifTrue: [ self calledMethods: anEntity ]
		ifFalse: [ self callingMethods: anEntity ]
]

{ #category : 'dependencies' }
P16APIMapModel >> relatedEntities: anEntity [
	"only needs to return the 'depending' entities"

	(self srcClassLayer   includes: anEntity) ifTrue: [ ^{anEntity typeContainer} ].
	(self srcMethodLayer  includes: anEntity) ifTrue: [ ^{anEntity parentType} ].
	(self tgtMethodLayer  includes: anEntity) ifTrue: [ ^{anEntity parentType} , (self pairedMethods: anEntity) asOrderedCollection ].
	(self tgtClassLayer   includes: anEntity) ifTrue: [ ^{anEntity typeContainer} ].

	^#()
]

{ #category : 'settings' }
P16APIMapModel >> settings [

]

{ #category : 'highlighting' }
P16APIMapModel >> srcClassHighlightList: anEntity [

	^(self classParents: anEntity) asSet ,
	 ((self classDependents: anEntity) flatCollect: [:m | self methodParents: m])
]

{ #category : 'accessing' }
P16APIMapModel >> srcClassLayer [

	^layers second
]

{ #category : 'highlighting' }
P16APIMapModel >> srcMethodHighlightList: anEntity [

	^(self methodParents: anEntity) asSet ,
	 ((self calledMethods: anEntity) flatCollect: [:m | self methodParents: m])
]

{ #category : 'accessing' }
P16APIMapModel >> srcMethodLayer [

	^layers third
]

{ #category : 'highlighting' }
P16APIMapModel >> srcPackageHighlightList: anEntity [

	^(Set with: anEntity),
	 ((self packageClasses: anEntity) flatCollect: [:c | self srcClassHighlightList: c])
]

{ #category : 'accessing' }
P16APIMapModel >> srcPackageLayer [

	^layers first
]

{ #category : 'highlighting' }
P16APIMapModel >> tgtClassHighlightList: anEntity [

	^(self classParents: anEntity) asSet ,
	 ((self classDependents: anEntity) flatCollect: [:m | self methodParents: m])
]

{ #category : 'accessing' }
P16APIMapModel >> tgtClassLayer [

	^layers fifth
]

{ #category : 'highlighting' }
P16APIMapModel >> tgtMethodHighlightList: anEntity [

	^(self methodParents: anEntity) asSet ,
	 ((self callingMethods: anEntity) flatCollect: [:m | self methodParents: m])
]

{ #category : 'accessing' }
P16APIMapModel >> tgtMethodLayer [

	^layers fourth
]

{ #category : 'highlighting' }
P16APIMapModel >> tgtPackageHighlightList: anEntity [

	^(Set with: anEntity),
	 ((self packageClasses: anEntity) flatCollect: [:c | self srcClassHighlightList: c])
]

{ #category : 'accessing' }
P16APIMapModel >> tgtPackageLayer [

	^layers sixth
]
