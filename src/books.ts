// Joins the list in content/books.md with the optional per-book pages in
// content/books/. A book gets a page when a file there is named after it:
// "The Vegetarian" matches the-vegetarian.md (case, spaces and punctuation
// don't matter).
import { getCollection, getEntry } from 'astro:content';

const key = (s: string) => s.toLowerCase().replace(/[^a-z0-9]/g, '');

export async function getBooks() {
  const list = await getEntry('books', 'books');
  if (!list) throw new Error('content/books.md is missing');
  const { intro, reading, finished } = list.data;

  const pages = await getCollection('bookPages', ({ data }) => !data.draft);
  const all = [...reading, ...finished];

  // A page whose name matches no book would silently never appear, so stop
  // the build and say which book names it could have meant.
  for (const page of pages) {
    if (!all.some((book) => key(book.title) === key(page.id))) {
      throw new Error(
        `content/books/${page.id}.md doesn't match any book in content/books.md. ` +
          `Name it after one of: ${all.map((b) => b.title).join(', ')}.`
      );
    }
  }

  const withPage = <T extends { title: string }>(book: T) => ({
    ...book,
    page: pages.find((page) => key(page.id) === key(book.title)),
  });

  return { intro, reading: reading.map(withPage), finished: finished.map(withPage) };
}
