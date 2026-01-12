---
name: xhs-researcher
description: Research product pain points and user needs by analyzing XiaoHongShu (Little Red Book) comments.
input_schema:
  type: object
  properties:
    keyword:
      type: string
      description: The keyword to search for (e.g., product name, topic)
    url:
      type: string
      description: (Optional) A specific XiaoHongShu post URL to analyze. If not provided, will search using the keyword.
  required:
    - keyword
---

<input>
Keyword: {{keyword}}
URL: {{url}}
</input>

I need to analyze XiaoHongShu content to find user pain points and unmet needs related to "{{keyword}}".

<if condition="url">
I will analyze the specific post provided.
<bash_action>
python3 ~/.claude/skills/xhs-researcher/scrape_xhs.py --url "{{url}}"
</bash_action>
</if>

<if condition="!url">
Since no URL was provided, I will first search for the keyword "{{keyword}}" and analyze the most relevant post.
<bash_action>
python3 ~/.claude/skills/xhs-researcher/scrape_xhs.py --keyword "{{keyword}}"
</bash_action>
</if>

Now, please analyze the output above.
Focus on:
1. What problems are users complaining about?
2. What features are they asking for?
3. What are the common "avoid" (避雷) points?
4. Are there any specific use cases mentioned that current products don't satisfy?

Summarize the findings into a clear report on "Product Pain Points & Opportunities".
