Class {
	#name : 'HUpdateTagsMenuItem',
	#superclass : 'HCanvasMenuItem',
	#category : 'P16-Rules-API-browser',
	#package : 'P16-Rules',
	#tag : 'API-browser'
}

{ #category : 'execution' }
HUpdateTagsMenuItem >> execute [
	visualization updateTags
	
]

{ #category : 'execution' }
HUpdateTagsMenuItem >> label [
	^ 'Update tags'
]

{ #category : 'execution' }
HUpdateTagsMenuItem >> order [
	^ 65
]
