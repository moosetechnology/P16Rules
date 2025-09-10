"
I import a Jacoco reaport and mark the covered methods with a given tag

use:
```
P16JacocoImporter new
	mooseModel: aModel ;
	tagName: aString ;
	on: '/path/to/jacoco-report.xml'
```
"
Class {
	#name : 'P16JacocoImporter',
	#superclass : 'Object',
	#instVars : [
		'tagName',
		'mooseModel'
	],
	#category : 'P16-Rules-JacocoImporter',
	#package : 'P16-Rules',
	#tag : 'JacocoImporter'
}

{ #category : 'run' }
P16JacocoImporter >> findMethodNamed: fullyQualifiedName [

	| path root |
	path := ($/ split: fullyQualifiedName).
	root := mooseModel entityNamed: path first ifAbsent: [ ^nil ].
	path removeFirst.
	^self findPath: path in: root
	
]

{ #category : 'run' }
P16JacocoImporter >> findPath: path in: entity [

	| child |
	path ifEmpty: [ ^entity ].
	child := entity children detect: [ :c | c name = path first ] ifNone: [^nil].
	path removeFirst.
	^self findPath: path in: child

]

{ #category : 'accessing' }
P16JacocoImporter >> mooseModel [

	^mooseModel
]

{ #category : 'accessing' }
P16JacocoImporter >> mooseModel: anObject [

	mooseModel := anObject
]

{ #category : 'run' }
P16JacocoImporter >> on: aFilename [

	| visitor coveredMethods |
	visitor := P16JacocoVisitor new.
	coveredMethods := (XMLDOMParser parse: aFilename asFileReference contents)
		acceptNodeVisitor: visitor.
	self tagMethods: coveredMethods
]

{ #category : 'run' }
P16JacocoImporter >> tagMethods: methodNames [

	methodNames do: [ :name |
		(self findMethodNamed: name)
			ifNotNil: [ :method | method tagWithName: self tagName ]
	]
]

{ #category : 'accessing' }
P16JacocoImporter >> tagName [

	^ tagName
]

{ #category : 'accessing' }
P16JacocoImporter >> tagName: anObject [

	tagName := anObject
]
