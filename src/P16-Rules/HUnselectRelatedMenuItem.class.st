Class {
	#name : 'HUnselectRelatedMenuItem',
	#superclass : 'HGroupMenuItem',
	#category : 'P16-Rules-API-browser',
	#package : 'P16-Rules',
	#tag : 'API-browser'
}

{ #category : 'accessing' }
HUnselectRelatedMenuItem >> execute [

	visualization unselectRelatedTo: shape model rawModel
]

{ #category : 'accessing' }
HUnselectRelatedMenuItem >> group [

	^ 3
]

{ #category : 'accessing' }
HUnselectRelatedMenuItem >> label [

	^ 'Un-select related entities'
]

{ #category : 'accessing' }
HUnselectRelatedMenuItem >> order [

	^80
]
