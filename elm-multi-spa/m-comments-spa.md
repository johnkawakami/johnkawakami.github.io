# Comments as a separate SPA

Sketch for splitting comments out of the /m/ Elm app into its own SPA,
mounted as a widget inside the server-rendered article pages. This is
the "SPA island" approach: the article page stays PHP/Twig, and the
comments app owns one `div` inside it.

## Why an island

The /m/ app today is one Elm program (public/m/src/Main.elm) that
handles the features list, the article view, and the comments view +
post form. Comments are the one piece that needs a form, CSRF, and a
POST cycle, so they are the natural thing to carve off: the article
page stops shipping form logic it mostly does not use, comments get
their own lifecycle, and the two apps can evolve (or fail) separately.
Elm is well suited to this because `Elm.Comments.init({ node: ... })`
mounts into any element; no router or shell is needed.

The two alternatives considered:

- **One shell SPA routing between sub-apps**: no reload between views,
  but we own the router and lifecycle code, and every bug in the shell
  breaks everything. More work, no current need.
- **Fully separate pages** (a comments URL that is its own document):
  good if comments need to be a shareable destination with its own
  history entry. Not needed yet; the island can graduate into this
  later by giving the widget's URL its own entry script.

## The current comments flow (what we are extracting)

All of this exists in Main.elm today and moves more or less verbatim:

- GET `/api/articles/{id}/comments` returns the payload decoded by
  `commentsDecoder`: `parent_id`, `numcomment`, and a list of comments
  with `id`, `heading`, `author`, `created`, and the trusted comment
  HTML (which arrives under the JSON key `article` and lands in
  `Comment.html`).
- Comment bodies are trusted server-side HTML, injected via the
  `injectHtml` port: index.html looks each `comment-<id>` node up by
  id and sets `innerHTML`. The widget keeps exactly this trust
  boundary: Elm never renders the HTML itself.
- Posting is the two-step dance: `SubmitComment` sends the app to GET
  `/api/csrf` (token arrives under `"token"`), `GotCsrf` then POSTs
  urlencoded `csrf_token`, `author`, `subject`, `text` to
  `/api/articles/{id}/comments`.
- The stale-while-revalidate cache: responses are stored raw under the
  localStorage key `imc-js.cache:<news-path>` (e.g.
  `imc-js.cache:/news/2025/07/302882.json`); a cached render survives
  a failed revalidation and a fresh fetch survives a late cache read
  (the keepLoaded rule).

## Target shape

### The host page

The server-rendered article page (the same Twig templates that already
serve the article HTML) carries a mount point next to the comments
section:

```html
<div id="comments-app"
     data-article-id="302882"
     data-news-path="/news/2025/07/302882.json"></div>
<script defer src="/m/comments.js"></script>
```

The script tag loads only on article pages, and comments.js is the
compiled Elm widget (small: one view, one form, no list/article code).
The template can render a static "Comments" heading so the page makes
sense before and without JS.

### Mount contract

comments.js exposes the module and boots itself:

```js
Elm.Comments.init({
  node: document.getElementById('comments-app'),
  flags: {
    articleId: Number(el.dataset.articleId),
    newsPath: el.dataset.newsPath,
  },
});
```

Flags carry everything the widget needs; it does not reach into the
host DOM anywhere else. `articleId` selects the API routes (mind the
two id namespaces: regular articles use `/api/articles/{id}`, feature
articles from the archives use `/api/articles/archives/{id}`; if the
widget ever serves archive pages, the host passes
`data-archives="1"`).

### Ports

The widget reuses the /m/ port set, minus the view-only ones:

- `loadCache(newsPath)` / `cacheLoaded(rawJson)` /
  `saveCache((key, rawJson))`: the same three cache ports, talking to
  the same JS glue, so the widget and /m/ share one cache. Same keys,
  same stale-while-revalidate semantics, same keepLoaded rule.
- `injectHtml(list of (id, html))`: comment bodies (and nothing else;
  the widget's own UI is plain Elm `Html`).
- New, optional: `announceCount(int)` -- see below.

Font size and theme need no ports here: the host page's glue already
applies `imc-js.fontsize` and `imc-js.theme` document-wide, and the
widget inherits it because it lives in the same document.

### Storage keys

Shared with /m/, deliberately:

- `imc-js.cache:<news-path>`: comments (and article) payloads. /m/
  writes these today; the widget reads and revalidates the same key,
  so returning readers get the cached comments instantly either way.
- `imc-js.fontsize`, `imc-js.theme`: read-only inheritance from the
  host page's glue.
- `imc-js.story:<id>` stays owned by /m/ (it is article-view state,
  not comments state).

One consequence worth noting: /m/ and the widget both write
`imc-js.cache:<news-path>`, and both must keep writing the same payload
shape, or each app needs its own key. Keep the payload shape (and its
decoder) in one shared place -- see the build section.

### Structure

```
public/m/src/
  Main.elm          -- unchanged until step 5 below
  Comments.elm      -- the widget: model, view, update, ports
  Shared/Payload.elm -- payload decoders (comments, article) so /m/
                       and the widget decode one shape
```

Build:

```
elm make src/Comments.elm --optimize --output=comments.js
```

(Plus the standard minify step used for main.js.) comments.js is
checked in next to main.js; the nginx rules already serve /m/ statically.

## The flow after extraction

1. Page loads, widget boots, glue sends `cacheLoaded` with the cached
   payload for the news path if present.
2. Widget GETs `/api/articles/{id}/comments`, decodes, applies the
   keepLoaded rule against what is displayed, saves to cache, injects
   each comment body into its `comment-<id>` node via `injectHtml`.
3. On submit: GET `/api/csrf`, then POST the four fields. On success:
   clear the form, drop the cached key (or mark it stale), and
   re-fetch. Note the known open bug: after a successful POST the GET
   currently serves stale cached JSON, because the server-side cache
   regeneration step (render_everything / cache_to_disk) does not land
   where the GET reads from. That bug is being fixed server-side; the
   widget's contract stays "re-fetch after post and re-render".
4. Count badge: the host page can show "Comments (n)" above the
   widget. Simplest contract: the widget dispatches
   `announceCount(numcomment)` and the glue sets a
   `CustomEvent('imc:comments-count', { detail: n })` on the mount
   node's parent; the static heading listens once and updates its
   text. If the host already embeds `numcomment` from PHP, the event
   only corrects it after a post.

## Migration steps

1. Extract `Comments.elm` and `Shared/Payload.elm` from Main.elm
   without changing behavior; compile comments.js and boot it
   side-by-side (the widget mounts, /m/'s comments view still exists).
   Verify against the existing Playwright checks (post-test.js and
   inject-debug.js in the /tmp/mtest harness cover exactly this flow).
2. Add the mount div + script tag to the article template; the widget
   replaces /m/'s comments view for article pages reached from the
   web.
3. Delete the comments view (and form state) from Main.elm once the
   widget is confirmed; /m/ keeps the article view and its
   `Comments (n)` link, which now just scrolls to the widget's
   section (same page, no navigation).
4. Add a widget-specific Playwright smoke: boot with no cache, boot
   with stale cache, post, reload, verify persistence, offline
   render.
5. Only if comments need their own shareable URL later: a tiny entry
   script that serves the article page with the widget focused, so
   the island graduates to a page without becoming a second CMS
   surface.

## Non-goals

- No iframe, no postMessage channel, no micro-frontend machinery: the
  island is same-origin, same document, one script tag.
- No state handoff beyond flags in and one event out; anything the
  widget needs lives in the payload or localStorage.
