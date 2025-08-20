extends Control

var options = null


func _ready():
	options = GutUtils.OptionMaker.new($ScrollContainer/VBoxContainer)
	_add_controls()
	
	
func _add_controls():
	options.add_title("Shell Out Options")
	options.add_blurb("These options affect how GUT is run when not run through the editor.  The main reason why you would not want to run through the editor is so that you can disable the debugger.  That's the main reason it was made, you might have other reasons.")
	options.add_title('Blocking Mode')
	options.add_blurb("""[b]Blocking[/b]
Test output and errors and appear together but the editor cannot be used while tests are running.""")
	options.add_blurb("""[b]Non-Blocking[/b]
Only test output is returned back to the editor but you can use the editor while tests are running.""")
	options.add_select('execute_method', 'Blocking', ['Blocking', 'Non-Blocking'], '')
	options.add_title("Additional Options")
	options.add_blurb("Supply any additional command line options for either GUT or Godot")
	options.add_value("cmd_options", '', '', '')
