import gdb
import os

class RefreshBreaks(gdb.Command):
    """deletes and re-creates all breakpoints"""

    def __init__(self):
        super(RefreshBreaks, self).__init__("refresh-breaks", gdb.COMMAND_FILES,
                                        gdb.COMPLETE_FILENAME)

    def invoke(self, arg, from_tty):
        breaks = []
        if hasattr(gdb, 'breakpoints') and not gdb.breakpoints() is None:
            for bp in gdb.breakpoints():
                breaks.append((bp.commands, bp.location))
                bp.delete()

            for cmd, loc in breaks:
                new_bp = gdb.Breakpoint(loc, type=gdb.BP_HARDWARE_BREAKPOINT)
                new_bp.commands = cmd

RefreshBreaks()
