// Everything editable lives in the top-level content/ folder as Markdown.
// The schemas below check those files at build time, so a typo (say, a book
// with no author) stops the build with a clear message instead of shipping
// a broken page.
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

// Text typed in the settings gets typographic quotes, like the Markdown body
// does: I'm becomes I’m, "this" becomes “this”.
const text = z.string().transform((s) =>
  s
    .replace(/(^|[\s(\[])"/g, '$1\u201c')
    .replace(/"/g, '\u201d')
    .replace(/(^|[\s(\[])'/g, '$1\u2018')
    .replace(/'/g, '\u2019')
);

// A YAML list whose entries are all commented out reads as null; treat that as empty.
const list = <T extends z.ZodTypeAny>(item: T) =>
  z
    .array(item)
    .nullish()
    .transform((v) => v ?? []);

const book = z.object({
  title: text,
  author: text,
  year: z.coerce.string().optional(),
});

const site = defineCollection({
  loader: glob({ pattern: 'site.md', base: './content' }),
  schema: z.object({
    x: z.string().url(),
    linkedin: z.string().url(),
    description: text,
    footer: text,
    goatcounter: z.string().nullish(),
  }),
});

const home = defineCollection({
  loader: glob({ pattern: 'home.md', base: './content' }),
  schema: z.object({
    eyebrow: text,
    name: text,
    intro: text,
    portrait_alt: text,
    section_label: text,
    ps: text.optional(),
  }),
});

const books = defineCollection({
  loader: glob({ pattern: 'books.md', base: './content' }),
  schema: z.object({
    intro: text,
    reading: list(book),
    finished: list(book),
  }),
});

const blog = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './content/blog' }),
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    description: z.string().optional(),
    draft: z.boolean().default(false),
  }),
});

export const collections = { site, home, books, blog };
