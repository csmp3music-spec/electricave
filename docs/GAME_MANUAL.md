# Electric Avenue Player Manual

This manual is for the current playable build of `Electric Avenue`: a historically inspired Massachusetts electric railway management and operations game set in the street-railway and early rapid-transit era. It combines hands-on trolley driving, line management, town growth, construction, and a layered historical map of Boston-area subway, elevated, and interurban lines.

The current build is best understood as a playable operations sandbox with a growing tycoon layer. You can drive cars manually, switch between multiple historical services, place new infrastructure, grow station districts, manage depots and headways, and explore a network that mixes recreated history with plausible in-game extensions.

## 1. What Is In The Current Build

The current game world includes:

- A playable `Boston-Worcester Air Line (Route 9)` main line that starts in the Boston subway core and runs west to Worcester.
- Route 9 side branches and leisure spurs for `Saxonville`, `South Framingham`, `Upton`, `Marlborough`, and `Norumbega Park`.
- A downtown historic streetcar subway core built around `Park Street`, `Boylston`, `Arlington`, `Copley`, `Massachusetts Avenue`, and `Kenmore`.
- A north terminal extension linking `Park Street` to `Scollay Square`, `Adams Square`, `Haymarket`, `Friend Street`, `North Station`, `Science Museum`, and `Lechmere`.
- Separate operational historical rapid-transit families for:
  - `Atlantic Avenue Elevated`
  - `Washington Street Tunnel`
  - `Cambridge-Dorchester Tunnel`
  - `Mattapan High-Speed Line`
  - `Blue Line North Shore`
- Visible passengers who wait at stations, board when you stop correctly, and generate fare revenue.
- A finance layer with capital construction costs, recurring operating costs, and monthly reporting.
- Procedural town growth around stops, including denser Boston cores, suburban streetcar growth, and industrial western centers.
- A live clock, day/night lighting, weather changes, snow restrictions, and storm-driven line closures on exposed coastal routes.

## 2. Starting A Session

When the game opens, you begin in a live world rather than a menu shell. The network is seeded automatically.

At the start of play:

- The calendar begins on `May 1, 1900` at `06:30`.
- The camera starts in the network world and can be cycled immediately.
- The player-controlled service defaults to the main Boston-Worcester line.
- Existing historical services are already present and can be selected from the line selector in the upper-left corner.

The screen has three user-facing control areas:

- `Upper-left line selector`: choose the active line and switch between `Manual` and `Auto stops`.
- `Bottom status bar`: shows time, weather, service status, stop demand, onboard load, and signal aspect.
- `Tool strip`: opens routes, finances, overlay, build mode, map, and other major systems.

## 3. Core Controls

### Camera And Navigation

| Action | Control | What it does |
| --- | --- | --- |
| Cycle main camera modes | `C` | Rotates through state view, isometric view, street view, and subway view |
| Jump/cycle subway inspection camera | `X` | Puts the camera into subway inspection mode and steps through subway viewpoints |
| Zoom camera | Mouse wheel | Zooms in and out |
| Toggle historic overlay | `O` | Shows or hides the historic map overlay |
| Open system map | `M` | Opens the live system map panel |
| Toggle driver cab/chase view | `V` | Switches between the driver-facing view and chase view for the controlled car |

### Windows And Management

| Action | Control | What it does |
| --- | --- | --- |
| Open routes/timetable window | `R` | Shows segment headways and depot operations |
| Open finances window | `F` | Shows revenue, costs, cash, and monthly trend |
| Cycle active service line | `L` | Jumps the player to the next line with an available fleet |
| Cycle player trolley body | `N` | Changes the player car body when multiple car scenes are available |
| Recover after an incident | `K` | Clears the current incident state |

### Manual Driving

These controls matter when the upper-left toggle is set to `Manual`.

| Action | Control | What it does |
| --- | --- | --- |
| Increase throttle notch | `Shift+W` | Raises the power notch and target speed |
| Decrease throttle notch / reverse | `Shift+S` | Lowers the power notch and can move into reverse notches |
| Service brake | `Space` | Brings speed toward zero quickly for station work and safe spacing |

