From `res://addons/gut`
```
grep -r 'class\s*[a-zA-z]*:'
```

# Likely to clash with singletons
```
./printers.gd:                  class Printer:
./cli/optparse.gd:              class Option:
./cli/optparse.gd:              class Options:
```

# Less likely
```
./awaiter.gd:                   class AwaitLogger:
./cli/gut_cli.gd:               class OptionResolver:
./cli/optparse.gd:              class OptionHeading:
./gui/gut_logo.gd:              class Eyeball:
./gui/gut_user_preferences.gd:  class GutEditorPref:
./gui/OutputText.gd:            class TextEditSearcher:
./gui/panel_controls.gd:        class BaseGutPanelControl:
./gui/panel_controls.gd:        class BooleanControl:
./gui/panel_controls.gd:        class ColorControl:
./gui/panel_controls.gd:        class DirectoryControl:
./gui/panel_controls.gd:        class FileDialogSuperPlus:
./gui/panel_controls.gd:        class FloatControl:
./gui/panel_controls.gd:        class MultiLineStringControl:
./gui/panel_controls.gd:        class NumberControl:
./gui/panel_controls.gd:        class SaveLoadControl:
./gui/panel_controls.gd:        class SelectControl:
./gui/panel_controls.gd:        class StringControl:
./input_sender.gd:              class InputQueueItem:
./input_sender.gd:              class MouseDraw:
./method_maker.gd:              class CallParameters:
./orphan_counter.gd:            class Orphanage:
./printers.gd:                  class ConsolePrinter:
./printers.gd:                  class GutGuiPrinter:
./printers.gd:                  class TerminalPrinter:
./script_parser.gd:             class ParsedMethod:
./script_parser.gd:             class ParsedScript:
./singleton_parser.gd:          class ParsedSingleton:
./test.gd:                      class _ConnectionInfo:
./test.gd:                      class SignalAssertParameters:
./version_conversion.gd:        class ConfigurationUpdater:
./version_numbers.gd:           class VerNumTools:
```

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