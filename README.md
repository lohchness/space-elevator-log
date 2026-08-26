# Space Elevator Log

Display stats and records of trains travelling through Space Exploration's space elevator.

> ⚠️ Beta Release
>
> Please give any feedback, suggestions, or bug reports via the discussions tab or [GitHub issues](https://github.com/lohchness/space-elevator-log/issues)!

## Features

- Keeps a record of the train and its contents when a train travels through a space elevator.
- Filter by location, item, fluid, direction, and time period.
- Group by content.
- View summary of most loaded items and fluids.
- Click on a train to focus.
- Click on content icon to quick set filter.
- `/sel-clear-storage` to clear all entries.
- `/sel-rebuild-guis` to rebuild GUIs.

## Upcoming

- GUI Overhaul
- Group by train group
- Icon overlay to distinguish incoming and outgoing trains

## Performance

Logging trains does not impact UPS.

The only performance hit is a short lag when opening or refreshing the GUI if you choose to render 2,000+ icons (1,000+ entries). Reduce the amount of renders by choosing a smaller time period, grouping by content, or selecting a single direction (Incoming/Outgoing).

## Credits

[Rocket Log](https://mods.factorio.com/mod/rocket-log) by robot256

[Train Log](https://mods.factorio.com/mod/train-log) by zomis

[Space Exploration](https://mods.factorio.com/mod/space-exploration) by Earendel