### Construction

| Action | Control | What it does |
| --- | --- | --- |
| Toggle build tool | `T` | Turns build mode on or off |
| Cycle build mode | `G` | Cycles through track, station, depot, signal, and bulldoze |
| Track tool | `1` | Selects track laying |
| Station tool | `2` | Selects station placement |
| Depot tool | `3` | Selects depot placement |
| Signal tool | `4` | Selects signal placement |
| Bulldoze tool | `5` | Selects demolition |
| Toggle autorail | `A` | Switches between guided autorail placement and direct placement |
| Rotate station/depot preview left | `Q` | Rotates placeable assets |
| Rotate station/depot preview right | `E` | Rotates placeable assets |
| Adjust station length / signal spacing / stop frequency | `[` and `]` or `-` and `=` | Context-sensitive build adjustment |
| Confirm build | Left click | Places or anchors the selected tool |
| Cancel current anchor / exit build | Right click or `Esc` | Cancels the current build step; repeated cancel turns build off |

## 4. First Trip Tutorial

If you want the shortest path to understanding the game, do this:

1. Leave the line selector on the main Boston-Worcester line.
2. Keep `Manual` enabled in the upper-left selector.
3. Press `V` until you are in the view you prefer for driving.
4. Press `Shift+W` a few times to raise the power notch and get the car moving.
5. Watch the status panel:
   - `Next Stop`
   - `Waiting`
   - `Load`
   - signal aspect
6. As you approach a station, brake with `Space`.
7. Slow down enough to board passengers. The game only services a stop when your car is at platform speed.
8. Wait for the dwell to complete. The HUD will show boarding, alighting, fare revenue, and how many passengers remain.
9. Continue to the next stop while maintaining spacing from the car ahead.
10. Press `R` to inspect the timetable and depot panel, and `F` to check whether your operation is paying for itself.

What a good first trip should teach you:

- Demand is visible and local. Stations with crowds matter.
- Boarding is not automatic at full speed. You must actually work the stop.
- Signal spacing matters. Running up on the next car will show yellow or red aspects.
- Service quality affects revenue. Better operation improves service rating and fare multiplier.

## 5. Understanding The Interface

### Upper-Left Line Selector

This panel does two jobs:

- It switches the active service line.
- It switches the controlled car between `Manual` and `Auto stops`.

When `Manual` is on:

- You control speed and braking.
- You are responsible for approaching stops correctly.
- Your spacing and station work feed the service rating system directly.

When `Auto stops` is on:

- The controlled car returns to AI handling.
- You can observe the service instead of driving it.
- This is useful when inspecting expansion work, the map, or scenery.

### Bottom Status Panel

The lower status area is your main operating dashboard.

It shows:

- Time and date
- Weather state
- Current or next station
- Waiting passengers
- Current onboard load and capacity
- Recent boarding/alighting results
- Service rating and fare multiplier
- Signal aspect and reason

Treat it like a dispatcher-and-motorman dashboard. Most of the information you need to drive well is already there.

### Routes / Timetable Window

Open it with `R` or the `Routes` button.

This window shows:

- Live timetable segments
- Current target headway for each segment
- Active cars versus suggested cars
- Segment length
- Depot inventory and actions

From this window you can:

- tighten or loosen headways with `-1` and `+1`
- launch cars from depots
- store the currently controlled car at a depot

For the main line, the game breaks operations into:

- `North Terminal`
- `Downtown Subway`
- `Route 9 Inner`
- `Route 9 Outer`

That split is important. It lets you operate the Boston subway core more densely than the outer Worcester segment.

### Finances Window

Open it with `F` or the `Finance` button.

This window shows:

- current period revenue and expenses
- cash on hand
- service rating
- route length
- number of stops and cars
- a monthly history graph

The categories are already tied into construction and operating costs, so this is not just decorative UI. It is the place to check whether expansion is sustainable.

### System Map

Open it with `M` or the `Map` button.

