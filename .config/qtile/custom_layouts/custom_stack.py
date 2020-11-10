from libqtile import utils
from libqtile.layout.base import Layout, _ClientList


class _WinStack(_ClientList):

    # shortcuts for current client and index used in Columns layout
    cw = _ClientList.current_client

    def __init__(self, autosplit=False):
        _ClientList.__init__(self)
        self.split = autosplit

    def toggle_split(self):
        self.split = False if self.split else True

    def __str__(self):
        return "_WinStack: %s, %s" % (
            self.cw, str([client.name for client in self.clients])
        )

    def info(self):
        info = _ClientList.info(self)
        info['split'] = self.split
        return info


class CustomStack(Layout):
    """A layout composed of at most two stacks of windows

    This custom stack layout distributes the windows in at most two
    horizontally splitted stacks. Stacks are created as needed, always taking
    the whole screen space. Each pane can be set to autosplit vertically,
    instead of stacking its clients. When closing all the windows in a stack,
    the other pane will take up the whole screen if not set to autosplit (or if
    there is only one client in it), otherwise, the last focused window will
    fill the space of the closed one. Clients can be moved between stacks; if
    there is only one pane with multiple windows in it, moving a window to
    another stack will create a new pane in order to place it.
    """

    defaults = [
        ("border_focus", "#0000ff", "Border colour for the focused window."),
        ("border_normal", "#000000", "Border colour for un-focused windows."),
        ("border_width", 1, "Border width."),
        ("name", "customstack", "Name of this layout."),
        ("autosplit", [False, False], "Auto split left and right stacks."),
        ("fair", False, "Add new windows to the stacks in a round robin way."),
        ("margin", 0, "Margin of the layout."),
        ("max_single", False, "Remove margins if there is only one stack."),
    ]

    def __init__(self, **config):
        Layout.__init__(self, **config)
        self.add_defaults(CustomStack.defaults)
        self.stacks = []

    @property
    def current_stack(self):
        return self.stacks[self.current_stack_offset]

    @property
    def current_stack_offset(self):
        for i, s in enumerate(self.stacks):
            if self.group.current_window in s:
                return i
        return 0

    @property
    def clients(self):
        client_list = []
        for stack in self.stacks:
            client_list.extend(stack.clients)
        return client_list

    def clone(self, group):
        clone = Layout.clone(self, group)
        # These are mutable
        clone.stacks = [_WinStack(autosplit=self.autosplit[i])
                        for i in range(len(self.stacks))]
        return clone

    # def _find_next(self, lst, offset):
    #     for i in lst[offset + 1:]:
    #         if i:
    #             return i
    #     else:
    #         for i in lst[:offset]:
    #             if i:
    #                 return i

    def _append_stack(self):
        new_idx = len(self.stacks)
        new_stack = _WinStack(autosplit=self.autosplit[new_idx])
        if self.autosplit[new_idx]:
            new_stack.split = True
        self.stacks.append(new_stack)

    def _prepend_stack(self):
        new_stack = _WinStack(autosplit=self.autosplit[0])
        if self.autosplit[0]:
            new_stack.split = True
        self.stacks.insert(0, new_stack)

    def _delete_stack(self, stack):
        self.stacks.remove(stack)
        if len(self.stacks) == 1:
            self.stacks[0].split = self.autosplit[0]

    def next_stack(self):
        current_offset = self.current_stack_offset
        if len(self.stacks) > 1 and current_offset < len(self.stacks) - 1:
            self.group.focus(self.stacks[current_offset + 1].cw, True)

    def previous_stack(self):
        current_offset = self.current_stack_offset
        if len(self.stacks) > 1 and current_offset > 0:
            self.group.focus(self.stacks[current_offset - 1].cw, True)

    def focus(self, client):
        for stack in self.stacks:
            if client in stack:
                stack.focus(client)

    def focus_first(self):
        for stack in self.stacks:
            if stack:
                return stack.focus_first()

    def focus_last(self):
        for stack in reversed(self.stacks):
            if stack:
                return stack.focus_last()

    def focus_next(self, client):
        iterator = iter(self.stacks)
        for i in iterator:
            if client in i:
                next = i.focus_next(client)
                if next:
                    return next
                break
        else:
            return

        for i in iterator:
            if i:
                return i.focus_first()

    def focus_previous(self, client):
        iterator = iter(reversed(self.stacks))
        for i in iterator:
            if client in i:
                next = i.focus_previous(client)
                if next:
                    return next
                break
        else:
            return

        for i in iterator:
            if i:
                return i.focus_last()

    def add(self, client):
        if len(self.stacks) < 2:
            self._append_stack()
            self.stacks[-1].add(client)
        else:
            if self.fair:
                target = min(self.stacks, key=len)
                target.add(client)
            else:
                self.current_stack.add(client)

    def remove(self, client):
        current_stack = self.current_stack
        for i, s in enumerate(self.stacks):
            if client in s:
                s.remove(client)
                if not s:
                    if len(self.stacks) == 1:
                        self._delete_stack(s)
                    elif len(self.stacks) == 2:
                        if len(self.stacks[not i]) > 1 and self.stacks[not i].split:
                            win = self.stacks[not i].cw
                            self.stacks[not i].remove(win)
                            s.add(win)
                            return win
                        else:
                            self._delete_stack(s)
                break
        if current_stack.cw:
            return current_stack.cw
        elif self.stacks:
            return self.stacks[0].cw

    def client_to_next(self):
        if self.stacks:
            win = self.current_stack.cw
            if len(self.stacks) == 1:
                if len(self.current_stack) > 1:
                    self._append_stack()
                    self.current_stack.remove(win)
                    self.stacks[1].add(win)
                    self.stacks[1].focus(win)
            elif len(self.stacks) == 2 and self.current_stack_offset == 0:
                if len(self.current_stack) > 1:
                    self.current_stack.remove(win)
                    self.stacks[1].add(win)
                    self.stacks[1].focus(win)
                else:
                    self.current_stack.remove(win)
                    self._delete_stack(self.stacks[0])
                    self.stacks[0].split = False
                    self.stacks[0].add(win)
                    self.stacks[0].focus(win)

    def client_to_previous(self):
        if self.stacks:
            win = self.current_stack.cw
            if len(self.stacks) == 1:
                if len(self.current_stack) > 1:
                    self._prepend_stack()
                    self.current_stack.remove(win)
                    self.stacks[0].add(win)
                    self.stacks[0].focus(win)
            elif len(self.stacks) == 2 and self.current_stack_offset == 1:
                if len(self.current_stack) > 1:
                    self.current_stack.remove(win)
                    self.stacks[0].add(win)
                    self.stacks[0].focus(win)
                else:
                    self.current_stack.remove(win)
                    self._delete_stack(self.stacks[1])
                    self.stacks[0].split = False
                    self.stacks[0].add(win)
                    self.stacks[0].focus(win)

    def configure(self, client, screen_rect):
        for i, s in enumerate(self.stacks):
            if client in s:
                break
        else:
            client.hide()
            return

        if client.has_focus:
            px = self.group.qtile.color_pixel(self.border_focus)
        else:
            px = self.group.qtile.color_pixel(self.border_normal)

        if self.max_single and len(self.stacks) == 1:
            border_width = 0
            margin = 0
        else:
            border_width = self.border_width
            margin = self.margin

        column_width = int(screen_rect.width / len(self.stacks))
        xoffset = screen_rect.x + i * column_width
        window_width = column_width - 2 * border_width

        # fix double margin
        if len(self.stacks) == 2:
            window_width += margin // 2
            if i == 1:
                xoffset -= margin // 2

        if s.split:
            client_idx = s.index(client)

            column_height = int(screen_rect.height / len(s))
            yoffset = screen_rect.y + client_idx * column_height

            # fix double margin
            if client_idx == 0:
                if len(s) > 1:
                    column_height += margin // 2
            elif client_idx == len(s) - 1:
                column_height += margin // 2
                yoffset -= margin // 2
            else:
                column_height += margin
                yoffset -= margin // 2

            window_height = column_height - 2 * border_width

            client.place(
                xoffset,
                yoffset,
                window_width,
                window_height,
                border_width,
                px,
                margin=margin,
            )
            client.unhide()
        else:
            if client == s.cw:
                client.place(
                    xoffset,
                    screen_rect.y,
                    window_width,
                    screen_rect.height - 2 * border_width,
                    border_width,
                    px,
                    margin=margin,
                )
                client.unhide()
            else:
                client.hide()

    def info(self):
        d = Layout.info(self)
        d["stacks"] = [i.info() for i in self.stacks]
        d["current_stack"] = self.current_stack_offset
        d["clients"] = [c.name for c in self.clients]
        return d

    def cmd_toggle_split(self):
        """Toggle vertical split on the current stack"""
        if len(self.stacks) > 1:
            self.current_stack.toggle_split()
            self.group.layout_all()

    def cmd_down(self):
        """Switch to the next window in this stack"""
        self.current_stack.current_index += 1
        self.group.focus(self.current_stack.cw, False)

    def cmd_up(self):
        """Switch to the previous window in this stack"""
        self.current_stack.current_index -= 1
        self.group.focus(self.current_stack.cw, False)

    def cmd_shuffle_up(self):
        """Shuffle the order of this stack up"""
        self.current_stack.shuffle_up()
        self.group.layout_all()

    def cmd_shuffle_down(self):
        """Shuffle the order of this stack down"""
        self.current_stack.shuffle_down()
        self.group.layout_all()

    def cmd_rotate(self):
        """Rotate order of the stacks"""
        utils.shuffle_up(self.stacks)
        self.group.layout_all()

    def cmd_next(self):
        """Focus next stack"""
        return self.next_stack()

    def cmd_previous(self):
        """Focus previous stack"""
        return self.previous_stack()

    def cmd_client_to_next(self):
        """Send the current client to the next stack"""
        self.client_to_next()
        self.group.layout_all()

    def cmd_client_to_previous(self):
        """Send the current client to the previous stack"""
        self.client_to_previous()
        self.group.layout_all()

    # def cmd_swap_main(self):
    #     if len(self.stacks) == 2:
    #         current_offset = self.current_stack_offset
    #         if (self.stacks[current_offset].split and
    #             (not self.stacks[not current_offset].split or
    #                 len(self.stacks[not current_offset]) == 1)):
    #             if current_offset == 0:
    #                 self.cmd_client_to_next()
    #             elif current_offset == 1:
    #                 self.cmd_client_to_previous()

    def cmd_info(self):
        return self.info()
