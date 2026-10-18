# Clientela

Client analytics for independent professionals (tour guides, trainers, tutors, physiotherapists, photographers, studios).
One page, no server: open `index.html` or the GitHub Pages address and it works.

- **Where data lives:** in the browser that uses it (IndexedDB). Nothing is sent anywhere unless sync is turned on.
- **Laptop and phone:** optional sync through your own Supabase project (Data → Backup, devices and AI). The SQL to run once is shown there.
- **Backup:** Data → Download backup (.json). The same file restores everything on another device, and also carries client profiles.
- **AI analyst:** optional, with your own Anthropic API key, stored only in the browser. Without it, built-in answers are used.

This folder holds the built page. The source lives with Gabriele and is built with `python3 build.py`.
Client names and client profiles are not part of this public page: they are imported from a private profile file.
