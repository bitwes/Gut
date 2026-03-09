
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
./orphan_counter.gd:            class Orphanage:
./input_sender.gd:              class MouseDraw:
```

# Unlikely
```
./printers.gd:                  class ConsolePrinter:
./printers.gd:                  class TerminalPrinter:
./version_numbers.gd:           class VerNumTools:
./printers.gd:                  class GutGuiPrinter:
./version_conversion.gd:        class ConfigurationUpdater:
./singleton_parser.gd:          class ParsedSingleton:
./script_parser.gd:             class ParsedMethod:
./script_parser.gd:             class ParsedScript:
./awaiter.gd:                   class AwaitLogger:
./cli/gut_cli.gd:               class OptionResolver:
./cli/optparse.gd:              class OptionHeading:
./input_sender.gd:              class InputQueueItem:
./gui/gut_logo.gd:              class Eyeball:
./gui/panel_controls.gd:        class BaseGutPanelControl:
./gui/panel_controls.gd:        class NumberControl:
./gui/panel_controls.gd:        class FloatControl:
./gui/panel_controls.gd:        class StringControl:
./gui/panel_controls.gd:        class MultiLineStringControl:
./gui/panel_controls.gd:        class BooleanControl:
./gui/panel_controls.gd:        class SelectControl:
./gui/panel_controls.gd:        class ColorControl:
./gui/panel_controls.gd:        class DirectoryControl:
./gui/panel_controls.gd:        class FileDialogSuperPlus:
./gui/panel_controls.gd:        class SaveLoadControl:
./gui/gut_user_preferences.gd:  class GutEditorPref:
./gui/OutputText.gd:            class TextEditSearcher:
./method_maker.gd:              class CallParameters:
./test.gd:                      class SignalAssertParameters:
./test.gd:                      class _ConnectionInfo:
```
