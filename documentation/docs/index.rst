.. toctree::
   :hidden:
   :maxdepth: 3
   :caption: Getting Started
   :name: sec-started

   New-For-Godot-4
   Install
   Quick-Start
   Command-Line


.. toctree::
   :hidden:
   :caption: GutTest
   :name: sec-guttest

   Creating-Tests
   Asserts-and-Methods
   Awaiting
   Inner-Test-Classes
   Parameterized-Tests
   Simulate
   Comparing-Things


.. toctree::
   :hidden:
   :maxdepth: 1
   :caption: Doubling
   :name: sec-doubles

   Doubles
   Partial-Doubles
   Double-Strategy
   Stubbing
   Spies


.. toctree::
   :hidden:
   :maxdepth: 1
   :caption: Mocking Input
   :name: sec-mockinput

   Mock-Input
   Input-Factory



.. toctree::
   :hidden:
   :maxdepth: 1
   :caption: Other
   :name: sec-other

   Contributing
   Export-Test-Results
   Hooks
   Memory-Management
   Orphans
   Running-On-Devices
   Tutorials


Gut 7.4.3 (Godot 3.x)
=========
GUT (Godot Unit Test) is a utility for writing tests for your Godot Engine game.  It allows you to write tests for your gdscripts in gdscript.



Getting Started
----------------

* :doc:`Quick-Start <Quick-Start>`
* :doc:`Install <Install>`
* :doc:`Asserts and Methods <Asserts-and-Methods>`
* :doc:`Creating Tests <Creating-Tests>`
* :doc:`Gut Settings and Methods <Gut-Settings-And-Methods>`
* :doc:`Using Gut at the command line <Command-Line>`


Advanced Testing
----------------

* :doc:`Inner Test Classes <Inner-Test-Classes>`
* :doc:`Doubling <Doubles>`
* :doc:`Spies <Spies>`
* :doc:`Stubbing <Stubbing>`
* :doc:`Parameterized Tests <Parameterized-Tests>`
* :doc:`Simulate <Simulate>`
* :doc:`Yielding during tests <Yielding>`
* :doc:`Pre/Post Run Hooks <Hooks>`
* :doc:`Exporting Results <Export-Test-Results>`


Editor GUI
----------

.. image:: _static/images/gut_panel.png

GUT GUI
-------

.. image:: _static/images/GutGui.png

1.  Output Box.
#.  List of Test Scripts.  Inner Classes are indented under scripts.
#.  Progress bars for all scripts and the current script.
#.  Log Level slider.
#.  Previous Script (in list of scripts)
#.  Run the currently selected script and all scripts after it.  This can be especially useful when running on another device and some script in the middle of the list causes a crash.  To run the tests after the crash, just select that test in the list and click this button.  It will run that one and all the ones after.
#.  Next Script (in list of scripts)
#.  Run the currently selected script.  If an Inner Class is selected then just that class will be run.  If a Script is selected then the script and all of its Inner Classes will be run.
#.  Toggle display of List of Test Scripts
#.  The Hamburger button.  It shows some additional options.
#.  Continue button will be enabled if a call to `yield_before_teardown` occurs.  Click it to continue running tests.
#.  The title bar.  It has a maximize button, shows the current script, has a running tally on the left of the pass/fail count, shows the elapsed time.  Also you can drag it all about.

Also, in the bottom right corner, you can drag to resize the dialog.


Engine Warnings
---------------

There are a fair number of warnings that Godot will show related to GUT.  Some of the warnings are valid and are being cleaned up overtime.  Most of the warnings are not valid and sometimes relate to generated code.  As of 3.2 you can disable warnings for addons, and it recommended you do so.

.. image:: _static/images/exclude_addons.png


License
-------

Gut is provided under the MIT license.  [The license is distributed with Gut so it is in the `addons/gut` folder](https://github.com/bitwes/Gut/blob/master/addons/gut/LICENSE.md).


Contributing
------------

:doc:`Contributing <Contributing>`


Indices and tables
==================

* :ref:`genindex`
* :ref:`search`

