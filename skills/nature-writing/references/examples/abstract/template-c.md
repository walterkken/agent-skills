# Abstract Template C: Several Contributions

Use this pattern when the paper has multiple distinct contributions that require separate explanations.

For each contribution, pair a concrete design choice with the problem it addresses. Keep the level of detail consistent: avoid describing one contribution as an entire system and another as a minor implementation setting.

The local Deep Snake example illustrates three writing roles:

- Introduce contour deformation as the basic approach.
- Explain why an operation adapted to a closed contour is useful.
- Connect the proposal and refinement stages to the overall segmentation task.

These roles form a coherent account because each advances the same task. A list of unrelated features would not serve the same purpose.

```latex
% Scope: [task, inputs, and desired outputs]
% Contribution A: [design choice] addresses [limitation A].
% Contribution B: [design choice] addresses [limitation B].
% System: [how the contributions work together]
% Evaluation: [supported result and relevant comparison]
```

This file summarizes the teaching pattern without reproducing the paper's abstract. Teaching-source links are recorded in the [example bank index](../index.md).
