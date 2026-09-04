# Academic-paper storage and workflow template

This is a portable template derived from a personal Windows configuration. Set the project name and existing manuscript entry point before use. The `E:\Overleaf` convention is an example storage policy; adapt it consistently if your machine uses a different drive.

## Storage

- Store local Overleaf repositories, Git history, manuscript files, figures, bibliography files, exported PDFs, backups, and temporary synchronization files under `E:\Overleaf`.
- Place each project at `E:\Overleaf\projects\<project-name>`.
- Put exported deliverables in `E:\Overleaf\exports\<project-name>`, backups in `E:\Overleaf\backups`, and temporary synchronization artifacts in `E:\Overleaf\temp`.
- Never store authentication tokens in repositories, URLs, scripts, chat messages, or plaintext files. On Windows, use Git Credential Manager.
- Preserve LF line endings. Review and validate changes before committing each coherent successful version.
- If an official Overleaf Git remote is configured, pull before editing and push only as part of requested synchronization. Where Git access is unavailable, use a verified browser export, compare, and upload workflow. Do not describe local Git as live synchronization.

## Academic-paper workflow

- For requests to draft, translate, revise, polish, or output a manuscript, produce or update actual local LaTeX files by default. Return chat-only text when the user explicitly asks for it.
- Use the named or clearly established repository. If multiple existing repositories are plausible, clarify the target; do not bind new requests to a previous paper.
- Preserve the existing class, compiler, bibliography system, labels, citation keys, structure, and intentionally parallel manuscript copies unless the user requests a change.
- When no target journal or length limit is supplied, retain the existing structure and approximate length, use a generic journal-ready style, and report the assumption.
- Build with the repository's existing `build.cmd` or documented build command. If the `sync-overleaf-local` skill is installed, its build script may be used. Resolve fatal errors, verify citations and cross-references, and export the successful PDF under `E:\Overleaf\exports\<project-name>`.
- Review the diff after a successful build. Exclude generated build intermediates and secrets, then create a concise local Git commit.
- Report the project location, PDF location, compilation result, material remaining warnings, and commit ID.
- Keep work local unless upload, synchronization, publication, or submission is explicitly requested or already authorized within the workflow.
- Treat a dry run, inspection, diagnosis, or explicit no-write request as read-only: do not edit, build, commit, upload, or update synchronization metadata.
