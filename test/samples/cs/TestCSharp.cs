using Godot;
using System;
// using GutCSharp;

public partial class TestCSharp : GutTest
{
    public void TestOne()
    {
        // This should pass
        // AssertEq("five", "five", "Values should be equal");
    }
    
    public void TestTwo()
    {
        // This should fail (like your sample)
        // AssertNe("five", "five", "This should fail");
    }

    public void test_three() {
        AssertEq(1, 1, "This should pass");
    }
}
