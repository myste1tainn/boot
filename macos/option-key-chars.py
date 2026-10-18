#!/usr/bin/env python3
"""Dump what each Option+<key> combination types on the active keyboard layout.

Some terminals do not deliver macOS Option as Alt/Meta — they let the keyboard
layout compose it, so Option+b arrives as "∫" rather than as Alt+b. The configs
in this repo bind both forms, and the composed half of those tables comes from
here:

    zsh/zshrc                                   (_alt_bindkey calls)
    tmux/home/dotfiles/tmux.conf                (bind-key '∆' …)
    ~/.config/nvim/lua/core/keymaps/option_alt.lua   (separate repo)

Run it after changing the active input source and update those tables to match.
Keys reported as DEAD-KEY (Option+e/i/n/u/` on the US layout) emit nothing until
the next keypress, so they cannot be bound by their composed character at all.

The layout is read from the live input source through UCKeyTranslate, so the
output is whatever the keyboard is actually set to right now.
"""

import ctypes

cf = ctypes.CDLL("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation")
cb = ctypes.CDLL("/System/Library/Frameworks/Carbon.framework/Carbon")

for fn, res, args in [
    (cf.CFDataGetBytePtr, ctypes.c_void_p, [ctypes.c_void_p]),
    (cf.CFGetTypeID, ctypes.c_ulong, [ctypes.c_void_p]),
    (cf.CFDataGetTypeID, ctypes.c_ulong, []),
    (cb.TISCopyCurrentKeyboardLayoutInputSource, ctypes.c_void_p, []),
    (cb.TISCopyCurrentKeyboardInputSource, ctypes.c_void_p, []),
    (cb.TISGetInputSourceProperty, ctypes.c_void_p, [ctypes.c_void_p, ctypes.c_void_p]),
    (cb.UCKeyTranslate, ctypes.c_int32, [
        ctypes.c_void_p, ctypes.c_uint16, ctypes.c_uint16, ctypes.c_uint32,
        ctypes.c_uint32, ctypes.c_uint32, ctypes.POINTER(ctypes.c_uint32),
        ctypes.c_ulong, ctypes.POINTER(ctypes.c_ulong), ctypes.c_void_p]),
]:
    fn.restype, fn.argtypes = res, args
cf.CFStringGetCString.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_long, ctypes.c_uint32]
cb.LMGetKbdType.restype = ctypes.c_uint8

K_LAYOUT = ctypes.c_void_p.in_dll(cb, "kTISPropertyUnicodeKeyLayoutData")
K_NAME = ctypes.c_void_p.in_dll(cb, "kTISPropertyLocalizedName")
UTF8 = 0x08000100

# Virtual key codes, labelled by what the key types unmodified on a US layout.
KEYS = [
    ("a", 0), ("b", 11), ("c", 8), ("d", 2), ("e", 14), ("f", 3), ("g", 5),
    ("h", 4), ("i", 34), ("j", 38), ("k", 40), ("l", 37), ("m", 46), ("n", 45),
    ("o", 31), ("p", 35), ("q", 12), ("r", 15), ("s", 1), ("t", 17), ("u", 32),
    ("v", 9), ("w", 13), ("x", 7), ("y", 16), ("z", 6),
    ("1", 18), ("2", 19), ("3", 20), ("4", 21), ("5", 23), ("6", 22),
    ("7", 26), ("8", 28), ("9", 25), ("0", 29),
    ("-", 27), ("=", 24), ("[", 33), ("]", 30), ("\\", 42), (";", 41),
    ("'", 39), (",", 43), (".", 47), ("/", 44), ("`", 50), ("space", 49),
]


def _name(src):
    p = cb.TISGetInputSourceProperty(src, K_NAME)
    buf = ctypes.create_string_buffer(512)
    if p and cf.CFStringGetCString(p, buf, 512, UTF8):
        return buf.value.decode()
    return "?"


def _layout_data(src):
    """The source's 'uchr' layout table, or None if it does not expose one."""
    p = cb.TISGetInputSourceProperty(src, K_LAYOUT)
    if p and cf.CFGetTypeID(p) == cf.CFDataGetTypeID():
        return p
    return None


def active_layout():
    for getter in ("TISCopyCurrentKeyboardLayoutInputSource",
                   "TISCopyCurrentKeyboardInputSource"):
        src = getattr(cb, getter)()
        if not src:
            continue
        data = _layout_data(src)
        if data:
            return _name(src), ctypes.c_void_p(cf.CFDataGetBytePtr(data))
    raise SystemExit("no active input source exposes Unicode key layout data")


def translate(layout, code, kbd_type, shift):
    """What this key types with Option (and optionally Shift) held."""
    option, shift_bit = 0x0800 >> 8, 0x0200 >> 8
    dead, length = ctypes.c_uint32(0), ctypes.c_ulong(0)
    out = (ctypes.c_uint16 * 8)()
    status = cb.UCKeyTranslate(
        layout, code, 0, option | (shift_bit if shift else 0), kbd_type, 0,
        ctypes.byref(dead), 8, ctypes.byref(length), out)
    if status != 0:
        return "<UCKeyTranslate error %d>" % status
    text = "".join(chr(out[i]) for i in range(length.value))
    if dead.value and not text:
        return "DEAD-KEY"
    if not text:
        return "<nothing>"
    return "%s  %s" % (text, " ".join("U+%04X" % ord(c) for c in text))


def main():
    name, layout = active_layout()
    kbd_type = cb.LMGetKbdType()
    print("# active keyboard layout: %s" % name)
    for label, code in KEYS:
        print("opt+%-6s %-24s   opt+shift+%-6s %s" % (
            label, translate(layout, code, kbd_type, False),
            label, translate(layout, code, kbd_type, True)))


if __name__ == "__main__":
    main()
