## This script processes the junit.xml results and checks if the correct tests failed.
extends SceneTree

var expected_failures: Array[FailingCase] = [

]

func _init():
    var parser: XMLParser = XMLParser.new()
    parser.open("junit.xml")
    var failing_cases: Array[FailingCase] = []
    while parser.read() != ERR_FILE_EOF:
        if parser.get_node_type() == XMLParser.NODE_ELEMENT:
            var node_name: String           = parser.get_node_name()
            var attributes_dict: Dictionary = {}
            for idx in range(parser.get_attribute_count()):
                attributes_dict[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
            match node_name:
                "testcase":
                    if attributes_dict["status"] == "fail":
                        failing_cases.append(FailingCase.new(attributes_dict["classname"], attributes_dict["name"]))
    var success: bool = true
    for failing_case in failing_cases:
        var found: bool = false
        for expected_failure in expected_failures:
            if failing_case.equals(expected_failure):
                found = true
                break
        if !found:
            success = false
            printerr("Unexpected test failure: %s"%[str(failing_case)])
    for expected_failure in expected_failures:
        var found: bool = false
        for failing_case in failing_cases:
            if failing_case.equals(expected_failure):
                found = true
                break
        if !found:
            success = false
            printerr("Expected failure not found: %s"%[str(expected_failure)])
    if success:
        quit(0)
    else:
        quit(1)

class FailingCase:
    var className: String
    var case: String

    func _init(new_className: String, new_case: String):
        className = new_className
        case = new_case

    func equals(other: FailingCase) -> bool:
        return className == other.className and case == other.case

    func _to_string() -> String:
        return "%s : %s"%[className, case]
