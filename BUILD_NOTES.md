# Build notes

Recommended engine: Godot 4.x (stable).

This is a source project, not an APK. The project must be opened and tested in Godot before export. Android export requires the matching export templates and Android build prerequisites configured in Godot.

Suggested next work:
- Add player/team data resources.
- Add local save/load using `FileAccess` or `ConfigFile`.
- Implement a deterministic match simulation model with unit tests.
- Separate player career, manager career, and club management as game modes sharing the same world model.
