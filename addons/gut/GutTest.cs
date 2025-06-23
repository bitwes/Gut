using Godot;
using System;
using System.Reflection;

// namespace GutCSharp
// {
	public partial class GutTest : Godot.Node
	{
		// Public property that proxies to _gdGutTest
		public Node gut
		{
			get
			{
				if (_gdGutTest != null)
				{
					return (Node)_gdGutTest.Get("gut");
				}
				return null;
			}
			set
			{
				if (_gdGutTest != null)
				{
					_gdGutTest.Set("gut", value);
				}
			}
		}
		
		// Reference to GDScript GutTest instance that will handle the actual implementation
		private Node _gdGutTest;
		
		// Flag to track if ready was called
		public bool _was_ready_called
		{
			get
			{
				if (_gdGutTest != null)
				{
					return (bool)_gdGutTest.Get("_was_ready_called");
				}
				return false;
			}
		}
		
		// Constructor - creates the GDScript GutTest instance
		public GutTest()
		{
			// Load the GDScript GutTest scene/script
			var gdTestScript = GD.Load<Script>("res://addons/gut/test.gd");
			_gdGutTest = new Node();
			_gdGutTest.SetScript(gdTestScript);
		}
		
		// Override _Ready to setup the GDScript instance
		public override void _Ready()
		{
			base._Ready();
			// Add the GDScript instance as a child so it gets properly initialized
			AddChild(_gdGutTest);
		}

		// Lifecycle methods - these are virtual and meant to be overridden
		public virtual void BeforeAll() { }
		public void before_all() {
			BeforeAll();
		}

		public virtual void AfterAll() { }
		public void after_all() {
			AfterAll();
		}

		public virtual void BeforeEach() { }
		public void before_each() {
			BeforeEach();
		}

		public virtual void AfterEach() { }
		public void after_each() {
			AfterEach();
			// Call GDScript implementation
			if (_gdGutTest != null)
			{
				_gdGutTest.Call("after_each");
			}
		}

		// Assertion methods - proxied to GDScript implementation when possible
		public void AssertEq(object a, object b, string text = "")
		{
			// Using direct implementation instead of proxying due to type conversion issues
			if (a.Equals(b))
				gut.Call("_pass", $"Expecting {a} to equal {b}. {text}");
			else
				gut.Call("_fail", $"Expecting {a} to equal {b}. {text}");
		}

		public void AssertNe(object a, object b, string text = "")
		{
			// Using direct implementation instead of proxying due to type conversion issues
			if (!a.Equals(b))
				gut.Call("_pass", $"Expecting {a} to not equal {b}. {text}");
			else
				gut.Call("_fail", $"Expecting {a} to not equal {b}. {text}");
		}

		// Virtual method that can be overridden
		public virtual bool should_skip_script() {
			return false;
		}

		// Proxy methods to GDScript implementation
		public void set_logger(RefCounted logger) {
			if (_gdGutTest != null)
			{
				_gdGutTest.Call("set_logger", logger);
			}
		}

		public Variant get_assert_count() {
			if (_gdGutTest != null)
			{
				return _gdGutTest.Call("get_assert_count");
			}
			return 0;
		}

		public void _do_ready_stuff() {
			if (_gdGutTest != null)
			{
				_gdGutTest.Call("_do_ready_stuff");
			}
		}

		public void clear_signal_watcher() {
			if (_gdGutTest != null)
			{
				_gdGutTest.Call("clear_signal_watcher");
			}
		}
		
		// Additional methods to proxy common GutTest functionality
		
		// Example of how to add more assertion methods:
		public void AssertTrue(bool condition, string text = "")
		{
			if (condition)
				gut.Call("_pass", $"Expecting true. {text}");
			else
				gut.Call("_fail", $"Expecting true. {text}");
		}
		
		public void AssertFalse(bool condition, string text = "")
		{
			if (!condition)
				gut.Call("_pass", $"Expecting false. {text}");
			else
				gut.Call("_fail", $"Expecting false. {text}");
		}

	}
//}
