colorsCodes = {
    'black': 0,
    'red': 1,
    'green': 2,
    'yellow': 3,
    'blue': 4,
    'magenta': 5,
    'cyan': 6,
    'white': 7,
    'gray': 8,
    'lightred': 9,
    'lightgreen': 10,
    'lightyellow': 11,
    'lightblue': 12,
    'lightmagenta': 13,
    'lightcyan': 14,
    'lightwhite': 15,
};

function applyEscapedSequence(string) {
    const hexNumber = new RegExp('\\\\x([0-9a-fA-F]{2})', 'g');
    string = string.replace("\\n", "\n");
    string = string.replace("\\r", "\r");
    string = string.replace("\\t", "\t");
    string = string.replace(
        hexNumber,
        (_, number) => String.fromCharCode(parseInt(number, 16))
    );
    return string.replace("\\\\", "\\");
}

function interpretNumber(string) {
    string = string.trim().toLowerCase();
    if (colorsCodes[string] !== undefined) {
        return colorsCodes[string]
    } else if (string.substring(0, 2) == '0x') {
        return parseInt(string.substring(2), 16);
    } else {
        return parseInt(string, 10);
    }
}

function interpretBoolean(string) {
    return [ 'on', 'yes', 'true', 'visible' ].includes(
        string.trim().toLowerCase()
    );
}

const commands = {
    nul: function() {
        return String.fromCharCode(0x00);
    },

    clearscreen: function() {
        return String.fromCharCode(0x01, 0x21);
    },

    clearbol: function() {
        return String.fromCharCode(0x01, 0x29);
    },

    cleareol: function() {
        return String.fromCharCode(0x01, 0x28);
    },

    clearbod: function() {
        return String.fromCharCode(0x01, 0x2b);
    },

    cleareod: function() {
        return String.fromCharCode(0x01, 0x2a);
    },

    clearline: function() {
        return String.fromCharCode(0x01, 0x2d);
    },

    clearchars: function(count) {
        return String.fromCharCode(0x01, 0x30 + interpretNumber(count));
    },

    foreground: function(color) {
        return String.fromCharCode(0x02, 0x40 + interpretNumber(color));
    },

    background: function(color) {
        return String.fromCharCode(0x02, 0x50 + interpretNumber(color));
    },

    locate: function(x, y) {
        return String.fromCharCode(
            0x04,
            0x30 + interpretNumber(y),
            0x30 + interpretNumber(x)
        );
    },

    reset: function() {
        return String.fromCharCode(0x05, 0x2a);
    },

    underline: function(state) {
        if (interpretBoolean(state)) {
            return String.fromCharCode(0x05, 0x55);
        } else {
            return String.fromCharCode(0x05, 0x75);
        }
    },

    blink: function(state) {
        if (interpretBoolean(state)) {
            return String.fromCharCode(0x05, 0x42);
        } else {
            return String.fromCharCode(0x05, 0x62);
        }
    },

    highlight: function(state) {
        if (interpretBoolean(state)) {
            return String.fromCharCode(0x05, 0x48);
        } else {
            return String.fromCharCode(0x05, 0x68);
        }
    },

    reverse: function(state) {
        if (interpretBoolean(state)) {
            return String.fromCharCode(0x05, 0x52);
        } else {
            return String.fromCharCode(0x05, 0x72);
        }
    },

    size: function(state) {
        state = state.trim().toLowerCase();

        if (state === 'normal') {
            return String.fromCharCode(0x05, 0x30);
        } else if (state == 'doublewidth') {
            return String.fromCharCode(0x05, 0x31);
        } else if (state == 'doubleheight') {
            return String.fromCharCode(0x05, 0x32);
        } else if (state == 'double') {
            return String.fromCharCode(0x05, 0x33);
        } else {
            throw new Error(
                "Expected normal, doublewidth, doubleheight or double"
            );
        }
    },

    cursor: function(state) {
        if (interpretBoolean(state)) {
            return String.fromCharCode(0x06, 0x43);
        } else {
            return String.fromCharCode(0x06, 0x63);
        }
    },

    mouse: function(state) {
        if (interpretBoolean(state)) {
            return String.fromCharCode(0x19, 0x41);
        } else {
            return String.fromCharCode(0x19, 0x40);
        }
    },

    mousecursor: function(cursorNumber) {
        return String.fromCharCode(
            0x19, 0x30 | (interpretNumber(cursorNumber) & 0x07)
        )
    },

    scroll: function(direction) {
        direction = direction.trim().toLowerCase();

        if (direction === 'up') {
            return String.fromCharCode(0x0b);
        } else if (direction === 'down') {
            return String.fromCharCode(0x0c);
        } else {
            throw new Error("Expected up or down");
        }
    },

    go: function(direction) {
        direction = direction.trim().toLowerCase();

        if (direction === 'up') {
            return String.fromCharCode(0x06, 0x75);
        } else if (direction === 'right') {
            return String.fromCharCode(0x06, 0x72);
        } else if (direction === 'down') {
            return String.fromCharCode(0x06, 0x64);
        } else if (direction === 'left') {
            return String.fromCharCode(0x06, 0x6c);
        } else {
            throw new Error("Expected up, down, left or right");
        }
    },

    move: function(direction) {
        direction = direction.trim().toLowerCase();

        if (direction === 'up') {
            return String.fromCharCode(0x0e);
        } else if (direction === 'right') {
            return String.fromCharCode(0x11);
        } else if (direction === 'down') {
            return String.fromCharCode(0x0f);
        } else if (direction === 'left') {
            return String.fromCharCode(0x10);
        } else {
            throw new Error("Expected up, down, left or right");
        }
    },

    repeat: function(count) {
        count = interpretNumber(count);
        if (count > 0 && count < 256 - 32) {
            return String.fromCharCode(0x12, 0x20 + count);
        } else {
            throw new Error("Expected count between 1 and 223");
        }

    },

    charpage: function(page) {
        page = interpretNumber(page);

        if (page >= 0 && page <= 4) {
            return String.fromCharCode(0x13 + page);
        } else {
            throw new Error("Expected 0, 1, 2, 3 or 4");
        }
    },

    print: function(string) {
        return applyEscapedSequence(string);
    },
}

