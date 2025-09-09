Class {
	#name : 'P16JacocoVisitor',
	#superclass : 'XMLNodeVisitor',
	#instVars : [
		'parentClass',
		'methods'
	],
	#category : 'P16-Rules-JacocoImporter',
	#package : 'P16-Rules',
	#tag : 'JacocoImporter'
}

{ #category : 'accessing' }
P16JacocoVisitor >> get: aNode attribute: attributeName [

	^aNode attributeAt: attributeName ifAbsent: [ nil ]

]

{ #category : 'visiting' }
P16JacocoVisitor >> visitClass: aClassNode [

	parentClass := self get: aClassNode attribute: 'name'.
	super visitNodeWithElements: aClassNode.
	parentClass := nil
]

{ #category : 'visiting' }
P16JacocoVisitor >> visitCounter: aXMLElement [ 
]

{ #category : 'visiting' }
P16JacocoVisitor >> visitDocument: aDocumentNode [

	parentClass := nil.
	methods := OrderedCollection new.

	super visitNodeWithElements: aDocumentNode.
	^methods 
]

{ #category : 'visiting' }
P16JacocoVisitor >> visitElement: anElement [

	| selector |
	selector := ('visit' , anElement name capitalized , ':')  asSymbol.
	^ self perform: selector with: anElement
]

{ #category : 'visiting' }
P16JacocoVisitor >> visitMethod: aMethodNode [

	methods add: parentClass , '/' , (self get: aMethodNode attribute: 'name').

]

{ #category : 'visiting' }
P16JacocoVisitor >> visitPackage: aPackageNode [

	^ super visitNodeWithElements: aPackageNode 
]

{ #category : 'visiting' }
P16JacocoVisitor >> visitReport: aReportNode [

	^ super visitNodeWithElements: aReportNode
]

{ #category : 'visiting' }
P16JacocoVisitor >> visitSessioninfo: aNode [

]

{ #category : 'visiting' }
P16JacocoVisitor >> visitSourcefile: aXMLElement [ 
]
