# Audit framework

## Verification statuses

| Status | Meaning |
|---|---|
| Verified | Source directly supports the claim within the stated scope. |
| Partially verified | Source supports only part of the claim or requires narrower wording. |
| Misleading | Individual facts may be correct, but framing, omitted context, or causal language materially distorts the source. |
| Contradicted | Credible source evidence directly conflicts with the claim. |
| Not supported | Inspected source does not entail the claim. |
| Unverifiable | Source, passage, data, or version could not be accessed or identified. |

## Evidence-strength factors

Judge confidence from the whole evidence base, not source prestige alone:

- directness to the question;
- design fitness and risk of bias;
- measurement validity;
- sample adequacy and uncertainty;
- independence and replication;
- consistency across credible sources;
- relevance to the target population, context, and period;
- transparency, data availability, and reproducibility.

Use `high`, `moderate`, `low`, or `very low` confidence and give a one-sentence rationale. Separate confidence in a source-reported result from confidence in a broader synthesized conclusion.

## Claim ledger

| ID | Claim | Source + locator | Evidence excerpt/data | Status | Scope caveat | Confidence |
|---|---|---|---|---|---|---|

Keep excerpts short. Paraphrase when quotation is unnecessary. Include page, section, table, figure, timestamp, cell range, or dataset field whenever available.

## Pattern table

| Pattern | Supporting observations | Independent sources/datasets | Counterexamples | Alternative explanation | Confidence |
|---|---|---|---|---|---|

Do not infer a trend from incomparable measurements. Note publication bias, duplicated samples, or shared data pipelines.

## Contradiction matrix

| Claim A | Claim B | Conflict type | Key design/context differences | Possible reconciliation | Resolution |
|---|---|---|---|---|---|

Allowed resolutions: `A better supported`, `B better supported`, `boundary condition`, `apparent conflict`, or `unresolved`.

## Evidence-gap map

| Gap | Gap type | Why it matters | Existing evidence | Evidence needed | Priority |
|---|---|---|---|---|---|

Prioritize by decision impact, uncertainty, feasibility, and the likelihood that new evidence changes the conclusion.

## Minimum audit rules

- Never treat a bibliography entry as proof that the cited claim is supported.
- Never replace a missing primary source with an uncited summary without labeling the substitution.
- Never merge distinct outcomes, populations, or time horizons merely because their conclusions sound similar.
- Never convert association into causation.
- Never hide null, negative, or conflicting evidence.
- Never assign independence to studies using the same underlying sample or dataset.
- Always distinguish `not found in this search` from `does not exist`.
