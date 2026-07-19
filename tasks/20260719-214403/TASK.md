# Blog - impl micropub somehow

- STATE: OPEN
- PRIORITY: 50
- TAGS: blog

It would probably be something like a small go/python webserver that can authenticate and handle requests with IndieAuth, for example against github as a provider, and then it should support pushing `h-entry`'s to the blog by generating a simple markdown file.

The base properties all trivially map to an entry in the YAML frontmatter, so implementing a template should be straightforward.

```markdown
---
title: {{name}}
summary: {{summary}}
date: {{published}}
updated: {{updated}} # to be implemented still
tags: {{category}} # both are arrays, so you'd only have to parse the url-encoded array into a YAML array
---

{{content}}
```

## MVP

The [docs](https://micropub.spec.indieweb.org/#servers-li-1) outline a bare minimum:

> - MUST support both header and form parameter methods of authentication
> - MUST support creating posts with the [h-entry] vocabulary
> - MUST support creating posts using the x-www-form-urlencoded syntax

Which is easy. I kinda wanna do it in Rust because I'm quite comfortable with Axum, but maybe go is a better fit because of compilation times and simplicity.
