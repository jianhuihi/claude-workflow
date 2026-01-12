import sys
import asyncio
import argparse
import random
from playwright.async_api import async_playwright

async def analyze_reddit(keyword, subreddit=None, direct_urls=None):
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        # Use a randomized user agent to avoid basic blocking
        context = await browser.new_context(
            user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
            viewport={'width': 1366, 'height': 768}
        )
        page = await context.new_page()

        try:
            # 1. Search Logic
            urls = []
            if keyword and not direct_urls:
                # Fallback to DDG Search if no URLs provided
                search_query = f"site:reddit.com {keyword}"
                if subreddit:
                    search_query += f" subreddit:{subreddit}"

                print(f"Searching for: {search_query}...", file=sys.stderr)
                try:
                    await page.goto(f"https://duckduckgo.com/?q={search_query}&kl=us-en")
                    # Try waiting for result links with a longer timeout and broader selector
                    try:
                        await page.wait_for_selector("a[href*='reddit.com/r/']", timeout=15000)
                    except:
                        print("Timeout waiting for DDG results.", file=sys.stderr)

                    links = page.locator("a[href*='reddit.com/r/']")
                    count = await links.count()

                    for i in range(min(count, 5)):
                        url = await links.nth(i).get_attribute("href")
                        if url and "comments" in url and url not in urls:
                            urls.append(url)
                except Exception as e:
                     print(f"Search failed: {e}", file=sys.stderr)

            elif direct_urls:
                urls = direct_urls

            if not urls:
                print("No URLs found to analyze.", file=sys.stderr)
                return

            print(f"Analyzing {len(urls)} posts...", file=sys.stderr)

            # 2. Visit each URL and scrape content
            for url in urls:
                print(f"\n--- Analyzing Post: {url} ---")
                try:
                    await page.goto(url, wait_until="domcontentloaded")
                    # Random delay to be polite
                    await asyncio.sleep(random.uniform(1.0, 2.0))

                    # Reddit loads comments dynamically. We try to grab the main title and content first.
                    # We use generic selectors or text extraction because classes change.

                    # Get Title - usually h1
                    title = await page.title()
                    # Clean title
                    title = title.replace(" : r/", "").replace(" - Reddit", "")
                    print(f"TITLE: {title}")

                    # Extract visible text from the main post and comments
                    # This is a brute-force approach that works well with LLMs because they can filter noise.
                    # We target the main content area if possible, or body text.

                    # Try to find the main post content shreddit-post or generic content div
                    content_text = await page.evaluate("""() => {
                        // Helper to get text from an element
                        function getText(selector) {
                            const el = document.querySelector(selector);
                            return el ? el.innerText : "";
                        }

                        // Try to get specific post body
                        let body = getText('[data-test-id="post-content"]');
                        if (!body) body = getText('.shreddit-post'); // New reddit structure

                        // Get comments - limit to top level to save token space or first few screens
                        let comments = [];
                        // Select comment bodies. New Reddit often uses 'shreddit-comment'
                        document.querySelectorAll('shreddit-comment').forEach((el, index) => {
                            if (index < 10) { // Limit to top 10 comments
                                const author = el.getAttribute('author');
                                const text = el.innerText;
                                comments.push(`[User: ${author}] ${text}`);
                            }
                        });

                        // Fallback for old reddit or other layouts: just grab paragraphs
                        if (comments.length === 0) {
                             document.querySelectorAll('p').forEach((p, index) => {
                                 if (index < 30 && p.innerText.length > 20) {
                                     comments.push(p.innerText);
                                 }
                             });
                        }

                        return { body, comments };
                    }""")

                    if content_text['body']:
                        print(f"POST CONTENT: {content_text['body'][:500]}...") # Truncate for brevity in log

                    print("COMMENTS:")
                    for c in content_text['comments']:
                        # Simple cleanup
                        clean_c = c.strip().replace("\n", " ")
                        if len(clean_c) > 0:
                            print(f"- {clean_c[:300]}") # Truncate individual comments

                except Exception as e:
                    print(f"Error scraping {url}: {e}", file=sys.stderr)

        except Exception as e:
            print(f"Global Error: {e}", file=sys.stderr)
        finally:
            await browser.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Analyze Reddit sentiment')
    parser.add_argument('--keyword', help='Keyword to search')
    parser.add_argument('--subreddit', help='Specific subreddit')
    parser.add_argument('--urls', nargs='+', help='Direct list of URLs to analyze')

    args = parser.parse_args()

    if not args.keyword and not args.urls:
        print("Error: Must provide either --keyword or --urls")
        sys.exit(1)

    asyncio.run(analyze_reddit(args.keyword, args.subreddit, args.urls))