The map is live and interactive:

- Click a stop to move the camera there.
- Click a trolley to take control of that specific car.
- Read line positions and how the different historical services overlap.

If you are lost, use the system map first.

## 6. How The Simulation Works

### Passengers And Stations

Passengers visibly gather at stops. Their waiting count depends on:

- ridership demand
- service frequency
- connectivity to nearby stops
- local stop importance

Busy places like `Park Street`, `Boylston`, `Arlington`, `Copley`, `Kenmore`, and `Brookline` are deliberately stronger demand nodes in the current build.

When you service a stop correctly:

- some riders board
- some riders alight
- you earn fare revenue
- the visible crowd shrinks
- your service rating can improve

If you run too fast through a station:

- boarding does not happen
- waiting crowds stay put
- service quality suffers

### Service Rating

The service system rewards:

- even spacing
- controlled station stops
- repeated successful service

The fare multiplier scales with service quality from roughly `0.85x` to `1.15x`. Better operation is not just cosmetic; it affects revenue.

### Signals

Signals are block-based. The active signal display reflects the distance to the next car ahead on the same line:

- `Green`: proceed
- `Yellow`: caution
- `Red`: stop, car too close ahead

If you build your own signal runs, they become part of the playable management layer. If you ignore spacing, the HUD and line-side signals will tell you immediately.

### Economy

The network starts with:

- `$500,000` cash
- a `$175,000` bond principal
- monthly operating costs that scale with fleet size, stop count, track length, depot count, and signal count

Important current cost values:

- Track: `$140` per meter
- Station: base `$8,000`, scaled upward by platform length and track count
- Depot: `$22,000`
- Signal post: `$3,500`
- Bulldoze refund: `35%`

Recurring costs include:

- crew wages
- power and substations
- track upkeep
- car maintenance
- right-of-way leases
- depot upkeep
- signal upkeep
- debt interest

### Calendar, Lighting, And Weather

Time advances continuously. The game tracks:

- clock time
- day
- month
- year

At month turnover:

- the economy closes the current month
- a new monthly period begins

At year turnover:

- historical events can fire, including wartime shortages, auto competition, and depression-era pressure

Weather changes day by day and currently affects:

- fog and atmosphere
- snow restrictions
- coastal portal closures
- line-specific storm damage on exposed routes

In particular:

- snow can impose speed restrictions on the main line, Atlantic line, Blue line, and Mattapan line
- coastal flooding can close the `Blue` and `Atlantic` routes
- the `1938 hurricane` can disable those exposed coastal lines in the historical weather layer

## 7. How To Build More

This is the part most players care about once they understand the base network.

### The Basic Expansion Loop

1. Open build mode with `T`.
2. Lay new track from an existing line or built segment.
3. Add a station where you want a new town node or service point.
4. Add a depot if you want more fleet control in that district.
5. Add signal runs on busy segments.
6. Open `Routes` and adjust headways or launch/store cars.
7. Use the `Growth` button to force immediate suburb growth around all stops.
8. Check `Finances` to see whether the expansion is paying off.

### Track Tool

Select it with `1`.

How it works:

- Left-click once to set an anchor.
- Move the cursor and left-click again to lay track.
- If `Autorail` is on, the game tries to produce a guided placement from your anchor to the target.
- If `Autorail` is off, placement becomes more direct.

Rules worth knowing:

- minimum useful segment length is about `18m`
- track must be placeable on terrain
- you need enough cash for the previewed cost
- right-click or `Esc` clears the current anchor

Best use:

- extend out from the main route to make your own secondary corridors
- create short connectors to new station districts
- build yard leads to planned depot locations

### Station Tool

Select it with `2`.

How it works:

- Snap the cursor near track.
- Left-click to place a station.
- While station mode is active, `[` and `]` change platform length from `2` to `8` tiles.
- `Q` and `E` rotate the previewed station orientation.

Current station rules:

- stations must be close enough to the rail network to snap
- stations cannot be too close to one another
- stations cannot be placed on unsuitable grade or water
- longer and wider stations cost more

