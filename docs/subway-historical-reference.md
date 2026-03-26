# Boston Subway Historical Reference

## Integrated now

The current `CorridorSeed.gd` subway pass has been shifted from generic station boxes to station-specific geometry for:

- North Station
- Haymarket
- Adams Square
- Scollay Square
- Park Street
- Boylston
- Arlington
- Copley
- Massachusetts Avenue
- Kenmore

The intent is visual and operational identity first:

- `Park Street`: four-track upper level, dual-island arrangement, added northbound edge-platform wing, larger mezzanine and multiple headhouses.
- `North Station`: wider four-track terminal geometry to start the route north of Park Street and anchor the Causeway side of the system.
- `Haymarket`: compact island-platform stop between North Station and Adams Square.
- `Adams Square`: small island-platform stop with an early loop/junction gesture.
- `Scollay Square`: island-platform transfer core south of Adams Square and north of Park Street.
- `Boylston`: four-track station with side-island geometry to imply the disused outer tracks and the Pleasant Street incline connection.
- `Arlington`: two-track side-platform station with a larger east mezzanine and a smaller secondary west mezzanine.
- `Copley`: offset split side-platform arrangement with a west-end branch/junction gesture for the Huntington Avenue split.
- `Massachusetts Avenue`: historical station in place of the modern Hynes label, with side platforms, a broader fare lobby, and a surface transfer structure.
- `Kenmore`: four-track/two-island junction station with a broader concourse and west-end branch geometry to read as the portal/junction terminal.

## Primary source pack

### Green Line core subway

- Park Street overview: [Park Street station (MBTA)](https://en.wikipedia.org/wiki/Park_Street_station_(MBTA))
- Park Street plans: [Floor plans of Park Street station](https://commons.wikimedia.org/wiki/Category:Floor_plans_of_Park_Street_station)
- Boylston overview: [Boylston station](https://en.wikipedia.org/wiki/Boylston_station)
- Boylston plans: [Floor plans of Boylston station](https://commons.wikimedia.org/wiki/Category:Floor_plans_of_Boylston_station)
- Arlington overview: [Arlington station (MBTA)](https://en.wikipedia.org/wiki/Arlington_station_(MBTA))
- Arlington plan: [Arlington station plan, December 1949](https://commons.wikimedia.org/wiki/File:Arlington_station_plan,_December_1949.png)
- Copley overview: [Copley station](https://en.wikipedia.org/wiki/Copley_station)
- Copley plan: [Copley station plan, November 1958](https://commons.wikimedia.org/wiki/File:Copley_station_plan,_November_1958.png)
- Massachusetts Avenue / Hynes overview: [Hynes Convention Center station](https://en.wikipedia.org/wiki/Hynes_Convention_Center_station)
- Massachusetts Avenue surface transfer plan: [Massachusetts Avenue surface station plan, 1918](https://commons.wikimedia.org/wiki/File:Massachusetts_Avenue_surface_station_plan,_1918.jpg)
- Kenmore overview: [Kenmore station](https://en.wikipedia.org/wiki/Kenmore_station)
- Kenmore plan: [Kenmore station plan, 1932](https://commons.wikimedia.org/wiki/File:Kenmore_station_plan,_1932.jpg)

### Next Boston rapid transit phase

These are the source anchors for the next phase you described: Park Street northward, the Causeway elevated approach, the Atlantic Avenue Elevated, the Washington Street subway/main line elevated, and the East Boston/Blue Line core.

- Scollay Square / Government Center context: [Government Center station](https://en.wikipedia.org/wiki/Government_Center_station)
- Scollay Square plan: [Scollay Square plan](https://commons.wikimedia.org/wiki/File:Scollay_Square_plan.png)
- Adams Square plan: [Adams Square plan](https://commons.wikimedia.org/wiki/File:Adams_Square_plan.png)
- Haymarket plan: [Haymarket plan](https://commons.wikimedia.org/wiki/File:Haymarket_plan.png)
- North Station elevated/surface track plan: [Plan of elevated and surface tracks at North Station, 1912](https://commons.wikimedia.org/wiki/File:Plan_of_elevated_and_surface_tracks_at_North_Station,_1912.jpg)
- Causeway elevated context: [Causeway Street Elevated](https://en.wikipedia.org/wiki/Causeway_Street_Elevated)
- Atlantic Avenue Elevated context: [Atlantic Avenue Elevated](https://en.wikipedia.org/wiki/Atlantic_Avenue_Elevated)
- Atlantic Avenue station headhouse: [Floor plan of Atlantic Avenue station headhouse, 1904](https://commons.wikimedia.org/wiki/File:Floor_plan_of_Atlantic_Avenue_station_headhouse,_1904.png)
- Atlantic Avenue station exits: [Atlantic Avenue station emergency exit plans (1), 1904](https://commons.wikimedia.org/wiki/File:Atlantic_Avenue_station_emergency_exit_plans_(1),_1904.png)
- Bowdoin context: [Bowdoin station](https://en.wikipedia.org/wiki/Bowdoin_station_(MBTA))
- Bowdoin plan: [Bowdoin station plan, 1916](https://commons.wikimedia.org/wiki/File:Bowdoin_station_plan,_1916.jpg)
- Court Street context: [Court Street station](https://en.wikipedia.org/wiki/Court_Street_station_(Boston))
- Court Street plan: [Court Street station plan, 1903](https://commons.wikimedia.org/wiki/File:Court_Street_station_plan,_1903.jpg)
- State Street / tunnel connection context: [State station](https://en.wikipedia.org/wiki/State_station_(MBTA))
- Atlantic / Blue Line replacement context: [Aquarium station](https://en.wikipedia.org/wiki/Aquarium_station)
- Washington Street subway/main line elevated context: [Tremont Street subway](https://en.wikipedia.org/wiki/Tremont_Street_subway), [Washington Street Elevated](https://en.wikipedia.org/wiki/Washington_Street_Elevated)

## Asset direction for White City and Norumbega

Exact named 3D models for White City or Norumbega did not turn up in the current search. The practical route is a kitbash set assembled from period-appropriate amusement structures:

- carousel / pavilion search: [Sketchfab carousel models](https://sketchfab.com/search?q=carousel&type=models)
- Victorian gazebo / music shell search: [Sketchfab Victorian gazebo models](https://sketchfab.com/search?q=victorian%20gazebo&type=models)
- wooden coaster search: [Sketchfab wooden roller coaster models](https://sketchfab.com/search?q=wooden%20roller%20coaster&type=models)
- fairground gate / midway search: [Sketchfab amusement entrance models](https://sketchfab.com/search?q=amusement%20park%20entrance&type=models)

For this project specifically:

- `White City` already exists as a stop in the main corridor list.
- `Norumbega Park` already exists as a leisure spur target from `Newton Centre`.

That means the immediate work is not route logic. It is model selection and wiring the park stop categories to period pavilion, ride, and midway assets.

## Next integration pass

1. Add Park Street north of the current throat with separate Scollay / Adams / Haymarket / North Station station specs.
2. Add a dedicated elevated geometry builder for Causeway Street and Atlantic Avenue instead of reusing the cut-and-cover subway box builder.
3. Split the current `Massachusetts Avenue` station into a surface-transfer-aware subway station and later a modern `Hynes` variant if you want era toggles.
4. Replace placeholder growth prefabs with the imported Victorian house, commercial block, and civic building scenes so the Boston/Worcester corridor reads historically above ground.
