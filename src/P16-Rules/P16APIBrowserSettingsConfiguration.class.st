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
P16APIBrowserSettingsConfiguration >> accessedPrefix [

	^ accessedPrefix
]

{ #category : 'accessing' }
P16APIBrowserSettingsConfiguration >> accessedPrefix: anObject [

	accessedPrefix := anObject
]

{ #category : 'accessing' }
P16APIBrowserSettingsConfiguration >> clientPrefix [

	^ clientPrefix
]

{ #category : 'accessing' }
P16APIBrowserSettingsConfiguration >> clientPrefix: anObject [

	clientPrefix := anObject
]

{ #category : 'ui' }
P16APIBrowserSettingsConfiguration >> settingsPresenters [

	^{
	(MiTextFieldSettingPresenter on: self)
		label: 'Provider prefix' ;
	   help: 'The prefix name of accessed entities
ex: the fully qualified name of a package.' ;
		text: self accessedPrefix ;
	   whenTextChangedDo: [ :txt | self accessedPrefix: txt ] ;
		yourself
	.
	(MiTextFieldSettingPresenter on: self)
		label: 'Client prefix' ;
	   help: 'The prefix name of client entities
ex: the fully qualified name of a package.' ;
		text: self clientPrefix ;
	   whenTextChangedDo: [ :txt | self clientPrefix: txt ] ;
		yourself
	}
]
