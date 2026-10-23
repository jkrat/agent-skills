---
name: doc-creation
description: Start and write an end-user documentation page (Docusaurus markdown in docs/) with the standard metadata, title, description, updated date, and images. The user gives an opening summary, Claude asks clarifying questions about gaps, order, and image placement, then fills in the page. Use when the user wants to create or fill in a docs page.
---

Help the user start or fill in a documentation page in `docs/`. Every page is written entirely for the end user, who is usually not technical. The user has usually already dropped screenshots into a matching folder under `docs/img/`.

## Page format

Every page follows this shape:

```markdown
---
sidebar_position: 1
sidebar_label: Short Label
title: Page Title
description: One sentence saying what the reader can do with this page.
---

# Page Title {#kebab-case-anchor}

One-sentence tagline that matches the description.

📅 Updated on September 24, 2026

## First Section {#first-section}
...
```

## Process

### 1. Find or start the page, and find its images

- **Page exists:** keep its front matter, title, heading anchor, and filename as they are. Only change `description` and the tagline, and only when they are placeholders or wrong.
- **Page doesn't exist:** create it in the folder the user names, using the format above. Take the title from the user. Choose `sidebar_position` as the next free number among the sibling pages, and default `sidebar_label` to the title unless a shorter label makes sense. Write the description and tagline after the opening summary in step 2. Leave any `_category_.json` alone.
- Find the image folder for the page. It mirrors the doc folder and is named after the page: `docs/img/<doc folder>/<page name>/`. If there is no exact match, use the closest folder and say which one you used.
- List the images, then **open each one** so you know what it shows. Note any red boxes or highlights, since they mark the button or field to talk about.

### 2. Ask for the opening summary

Before writing anything, ask the user to describe the page in their own words: what the user is trying to do and the steps they follow. Keep the ask short and let them write it loosely. Then wait.

### 3. Verify against the app

If the summary names buttons, fields, or screens, check the real labels in the screenshots and in the Blazor components under `Fixit/Components/`. Use the on-screen wording in the doc. Read any file the user points to for names, categories, and options.

### 4. Ask clarifying questions

Ask follow-up questions only for things you can't work out from the summary, screenshots, and code. Focus on:

- Gaps in the steps, such as what happens between two actions or what a term means.
- The order of sections and steps.
- Which image goes where, when it isn't obvious from the screenshot.
- Business rules, exceptions, or warnings the user hasn't mentioned.

Ask in one batch, not one at a time. Skip the questions if there's nothing to ask.

### 5. Write the page

- Add sections with `##` headings and `{#kebab-case-anchor}` ids, matching the page's title heading.
- Place images with relative paths, such as `![Short description](../img/<doc folder>/<page name>/file.png)`, right after the step they show.
- Use `:::tip` or `:::note` for side notes and warnings.
- Refer to buttons and fields by their on-screen label in **bold**.
- Leave a stub, *description needed* in italics, for anything that needs business knowledge you don't have.
- Write the `description` and tagline, and set the `📅 Updated on` date line to today.
- Write only what the reader needs to do the task. Do not add sections for audience, background, or prerequisites unless the user asks for them.

### 6. Report back

Keep it short. Say what you wrote, and list anywhere you used the on-screen label instead of the user's wording, any stubs left, and any mismatches you noticed (such as a filename that doesn't match the title). Do not rename files or folders.

## Tone

Plain and direct, written for someone who uses the application daily but is not technical. Use natural labels rather than field names, code terms, or backticks. Use short paragraphs and numbered steps for anything the reader does.