Why stations matter:

- every station becomes a new growth seed
- station spacing shapes demand and town form
- stop placement affects passenger waiting counts and service economics

### Frequency While Building

Outside station-length and signal-spacing adjustment, the same bracket keys control the stop frequency value used for new stops. Higher or lower frequency changes how the station behaves as a service node once placed.

### Depot Tool

Select it with `3`.

Depots are the link between construction and operations:

- they cost `$22,000`
- they must be near track
- they cannot be stacked too tightly

Once built, depots appear in the `Routes` window where you can:

- launch additional cars
- store the current car
- read depot inventory counts

If you want a new district to become a true operating base, build a depot there.

### Signal Tool

Select it with `4`.

How it works:

- Click once to set the beginning of a signal run.
- Move along the line and click again to end the run.
- The game fills the corridor with signal posts at the current spacing.

While signal mode is active:

- `[` and `]` change spacing
- the default spacing is around `70m`
- the legal range is tighter in practice than a full custom tool, so watch the preview

Signal runs are most valuable:

- on busy downtown or terminal approaches
- near depots and merges
- on heavily used trunk segments where headways are tight

### Bulldoze Tool

Select it with `5`.

This can remove:

- placed track
- stations
- player-built depots
- player-built signals

You recover `35%` of the original capital cost. Use it to clean up failed experiments instead of trying to live with bad geometry.

### Growth And Land Use

Every stop creates a development field around it.

The game treats different places differently:

- `Boston core stops` grow dense commercial, civic, and higher residential fabric
- `streetcar suburb stops` grow smaller commercial centers and denser housing rings
- `western centers` get stronger industrial and civic weight
- leisure destinations like `White City` and `Norumbega Park` get park-oriented treatment

If you want to build more successfully:

- use stations to create a chain rather than isolated outposts
- connect new stops close enough to improve connectivity
- seed depots where you expect real operational density
- trigger growth after major expansion so you can see whether the new district is taking hold

## 8. Practical Strategy For New Players

If you want a stable, readable first campaign, follow this order:

1. Learn the main line first instead of jumping immediately to the coastal or branch services.
2. Improve operation before expanding. A clean service rating improves revenue.
3. Add one depot near a useful branch or suburban center before laying a lot of speculative track.
4. Tighten headways only where you have enough fleet to support them.
5. Use manual driving in the dense downtown core where station work matters most.
6. Switch to `Auto stops` when surveying expansion or weather effects.
7. Watch the finances after every major capital project.

## 9. Historical Guide To Every Subway System And Trolley Line In The Game

This section describes the systems represented in the build. Some are close historical recreations, and some are intentionally playable interpretations or extensions. Where the current project documents call something inferred or approximate, this manual preserves that caveat.

### 9.1 Boston-Worcester Air Line (Route 9)

This is the game’s main playable interurban-style trunk line.

Its westbound Boston-to-Worcester spine serves:

- `Park Street`
- `Boylston`
- `Arlington`
- `Copley`
- `Massachusetts Avenue`
- `Kenmore`
- `Brookline`
- `Chestnut Hill`
- `Newton Centre`
- `Wellesley Center`
- `Natick Center`
- `Framingham Junction`
- `Framingham Center`
- `Fayville`
- `Whites Corner`
- `Westborough Center`
- `Grafton Center`
- `Shrewsbury Center`
- `White City`
- `Belmont Street`
- `Lincoln Square`

The same playable service also shares the Boston north terminal approach covered in section `9.3`, which is why the main line feels larger than a simple westbound surface route.

In addition, the seeded network includes side branches or branch-like stubs to:

- `Saxonville`
- `South Framingham`
- `Upton`
- `Marlborough`
- `Norumbega Park`

Historical intent:

- The main line is grounded in the project’s `Boston and Worcester Street Railway` reference work.
- `Framingham Junction` is explicitly included because the current historical pass wanted a more plausible Hastingsville / South Framingham operating center.
- `White City` and `Norumbega Park` are treated as recognizable excursion-era leisure destinations in the system.

