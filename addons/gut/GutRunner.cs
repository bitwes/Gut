using Godot;
using System;
using System.Reflection;
using System.Collections.Generic;

namespace GutCSharp
{
	public partial class GutCSharpRunner : RefCounted
	{
		private Node _gut;

		public GutCSharpRunner(Node gut)
		{
			_gut = gut;
		}

		public void RunTests(string scriptPath)
		{
			// Load the C# script/class
			var script = GD.Load<CSharpScript>(scriptPath);
			if (script == null) return;
			
			var instance = script.New().As<GutTest>();
			if (instance == null) return;
			
			instance.gut = _gut;
			
			// Get all methods from the instance
			Type type = instance.GetType();
			MethodInfo[] methods = type.GetMethods(BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly);
			
			// Filter for test methods (prefixed with "Test")
			List<MethodInfo> testMethods = new List<MethodInfo>();
			foreach (var method in methods)
			{
				if (method.Name.StartsWith("Test") && method.GetParameters().Length == 0)
				{
					testMethods.Add(method);
				}
			}
			
			// Run lifecycle and test methods
			try
			{
				instance.BeforeAll();
				
				foreach (var testMethod in testMethods)
				{
					string testName = testMethod.Name;
					_gut.Call("_pre_run_test", testName);
					
					instance.BeforeEach();
					testMethod.Invoke(instance, null);
					instance.AfterEach();
					
					_gut.Call("_post_run_test");
				}
				
				instance.AfterAll();
			}
			catch (Exception e)
			{
				_gut.Call("_fail", "Error in test: " + e.Message);
			}
		}
	}
}
