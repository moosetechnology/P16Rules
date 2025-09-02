Class {
	#name : 'HSelectRelatedMenuItem',
	#superclass : 'HNodeMenuItem',
	#category : 'P16-Rules-API-browser',
	#package : 'P16-Rules',
	#tag : 'API-browser'
}

{ #category : 'execution' }
HSelectRelatedMenuItem >> execute [

	visualization mapModel selectRelatedTo: shape model rawModel
]

{ #category : 'execution' }
HSelectRelatedMenuItem >> group [

	^ 3
]

{ #category : 'execution' }
HSelectRelatedMenuItem >> label [

	^ 'Select related entities'
]

{ #category : 'execution' }
HSelectRelatedMenuItem >> order [

	^85
]
