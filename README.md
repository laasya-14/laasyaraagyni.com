# laasyaraagyni.com

Personal site. Built with [Astro](https://astro.build) (open source), deployed to GitHub Pages.

## Running it locally

```bash
npm install
npm run dev
```

Then open http://localhost:4321

## Adding a blog note

Create a new file in `src/content/blog/`, for example `src/content/blog/my-note.md`:

```markdown
---
title: "The title of the note"
date: 2026-09-01
description: "One line, used for search engines and previews."
draft: false
---

Write here. Normal Markdown: *italics*, **bold**, [links](https://example.com),
lists, and `## Headings`.
```

The filename becomes the URL, so `my-note.md` becomes `/blog/my-note`.
Set `draft: true` to keep a note out of the site while you work on it.

## Adding a book

Open `src/pages/books.astro` and add a line to the `reading` or `finished` list
at the top of the file.

## Adding a whole new page

Create a file in `src/pages/`, for example `src/pages/projects.astro`, and copy
the structure of `books.astro`. To put it in the header nav, add it to the
`navItems` list in `src/layouts/BaseLayout.astro`.

## Where things live

| Path | What it is |
| --- | --- |
| `src/layouts/BaseLayout.astro` | Shared shell: header, nav, footer, fonts |
| `src/styles/global.css` | All the styling |
| `src/pages/` | One file per page |
| `src/content/blog/` | Blog notes, as Markdown |
| `public/` | Files served as-is (the portrait, `CNAME`) |

## Deploying

Push to `main`. The GitHub Action in `.github/workflows/deploy.yml` builds the
site and publishes it. No manual build needed.

`public/CNAME` tells GitHub Pages to serve the custom domain.

## Pointing laasyaraagyni.com at the site

The domain is registered with GoDaddy. In **GoDaddy → My Products → Domains →
laasyaraagyni.com → DNS**, make the records look like this:

Delete the existing parked `A` record for `@`, then add four `A` records, all
with name `@`:

| Type | Name | Value |
| --- | --- | --- |
| A | @ | 185.199.108.153 |
| A | @ | 185.199.109.153 |
| A | @ | 185.199.110.153 |
| A | @ | 185.199.111.153 |

And one CNAME so `www` works too (replace any existing `www` record):

| Type | Name | Value |
| --- | --- | --- |
| CNAME | www | laasya-14.github.io |

DNS takes anywhere from a few minutes to a few hours to propagate. Once it has,
go to the repo's **Settings → Pages** and tick **Enforce HTTPS** (the option
only becomes available after GitHub can see the DNS and issue a certificate).

Check progress from the terminal:

```bash
dig +short laasyaraagyni.com A      # should list the four 185.199.x.x addresses
curl -sI https://laasyaraagyni.com  # should return HTTP/2 200
```

## Counting visitors

Visits are counted by [GoatCounter](https://www.goatcounter.com) (open source,
free for personal sites, no cookies, so no consent banner is needed).

To switch it on, sign up, pick a site code, then set it in `src/site.ts`:

```js
export const GOATCOUNTER_CODE = 'your-code';
```

If your dashboard is at `https://laasya.goatcounter.com`, the code is `laasya`.
While the value is empty no script is added at all, and the script is only
included in the built site, so local development is never counted.

Note that browser-based counting always undercounts, because ad blockers block
the script. Treat the numbers as a trend, not an exact count.

## The portrait

`public/portrait.png` was made from the original pencil scan by flattening the
paper to transparent so only the graphite lines remain:

```bash
magick "original.JPEG" -auto-orient -colorspace Gray \
  \( +clone -blur 0x40 \) -compose Divide -composite \
  -level 18%,96% -negate -resize 1400x \
  -write MPR:m -fill "#171717" -colorize 100 \
  MPR:m -compose CopyOpacity -composite -strip public/portrait.png
```
