eFrom `res://addons/gut`
```
grep -r 'class\s*[a-zA-z]*:'
```

## Likely to clash

- [x] `./printers.gd:                  class Printer:`
- [x] `./cli/optparse.gd:              class Option:`
- [x] `./cli/optparse.gd:              class Options:`


## Less likely
- [x] `./awaiter.gd:                   class AwaitLogger:`
- [x] `./cli/gut_cli.gd:               class OptionResolver:`
- [x] `./cli/optparse.gd:              class OptionHeading:`
- [x] `./gui/gut_logo.gd:              class Eyeball:`
- [x] ~~`./gui/gut_user_preferences.gd:  class GutEditorPref:`~~
- [ ] `./gui/OutputText.gd:            class TextEditSearcher:`
- [x] `./gui/panel_controls.gd:        class BaseGutPanelControl:`
- [x] `./gui/panel_controls.gd:        class BooleanControl:`
- [x] `./gui/panel_controls.gd:        class ColorControl:`
- [x] `./gui/panel_controls.gd:        class DirectoryControl:`
- [x] `./gui/panel_controls.gd:        class FileDialogSuperPlus:`
- [x] `./gui/panel_controls.gd:        class FloatControl:`
- [x] `./gui/panel_controls.gd:        class MultiLineStringControl:`
- [x] `./gui/panel_controls.gd:        class NumberControl:`
- [x] `./gui/panel_controls.gd:        class SaveLoadControl:`
- [x] `./gui/panel_controls.gd:        class SelectControl:`
- [x] `./gui/panel_controls.gd:        class StringControl:`
- [x] `./input_sender.gd:              class InputQueueItem:`
- [x] `./input_sender.gd:              class MouseDraw:`
- [ ] `./method_maker.gd:              class CallParameters:`
- [ ] `./orphan_counter.gd:            class Orphanage:`
- [x] `./printers.gd:                  class ConsolePrinter:`
- [x] ~~`./printers.gd:                  class GutGuiPrinter:`~~
- [x] `./printers.gd:                  class TerminalPrinter:`
- [ ] `./script_parser.gd:             class ParsedMethod:`
- [ ] `./script_parser.gd:             class ParsedScript:`
- [ ] `./singleton_parser.gd:          class ParsedSingleton:`
- [ ] `./test.gd:                      class _ConnectionInfo:`
- [ ] `./test.gd:                      class SignalAssertParameters:`
- [x] `./version_conversion.gd:        class ConfigurationUpdater:`
- [ ] `./version_numbers.gd:           class VerNumTools:`


# Unlikely
```

```

```
grp '^class_name '
```
```
./input_factory.gd:             class_name GutInputFactory
./utils.gd:                     class_name GutUtils
./strutils.gd:                  class_name GutStringUtils
./gut.gd:                       class_name GutMain
./hook_script.gd:               class_name GutHookScript
./input_sender.gd:              class_name GutInputSender
./test.gd:                      class_name GutTest
./gut_tracked_error.gd:         class_name GutTrackedError
./error_tracker.gd:             class_name GutErrorTracker
```

# Reasoning
All uses of `class_name` in GUT do have a `Gut` prefix.  These names have a global context and should avoid clashes as much as possible.  They can clash with other `class_name`, Autoloads, and are visible in many places.

Inner class names will only clash with Autoloads.