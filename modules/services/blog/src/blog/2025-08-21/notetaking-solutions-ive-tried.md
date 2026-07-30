---
title: "Notetaking solutions I've tried"
date: 2025-08-21T22:59:29+02:00
tags: ["emacs", "neovim", "notetaking"]
layout: post
draft: false
aliases:
    - /2025-08-21-notetaking-solutions-ive-tried
---

As a former high school student and soon-to-be college student, I have
been struggling with note-taking. It's the 21st century, the digital
age; note-taking should've never been easier... but the rabbit-hole is
deep as the Mariana Trench and the possibilities endless, so being the
tech-savvy guy that I am, who likes to experiment with new tools and
software, I have, as of now, tried a grand total of **15** digital
note-taking/task-taking solutions and/or combinations.

In this blog post, I will try to sum up all the note-taking
systems/programs/editors I've tried to this date, what my experiences
were, and what I think about them. Some entries in the list I have
written less about than the others, because I either (i) haven't used
it for an extended period of time, (ii) don't have much to say about
it, or (iii) has been covered extensively in the "note-taking" media
space before.

Beware: this post will probably not help you get off the productivity
treadmill that you are probably on right now (you clicked on this
after all), since I am also still very much on it and I like playing
with software.

Beware: this is a bit of a ramble. Forgive me for my sub-par writing
skills.

# [Obsidian](https://obsidian.md)

The one I've used for the longest, and which has carried me through
high school. It's killer for making notes for school, quickly jotting
down stuff and then later iterating on it until you have something
usable which you can link to, export, print out as a PDF, you name it.

Obsidian is a rabbit hole in and of itself, with plugins, themes,
"systems" to organize it all, template vaults, you name it. There's
even a plugin to run SQL-like queries on your notes and tasks, and
it's one of the more popular ones...

The one and only big downside doesn't come as a surprise: it's an
Electron app. They all are, at least, the "mainstream" ones. That's a
bummer, but I can live with it. If I want to use something more
lightweight to edit my notes I am free to do so.

The problem is that Obsidian vaults are _nearly_ interoperable with
all editors, _nearly_. The linking and tagging doesn't translate over
well to any other editor that tries to understand Markdown links, so
your Obsidian vault can only come to its full fruition in, well,
Obsidian itself. People talk about vendor lock-in all the time when it
comes to note-taking, and I'd call this a little bit of vendor lock-in
sadly...

4/5

# [Logseq](https://logseq.com/)

It's basically an Obsidian clone, except it has some funky features:

- The outlining is strictly bullet-point based
- It has built-in queries and inline bells and whistles, powered by EDN
  (the entire "backend" to the Electron app is written in Clojure)
- It's slower
- It enforces a single structure in your notes, with:
  - Journals
  - Whiteboards
  - Flashcards
  - Pages
- It indexes everything in a database, further creating some amount of lock-in
  - To be fair, the notes are openable from nvim/obsidian, because
    it's just markdown in a wonky directory structure after all

The thing with Logseq is that in its current state it needs a lot of
work (they are doing a complete "v2" overhaul at time of writing
this), so it's basically Obsidian from Alibaba right now. So currently
there's no point in using it. Obsidian is just less janky and more
flexible. I like the ideas in Logseq, but they aren't executed as
nicely IMHO.

3/5

# [Dendron](https://dendron.so/)

This is a VSCode extension, which might sound good to you, but I
promise you it isn't practical. The VSCode shell and extension
framework only gets in the way of good UX. Sure, you can carry over
your existing setup and extensions, and probably be really cozy if you
were a regular user of VSCode anyway, but what "setup" does one need
to edit markdown files? Maybe the YAML extension for the frontmatter?

