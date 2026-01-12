---
name: reddit-analyzer
description: Analyze Reddit discussions and sentiment for a specific keyword or topic.
input_schema:
  type: object
  properties:
    keyword:
      type: string
      description: The keyword or topic to search for (e.g., "AI video pain points", "React vs Vue")
    subreddit:
      type: string
      description: (Optional) Limit search to a specific subreddit (e.g., "artificial", "MachineLearning")
  required:
    - keyword
---

<input>
Keyword: {{keyword}}
Subreddit: {{subreddit}}
</input>

I need to analyze Reddit discussions about "{{keyword}}" <if condition="subreddit">in r/{{subreddit}}</if>.

**Strategy:**
1. Try to search and scrape automatically.
2. If the automatic search fails (due to bot protection), I will manually search for Reddit URLs and then feed them to the scraper.

<bash_action>
# Try automatic search first
python3 ~/.claude/skills/reddit-analyzer/analyze_reddit.py --keyword "{{keyword}}" <if condition="subreddit">--subreddit "{{subreddit}}"</if>
</bash_action>

**If the output above shows "No Reddit posts found" or a timeout error:**
Please perform a WebSearch for `site:reddit.com {{keyword}} <if condition="subreddit">subreddit:{{subreddit}}</if>`, pick the top 3 relevant discussion URLs, and run the scraper again using:
`python3 ~/.claude/skills/reddit-analyzer/analyze_reddit.py --urls "URL1" "URL2" "URL3"`

**Analysis:**
Once you have the content, please analyze:
1. **Overall Sentiment**: Is the community generally positive, negative, or skeptical?
2. **Key Themes/Debates**: What are the main points of discussion?
3. **Specific Pain Points**: What problems are users complaining about?
4. **Notable Insights**: Any unique perspectives?

Summarize the findings into a "Reddit Community Sentiment Report".
