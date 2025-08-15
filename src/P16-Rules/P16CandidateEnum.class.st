"
Represente un potentiel type Enum

variables d'instance:
- implementingClass : classe implementant les attirbuts static (note: ce n'est pas une vraie variable d'instance)
- values : liste des attibuts static qui seraient membre du Enum
- declaredType : type actuellement declaré de tous les attributs
- users : liste des methodes de la implementingClass qui utilise au moins 2 attributs
"
Class {
	#name : 'P16CandidateEnum',
	#superclass : 'Object',
	#instVars : [
		'values',
		'declaredType',
		'users'
	],
	#category : 'P16-Rules-rules',
	#package : 'P16-Rules',
	#tag : 'rules'
}

{ #category : 'instance creation' }
P16CandidateEnum class >> type: aType values: aCollection [

	^self new
		declaredType: aType ;
		values: aCollection ;
		yourself
]

{ #category : 'accessing' }
P16CandidateEnum >> declaredType [

	^ declaredType
]

{ #category : 'accessing' }
P16CandidateEnum >> declaredType: anObject [

	declaredType := anObject
]

{ #category : 'accessing' }
P16CandidateEnum >> implementingClass [

	^values anyOne parentType
]

{ #category : 'initialization' }
P16CandidateEnum >> initialize [ 

	super initialize.
	
	users := OrderedCollection new
]

{ #category : 'tracing' }
P16CandidateEnum >> print [

	'' traceCr.

	'## ' trace.
	self implementingClass mooseName traceCr.

	'' traceCr.

	'### Values' traceCr.
	
	self values do: [ :val |
		'- ' trace.
		val name traceCr.
	].

	self users ifEmpty: [ ^self ].

	'' traceCr.

	'### Users' traceCr.

	self users do: [ :user |
		'- ' trace.
		user name traceCr.
	].
]

{ #category : 'accessing' }
P16CandidateEnum >> users [

	^users
]

{ #category : 'accessing' }
P16CandidateEnum >> users: aCollection [

	users := aCollection 
]

{ #category : 'accessing' }
P16CandidateEnum >> values [

	^ values
]

{ #category : 'accessing' }
P16CandidateEnum >> values: anObject [

	values := anObject
]
