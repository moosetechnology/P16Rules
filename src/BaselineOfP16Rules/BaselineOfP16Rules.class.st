Class {
	#name : 'BaselineOfP16Rules',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfP16Rules',
	#package : 'BaselineOfP16Rules'
}

{ #category : 'baselines' }
BaselineOfP16Rules >> baseline: spec [

	<baseline>
	spec
		for: #common
		do: [ spec blessing: #baseline.
			spec description: 'Some analyses for P16'.
			self definePackages: spec.
			self defineGroups: spec ]
]

{ #category : 'baselines' }
BaselineOfP16Rules >> defineGroups: spec [
	spec
		group: 'default' with: #('P16-Rules')
]

{ #category : 'baselines' }
BaselineOfP16Rules >> definePackages: spec [
	spec
		package: 'P16-Rules'
]
