"
Bulk editor on a Java file: comment out a collection of (dead) methods

To use:
- compute all dead methods in a file
- call: `P16BulkEditor new runOn: deadMethodCollection.`
- Output the resulting lines in a file:
```
'someFile.java' asFileReference writeStreamDo: [ :st |
	bulkeditor lines do: [ :line | st << line ; cr ]
]
```
"
Class {
	#name : 'P16BulkEditor',
	#superclass : 'Object',
	#instVars : [
		'lines'
	],
	#category : 'P16-Rules-BulkEdit',
	#package : 'P16-Rules',
	#tag : 'BulkEdit'
}

{ #category : 'running' }
P16BulkEditor >> comment: method [

	| firstLastLine |
	firstLastLine := self firstLastLine: (method sourceAnchor startPos @ method sourceAnchor endPos).

	self uncloseCommentBetween: firstLastLine.
	lines add: ' --- dead code removal --- */' afterIndex: firstLastLine y.
	lines add: '/* --- dead code removal ---' beforeIndex: firstLastLine x.
]

{ #category : 'running' }
P16BulkEditor >> firstLastLine: firstLastPos [

	| startLine endLine totalPos |

	startLine := endLine := 0.
	totalPos := 0.
	lines withIndexDo: [ :line :iLine |
		totalPos := totalPos + line size + 1.
		((totalPos > firstLastPos x)  and: [ startLine = 0 ])
			ifTrue: [ startLine := iLine ].

		((totalPos > firstLastPos y)  and: [ endLine = 0 ])
			ifTrue: [
				endLine := iLine.
				^startLine @ endLine
			].
	].

	^startLine @ lines size

]

{ #category : 'running' }
P16BulkEditor >> getCode: methods [

	| file |
	file := methods anyOne mooseModel rootFolder asFileReference / (methods anyOne sourceAnchor fileName).
	^file contents
]

{ #category : 'accessing' }
P16BulkEditor >> lines [

	^lines
]

{ #category : 'running' }
P16BulkEditor >> runOn: methods [

	lines := (self getCode: methods) lines asOrderedCollection.

	(self sortByLine: methods) do: [ :meth | self comment: meth ].

	^lines
]

{ #category : 'running' }
P16BulkEditor >> sortByLine: methods [
	"sort methods in reverse order (decreasing) of their starting position"
	^methods sorted: [ :m1 :m2 |
		m1 sourceAnchor startPos > m2 sourceAnchor endPos
	]
]

{ #category : 'running' }
P16BulkEditor >> uncloseCommentBetween: firstLastLine [

	firstLastLine x to: firstLastLine y do: [ :i |
		lines at: i put: (self uncloseCommentsIn: (lines at: i))
	]
]

{ #category : 'running' }
P16BulkEditor >> uncloseCommentsIn: line [

	^(line includesSubstring: '*/')
		ifTrue: [ line copyReplaceAll: '*/' with: '*_/' ]
		ifFalse: [ line ]
]
