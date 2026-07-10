---
name: harmony-doc-search
description: How to effectively search and read HarmonyOS official documentation using the available tools.
---

# Harmony Documentation Search Skill

## Description
How to effectively search and read HarmonyOS official documentation using the available tools.

## Instructions
When the user needs HarmonyOS API or guideline information:

1. **Start with search**: Use `search_hmos_doc` with relevant keywords. Try both English and Chinese terms.
2. **Pick the right catalog**:
   - `harmonyos-guides` for how-to and concept docs
   - `harmonyos-references` for API reference details
   - `best-practices` for recommended patterns
   - `harmonyos-faqs` for common issues
   - `design-guides` for UX/UI guidelines
3. **Read sections**: Use `read_hmos_doc` with the `object_id` from search results. Start with root section to get the table of contents.
4. **Extract with prompt**: Use `fetch_hmos_doc` when you need specific information from a known page. Provide a clear prompt describing what to extract.
5. **Cache awareness**: Documents are cached locally after first fetch. Subsequent reads are instant.

## Tips
- Combine multiple keywords for better results: "ArkTS State管理" instead of just "State".
- If search returns no results, try broader terms or a different catalog.
- Always cite the document URL when sharing findings with the user.
