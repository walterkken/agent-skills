# Free Overleaf synchronization workflow

## Source-of-truth model

The local Git repository is the durable writing history. Overleaf remains an online copy for collaboration and cloud compilation. Free Overleaf accounts do not provide an atomic Git remote, so every browser synchronization needs an explicit comparison and verification cycle.

## Safe synchronization sequence

1. Preserve the Overleaf pre-edit state as a timestamped source ZIP.
2. Compare remote, local, and the last confirmed baseline.
3. Import remote-only changes and commit them.
4. Make and compile local edits.
5. Commit the local work.
6. Download Overleaf again immediately before upload.
7. Re-run the three-way comparison.
8. Generate a clean upload staging directory from tracked publishable files.
9. Upload changed/new files and explicitly apply deletions or renames.
10. Compile in Overleaf.
11. Download the resulting source and compare again.
12. Record a new baseline only when the file sets match.

## Review metadata warning

ZIP import/export and file replacement do not preserve all Overleaf-only metadata such as chat, comment anchors, or tracked-change anchors. Avoid bulk replacement or renaming when active review comments exist. Coordinate a short editing pause with collaborators before publication.

## Upload boundaries

The upload staging directory must contain only manuscript inputs. Never choose a Git repository root in the browser file picker. Exclude Git data, local editor settings, Codex instructions, build outputs, logs, and synchronization metadata.

Overleaf documents an upload limit of 180 files and 50 MB per upload. Split larger updates into verified batches.

Official references:

- Downloading projects: https://docs.overleaf.com/managing-projects-and-files/downloading-a-project
- Uploading files: https://docs.overleaf.com/managing-projects-and-files/adding-files-to-a-project/uploading-files-to-a-project
- Uploading a project: https://docs.overleaf.com/managing-projects-and-files/uploading-a-project
- History and versioning: https://docs.overleaf.com/writing-and-editing/history-and-versioning

## Three-way status meanings

- unchanged: local and remote still match the baseline.
- local-changed: only the local publishable version changed.
- remote-changed: only the Overleaf export changed.
- both-same: both changed to identical content.
- conflict: both changed and differ, including delete-versus-modify.

Do not publish while any conflict remains.

## Backup limitations

Multiple ZIP files and Git bundles on E protect against editing mistakes and repository corruption, but not against E-drive hardware failure. The user has requested E-drive-only local storage, so do not silently create a second local backup elsewhere.
