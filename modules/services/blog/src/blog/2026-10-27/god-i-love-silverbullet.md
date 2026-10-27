---
title: God I love SilverBullet
date: 2026-10-27T22:51:18+01:00
layout: post
lang: en
tags:
  - dx
  - tricks
  - notetaking
draft: true
---

![SilverBullet, in my public cs-notes space](/assets/img/silverbullet.png) Silverbullet, in my public cs-notes space [^1]

In today's [^2] episode on "God I love..." or "Wow this is something I've been hopping so much and _this time_ **I finally got it!** (hopefully)", we have [SilverBullet](https://silverbullet.md).

In three words, this is **[Obsidian](https://obsidian.md) but selfhosted**. It's completely FOSS as well! I decided I _have_ to write on this, because it seems like such a hidden gem no-one has heard of before...

Just last monday I found myself looking for something I could use to write quick notes with, self-hosted, on my own domain. Something like <https://notes.toostveen.nl>. My expectations were more-or-less high:

- Needs to be minimal-ish
- Needs an okay mobile experience
- Preferably usable even without connection to the server, so that it syncs when connection is regained
  - To elaborate on that: it would be pretty shitty to have your notes app break when you're offline, any notes app ever doesn't usually do that
- Preferably has a web interface so I don't need to run yet another "native" (read: Electron) app
- Preferably not PHP (this has only partly to do with the recent PHP CVSS 9.4 vulnerabilities)
- Preferably syncs somewhere else (or even locally)

Some options came to mind [^3]:

- [Flatnotes](https://github.com/dullage/flatnotes): good, almost used it, until I saw SilverBullet of course
- [Poznote](https://poznote.com/): featureful, but hefty and PHP
- [Standard Notes](https://standardnotes.com/): by Proton, seems cool, but the [self-hosting guide](https://standardnotes.com/help/self-hosting/docker) is not only wacky, it's also docker-only. I want NixOS, gawd damn it!! Also, it seemed like it wasn't really meant for self-hosting. They _really_ want you to make a free account instead...
- [Memos](https://usememos.com/): used this for a couple moments, but didn't like the organization of it being a timeline. Felt more like a microblogging platform. I'd rather want a more traditional folders/tagging experience.
- [Trilium Notes](https://triliumnotes.org/): to be honest, I have no good reason why I didn't end up using it. If I never found SilverBullet I might've settled for this.

All of the above are nice options and each have their own target audience. I'm just SilverBullet's.

## What makes it so good

Well, the most important part is that out of all of the above, it's just the
same paradigm as I'm used to from Obsidian: _your notes are a single folder
with plain-text markdown files in them_. They may reside on a server, but when
combined with their [desktop app](https://silverbullet.plus/), they'll actually
sync as files on your local disk! That makes this the _first electron app ever_
that adds value on top of Just Using the Website Directly. Impressive!

That doesn't mean that directly accessing the space from the browser is any
different though. It just syncs the notes to IndexedDB instead. But it's still
not a proprietary format. It's still just your own plain markdown on your disk
at the end of the day.

Okay, now rapid-fire:

- [DataView](https://community.obsidian.md/plugins/dataview)-like queries are built-in
- It has powerful tagging, templating, journaling, and automation features
- It's configured and scripted with Lua
- It has a PWA for mobile and offline use
- It has semi-live sync and collaboration (and revision history)
- You can have multiple users and spaces, and even make certain spaces available to guest users
- The documentation is enormously great
- It has vim mode built-in

## Conclusions

To be honest, I've always been a sucker for underrated power-user-software. I think I struck a pot of gold with this one, once more. I might've even used SilverBullet as my blog if I never found [jorge](https://jorge.oleano.dev) first...

Anyways, my only public space right now is my CS one. Go [check it out](https://cs.toostveen.nl), or go to the [official demo](https://demo.silverbullet.md/personal/) (well, this is one of four, the showcase for personal usage). Highly highly recommended. It may be a bit unwieldy at first, and less intuitive than Obsidian, but if you've used that before, you'll feel at home in mere hours.

[^1]: yes, that's a _custom sidebar_ (!!)

[^2]: yes, it's been a while, I'm sorry... No I'm not, just been busy.

[^3]: shout-out to this [Reddit thread](https://www.reddit.com/r/selfhosted/comments/1bs8uzh/self_hosted_note_taking_app/) I read almost all the way through in order to arrive at the choice I made now.

## Related posts

- [Notetaking solutions I've tried](/blog/2025-08-21/notetaking-solutions-ive-tried)
- [God I love Neovim](/blog/2026-07-22/god-i-love-neovim/)
