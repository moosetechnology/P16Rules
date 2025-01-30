# P16Rules
A set of small analysis as a temporary work-around for P16 analyses

## To load
```st
Metacello new
  baseline: 'P16Rules';
  repository: 'github://moosetechnology/P16Rules:main';
  onConflict: [ :ex | ex allow ];
  load.
```

Must be loaded in a moose 12 image

## To use

(see also `P16RuleAnalyser` class comment)

```st
analyser := P16RuleAnalyser on: corese.

analyser findEnumsFromStatic.
analyser print.
analyser methodsAccessingEnums.
analyser print.

analyser nonTestDeadMethods.
analyser print.

analyser illNamedTestClasses.
analyser print.

analyser emptyMethods.
analyser print.
analyser emptyMethodsCalled.
analyser print.

analyser traceMethodsCalledElsewhere.
analyser print.

analyser libraryClasses.
analyser print.
```

Each call to `print` will print the result of the last analysis to the `Transcript` (can the be copy-pasted to your favorite editor)
