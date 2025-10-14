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
P16JacocoImporter >> findChildNamed: name line: lineno in: entity [
	"if #entity is not a class, the child is not a method and the name alone is enough to identify it
	 For methods we use line number to help"

	entity isClass ifFalse: [
			^ entity containedEntities
				  detect: [ :c | c name = name ]
				  ifNone: [ nil ] ].

	"too lazy to do it now :-("
	^ entity containedEntities
		  detect: [ :c | c name = name ]
		  ifNone: [ nil ]
]

{ #category : 'run' }
P16JacocoImporter >> findMethodNamed: methodIdentifier [

	| path root |
	path := ($/ split: methodIdentifier key).
	root := mooseModel entityNamed: path first ifAbsent: [ ^nil ].
	path removeFirst.
	^self findPath: path line: methodIdentifier value in: root
	
]

{ #category : 'run' }
P16JacocoImporter >> findPath: path line: lineno in: entity [

	| child |
	path ifEmpty: [ ^entity ].
	child := self findChildNamed: path first line: lineno in: entity.
	child ifNil: [ ^nil ].
	path removeFirst.
	^self findPath: path line: lineno in: child

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
