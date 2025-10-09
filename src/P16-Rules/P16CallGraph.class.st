Class {
	#name : 'P16CallGraph',
	#superclass : 'Object',
	#instVars : [
		'origin',
		'destination',
		'graph',
		'allNodes'
	],
	#category : 'P16-Rules-CallGraph',
	#package : 'P16-Rules',
	#tag : 'CallGraph'
}

{ #category : 'accessing' }
P16CallGraph >> allNodes [

	^ allNodes
]

{ #category : 'running' }
P16CallGraph >> buildGraph [

	graph := (FamixJavaCHABuilder entryPoints: self origin) build.
]

{ #category : 'accessing' }
P16CallGraph >> destination [

	^ destination
]

{ #category : 'accessing' }
P16CallGraph >> destination: anObject [

	destination := anObject
]

{ #category : 'accessing' }
P16CallGraph >> destinationNodes [

	^allNodes select: [ :node |
		(self destination includes: node realMethod) ].
]

{ #category : 'accessing' }
P16CallGraph >> graph [

	^ graph
]

{ #category : 'accessing' }
P16CallGraph >> graph: anObject [

	graph := anObject
]

{ #category : 'accessing' }
P16CallGraph >> origin [

	^ origin
]

{ #category : 'accessing' }
P16CallGraph >> origin: anObject [

	origin := anObject
]

{ #category : 'accessing' }
P16CallGraph >> originNodes [

	^allNodes select: [ :node |
		(self origin includes: node realMethod) ].
]

{ #category : 'running' }
P16CallGraph >> pruneGraph [

	| removableLeaves |

	[ removableLeaves := self removableLeaves.
	  removableLeaves isEmpty ]
	whileFalse: [
		removableLeaves do: [ :node | node isolate ].
		allNodes removeAll: removableLeaves 
	]
]

{ #category : 'running' }
P16CallGraph >> removableLeaves [
	"leaves do not have #callees and they are removable if they are not a recognized destination"

	^allNodes select: [ :node |
		(node callees isEmpty) and: 
		[ (self destination includes: node realMethod) not ] ]
]

{ #category : 'running' }
P16CallGraph >> run [ 

	self buildGraph.
	allNodes := graph allNodes.
	self pruneGraph
]
