"
A visualization showing API dependencies between 2 ""subsystems""
Currently very specialized for Corese-core and Corese-command
(see `P16APIMapModel >> #allInvocations`)

Use:
  Launch it and propagate a full corese model to it
"
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

{ #category : 'interactions' }
P16APIBrowser >> addToSelection: entities [
	"Add to currently selected shapes all shapes for entities"

	| shapesToHighlight shapesHighlighted |

	shapesHighlighted := self canvas selectedShapes ifNil: [ #(  ) ].
	shapesToHighlight := self shapesFromModels: entities.

	self canvas setSelectedShapes: shapesToHighlight , shapesHighlighted
]

{ #category : 'testing' }
P16APIBrowser >> canFollowEntity: anObject [

	^anObject isMooseObject
]

{ #category : 'accessing' }
P16APIBrowser >> canvas [

	^mainPresenter canvas
]

{ #category : 'actions' }
P16APIBrowser >> followEntity: anEntity [

	| mooseModel |

	mooseModel := self getMooseModel: anEntity.
	super followEntity: mooseModel.
	self model mooseModel: mooseModel
]

{ #category : 'accessing' }
P16APIBrowser >> getMooseModel: aMooseObject [

	aMooseObject isMooseModel ifTrue: [ ^aMooseObject ].
	aMooseObject isCollection  ifTrue: [ ^aMooseObject anyOne mooseModel ].
	^aMooseObject mooseModel
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

{ #category : 'accessing' }
P16APIBrowser >> linkShapesFromModels: associations [

	| linkShapes |
	
	linkShapes := self canvas shapes select: #isLine.

	^associations collect: [ :assoc || shapeFrom shapeTo |
		shapeFrom := self canvas shapeFromModel: (assoc key propertyNamed: #p16APIHNode).
		shapeTo := self canvas shapeFromModel: (assoc value propertyNamed: #p16APIHNode).

		linkShapes detect: [ :link | (link from = shapeFrom) and: [ link to = shapeTo ] ]
	]
]

{ #category : 'accessing' }
P16APIBrowser >> miSelectedItem [

	^ self canvas selectedShapes reject: #isLine thenCollect: [ :shape | shape model rawModel ]
]

{ #category : 'accessing' }
P16APIBrowser >> miSelectedItemToPropagate [

	^ self miSelectedItem 
]

{ #category : 'accessing' }
P16APIBrowser >> nodeShapesFromModels: famixEntities [

	^self canvas shapesFromModels: (famixEntities collect: [ :fmx | fmx propertyNamed: #p16APIHNode])
]

{ #category : 'interactions' }
P16APIBrowser >> removeFromSelection: entities [
	"Remove from currently selected shapes those representing #entities"

	| shapesToUnhighlight shapesHighlighted |

	shapesHighlighted := self canvas selectedShapes ifNil: [ #() ].
	shapesToUnhighlight := self shapesFromModels: entities.

	self canvas setSelectedShapes: (shapesHighlighted \ shapesToUnhighlight)
]

{ #category : 'accessing' }
P16APIBrowser >> shapesFromModels: famixEntities [
	"note: both lists or sets, but we cannot use concatenation on sets :-(
	   so we make an OrderedCollection of it"

	^(self nodeShapesFromModels: (famixEntities reject: [ :fmx | fmx isAssociation ])) ,
	(self linkShapesFromModels: (famixEntities select: [ :fmx | fmx isAssociation ]))
	
]

{ #category : 'actions' }
P16APIBrowser >> updateTags [

	mainPresenter currentCanvas shapes do: [ :sh |
		sh isLine ifFalse: [
			sh model rawModel isTagged ifTrue: [
				(sh nodes noneSatisfy: [:node | node class = RSCircle ]) ifTrue: [
					sh add: (RSCircle new
						color: sh model rawModel tags first color;
						radius: 7;
						yourself)
				]
			]
		]
	]
]
