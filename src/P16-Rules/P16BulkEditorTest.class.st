"
A P16BulkEditorTest is a test class for testing the behavior of P16BulkEditor
"
Class {
	#name : 'P16BulkEditorTest',
	#superclass : 'TestCase',
	#instVars : [
		'bulkEditor'
	],
	#category : 'P16-Rules-BulkEdit',
	#package : 'P16-Rules',
	#tag : 'BulkEdit'
}

{ #category : 'running' }
P16BulkEditorTest >> bulkEditorLines: lines [

	bulkEditor instVarNamed: #lines put: lines
]

{ #category : 'running' }
P16BulkEditorTest >> methodWithPos: pos [

	^FamixJavaMethod new
		sourceAnchor: (FamixJavaIndexedFileAnchor new 
			startPos: pos x ;
			endPos: pos y)
]

{ #category : 'running' }
P16BulkEditorTest >> setUp [

	bulkEditor := P16BulkEditor new.

	self bulkEditorLines: #( 'l1*/5' 'l2_4' 'l3*/_*/10') asOrderedCollection.

]

{ #category : 'tests' }
P16BulkEditorTest >> testCommentFirst [

	| mth |
	mth := self methodWithPos: 3@8.

	bulkEditor comment: mth.

	self assert: bulkEditor lines size equals: 5.
	self assert: (bulkEditor lines at: 1) equals: '/* --- dead code removal ---'.
	self assert: (bulkEditor lines at: 2) equals: 'l1*_/5'.
	self assert: (bulkEditor lines at: 3) equals: 'l2_4'.
	self assert: (bulkEditor lines at: 4) equals: ' --- dead code removal --- */'.
]

{ #category : 'tests' }
P16BulkEditorTest >> testCommentInside [

	| mth |
	mth := self methodWithPos: 7@10.

	bulkEditor comment: mth.

	self assert: bulkEditor lines size equals: 5.
	self assert: (bulkEditor lines at: 2) equals: '/* --- dead code removal ---'.
	self assert: (bulkEditor lines at: 3) equals: 'l2_4'.
	self assert: (bulkEditor lines at: 4) equals: ' --- dead code removal --- */'.
]

{ #category : 'tests' }
P16BulkEditorTest >> testCommentLast [

	| mth |
	mth := self methodWithPos: 12@17.

	bulkEditor comment: mth.

	self assert: bulkEditor lines size equals: 5.
	self assert: (bulkEditor lines at: 3) equals: '/* --- dead code removal ---'.
	self assert: (bulkEditor lines at: 4) equals: 'l3*_/_*_/10'.
	self assert: (bulkEditor lines at: 5) equals: ' --- dead code removal --- */'.
]

{ #category : 'tests' }
P16BulkEditorTest >> testFirstLastLineFirstChar [

	self assert: (bulkEditor firstLastLine: 1@7) equals: 1@2
]

{ #category : 'tests' }
P16BulkEditorTest >> testFirstLastLineFirstLineChar [

	self assert: (bulkEditor firstLastLine: 7@17) equals: 2@3
]

{ #category : 'tests' }
P16BulkEditorTest >> testFirstLastLineLastChar [

	self assert: (bulkEditor firstLastLine: 7@21) equals: 2@3
]

{ #category : 'tests' }
P16BulkEditorTest >> testFirstLastLineLastLineChar [

	self assert: (bulkEditor firstLastLine: 2@10) equals: 1@2
]

{ #category : 'tests' }
P16BulkEditorTest >> testFirstLastLineLastSameLine [

	self assert: (bulkEditor firstLastLine: 12@15) equals: 3@3
]

{ #category : 'tests' }
P16BulkEditorTest >> testUncloseCommentBetween [

	bulkEditor uncloseCommentBetween: 1@3.

	self assert: (bulkEditor lines at: 1) equals: 'l1*_/5'.
	self assert: (bulkEditor lines at: 2) equals: 'l2_4'.
	self assert: (bulkEditor lines at: 3) equals: 'l3*_/_*_/10'
]

{ #category : 'tests' }
P16BulkEditorTest >> testUncloseCommentsInMultiple [

	self assert: (bulkEditor uncloseCommentsIn: 'xx*/xx*/') equals: 'xx*_/xx*_/'
]

{ #category : 'tests' }
P16BulkEditorTest >> testUncloseCommentsInNone [

	self assert: (bulkEditor uncloseCommentsIn: 'xxxxx') equals: 'xxxxx'
]

{ #category : 'tests' }
P16BulkEditorTest >> testUncloseCommentsInOne [

	self assert: (bulkEditor uncloseCommentsIn: 'xx*/xx') equals: 'xx*_/xx'
]
