from godot_consts import *

def print_error(error: str, state) -> None:
    print(f'{STYLES["red"]}{STYLES["bold"]}ERROR:{STYLES["regular"]} {error}{STYLES["reset"]}')
    state.num_errors += 1


def print_warning(warning: str, state) -> None:
    print(f'{STYLES["yellow"]}{STYLES["bold"]}WARNING:{STYLES["regular"]} {warning}{STYLES["reset"]}')
    state.num_warnings += 1


verbose_enabled = True
def vprint(*arg) -> None:
    if(verbose_enabled):
        out = ""
        for a in arg:
            out += str(a) + " "
        print(f"Info:  {out}")


debug_enabled = True
def dbg(*arg) -> None:
    if(debug_enabled):
        out = ""
        for a in arg:
            out += str(a) + " "
        print(f"Debug:  {out}")

