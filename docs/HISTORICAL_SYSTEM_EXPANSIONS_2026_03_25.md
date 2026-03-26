# Historical System Expansions - 2026-03-25

This pass implemented four user-requested historical additions:

1. Heavier rapid-transit rolling stock for the Blue, Washington Street Tunnel, and Cambridge-Dorchester lines.
2. Atlantic Avenue Elevated operations switched to the PCC body by explicit user request.
3. Framingham Junction added as a main-line stop between Natick Center and Framingham Center, with Framingham-area railway landmarks.
4. Later Ashmont-Mattapan extension added as a separate operational Mattapan High-Speed branch using PCC stock.

## Research basis

- Boston and Worcester Street Railway:
  - https://en.wikipedia.org/wiki/Boston_and_Worcester_Street_Railway
  - Used for the Framingham Junction stop and the Saxonville / South Framingham branching context.
- Hastings family / Framingham Junction office context:
  - https://biographies.framinghamhistory.org/the-hastings-family/
  - Used because it explicitly notes Boston and Worcester Electric Companies offices in Hastingsville, which supports the Framingham Junction HQ landmark.
- Atlantic Avenue Elevated:
  - https://en.wikipedia.org/wiki/Atlantic_Avenue_Elevated
  - Used for station sequence and architectural context. Rolling stock here was rapid-transit/elevated equipment historically; the PCC body is a deliberate user-directed override.
- Blue Line / East Boston Tunnel rolling stock:
  - https://collections.trolleymuseum.org/items/126
  - Seashore Trolley Museum page for MBTA 0546/0547, used to ground the Blue Line train proportions around the smaller 1924 East Boston Tunnel rapid-transit cars.
- Mattapan line:
  - https://en.wikipedia.org/wiki/Mattapan_Line
  - Used for the Ashmont-Mattapan stop sequence and the decision to run PCC equipment on the branch.

## Implementation notes

- Framingham Junction location is approximate. I inserted it between Natick Center and Framingham Center using a historically plausible Hastingsville/Framingham Junction position on the corridor.
- The Trolley Square car barn footprint is inferred rather than surveyed. I placed it as a Framingham railway landmark tied to the Framingham Junction / South Framingham branch geometry.
- The Mattapan branch is represented as a separate selectable service line rather than merging heavy-rail cars directly onto the branch. That matches the historical PCC-operated high-speed line more closely.
