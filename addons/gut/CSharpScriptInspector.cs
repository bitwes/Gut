using Godot;
using System;
using System.Reflection;

// namespace GutCSharp
// {
	/// <summary>
	/// Utility class to handle inspection of C# scripts for the GUT testing framework.
	/// This provides reflection-based methods that help GUT understand C# class inheritance.
	/// </summary>
	public partial class CSharpScriptInspector : RefCounted
	{
		/// <summary>
		/// Checks if a C# type inherits from GutTest
		/// </summary>
		/// <param name="type">The Type to check</param>
		/// <returns>True if the type inherits from GutTest</returns>
		private bool TypeInheritsFromGutTest(Type type)
		{
			if (type == null)
				return false;
				
			// If this is the GutTest class itself (base case for successful inheritance)
			if (type.FullName == "GutCSharp.GutTest")
			{
				GD.Print("FULL NAME: ", type.FullName);
				return true;
			}
				
			// Check the base type
			return TypeInheritsFromGutTest(type.BaseType);
		}
		
		/// <summary>
		/// Determines if a CSharpScript inherits from GutTest
		/// </summary>
		/// <param name="script">The CSharpScript to check</param>
		/// <returns>True if the script inherits from GutTest</returns>
		public bool InheritsFromTest(CSharpScript script)
		{

			if (script == null)
				return false;
			Variant instance = script.New();
			var tryCast = instance.As<GutTest>();
			
			return tryCast != null;
		}
		
		/// <summary>
		/// Determines if an object instance inherits from GutTest
		/// </summary>
		/// <param name="instance">The object instance to check</param>
		/// <returns>True if the object inherits from GutTest</returns>
		public bool InheritsFromTest(object instance)
		{

            GD.Print("here");


			if (instance == null)
				return false;

				
			return TypeInheritsFromGutTest(instance.GetType());
		}
	}
// } 
