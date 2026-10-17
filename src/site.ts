// Site-wide settings, read from content/site.md. Edit that file, not this one.
import { getEntry } from 'astro:content';

const entry = await getEntry('site', 'site');
if (!entry) throw new Error('content/site.md is missing');

export const site = entry.data;
