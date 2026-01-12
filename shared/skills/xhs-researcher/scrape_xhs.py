import sys
import asyncio
import argparse
from playwright.async_api import async_playwright

async def get_comments(url=None, keyword=None):
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(
            user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            viewport={'width': 1280, 'height': 800}
        )
        page = await context.new_page()

        try:
            target_url = url
            if keyword:
                print(f"Searching for keyword: {keyword}...", file=sys.stderr)
                # Note: XHS search often requires login. We'll try a direct search URL or a workaround.
                # Since XHS is tough to scrape without login, we'll try to find a relevant note via Google search first as a proxy
                # OR we try the XHS explore page.
                # For this simple v1 implementation, let's try a google search to find an XHS link if no URL is provided.

                # Try DuckDuckGo first as it's often easier to scrape
                print(f"Searching DuckDuckGo for: site:xiaohongshu.com {keyword}", file=sys.stderr)
                await page.goto(f"https://duckduckgo.com/?q=site:xiaohongshu.com+{keyword}&kl=cn-zh")

                try:
                    await page.wait_for_selector(".react-results--main", timeout=10000)
                    first_result = page.locator("a[data-testid='result-title-a']").first
                except:
                    # Fallback to waiting for any link if specific selector fails
                    await page.wait_for_selector("a", timeout=5000)
                    first_result = page.locator("a[href*='xiaohongshu.com/explore']").first

                if await first_result.count() > 0:
                    target_url = await first_result.get_attribute("href")
                    print(f"Found XHS link: {target_url}", file=sys.stderr)
                else:
                    print("No XHS links found via DuckDuckGo, trying Google...", file=sys.stderr)
                    # Fallback to Google logic here if needed, or just fail gracefully
                    return

            if not target_url:
                print("No URL provided or found.", file=sys.stderr)
                return

            print(f"Loading page: {target_url}", file=sys.stderr)
            await page.goto(target_url, wait_until="domcontentloaded")

            # Wait for content to load
            try:
                await page.wait_for_selector(".note-content", timeout=10000)
            except:
                print("Could not load note content. Might be captcha or login wall.", file=sys.stderr)
                # Take screenshot for debug
                # await page.screenshot(path="debug_error.png")
                return

            # Get title and description
            title = await page.locator(".title").inner_text()
            desc = await page.locator(".desc").inner_text()

            print(f"Post Title: {title}")
            print(f"Post Description: {desc}\n")
            print("-" * 50)
            print("COMMENTS:")

            # Scroll to load comments
            for _ in range(5):
                await page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
                await page.wait_for_timeout(1500)

            # Extract comments
            comments = page.locator(".comment-item .content")
            count = await comments.count()

            if count == 0:
                print("No comments found or failed to load comments section.")

            for i in range(count):
                text = await comments.nth(i).inner_text()
                print(f"- {text}")

        except Exception as e:
            print(f"Error scraping: {e}", file=sys.stderr)
        finally:
            await browser.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Scrape XHS comments')
    parser.add_argument('--url', help='Direct XHS post URL')
    parser.add_argument('--keyword', help='Keyword to search for')

    args = parser.parse_args()

    if not args.url and not args.keyword:
        print("Please provide either --url or --keyword")
        sys.exit(1)

    asyncio.run(get_comments(url=args.url, keyword=args.keyword))