What the game is doing with that history:

- It turns the Boston-to-Worcester electric railway idea into a single playable trunk.
- It compresses several historical and scenic ideas into one operational corridor.
- It uses the line as the backbone for suburban growth, western industrial centers, and depot management.

### 9.2 Tremont Street Subway Core

The downtown subway segment centered on `Park Street`, `Boylston`, `Arlington`, `Copley`, `Massachusetts Avenue`, and `Kenmore` is the game’s historic streetcar-subway heart.

Historical intent:

- The project’s own research file identifies this as the older warm-tile, brick-headhouse streetcar-subway treatment.
- `Park Street` is treated as the central identity anchor of the corridor.
- `Boylston`, `Arlington`, `Copley`, `Massachusetts Avenue`, and `Kenmore` all receive station-specific historical styling rather than generic boxes.

What to notice in play:

- This is the densest passenger part of the main line.
- It is the easiest place to learn stop discipline and spacing.
- In timetable terms it forms the `Downtown Subway` segment between `Park Street` and `Kenmore`.

### 9.3 North Terminal Extension And Lechmere Approach

The project expands the northern side of the historic core with:

- `Scollay Square`
- `Adams Square`
- `Haymarket`
- `Friend Street`
- `North Station`
- `Science Museum`
- `Lechmere`

Historical intent:

- The pass is explicitly based on Park Street northward, the Causeway elevated approach, and the early Lechmere-side elevated geography.
- `North Station`, `Haymarket`, `Adams Square`, and `Scollay Square` are all treated as named, distinct geometry rather than generic fill-ins.

What this means for the player:

- The main line is not just a westbound Route 9 surface car. It also includes a stronger Boston terminal approach.
- The `North Terminal` timetable segment exists so you can operate the downtown north side more tightly than the westbound outer route.

### 9.4 Atlantic Avenue Elevated

The Atlantic Avenue line appears as its own separate elevated railway with stations:

- `North Station (Atlantic)`
- `Battery`
- `State (Atlantic)`
- `Rowes Wharf`
- `South Station (Atlantic)`
- `Beach`

Historical intent:

- The project treats this as a waterfront elevated, not as another subway box.
- The current historical notes explicitly say the present PCC-style operation is a user-directed override, not a strict historical rolling-stock reproduction.

Operational identity in game:

- It is one of the exposed coastal lines.
- It can be shut down by strong storm and flood logic.
- It provides a very different visual read from the subway corridors.

### 9.5 Washington Street Tunnel

This line is represented as a dedicated tunnel family with stations:

- `Haymarket (Wash)`
- `State (Wash)`
- `Summer`
- `Essex`
- `Dover`

Historical intent:

- The project’s implementation notes describe it as a tighter, orange-tinted tunnel family with offset side-platform geometry.
- It is meant to read as distinct from the older Tremont subway rather than as a recolor of the same station kit.

In practical terms:

- It is a separate operational service.
- It gives the player another dense central-city corridor to inspect and run.

### 9.6 Cambridge-Dorchester Tunnel

This line is represented as the historic Harvard-to-Ashmont sequence:

- `Harvard`
- `Central`
- `Kendall`
- `Charles`
- `Park Street Under`
- `Washington`
- `South Station Under`
- `Broadway`
- `Andrew`
- `Columbia`
- `Savin Hill`
- `Fields Corner`
- `Shawmut`
- `Ashmont`

Historical intent:

- The game frames this as the historic Cambridge-Dorchester alignment rather than the modern Red Line brand.
- The current implementation emphasizes heavier-rail proportions and more island-platform geometry.

Why it matters:

- It expands the game’s rapid-transit history southward.
- It also forms the parent trunk for the Mattapan branch in the current build’s historical progression.

### 9.7 Mattapan High-Speed Line

This branch is represented as a separate selectable line:

- `Ashmont`
- `Cedar Grove`
- `Butler`
- `Milton`
- `Central Avenue`
- `Valley Road`
- `Capen Street`
- `Mattapan`

