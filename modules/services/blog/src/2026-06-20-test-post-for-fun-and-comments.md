---
title: Test post for fun and comments
date: 2026-06-20T00:06:16+02:00
layout: post
lang: en
tags: [test]
draft: false
---

I've been trying out [Tyck](https://codeberg.org/natkr/tyck) as a comments
system for simple static sites. It works by SSI, or Server Side Includes, which
allows nginx to directly substitute part of a page with contents from
a different upstream. It's like HTMX without CORS :) Your browser only does
a single request, and everything is static. All that changes is that your
website will be doing a postgres query for the list of comments, and you'll be
substituted a different page. Which basically makes my site half-SSG... it's
neat, I think. Great for the small web. Go check it out.

{% assign cite-title = "Comments!" %}
{% assign cite-published = "2025-07-29" %}
{% assign cite-author = "Natalie Klestrup Röijezon" %}
{% assign cite-url = "https://natkr.com/2025-07-29-comments/" %}
{% include cite.html %}
