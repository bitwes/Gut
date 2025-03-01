:github_url: hide

.. DO NOT EDIT THIS FILE!!!
.. Generated automatically from GUT Plugin sources.
.. Generator: documentation/godot_make_rst.py.
.. _class_GutMain:

GutMain
=======

**Inherits:** `"addons/gut/gut_to_move.gd" <https://docs.godotengine.org/en/stable/classes/class_"addons/gut/gut_to_move.gd".html>`_

The GUT brains.

.. rst-class:: classref-introduction-group

Description
-----------

Most of this class is for internal use only.  Features that can be used are have descriptions and can be accessed through the :ref:`GutTest.gut<class_GutTest_property_gut>` variable in your test scripts (extends :ref:`GutTest<class_GutTest>`). The wiki page for this class contains only the usable features. 



GUT Wiki:  `https://gut.readthedocs.io <https://gut.readthedocs.io>`__ 



.. rst-class:: classref-reftable-group

Properties
----------

.. table::
   :widths: auto

   +--------------------------------------------------------------------------------+----------------------------------------------------+----------------+
   | `Variant <https://docs.godotengine.org/en/stable/classes/class_variant.html>`_ | :ref:`log_level<class_GutMain_property_log_level>` | ``_log_level`` |
   +--------------------------------------------------------------------------------+----------------------------------------------------+----------------+

.. rst-class:: classref-reftable-group

Methods
-------

.. table::
   :widths: auto

   +--------------------------------------------------------------------------------+--------------------------------------------------------------------------------+
   | `Variant <https://docs.godotengine.org/en/stable/classes/class_variant.html>`_ | :ref:`get_assert_count<class_GutMain_method_get_assert_count>`\ (\ )           |
   +--------------------------------------------------------------------------------+--------------------------------------------------------------------------------+
   | `Variant <https://docs.godotengine.org/en/stable/classes/class_variant.html>`_ | :ref:`get_fail_count<class_GutMain_method_get_fail_count>`\ (\ )               |
   +--------------------------------------------------------------------------------+--------------------------------------------------------------------------------+
   | `Variant <https://docs.godotengine.org/en/stable/classes/class_variant.html>`_ | :ref:`get_pass_count<class_GutMain_method_get_pass_count>`\ (\ )               |
   +--------------------------------------------------------------------------------+--------------------------------------------------------------------------------+
   | `Variant <https://docs.godotengine.org/en/stable/classes/class_variant.html>`_ | :ref:`get_pending_count<class_GutMain_method_get_pending_count>`\ (\ )         |
   +--------------------------------------------------------------------------------+--------------------------------------------------------------------------------+
   | `Variant <https://docs.godotengine.org/en/stable/classes/class_variant.html>`_ | :ref:`get_summary<class_GutMain_method_get_summary>`\ (\ )                     |
   +--------------------------------------------------------------------------------+--------------------------------------------------------------------------------+
   | `Variant <https://docs.godotengine.org/en/stable/classes/class_variant.html>`_ | :ref:`get_test_script_count<class_GutMain_method_get_test_script_count>`\ (\ ) |
   +--------------------------------------------------------------------------------+--------------------------------------------------------------------------------+

.. rst-class:: classref-section-separator

----

.. rst-class:: classref-descriptions-group

Property Descriptions
---------------------

.. _class_GutMain_property_log_level:

.. rst-class:: classref-property

`Variant <https://docs.godotengine.org/en/stable/classes/class_variant.html>`_ **log_level** = ``_log_level`` :ref:`🔗<class_GutMain_property_log_level>`

.. rst-class:: classref-property-setget

- |void| **@log_level_setter**\ (\ value\ )
- `Variant <https://docs.godotengine.org/en/stable/classes/class_variant.html>`_ **@log_level_getter**\ (\ )

The log detail level.  Valid values are 0 - 2.  Larger values do not matter.

.. rst-class:: classref-section-separator

----

.. rst-class:: classref-descriptions-group

Method Descriptions
-------------------

.. _class_GutMain_method_get_assert_count:

.. rst-class:: classref-method

`Variant <https://docs.godotengine.org/en/stable/classes/class_variant.html>`_ **get_assert_count**\ (\ ) :ref:`🔗<class_GutMain_method_get_assert_count>`

Get the number of assertions that were made

.. rst-class:: classref-item-separator

----

.. _class_GutMain_method_get_pass_count:

.. rst-class:: classref-method

`Variant <https://docs.godotengine.org/en/stable/classes/class_variant.html>`_ **get_pass_count**\ (\ ) :ref:`🔗<class_GutMain_method_get_pass_count>`

Get the number of assertions that passed

.. rst-class:: classref-item-separator

----

.. _class_GutMain_method_get_fail_count:

.. rst-class:: classref-method

`Variant <https://docs.godotengine.org/en/stable/classes/class_variant.html>`_ **get_fail_count**\ (\ ) :ref:`🔗<class_GutMain_method_get_fail_count>`

Get the number of assertions that failed

.. rst-class:: classref-item-separator

----

.. _class_GutMain_method_get_pending_count:

.. rst-class:: classref-method

`Variant <https://docs.godotengine.org/en/stable/classes/class_variant.html>`_ **get_pending_count**\ (\ ) :ref:`🔗<class_GutMain_method_get_pending_count>`

Get the number of tests flagged as pending

.. rst-class:: classref-item-separator

----

.. _class_GutMain_method_get_summary:

.. rst-class:: classref-method

`Variant <https://docs.godotengine.org/en/stable/classes/class_variant.html>`_ **get_summary**\ (\ ) :ref:`🔗<class_GutMain_method_get_summary>`

Returns a summary.gd object that contains all the information about the run results.

.. rst-class:: classref-item-separator

----

.. _class_GutMain_method_get_test_script_count:

.. rst-class:: classref-method

`Variant <https://docs.godotengine.org/en/stable/classes/class_variant.html>`_ **get_test_script_count**\ (\ ) :ref:`🔗<class_GutMain_method_get_test_script_count>`

Returns the number of test scripts.  Inner Test classes each count as a script.

.. |virtual| replace:: :abbr:`virtual (This method should typically be overridden by the user to have any effect.)`
.. |const| replace:: :abbr:`const (This method has no side effects. It doesn't modify any of the instance's member variables.)`
.. |vararg| replace:: :abbr:`vararg (This method accepts any number of arguments after the ones described here.)`
.. |constructor| replace:: :abbr:`constructor (This method is used to construct a type.)`
.. |static| replace:: :abbr:`static (This method doesn't need an instance to be called, so it can be called directly using the class name.)`
.. |operator| replace:: :abbr:`operator (This method describes a valid operator to use with this type as left-hand operand.)`
.. |bitfield| replace:: :abbr:`BitField (This value is an integer composed as a bitmask of the following flags.)`
.. |void| replace:: :abbr:`void (No return value.)`
