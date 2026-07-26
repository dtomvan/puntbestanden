// helper function to create an xhtml element with children
function h(tagName, attributes, ...children) {
    const element = document.createElementNS("http://www.w3.org/1999/xhtml", tagName);
    for (const [name, value] of Object.entries(attributes ?? {})) {
        element.setAttribute(name, value);
    }
    element.append(...children.filter(child => child != null));
    return element;
}

// add <head>, hide everything to prevent flash of unstyled content (FOUC)
var head = h('head', {},
    h('style', {}, `feed > * { display: none; }`)
);
document.documentElement.append(head);

document.addEventListener('DOMContentLoaded', function () {
    // convert atom text constructs to HTML
    document.querySelectorAll('content, rights, subtitle, summary, title').forEach(element => {
        var type = element.getAttribute("type");
        if (type === "html" || type === "xhtml") {
            var result = h(element.tagName);
            result.innerHTML = element.textContent;
            element.replaceWith(result);
        }
    });

    // populate <head>
        head.append(h('head', {},
            h('title', {}, document.querySelector('feed > title').textContent),
            h('meta', { name: "viewport", content: "width=device-width" }),
            h('style', {}, `
                entry > * {
                    display: none;
                }
                feed > title, entry, entry title, entry content, entry i, entry author, entry p.replies-link {
                    display: block;
                }
                entry a.tag {
                    display: inline-block;
                }
                entry summary:not(:has(~ content)) {
                    display: block;
                    margin-top: 1em;
                }
                `)
        ));

    // convert top-level `<title>/<link>` into `<h1><a>title</a></h1>`
    var feedTitle = document.querySelector('feed > title');
    var feedLink = document.querySelector('feed > link[rel="self"]');
    var newLink = h('h1', {}, h('a', { href: feedLink.getAttribute('href') }, ...feedTitle.childNodes))
    feedTitle.replaceChildren(newLink);
    newLink.insertAdjacentHTML("afterend", "<p>This is an <b>atom</b> feed. Add it to your reader, or just read by clicking links from here!</p>")

    // convert entry-level `<title>/<link>`s into `<h2><a>title</a></h2>`
    document.querySelectorAll('entry').forEach(entry => {
        var title = entry.querySelector('title');
        var link = entry.querySelector('link[rel="alternate"]');
        var newLink = h('h2', {}, h('a', { href: link.getAttribute('href') }, ...title.childNodes));
        title.replaceChildren(newLink);

        var authorName = entry.querySelector("author > name"); // required
        var authorLink = entry.querySelector("author > uri"); // optional
        if (authorLink) {
            authorName.replaceChildren(h("a", { href: authorLink.textContent }, authorName.textContent));
            authorLink.textContent = '';
        }
        
        // I've a small message about how it's cool that you're using RSS after
        // each post summary, but it doesn't make sense to include here.
        var summary = entry.querySelector('summary');
        summary.innerHTML = summary.innerHTML.replace(/<hr[\s\S]*/m, "")

        // If published == updated, it makes no sense to mention the same date
        // twice
        var published = entry.querySelector("published")
        var updated = entry.querySelector("updated")
        if (published.textContent == updated.textContent) {
            entry.removeChild(updated);
        }

        entry.querySelectorAll('published, updated').forEach(date => {
            var newDate = h("time", { datetime: date.textContent });
            newDate.textContent = new Date(date.textContent).toISOString().split("T")[0];

            var i = h("i");
            i.innerHTML = (date.tagName == 'published' ? 'Published ' : 'Last updated ') + newDate.outerHTML;

            date.outerHTML = i.outerHTML;
        });

        entry.querySelectorAll('category').forEach(category => {
            var tagName = category.getAttribute("term")
            var tagSpan = h("span");
            tagSpan.textContent = `#${tagName}`

            var tag = h("a", { class: "tag", href: `/blog/tags/#${tagName}`,  style: "color: var(--ctp-subtext0);text-decoration: none;" }, tagSpan);

            category.outerHTML = tag.outerHTML;
        })

        var repliesLink = entry.querySelector('link[rel="replies"]');
        if (repliesLink) {
            entry.insertAdjacentElement("beforeend", h("p", { class: "replies-link" }, h("a", { href: repliesLink.getAttribute("href") }, repliesLink.getAttribute("title"))));
        }
    });
});