Historical intent:

- The project explicitly describes this as a later historical addition run with PCC equipment.
- It is kept separate instead of forcing heavy-rail stock directly onto the branch, which better matches the line’s street-railway character.

Why players should care:

- It is shorter and easier to read operationally than the larger trunk lines.
- It is one of the weather-sensitive surface/elevated services during snow logic.

### 9.8 Blue Line North Shore / East Boston Tunnel Phase

The Blue service is represented as:

- `Bowdoin`
- `Government Center`
- `State`
- `Aquarium`
- `Maverick`
- `Airport`
- `Wood Island`
- `Orient Heights`
- `Suffolk Downs`
- `Beachmont`
- `Revere Beach`
- `Wonderland`
- `Lynn`
- `Salem`

Historical intent:

- The downtown and harbor part is tied to the East Boston Tunnel / Blue Line historical reference work.
- The extension north to `Lynn` and `Salem` is explicitly documented by the project as an inferred playable North Shore continuation rather than a strict historical reconstruction.

Operational consequences:

- This line is exposed to coastal closures.
- The harbor and shoreline sections make it the clearest weather-risk rapid-transit service in the build.

### 9.9 Branches, Excursion Traffic, And Leisure Stops

The main Route 9 system also includes side lines and special destinations that help the world read like an electric railway network instead of a single corridor.

These include:

- `Saxonville`
- `South Framingham`
- `Upton`
- `Marlborough`
- `White City`
- `Norumbega Park`

Historical intent:

- `White City` and `Norumbega Park` are treated as excursion-era amusement destinations.
- `South Framingham` and `Framingham Junction` reinforce the Framingham operating center and car-barn logic.
- The smaller branch destinations help sell the idea of a broader electric railway territory beyond the main trunk.

In gameplay terms:

- they create more growth anchors
- they broaden stop geography
- they make the westbound corridor feel less like a straight intercity line and more like a living street-railway system

## 10. What To Watch For As You Expand

The most common beginner mistakes are:

- laying track without a plan for stations
- placing stations too close together
- building depots with no useful district to serve
- ignoring signals on dense lines
- expanding capital plant faster than fare revenue can support it
- driving too fast into busy stations and wondering why revenue is flat

A good expansion usually has:

- one clear new destination
- one or two well-spaced stations
- at least one place where growth can visibly take hold
- a depot plan if the new district will need more cars
- a timetable adjustment after the build is complete

## 11. Current Limitations

This manual is intentionally honest about what is already deep and what is still scaffolding.

Already strong:

- line identity
- station demand feedback
- manual car operation
- build mode fundamentals
- depot and timetable control
- historical corridor presentation

Still early or explicitly provisional:

- some route geometry is approximate rather than survey-grade
- some historical lines are playable interpretations rather than strict recreations
- the Blue North Shore extension beyond the historical core is inferred
- the GIS pipeline is still documented as a future workflow, not a finished import system
- parts of the finance presentation are ahead of the fully simulated content they imply

## 12. Suggested Way To Use This Manual

If you are brand new:

1. Read sections `3`, `4`, and `7`.
2. Drive the main line for one trip.
3. Open the map and routes window.
4. Build one station and one depot.
5. Then come back to section `9` to understand what each historical system represents.

If you are returning after a break:

1. Skim sections `5`, `6`, and `7`.
2. Use section `9` as the network reference.

## 13. Internal Project References

This manual was written against the current project behavior and the repo’s existing historical design notes, especially:

- `README.md`
- `docs/TYCOON_BUILD_MODE.md`
- `docs/GAMEPLAY_IMPROVEMENTS.md`
- `docs/HISTORICAL_BOSTON_RAPID_TRANSIT.md`
- `docs/subway-historical-reference.md`
- `docs/HISTORICAL_SYSTEM_EXPANSIONS_2026_03_25.md`
- `docs/REAL_GEOGRAPHY_AND_WEATHER_WORKFLOW.md`

If those implementation docs change, this manual should be updated with them.