They have a nice philosophy [where all notes are in a single flat directory](https://wiki.dendron.so/notes/f3a41725-c5e5-4851-a6ed-5f541054d409/)
and structure is added by "namespacing" notes like:

```
world.flora.grass.md
world.flora.tree.md
world.fauna.elephant.md
space.planets.mars.md
```

Then, one optionally could add YAML
[schema's](https://wiki.dendron.so/notes/c5e5adde-5459-409b-b34d-a0d75cbb1052/)
that dictates the contents of a given subset of your notes. Say, you
want to put all your notes under `daily`, where then they are nested
by year first, then month, then day. You'd get notes like
`daily.2025.08.21.md`. And every time you create such a note, that
template will get assigned automatically, like QuickAdd in Obsidian
and org-capture in Emacs.

Overall, nice idea, but it doesn't work for me. It's a bit too rigid
and explicit for my taste. It's like writing GitHub actions: you don't
want to be doing it, and it feels like unneeded boilerplate code
(because YAML it Turing-complete now...)...

3/5

# [Notion](https://notion.so)

This one looked cool at first, for _NORMIES_!!!

I'll keep this one short, there's been a lot of critique on this one
for it's cloud-onlyness, corporateness, slowness, you name
it. Although I've heard the tech behind it is impressive, [or
something](https://www.youtube.com/watch?v=NwZ26lxl8wU) ("How notion
handles 200 billion notes without crashing", by Coding with Lewis on
YouTube).

# [Neovim](https://neovim.org) + [Neorg](https://github.com/nvim-neorg/neorg)

I didn't dive to deep into this one, because it felt way too
convoluted, and my Neovim config was dangerously close to 10kLoC at
the time, so I got rid of it quite quickly.

The problem with this one is, it might sound like `org-mode` for an
editor that isn't Emacs, but it isn't. It's an entire other ecosystem
of its own; it doesn't operate on `.org` files, but on `.norg`! So
honestly, that makes it go from a semi-widely-used format to a format
that no-one has ever seen before, and I simply cannot "full send" all
of my notes into it.

4/5

# [Neovim](https://neovim.org) + plain markdown

I know this is the note-taking system I should be using, be it with or
without vimwiki. The problem with it is: it's boring. This is also the
reason I know it's probably the best one on the list (simple and
boring beats flashy and unreliable), but it turns out that my brain
doesn't like to be productive, so even by writing this (in "the last
note-taking system I'll ever need, trust me bro") I'm keeping myself on
the "productivity treadmill"... such a bummer...

4/5

# [QOwnNotes](https://www.qownnotes.org/)

