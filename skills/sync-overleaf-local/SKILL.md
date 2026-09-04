---
name: sync-overleaf-local
description: Write, revise, polish, compile, and version academic papers as local LaTeX projects on drive E, with optional browser synchronization to Overleaf Free. Use whenever the user asks to write or output a paper, manuscript, SCI article, abstract, introduction, methods, results, discussion, conclusion, or supplementary information; edit or polish an existing paper; compile LaTeX; save a Git version; manage an Overleaf Free project; or synchronize a manuscript without Overleaf Git Bridge. Default to producing real .tex/.bib files, a verified PDF, and a local Git commit instead of returning only prose in chat unless the user explicitly asks for chat-only text.
---

# Sync Overleaf Locally

Use E:\Overleaf as the storage root. Treat the local Git repository as the writing source of truth and Overleaf as the online collaboration copy.

## Default paper-authoring behavior

When the user asks to draft, write, translate, revise, polish, or output an academic paper, create or update the actual local LaTeX project rather than placing the full deliverable only in chat.

1. Resolve the target project before editing:
   - Use the explicitly named repository when the user names one.
   - Continue in the single clearly relevant repository when the conversation or current workspace identifies it.
   - For a new paper, create a concise project folder under E:\Overleaf\projects.
   - Ask one concise question only when multiple existing repositories are plausible and choosing the wrong one could overwrite unrelated work.
2. Inspect the configured main document and sibling manuscript variants such as main_clean.tex, main_red.tex, anonymous copies, or tracked-revision copies. When requested content is duplicated across intentionally parallel variants, update all affected variants consistently or state why a variant must remain different.
3. Keep manuscript content in tracked .tex, .bib, figure, table, and supporting files inside the repository. Preserve the existing document class, bibliography system, compiler, file organization, labels, citation keys, and house style unless the user requests a change.
4. When content work is in scope, combine this workflow with the installed nature-writing skill for drafting or restructuring and the nature-polishing skill for language or LaTeX-layout refinement. Those skills guide the writing quality; this skill controls artifact delivery, so place the finished text in the local LaTeX files and do not duplicate the full passage in chat unless the user asks.
5. If a journal, word limit, abstract type, or style guide is missing, preserve the manuscript's existing length and structure and use a clear generic journal-ready style. State that assumption in the handoff instead of stopping, unless the missing choice would materially change the scientific claim or document structure.
6. Build with scripts/Build-OverleafProject.ps1, or the repository's build.cmd when present. Inspect the log, repair fatal LaTeX errors, and rebuild until the requested manuscript compiles successfully or a genuine external dependency blocks completion.
7. Verify that the final PDF exists, citations and cross-references are resolved, and no requested files are missing. Report material non-fatal warnings such as overfull boxes when they remain.
8. Review the Git diff for accidental generated files, secrets, or unrelated changes. Commit the coherent, validated manuscript version with a concise message. Do not amend or rewrite unrelated user history.
9. Return a compact handoff containing the project path, PDF path, compilation status, remaining warnings if any, and Git commit ID. Include manuscript text in chat only when the user asks for it there.
10. Keep work local by default. Upload or publish to Overleaf only when the user asks to synchronize or publish, or when that action is explicitly part of an already requested workflow.

### Dry runs and read-only requests

When the user asks for a dry run, preview, inspection, diagnosis, or says not to modify files, do not edit manuscript files, generate build artifacts, stage changes, commit, upload, or update synchronization metadata. Inspect existing configuration and artifacts read-only, then report the exact files and actions the full workflow would use.

## Storage contract

- Put repositories in E:\Overleaf\projects.
- Put original source ZIP files in E:\Overleaf\backups\<project>\downloads.
- Put compiled PDFs in E:\Overleaf\exports\<project>.
- Put builds, comparisons, and upload staging in E:\Overleaf\temp\<project>.
- Keep the skill itself in E:\Overleaf\skills.
- Never save passwords, cookies, login codes, or shared-access tokens in files or Git.
- A browser download may briefly land in the system Downloads folder. Move that exact file to the E-drive backup directory immediately after verifying both paths.

## Choose the workflow

### First import

1. Open the Overleaf project using the signed-in browser.
2. Record the project ID, title, main document, compiler, and TeX Live version when visible.
3. Download File > Download > Download as source (.zip).
4. Move the ZIP to the E-drive backup directory without overwriting an older archive.
5. Extract it into E:\Overleaf\projects\<project>.
6. Run scripts/Initialize-OverleafProject.ps1.
7. Run scripts/Build-OverleafProject.ps1 and confirm that a PDF is produced.

### Local writing

1. Compare a fresh Overleaf source export before editing when collaborators may have changed the project.
2. Resolve remote-only changes before modifying local files.
3. Edit only inside the E-drive repository.
4. Build locally, inspect compilation errors, and rerun until the manuscript compiles successfully.
5. Verify citations, references, and the exported PDF.
6. Review Git diff, then commit a coherent version.

### Publish to Overleaf

1. Download a fresh source ZIP immediately before publishing.
2. Run scripts/Compare-OverleafExport.ps1.
3. Stop if the comparison reports a conflict, a delete-versus-modify case, or two different versions of a binary file.
4. Run scripts/Prepare-OverleafUpload.ps1 only from a clean committed worktree.
5. Read the browser file-upload guidance before using Overleaf Upload.
6. Upload only files from the generated staging directory. Never upload .git, AGENTS.md, .overleaf-sync, .vscode, build files, or skill files.
7. Handle deletions and renames explicitly in the Overleaf file tree.
8. Recompile in Overleaf and verify the PDF.
9. Download the post-upload source ZIP, compare it with the local publishable set, then run scripts/Record-OverleafBaseline.ps1.
10. Commit the updated synchronization metadata and create a local Git tag.

## Conflict rules

- Import a remote-only change into Git before further writing.
- Upload a local-only change after a clean comparison.
- Merge text files from the recorded baseline when both sides changed.
- Require the user to choose between differing binary versions.
- Treat delete-versus-modify as a conflict.
- Do not update the baseline unless the post-upload download matches the intended publishable files.

## Local compilation

Use scripts/Build-OverleafProject.ps1. It reads .overleaf-sync/config.json, invokes latexmk with the recorded engine, keeps intermediate files on E, and copies the final PDF to E:\Overleaf\exports.

If the local and Overleaf TeX Live versions differ, treat a compile mismatch as an environment difference until reproduced with matching versions. Do not rewrite manuscript content merely to hide a version mismatch.

## Detailed guidance

Read references/free-sync-workflow.md before the first publish, a conflict resolution, a deletion or rename, or a project with active collaborators/comments.
