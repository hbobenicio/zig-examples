//! codes namespace groups all ANSI escape codes.
//! At the moment, we are only supporting color codes. But it could easily be extended.
//! Contributions are welcomed.


/// Esc represents the Escape code.
pub const Esc: []const u8 = "\x1b";

/// EscapePrefix represents the common "Esc[" escaping prefix pattern.
pub const EscapePrefix: []const u8 = Esc ++ "[";

pub const cursor = struct {
    /// Moves the cursor to the specified position (coordinates).
    /// If you do not specify a position, the cursor moves to the home position at the upper-left corner of the screen (line 0, column 0). This escape sequence works the same way as the following Cursor Position escape sequence.
    pub const PositionSuffix1: []const u8 = "H";
    pub const PositionSuffix2: []const u8 = "f";

    /// Moves the cursor up by the specified number of lines without changing columns.
    /// If the cursor is already on the top line, ANSI.SYS ignores this sequence. 
    pub const UpSuffix: []const u8 = "A";

    /// Moves the cursor down by the specified number of lines without changing columns.
    /// If the cursor is already on the bottom line, ANSI.SYS ignores this sequence.
    pub const DownSuffix: []const u8 = "B";

    /// Moves the cursor forward by the specified number of columns without changing lines.
    /// If the cursor is already in the rightmost column, ANSI.SYS ignores this sequence. 
    pub const ForwardSuffix: []const u8 = "C";

    /// Moves the cursor back by the specified number of columns without changing lines.
    /// If the cursor is already in the leftmost column, ANSI.SYS ignores this sequence.
    pub const BackwardSuffix: []const u8 = "D";

    /// Saves the current cursor position.
    /// You can move the cursor to the saved cursor position by using the Restore Cursor Position sequence.
    pub const SavePositionSuffix: []const u8 = "s";

    /// Returns the cursor to the position stored by the Save Cursor Position sequence.
    pub const RestorePositionSuffix: []const u8 = "u";

    /// Clears the screen and moves the cursor to the home position (line 0, column 0). 
    pub const EraseDisplaySuffix: []const u8 = "2J";

    /// Clears all characters from the cursor position to the end of the line (including the character at the cursor position).
    pub const EraseLineSuffix: []const u8 = "K";
};

pub const graphics = struct {
    /// GraphicsSuffix represents the suffix used for graphics escaping.
    ///
    /// Calls the graphics functions specified by the following values.
    /// These specified functions remain active until the next occurrence of this escape sequence.
    /// Graphics mode changes the colors and attributes of text (such as bold and underline) displayed on the screen.
    pub const SetModeSuffix: []const u8 = "m";

    pub const attr = struct {
        // TODO namespace conflicts 
        // pub const Reset: []const u8 = "0";
        pub const Bold: []const u8 = "1";
        pub const Dim: []const u8 = "2";
        pub const Italic: []const u8 = "3";
        pub const Underline: []const u8 = "4";
        // TODO 5? 6?
        pub const Inverse: []const u8 = "7";
        pub const Hidden: []const u8 = "8";
        pub const Strikethrough: []const u8 = "9";
    };
};


/// Reset represents the reset code. All text attributes will be turned off.
pub const Reset: []const u8 = "0";

/// color namespace groups all color codes.
pub const color = struct {
    /// fg namespace groups all foreground color codes.
    pub const fg = struct {
        pub const Black: []const u8 = "30";
        pub const Red: []const u8 = "31";
        pub const Green: []const u8 = "32";
        pub const Yellow: []const u8 = "33";
        pub const Blue: []const u8 = "34";
        pub const Magenta: []const u8 = "35";
        pub const Cyan: []const u8 = "36";
        pub const White: []const u8 = "37";
        // TODO 38?

        // TODO Namespace conflicts
        // pub const Reset: []const u8 = "39"; // https://github.com/chalk/ansi-styles/blob/master/index.js
    };
    /// bg namespace groups all background color codes.
    pub const bg = struct {
        pub const Black: []const u8 = "40";
        pub const Red: []const u8 = "41";
        pub const Green: []const u8 = "42";
        pub const Yellow: []const u8 = "43";
        pub const Blue: []const u8 = "44";
        pub const Magenta: []const u8 = "45";
        pub const Cyan: []const u8 = "46";
        pub const White: []const u8 = "47";
        // TODO 48?;

        // TODO Namespace conflicts
        // pub const Reset: []const u8 = "49";
    };
    // pub const ForegroundFancyBlue: []const u8 = comptime ESC ++ "[38;5;80m";
};

// TODO Consider adding a namespace for Graphics