This is one of the better ones on the list. It is foremost a QT
app, but it works on basically anything, even macOS. It's basically a
less bloated Obsidian. The surrounding ecosystem isn't as big, but there
is a [Script repository](https://github.com/qownnotes/scripts),
containing all kinds of integration and/or export scripts. QOwnNotes
does have its fair share of built-in features though, and most users
who don't publish anything in blogs for example will most likely do
just fine with the default OOTB experience.

But it's got something that Obsidian will never have: it's FOSS! It's
licensed under GPLv2, making it one of the few desktop GUI solutions
that doesn't want to steal your data.

For synchronization, it's got Nextcloud integration, making it perfect
for people who are already invested in the self-hosted ecosystem. It
also supports Evernote imports, and of course exiting Obsidian vaults
work just fine with it.

In order to get the wikilinks/backlinks functionality to work though,
you'll need to install the "Wiki links" and "Backlinks" scripts
respectively, and for the wikilinks you'll have to disable the
sanitization options in order to be fully compatible with Obsidian's
wikilinks...

There's just one thing for me holding it back, and it's the
_jank_. Just a few points:

- The default dark theme is as ugly as can be
- The settings menu is ugly, convoluted and slow
- The default keybinds often don't make sense (`C-S-a` for the command palette, for example)

4/5 because of it's jankiness

# [Emacs](https://www.gnu.org/software/emacs/) + [Orgmode](https://orgmode.org)

The OG note-taking system. It's been around since 2003, just a year
before [Markdown was invented](https://daringfireball.net/projects/markdown/).
Since then, it's `org-capture`'d all sorts of note-taking gurus,
Zettelkasten believers and GTD-ists. The reason why Orgmode is so good
is not (necessarily) that it's an Emacs thing, or the way the
formatting works. It's because the functionality on top is so nicely
integrated with the underlying markdown. Think of the `org-agenda`,
`org-babel`, `org-capture`, `org-export-dispatch`... It even exports
to ODT and [A Hugo blog](https://ox-hugo.scripter.co)!

I don't think I have much to say about Orgmode, as it has been
discussed a whole lot already in the notetaking space. It's very
cromulent for people who can take on the beast that is Emacs, and has
stood the test of time.

One problem I frequently have is that generally it doesn't sync
properly to my phone. With markdown, I could use Obsidian (Sync), and
read and my notes inside of a proper mobile experience. Org has
Orgzly, but it's just not there yet on UX. I've also tried the Emacs
for Android port that has been recently released, but it's just jank
galore since emacs is a keyboard-heavy piece of software (or menu
hell).

5/5

# [Emacs](https://www.gnu.org/software/emacs/) + [denote](https://github.com/protesilaos/denote)

Denote isn't much of a piece of software or a system, but rather a way
to name your files. It also stores relevant information in the notes'
frontmatter, but it can work with any filetype, like videos or PDFs,
since it's _just a naming scheme_ and nothing more in its core.

By default, it uses `.org` files though, making it compatible with the
previous entry on the list. You can just replace `org-capture` with
`denote` most of the time when you want to create a note for something.

While using denote, your filenames will take the form of:

```
YYYMMDDTHHmmss--slugified-name__tag1_tag2.{org,md,txt}
```

This way, you can search for `-name-part`, since every "name part"
starts with a dash (or whole name like `-whole-name_`), and you can
filter by tag with `_tag1`, no regex required! If you are using regex
though you can for example filter by year and month, like `^202208`.

This, IMO, is the only one that has zero vendor lock-in, because it's
just a way to name files. You could probably do something similar in
10 lines of bash...

When you don't use org as the filetype though, you lose some
org-builtin linking features, and hence you'll need to rely on
"denote-style" links, like `[[denote:YYYYMMDDTHHmmss]]`, which, well,
doesn't get picked up by most editors.

If you are interested, I highly recommend that you watch Prot's own
[demo video](https://protesilaos.com/codelog/2022-06-18-denote-demo/)
to Denote.

Also, I admire how Prot committed to his Emacs journey and Denote, he
seems to have been slowly but consistently working on Denote for the
past 3 years, judging from the GitHub history.

5/5, very much subject to change because I haven't used it a lot yet

# [nb](https://github.com/xwmx/nb)

This tool is a single, huge, feature-rich, probably
Swiss-cheese-shaped, BASH script that probably only the author and God
understand, for managing Markdown files and their attachments.

It's also a Swiss-army knife: it can do _any_ note format, encryption,
tagging, searching, wikilinks, tasks, workspaces... Hell, it even has
its own web UI through `nb browse`.

It's really cool that someone has been able to make this, and I have a
lot of respect for putting in the effort of actually building this,
but it's just not for me.

3/5

# BONUS: Task management

This last section isn't really about "note-taking" apps, but more
about managing your tasks list. Currently, I'm not really using either
one, I just schedule "events" in my Google calendar when I want to do
or think about a task, which isn't really a proper, coherent,
"system", isn't it?

## todo.txt/[ntodotxt](https://github.com/tmaegel/ntodotxt) for Android

Same as with the Neovim + plain markdown case. I know this is the one
I should be using, but it's the most boring, so my brain refuses to
start using it for all of my task management.

The ntodotxt app is really nice, since it could also in theory be used
on Linux, since it's a Flutter app. It basically provides a shell over
the todo.txt file format, so that your fat fingers don't need to type
everything perfectly by hand (like datetimes, for example, can be
input by the handy datetime widget in Android).

The only problem to me is synchronization: I could use something like
Dropbox or Syncthing to hand over the file, but it isn't as nice as
Google Tasks or Taskwarrior's built-in syncing, for example; Dropbox
and Syncthing don't have any clue what to do when a conflict arises,
that is, when two devices haven't talked to each other yet, but they've
both made local changes to a file at the same time. This happens all
the time if you're like me and don't use your PC at the same time that
your laptop is turned on, for example.

4/5

## [Taskwarrior](https://taskwarrior.org)

This one is really cool. I'll just list some of its features off the top of my head:

- Extensive querying
- Automatic urgency scoring based on priority, deadline, effort, etc.
- Hence can basically choose for you which task to do next through the
  appropriately-named `task next` command, which is very useful to
  neurodivergents, for example
- Recurring tasks done relatively well
- Timekeeping through `timewarrior`
- A fair amount of configurability and hackability
- Built-in synchronization

It's all inside of a single C++ CLI, which runs on Linux, macOS, and
even Windows (through WSL2, but what Windows user that's nerdy enough
to think about taskwarrior doesn't have that setup already?)

4/5

## Google keep/calendar/tasks

I know that I should be degoogling, and I want to, but the Google
"workspace" ecosystem has been way too convenient for me. Is this what
Apple users feel like all the time when they feel like this "need" an
iPad to go along with their iPhone and MacBook???

I don't use this as much anymore, but it is just a simple, cromulent
way to store your tasks and events. The Android apps are one of the
best in the entire ecosystem.

4/5

## [Todoist](https://www.todoist.com/)

This one might seem like you are finally being productive and finally
getting your life together and organized, but it's not: it's just
adding a lot of noise and extra features you now "have to use" before
you can actually do the thing you want: input tasks and then later
read them back in a list...

Also, it's centralized in the cloud and big corporate, so they'll
probably screw you over in the future, with a high subscription fee
for example. If you want a calendar, deadlines and room for more than
5 "projects" you'll need to pay €4/month, which might be respectable
_right now_ (although charging for such basic features seems a bit too
greedy to me), but it might become more and more as time goes on, and
VC money needs to make some ROI...

(and it has AI, so count me out anyway lol)

2/5

## Obsidian again

Obsidian for task management is kind-of a mixed bag for me. I just
don't know how it's supposed to work. The only thing in Obsidian that
would come close to the Orgmode agende I've found so far is the
following, slightly convoluted setup:

- Use the Homepage plugin that directs you to your daily note on
  startup
- Use the Dataview plugin to query relevant tasks for today inside the
  daily note
- Use the Templater plugin to automate writing a Dataview query when
  the daily note gets created

Notwithstanding the amount of time and investment required to come up
with "the perfect template" for your daily notes and "the perfect
query" for your tasks. I've tried, and at the end of the day it just
means you're procrastinating. With Org I just `(setq org-agenda-files
(list org-directory))`, write TODO's anywhere, and do `M-x org-agenda
a`, and I'm in. It isn't magic, just a good todo system. Obsidian just
doesn't have that AFAICT...

Still I am able to find the utility in storing your tasks inside of
Obsidian, and it's the same as with storing your tasks in Orgmode:
it's unification. When you have unified your notes and tasks in a
single workspace, you are able to link to your notes from your tasks
and back. And generally that's really for documenting context.

2/5

# BONUS 2: AI in note-taking

There has been a new hype (a sub-hype to the general AI hype if you
will) to incorporate LLMs and decision-making-algorithms into
note-taking and task management respectively. I have a more general
opinion about LLMs that then should be used as little as possible, but
alas, people just can't resist handing off their (creative) thinking
and research to a clanker, can they?

Take [Supernote](https://supernote.app/) for example. It's basically
ChatGPT for your notes. It can summarize videos, recordings,
documents, etc. But it also generates content from your other notes,
like flashcards, for example. To me, this just defeats the entire
purpose of note-taking. Not only are you handing off all of your data
and notes to these AI companies, but you are brutally destroying your
knowledge retention.

The purpose of taking notes is to accumulate knowledge. You're not
creating another Wikipedia, but you are using your notes to _learn, in
your own head_. Writing can be a useful means to get a good
understanding on a topic, and it's a form of _active learning_. What
you are doing when you let an LLM do all the hard work is turning that
into a _passive learning_ experience, as all you can do with notes
that were handed to you is, well, _read them_. But you aren't
interacting with the subject matter in any meaningful way. The entire
point of taking notes is lost.

To anyone considering buying a subscription to these platforms: please
think twice, _do not waste your money_. I cannot stress it enough.

# Conclusion?

I hope that, if you are still looking for the "perfect match" for your
notes/PKM, this post has helped you a bit with choosing your next (and
_definitely_ last) one. In the end, just use whatever works, I guess.

My problem is that I feel like I've tried everything and none of them
actually "work" or stick with me... so I am at a loss. Currently
trying Denote (this is my first note with it). Fingers crossed that
"this is it"...

Maybe, just maybe, I'll get off of this treadmill for good
someday. Probably when I get a full-time job 🤣...
