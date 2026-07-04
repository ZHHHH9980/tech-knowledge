---
name: github-browser-create-files
description: Use when files must be added to a GitHub repository through the browser UI, especially when git push, GitHub API writes, or the Upload files control are blocked or forbidden.
---

# GitHub Browser Create Files

## Hard Constraints

- Do not use `git push`, GitHub write APIs, or direct repository upload controls.
- Do not click `Upload files`.
- Do not use Playwright `setInputFiles()` or `input[type="file"]`.
- Use GitHub web UI only: `Add file` -> `Create new file` -> fill path -> paste text content -> commit.

## Browser Automation Pattern

1. Launch a persistent Chrome profile so GitHub login cookies survive reruns.
2. Build a candidate list from local text files and map each to a repository-relative path.
3. For each candidate, open `https://github.com/<owner>/<repo>/blob/<branch>/<path>` and skip it if it already exists.
4. Before live writes, print the exact missing paths and require an explicit terminal confirmation.
5. For each missing file:
   - open `https://github.com/<owner>/<repo>/tree/<branch>`
   - click `Add file` by stable role text, or a known current id if the user provides one
   - click `Create new file`
   - fill the filename input with the full repository-relative path, including directories
   - fill the visible editor with the local file content
   - click `Commit changes`
6. Run a dry-run again after completion; success means every candidate is reported as already existing.

## Practical Selectors

- `Add file`: prefer `getByRole('button', { name: /Add file/i })`; if the user confirms a current id such as `#_r_46_`, try it first and keep the role selector fallback.
- `Create new file`: `getByRole('menuitem', { name: /Create new file/i })` or matching link fallback.
- filename input: `input[aria-label="Name your file..."], input[placeholder="Name your file..."]`.
- content editor: use only visible textareas excluding `#feedback` / `name="feedback"`, then CodeMirror or Monaco editable nodes.
- commit message fields are optional on newer GitHub UI; click `Commit changes`, then fill visible summary fields in the modal if present.

## Failure Modes

- Repeated login usually means the script changed the persistent browser profile directory.
- `ERR_SSL_PROTOCOL_ERROR` on GitHub page navigation should be handled with bounded retries.
- Filling the hidden `feedback` textarea means the editor selector is wrong; filter for visible editor elements.
- A script that passes dry-run can still fail live if it assumes old GitHub commit fields; the commit modal may appear only after clicking `Commit changes`.
- If a previous run partially succeeded, rerun from the start with remote-existence checks; do not guess which files remain.

## Verification Checklist

- Search the automation source for forbidden strings: `Upload files`, `setInputFiles`, `input[type="file"]`.
- Dry-run before live write shows only intended missing files.
- Live run prints each `Create new file` path.
- Final dry-run reports all candidates as already existing.
