# P16Rules
A set of small analysis as a temporary work-around for P16 analyses

load with:
```st
Metacello new
  baseline: 'P16rules';
  repository: 'github://moosetechnology/P16Rules';
  onConflict: [ :ex | ex allow ];
  load.
```
