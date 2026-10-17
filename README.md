# laasyaraagyni.com

Personal site. Built with [Astro](https://astro.build) (open source), deployed to GitHub Pages.

## Running it locally

```bash
npm install
npm run dev
```

Then open http://localhost:4321

## Editing the site

All the words on the site live in the `content/` folder. You never need to touch
anything in `src/` to change what the site says.

| File | What it controls |
| --- | --- |
| `content/home.md` | The home page: name, tagline, the "A little more" paragraphs, the P.S. |
| `content/books.md` | The books page: currently reading, and finished books |
| `content/blog/*.md` | Blog posts, one file each |
| `content/site.md` | X and LinkedIn links, footer line, search description, visit counting |

Each file has settings between two `---` lines at the top, and (for the home
page and blog posts) normal Markdown writing below them. Lines starting with `#`
inside the settings are notes to yourself and don't appear on the site.

### Putting your edits live

Either of these works:

- **On your Mac:** edit the files, save, then double-click **`Publish.command`**
  in Finder. It shows what changed, checks the site still builds (if Node is
  installed), saves the changes to GitHub, and the site updates a minute or two
  later.
- **From anywhere, in a browser:** open the file on github.com, click the pencil
  icon, edit, and click **Commit changes**. The site rebuilds the same way.

If something in an edit is wrong (say, a book without an author), the build
stops and names the file and the field. On GitHub this shows up as a red X on the
[Actions page](https://github.com/laasya-14/laasyaraagyni.com/actions), and the
live site stays as it was.

### Settings tips

- Put a value in double quotes if it contains a colon (`:`) or starts with `#`,
  for example `intro: "Reading: mostly science"`.
- Indentation matters in the books list: keep it lined up like the existing entries.
- Straight quotes are fine. `I'm` shows up as `I’m` on the site.

### Adding a blog post

Create a new file in `content/blog/`, for example `content/blog/my-note.md`:

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
Set `draft: true` to keep a post off the site while you work on it.

### Adding a whole new page

This one does need code. Create a file in `src/pages/`, for example
`src/pages/projects.astro`, and copy the structure of `books.astro`. To put it
in the header nav, add it to the `navItems` list in `src/layouts/BaseLayout.astro`.

## Where things live

| Path | What it is |
| --- | --- |
| `content/` | Everything the site says (see above) |
| `Publish.command` | Double-click to publish your edits |
| `src/content.config.ts` | Which settings each content file has, and the checks on them |
| `src/layouts/BaseLayout.astro` | Shared shell: header, nav, footer, fonts |
| `src/styles/global.css` | All the styling |
| `src/pages/` | One file per page (the layout, not the words) |
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

To switch it on, sign up, pick a site code, then set it in `content/site.md`:

```yaml
goatcounter: your-code
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
