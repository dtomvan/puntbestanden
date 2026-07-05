---
title: Hello IndieWeb!
subtitle: ...and the slop that are link aggregators, sadly.
summary: I've implemented several Microformats on this website.
date: 2026-07-01T17:33:57+02:00
layout: post
lang: en
tags: [indieweb, microblogging, microformats]
draft: false
---

**Assumed audience:** either the IndieWeb-curious or IndieWeb enthusiasts, optional: people who have experience with the big web, especially aggregators

I've felt inspired by [James' Coffee Blog](https://jamesg.blog/indieweb) and
[Beto Dealmeida](https://robida.net) to become a better "smallweb citizen" and
start doing IndieWeb Things. A quick history. I've learned to love reading
blogs and feeds, but I'm less and less excited by reading link aggregators like
[Lobsters](https://lobste.rs), [Hacker News](https://news.ycombinator.com), and
[Reddit](https://reddit.com). If not for the more slop-oriented and semi-toxic
communities there, the feeds are just too big to keep up with. After 2 months or
so, I get around 1000 Lobsters entries piling up, and probably over double for
HackerNews. Even when pruning significantly, that's just way too much to keep
up with, and it gets tiring very quickly.

So I started tracking individuals more often through RSS and the like (well,
the only exception is probably [Phoronix](https://phoronix.com), but they also
have a huge output volume). Just like with the switch from Twitter to Mastodon
I made a while ago, I found that I actually started seeing posts that I'm
actually more likely to be interested in and actually finish, as opposed to the
endless stream of content on the aggregators, which encouraged me to skim
everything.

I am also way less focused on long-winded internet discourse, which seems more
healthy. While I think it's important to have a healthy discussion on
(technical) topics online, I don't think the way that it's currently done is
healthy at all. Today "important" things blow up and receive a tsunami of
"HackerNews traffic". A recent example I've seen first-hand was [`yt-dlp`
announcing that they would remove support for the new bun
rewrite](https://github.com/yt-dlp/yt-dlp/issues/16766), which got over 1000
reactions and 100 comments, whereas as [similar
announcement](https://github.com/yt-dlp/yt-dlp/issues/16766) had zero
discussion whatsoever. This goes to show that the "aggregator public" is a lot
less focused and tends to form opinions on stuff they don't _actually_ care
about, solely for the purpose of "internet discourse". This is discussion for
the sake of discussion, which isn't productive at all.

But I digress...

## So, IndieWeb

As of today, I've implemented some indieweb principles for this website:

- `rel=me` for [`RelMeAuth`](https://indieweb.org/RelMeAuth)
- [`rel=license`](https://microformats.org/wiki/rel-license)
- [`h-card`](https://microformats.org/wiki/h-card) (fun fact: on the homepage the `h-card` consists of the navigation bar followed by the first paragraph of introduction, which I think is neat)
- [`h-feed`](https://microformats.org/wiki/h-feed)
- [`h-entry`](https://microformats.org/wiki/h-entry) (inside of the `h-feed` of course, but also on `/` and on the actual posts' pages)

I have also implemented comments with [Natalie K. R.'s
Tyck](https://natkr.com/2025-07-29-comments/). I know, I know, those aren't
[webmentions](https://indieweb.org/Webmention) or
[micropub](https://indieweb.org/Micropub) or automated
[POSSE](https://indieweb.org/POSSE), but I do think it follows the [indieweb
principles](https://indieweb.org/principles) nicely. You still get to post with
your own identity (you can optionally reference your personal website), and
I get to own both the post and the comments infrastructure.

If you want to comment here though, I won't get pinged by the moderation queue yet, as Tyck only supports pinging by e-mail as of writing, and I don't have a good (read: not megacorp and preferably self-hosted)

## So why not do those things

In the previous section I mentioned that I haven't implemented webmentions or
POSSE yet. That's mostly because I'm lazy and I'm using a lot of drop-in
solutions, like [Jorge](https://jorge.oleano.dev) and Tyck. I'd probably have
to write a cron job with some custom code to scrape my own site, send
webmentions, and publish to Mastodon or whatever. I'm probably looking into that later, but who knows.

Bottom line is, the above adjustments have a lot more ROI. They basically only involve adding a couple `class` names in various places. You then get a lot back for it:

- You are welcome to the [IndieWeb ring](https://xn--sr8hvo.ws) (you don't even
  have to go through a vetting process, because you've "proven" yourself by
  implementing at least `h-card` and `RelMeAuth` :)
- People with IndieWeb readers can read through your `h-feed` (though Jorge
  supports generating an RSS feed, but let's pretend it doesn't)
- You can generate a simple profile banner from your toplevel `h-card` (example: https://xn--sr8hvo.ws/directory)

Also, one day I hope to be able to use [`rel=tag`](https://microformats.org/wiki/rel-tag), but I can't right now due to [Jorge lacking a little bit](https://github.com/facundoolano/jorge/issues/44). But that's okay. The code is really readable an tiny, so I should probably just address that myself some day.

## So do it yourself!

If you use any [SSG](https://en.wikipedia.org/wiki/Static_site_generator), this is most likely trivial to do! So why not! Make your website more independent and indexable (in a good way) today!

For Jorge, you could look at my diffs for [`h-entry`](https://git.toostveen.nl/tom/puntbestanden/commit/9a2b70d3ff90abf126a12c17f6c5db24a622238d) and [`h-feed`](https://git.toostveen.nl/tom/puntbestanden/commit/8ce4dd8b2d25526b7df7fc57ca194176b1781001), for example. Do keep in mind that I didn't start
from a "vanilla" (the kind you get from `jorge init`) blog though. But it still probably recognizable.
