Class {
	#name : 'P16APIBrowserSettingsConfiguration',
	#superclass : 'MiAbstractSettingsConfiguration',
	#instVars : [
		'accessedPrefix',
		'clientPrefix'
	],
	#category : 'P16-Rules-API-browser',
	#package : 'P16-Rules',
	#tag : 'API-browser'
}

{ #category : 'accessing' }
P16APIBrowserSettingsConfiguration >> accessedPrefixes [

	^ accessedPrefix
]

{ #category : 'accessing' }
P16APIBrowserSettingsConfiguration >> accessedPrefixes: anObject [

	accessedPrefix := anObject
]

{ #category : 'accessing' }
P16APIBrowserSettingsConfiguration >> clientPrefixes [

	^ clientPrefix
]

{ #category : 'accessing' }
P16APIBrowserSettingsConfiguration >> clientPrefixes: anObject [

	clientPrefix := anObject
]

{ #category : 'ui' }
P16APIBrowserSettingsConfiguration >> settingsPresenters [

	^{
	(MiTextAreaSettingPresenter on: self)
		label: 'Provider prefix' ;
	   help: 'The prefix name of accessed entities (one prefix per line)
ex: The fully qualified name of a package.' ;
		text: self accessedPrefixes ;
	   whenTextChangedDo: [ :txt | self accessedPrefixes: txt ] ;
		yourself
	.
	(MiTextAreaSettingPresenter on: self)
		label: 'Client prefix' ;
	   help: 'The prefix name of client entities (one prefix per line)
ex: The fully qualified name of a package.' ;
		text: self clientPrefixes ;
	   whenTextChangedDo: [ :txt | self clientPrefixes: txt ] ;
		yourself
	}
]
