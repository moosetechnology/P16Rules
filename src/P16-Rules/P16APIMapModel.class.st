Class {
	#name : 'P16APIMapModel',
	#superclass : 'MiAbstractModel',
	#instVars : [
		'mooseModel'
	],
	#category : 'P16-Rules-API-browser',
	#package : 'P16-Rules',
	#tag : 'API-browser'
}

{ #category : 'running' }
P16APIMapModel >> allInvocations [

	^mooseModel
		ifNil: [ #() ]
		ifNotNil: [ :model |
			model allInvocations select: [ :i |
				(i sender mooseName includesSubstring: '.corese.command.') and:
				[ i candidates anyOne mooseName includesSubstring: '.corese.core.' ] ]
	].

]

{ #category : 'running' }
P16APIMapModel >> allPackages: invocations [

	^((invocations collect: [ :i | i sender parentType typeContainer ]) ,
	(invocations collect: [ :i | i candidates anyOne parentType typeContainer ]))
		asSet
]

{ #category : 'running' }
P16APIMapModel >> entities [

	^self entitiesFromInvocations: self allInvocations
]

{ #category : 'running' }
P16APIMapModel >> entitiesFromInvocations: invocationCollection [

	^((invocationCollection collect: [ :i | i sender ]) ,
	(invocationCollection collect: [ :i | i candidates anyOne ]))
		asSet
]

{ #category : 'running' }
P16APIMapModel >> links [

	^self allInvocations
]

{ #category : 'accessing' }
P16APIMapModel >> mooseModel [

	^ mooseModel
]

{ #category : 'accessing' }
P16APIMapModel >> mooseModel: anObject [

	mooseModel := anObject.
	browser runVisualization
]
