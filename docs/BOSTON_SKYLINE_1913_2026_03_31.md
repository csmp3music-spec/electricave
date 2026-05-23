# Boston Skyline 1913 - 2026-03-31

This pass replaces the older generic `c. 1900` downtown massing with a skyline tuned to roughly `1913`.

## Research basis

- Boston Landmarks Commission, `Exchange Building Study Report`
  - https://www.boston.gov/sites/default/files/embed/e/exchange-building-study-report.pdf
  - Used for two key skyline constraints: the Exchange Building itself was built `1889-1891`, stands `11 stories`, and the surrounding late-19th/early-20th-century financial district averaged roughly `10 stories`.
- Boston Landmarks Commission, `Second Brazer Building Study Report`
  - https://www.cityofboston.gov/images_documents/27%20State%20Second%20Brazer%20Study%20Report_tcm3-19718.pdf
  - Used to anchor the State/Devonshire corner with an `11-story`, `125-foot` Beaux-Arts skyscraper completed in `1896`.
- Boston Landmarks Commission, `International Trust Company Building Study Report`
  - https://www.boston.gov/sites/default/files/embed/i/international-trust-co-study-report.pdf
  - Used for the southward shift of the financial district along Milk Street. The report describes the building as originally completed in `1893` and enlarged in `1906` to `9 stories` and about `125 feet`.
- Boston Landmarks Commission, `U.S. Custom House Study Report`
  - https://www.cityofboston.gov/images_documents/U.S.%20Custom%20House%20Study%20Report%20108_tcm3-43424.pdf
  - Used for the original Custom House footprint at McKinley Square and its immediate district context, including the Board of Trade Building across India Street and the Flour and Grain Exchange at Milk and India.
- Tufts Digital Library, `Custom House Tower under construction, ca. 1913`
  - https://dl.tufts.edu/concern/images/qv33s608k
  - Critical date correction: the full tower is not finished in `1913`; it is actively under construction.
- National Archives at Boston, `Boston Custom House Tower`
  - https://www.archives.gov/boston/highlights/custom-house
  - Used to confirm the tower was completed in `1915`, so a finished 496-foot tower would be too late for a strict `1913` skyline.
- Clio, `Ames Building, Boston`
  - https://theclio.com/entry/49399
  - Used as a quick cross-check that Ames remained Boston's dominant completed commercial tower until the Custom House tower was finished in `1915`.

## Implementation notes

- The skyline now reads as a dense pre-war financial district rather than a small `1900` landmark set.
- Named massings emphasize:
  - Ames Building
  - Exchange Building
  - Second Brazer Building
  - International Trust Company Building
  - Board of Trade Building
  - Old State House
  - Old South Meeting House
  - Park Street Church
  - Trinity Church
- The Custom House is represented as a low Greek Revival base with an exposed steel-and-scaffold tower frame and derrick, not as the finished `1915` tower.
- Additional anonymous ten-story blocks were added around State Street and Milk Street so the district reads as a real skyline wall instead of isolated monuments.

## Scope caveat

- The broader simulation still starts in `1900`, so this skyline is a user-requested visual target year rather than a full network-wide year shift for every system in the game.
