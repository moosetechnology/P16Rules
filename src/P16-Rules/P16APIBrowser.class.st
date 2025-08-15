Class {
	#name : 'P16APIBrowser',
	#superclass : 'MiAbstractVisualizationBrowser',
	#category : 'P16-Rules-API-browser',
	#package : 'P16-Rules',
	#tag : 'API-browser'
}

{ #category : 'accessing' }
P16APIBrowser class >> mapClass [

	^ P16APIVisualization 
]

{ #category : 'instance creation' }
P16APIBrowser class >> newModel [

	^ P16APIMapModel new
]

{ #category : 'instance creation' }
P16APIBrowser class >> open [

	<script>
	^ super open
]

{ #category : 'instance creation' }
P16APIBrowser class >> title [

	^ 'API explorer'
]

{ #category : 'testing' }
P16APIBrowser >> canFollowEntity: anObject [

	^anObject isMooseModel
]

{ #category : 'actions' }
P16APIBrowser >> followEntity: anEntity [

	"super followEntity: anEntity."
	self model mooseModel: anEntity
]

{ #category : 'initialization' }
P16APIBrowser >> initializeLayout [

	self layout: (SpScrollableLayout with: mainPresenter)
]

{ #category : 'initialization' }
P16APIBrowser >> initializePresenters [

	mainPresenter := self class mapClass owner: self.
	specModel browser: self.
	self initializeLayout
]