function splitCommand(command) {
    const INIT = 0;
    const LITERAL = 1;
    const STRING = 2;
    const ESCAPE = 3;
    const SPACES = [ ' ', '\t' ];
    const COMMENT_START = '#';
    const STRING_START = '"';
    const STRING_ESCAPE= '\\';

    const elements = []
    let state = INIT;
    let currentChar = "";
    let currentArgument = "";
    for (let index = 0; index < command.length; index++) {
        currentChar = command.substring(index, index + 1);

        if (state === INIT) {
            if (currentChar === COMMENT_START) {
                break;
            } else if (currentChar === STRING_START) {
                state = STRING;
            } else if (SPACES.includes(currentChar)) {
                state = INIT;
            } else {
                currentArgument = currentChar;
                state = LITERAL;
            }
        } else if (state === LITERAL) {
            if (currentChar === COMMENT_START) {
                break;
            } else if (SPACES.includes(currentChar)) {
                elements.push(currentArgument);
                currentArgument = "";
                state = INIT;
            } else {
                currentArgument += currentChar;
                state = LITERAL;
            }
        } else if (state === STRING) {
            if (currentChar === STRING_ESCAPE) {
                currentArgument += currentChar;
                state = ESCAPE;
            } else if (currentChar === STRING_START) {
                elements.push(currentArgument);
                currentArgument = "";
                state = INIT;
            } else {
                currentArgument += currentChar;
                state = STRING;
            }
        } else if (state === ESCAPE) {
            currentArgument += currentChar;
            state = STRING;
        }
    }

    if (currentArgument !== "") elements.push(currentArgument);

    return elements
}

function compileStream(sourceCode) {
    stream = "";
    sourceCode.split(/ *\r?\n */).forEach((command, line) => {
        let args = splitCommand(command);

        // Ignores empty lines or comments
        if (args.length == 0) return;

        let instruction = args[0].toLowerCase()
        args.shift();
        
        if (commands[instruction] === undefined) {
            throw new Error("Unknown instruction: " + instruction);
        }

        try {
            stream += commands[instruction](...args);
        } catch (err) {
            console.log(
                err.toString() +
                " (instruction " + instruction + ", line " + line + ")"
            );
        }
    });

    return stream;
}
