"
Calcul les potentiel Enum implementés comme des liste d'attribut static.
Calcul aussi les methodes qui utilisent plusieurs de ces attributs.


Utilisation:
```
analyser := CorEnumAnalysis on: <votre modele>.
analyser findEnumsFromStatic.
analyser methodsAccessingEnums.
analyser print
```
"
Class {
	#name : 'P16RuleAnalyser',
	#superclass : 'Object',
	#instVars : [
		'model',
		'refutingHeuristics',
		'result',
		'lastAnalysis'
	],
	#category : 'P16-Rules',
	#package : 'P16-Rules'
}

{ #category : 'instance creation' }
P16RuleAnalyser class >> on: aModel [

	^self new
		on: aModel ;
		yourself
]

{ #category : 'private' }
P16RuleAnalyser >> callersOutsideParentClass: aMethod [
	"looks for methods calling aMethod that are not defined in the same class hierarchy"

	| owner |
	owner := aMethod parentType.

	^(OrderedCollection withAll: aMethod incomingInvocations)
		collect: [ :invocation | invocation sender ]
		thenReject: [ :caller | (caller parentType inheritsFrom: owner) not ]
]

{ #category : 'private' }
P16RuleAnalyser >> candidateEnums: aClass [
	"groups static attributes of aClass by their declaredType.
	 The heuristic is that if a given type (e.g. int) has more than 2 static attributes, then
	 they could be re-implemented as an enum.
	 Returns a list of candidateEnum-s"

	^(self staticAttributesByType: aClass)
		associations
			select: [ :association | association value size > 2 ]
			thenCollect: [ :association | P16CandidateEnum type: association key values: association value ]
]

{ #category : 'accessing' }
P16RuleAnalyser >> defaultHeuristics [

	^{
		MiDeadCodeJavaInitializerHeuristic new .
		MiDeadCodeJavaTestAnnotationHeuristic new
	}
]

{ #category : 'api' }
P16RuleAnalyser >> emptyMethods [

	lastAnalysis := 'Empty methods'.

	refutingHeuristics := self defaultHeuristics.

	^result := model allModelMethods select: [ :method |
		self isEmptyMethod: method
	]
]

{ #category : 'api' }
P16RuleAnalyser >> emptyMethodsCalled [
	"becareful that calling #emptyMethods will set #lastAnalysis, so we reset it after to the right value"
	result := self emptyMethods.
	lastAnalysis := 'Empty methods called'.

	^result := result select: [ :meth |
		meth incomingInvocations isNotEmpty
	]
]

{ #category : 'api' }
P16RuleAnalyser >> findEnumsFromStatic [
	"In a list of classes, searches for the one that implement enums with static attributes
	 Returns a list of candidateEnum-s"

	lastAnalysis := 'Find enums from static attributes'.

	^result := model allModelClasses flatCollect: [ :class | self candidateEnums: class ]
]

{ #category : 'api' }
P16RuleAnalyser >> illNamedTestClasses [

	lastAnalysis := 'Ill named Test Classes'.

	^result := model allModelClasses select: [ :class |
		(self isTestClass: class) and:
		[ (class name endsWith: 'Test') not ]
	]
]

{ #category : 'private' }
P16RuleAnalyser >> inTestClass: method [

	^self isTestClass: method parentType
]

{ #category : 'private' }
P16RuleAnalyser >> isDeadMethod: method [
	"finds out 'dead' method re-using the heuristics for the DeadCodeBrowser"

	method incomingInvocations ifNotEmpty: [ ^false ].

	refutingHeuristics do: [ :heuristic |
		(heuristic notDead: method) ifTrue: [ ^false ]
	].

	^true
]

{ #category : 'private' }
P16RuleAnalyser >> isEmptyMethod: aMethod [
	"Empty methods have no statement
	 but we must ignore: abstract methods, methods defined in Interface, and virtual <Initializer> methods"

	aMethod isAbstract ifTrue: [ ^false ].
	aMethod parentType isInterface ifTrue: [ ^false ].
	(aMethod name = '<Initializer>') ifTrue: [ ^false ].

	^(aMethod numberOfStatements = 0)
]

{ #category : 'private' }
P16RuleAnalyser >> isLibraryEntity: anEntity [
	"a library class/method must be a 'stub' (ie. we don't have its source code)
	 and we ignore everything from java (java.lang: Object, String, Throwable,... ; java.utils...)"

	^anEntity isStub and:
	[ (anEntity mooseName beginsWith: 'java::') not ]
]

{ #category : 'private' }
P16RuleAnalyser >> isTestClass: aClass [
	"A testClass is a class with at least one method having @Test annotation"

	^aClass methods anySatisfy: [ :meth |
		meth annotationInstances isNotEmpty and:
		[ meth annotationInstances anySatisfy: [ :annot | annot annotationType name = 'Test' ] ]
	]
]

{ #category : 'private' }
P16RuleAnalyser >> isTraceMethod: method [

	(method name includesSubstring: 'trace') ifTrue: [ ^true ].
	(method name includesSubstring: 'log') ifTrue: [ ^true ].
	^false
]

{ #category : 'api' }
P16RuleAnalyser >> libraryClasses [

	lastAnalysis := 'External library classes'.

	^result := self libraryEntities: model allClasses
]

{ #category : 'private' }
P16RuleAnalyser >> libraryEntities: entities [
	"note: we need to create an OrederedCollectino form the entities because
	 select:thenCollect: is not defined for FamixGroups"

	^((OrderedCollection withAll: entities)
		select: [ :each | self isLibraryEntity: each ]
		thenCollect: #mooseName)
		asSet
		sorted: [ :a :b | a mooseName < b mooseName ]
]

{ #category : 'private' }
P16RuleAnalyser >> method: aMethod accessEnumValues: candidateEnum [

	^(aMethod accesses count: [ :acc | candidateEnum values includes: acc variable ])
		 > 1
]

{ #category : 'private' }
P16RuleAnalyser >> methodsAccessingEnumValues: candidateEnum [
	"in the class implementing the candidateEnum, looks for methods accessing several of the enum values"
	
	| theClass |
	theClass := candidateEnum implementingClass.

	^theClass methods select: [ :method |
		(method name = '<Initializer>') not and: 
		[self method: method accessEnumValues: candidateEnum]
	]
]

{ #category : 'api' }
P16RuleAnalyser >> methodsAccessingEnums [

	lastAnalysis := 'Methods accessing enums'.

	^self methodsAccessingEnums: result 
]

{ #category : 'private' }
P16RuleAnalyser >> methodsAccessingEnums: collectionOfEnums [
	"from a list of candidateEnum-s finds the methods that access several of the 'enum values'
	 the methods are searched in the same class as the static attributes composing the candidateEnum"

	collectionOfEnums
		do: [ :enum | enum users: (self methodsAccessingEnumValues: enum) ].
	^collectionOfEnums reject: [ :enum | enum users isEmpty ]

]

{ #category : 'api' }
P16RuleAnalyser >> nonTestDeadMethods [

	lastAnalysis := 'Non test dead methods'.

	refutingHeuristics := self defaultHeuristics.

	^result := model allModelMethods select: [ :method |
		(self inTestClass: method) and:
		[ self isDeadMethod: method ]
	]
]

{ #category : 'instance creation' }
P16RuleAnalyser >> on: aModel [

	model := aModel.

]

{ #category : 'tracing' }
P16RuleAnalyser >> print [

	'# ' trace.
	lastAnalysis traceCr.

	'' traceCr.

	result do: [ :each |
		(each class = P16CandidateEnum) 
		ifTrue: [each print]
		ifFalse: [
			'- ' trace.
			each mooseName traceCr
		]
	]
]

{ #category : 'private' }
P16RuleAnalyser >> staticAttributesByType: aClass [
	"in aClass looks for all static attributes that can be grouped by their declaredType"
	
	| classAttributes |
	classAttributes := aClass  attributes
		select: [ :att | 
			att declaredType isNotNil and: 
			[ att isClassSide ] ].

	^classAttributes groupedBy: [ : att | att declaredType ]
]

{ #category : 'api' }
P16RuleAnalyser >> traceMethodsCalledElsewhere [
	lastAnalysis := '"Trace" methods called elsewhere'.

	^result := model allModelMethods select: [ :method |
		(self isTraceMethod: method) and:
		[ (self callersOutsideParentClass: method) isNotEmpty ]
	].

]
