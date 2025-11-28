import logger as lgr

GODOT_CLASS_URL = "https://docs.godotengine.org/en/stable/classes/class_"
godot_classes = []
def make_type_link(link_type):
    # Only encountered this case when a script "extends" a path instead of a
    # clas_name.  In this case we don't make a link.
    if(link_type.endswith('.gd"')):
        return link_type.replace('"', "")

    if(not link_type in godot_classes):
        godot_classes.append(link_type)
        lgr.print_style("bold", f'Linking "{link_type}" as a Godot class.')

    return f"`{link_type} <{GODOT_CLASS_URL}{link_type.lower()}.html>`_"


# A down and dirty link to the Godot class for something in that class.
def make_type_link_for_part(link_type, part):
    lgr.print_style("bold", f'Linking "{link_type}.{part}" as Godot class {link_type}.')
    if(not link_type in godot_classes):
        godot_classes.append(link_type)

    return f"`{link_type}.{part} <{GODOT_CLASS_URL}{link_type.lower()}.html>`_"

