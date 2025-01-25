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
			self defineDependencies: spec.
			self definePackages: spec.
			self defineGroups: spec ]
]

{ #category : 'baselines' }
BaselineOfP16Rules >> defineDependencies: spec [
	spec
		baseline: 'P16Rules'
		with: [ spec
				loads: #('default');
				repository: 'https://github.com/moosetechnology/P16Rules' ]

]

{ #category : 'baselines' }
BaselineOfP16Rules >> defineGroups: spec [
	spec
		group: 'core' with: #('P16Rules');
		group: 'default' with: #('core')
]

{ #category : 'baselines' }
BaselineOfP16Rules >> definePackages: spec [
	spec
		package: 'P16Rules'
]
