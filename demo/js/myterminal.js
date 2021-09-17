const NORTH = 0
const EAST = 1
const SOUTH = 2
const WEST = 3

const SIZE_NORMAL = 0
const SIZE_DOUBLE_WIDTH = 1
const SIZE_DOUBLE_HEIGHT = 2
const SIZE_DOUBLE = 3

const FUNCTION_AND = 0
const FUNCTION_OR = 1
const FUNCTION_XOR = 2
const FUNCTION_BORDER = 3

const FILLED = true
const NOT_FILLED = false

class RawCode {
    constructor(bytes) {
        this.bytes = bytes;
    }

    getArrayBuffer() {
        return this.bytes.buffer;
    }
}

class LineBreakTransformer {
    constructor() {
        // A container for holding stream data until a new line.
        this.chunks = ""
    }

    transform(chunk, controller) {
        // Append new chunks to existing chunks.
        this.chunks += chunk
        // For each line breaks in chunks, send the parsed lines out.
        const lines = this.chunks.split("\r\n")
        this.chunks = lines.pop()
        lines.forEach((line) => controller.enqueue(line))
    }

    flush(controller) {
        controller.enqueue(this.chunks)
    }
}

class MyCode {
    constructor() {
        this.string = ""
    }

    getArrayBuffer() {
        const buffer = new ArrayBuffer(this.string.length)
        const bufferView = new Uint8Array(buffer)
        for (let index = 0; index < this.string.length; index++) {
            bufferView[index] = this.string.charCodeAt(index)
        }
    
        return buffer
    }

    locate(x, y) {
        this.string += (
            "\x04" +
            String.fromCharCode(0x30 + y) + 
            String.fromCharCode(0x30 + x)
        )

        return this
    }

    clearScreen() {
        this.string += "\x01!"
        return this
    }

    clearBeginningOfLine() {
        this.string += "\x01)"
        return this
    }

    clearEndOfLine() {
        this.string += "\x01("
        return this
    }

    clearBeginningOfDisplay() {
        this.string += "\x01+"
        return this
    }

    clearEndOfDisplay() {
        this.string += "\x01*"
        return this
    }

    clearChars(count) {
        this.string += "\x01" + String.fromCharCode(0x30 + count)
        return this
    }

    foreground(color) {
        this.string += "\x02" + String.fromCharCode(0x40 + (color & 0x0f))
        return this
    }

    background(color) {
        this.string += "\x02" + String.fromCharCode(0x50 + (color & 0x0f))
        return this
    }

    resetAttributes() {
        this.string += "\x05*"
        return this
    }

    underline(state) {
        this.string += "\x05" + (state ? "U" : "u")
        return this
    }

    blink(state) {
        this.string += "\x05" + (state ? "B" : "b")
        return this
    }

    highlight(state) {
        this.string += "\x05" + (state ? "H" : "h")
        return this
    }

    reverse(state) {
        this.string += "\x05" + (state ? "R" : "r")
        return this
    }

    size(value) {
        this.string += "\x05" + String.fromCharCode(0x30 + (value & 0x03))
        return this
    }

    cursor(state) {
        this.string += "\x06" + (state ? "C" : "c")
        return this
    }

    characterPage(page) {
        switch(page) {
            case 0: this.string += "\x13"; break
            case 1: this.string += "\x14"; break
            case 2: this.string += "\x15"; break
            case 3: this.string += "\x16"; break
            case 4: this.string += "\x17"; break
        }

        return this
    }

    mouse(state) {
        this.string += "\x19" + (state ? "A" : "@")
        return this
    }

    mouseCursor(cursor) {
        this.string += "\x19" + String.fromCharCode(0x30 | (cursor & 0x07))
        return this
    }

    applyPattern(patternId, functionId) {
        this.print(String.fromCharCode(0x03))
            .print(String.fromCharCode(0x40 | functionId | (patternId * 4)))

        return this
    }

    stopPattern() {
        return this.applyPattern(0, 0)
    }

    frame(offset, column, row, width, height) {
        this.characterPage(2)
            .locate(column, row)
            .print(String.fromCharCode(offset + 0x06))
            .print(String.fromCharCode(offset + 0x0a).repeat(width - 2))
            .print(String.fromCharCode(offset + 0x0c))

        for(let i = 0; i < height - 2; i++) {
            this.locate(column, row + i + 1)
                .print(String.fromCharCode(offset + 0x05))
                .clearChars(width - 2)
                .locate(column + width - 1, row + i + 1)
                .print(String.fromCharCode(offset + 0x05))
        }

        this.locate(column, row + height - 1)
            .print(String.fromCharCode(offset + 0x03))
            .print(String.fromCharCode(offset + 0x0a).repeat(width - 2))
            .print(String.fromCharCode(offset + 0x09))

        this.characterPage(0)

        return this
    }

    lightFrame(column, row, width, height) {
        return this.frame(0x20, column, row, width, height)
    }

    strongFrame(column, row, width, height) {
        return this.frame(0x40, column, row, width, height)
    }

    doubleFrame(column, row, width, height) {
        return this.frame(0x30, column, row, width, height)
    }

    bubble(filled, column, row, width, height, pointerOffset, pointerDirection) {
        const pointers = (filled
            ? [0x4f, 0x4d, 0x4e, 0x4c]
            : [0x4b, 0x49, 0x4a, 0x48]       
        ).map(charCode => String.fromCharCode(charCode))

        const lines = [0x59, 0x40, 0x50, 0x47].map(
            charCode => String.fromCharCode(charCode)
        )

        this.characterPage(3)

        for (let y = 0; y < height; y++) {
            this.locate(column, row + y)
            if (filled) {
                this.print(String.fromCharCode(0xc9).repeat(width))
            } else {
                this.clearChars(width)
            }
        }

        for (let y = 0; y < height; y++) {
            this.locate(column + width, row + y)
                .print(lines[EAST])
                .locate(column - 1, row + y)
                .print(lines[WEST])
        }

        this.locate(column, row - 1)
            .print(lines[NORTH].repeat(width))
            .locate(column, row + height)
            .print(lines[SOUTH].repeat(width))

        switch(pointerDirection) {
            case NORTH:
                this.locate(column + pointerOffset, row - 1)
                break
            case EAST:
                this.locate(column + width, row + pointerOffset)
                break
            case SOUTH:
                this.locate(column + offset, row + height)
                break
            case WEST:
                this.locate(column - 1, row + pointerOffset)
                break
        }
        this.print(pointers[pointerDirection])

        this.characterPage(0)
        return this
    }

    gauge(width, percent, orientation=EAST, joint=true) {
        const offset = joint ? [ 0xc0, 0xa0, 0xe0, 0xb0 ][orientation]
                             : [ 0xd0, 0xa8, 0xf0, 0xb8 ][orientation]
        const vertical = orientation == NORTH || orientation == SOUTH
        const divisions= vertical ? 11 : 9
        const barCount = Math.round(percent * width * divisions)
        const totalSteps = width * divisions

        this.characterPage(3)

        let remain = barCount
        for (let i = 0; i < width; i++) {
            if (remain == 0) {
                this.print(String.fromCharCode(0xff))
            } else if (remain >= divisions) {
                this.print(String.fromCharCode(offset + divisions - 2))
            } else {
                this.print(String.fromCharCode(offset + remain - 1))
            }

            switch(orientation) {
                case NORTH:
                    this.print(String.fromCharCode(0x10, 0x0e))
                    break
                case SOUTH:
                    this.print(String.fromCharCode(0x10, 0x0f))
                    break
                case WEST:
                    this.print(String.fromCharCode(0x10, 0x10))
            }

            remain = Math.max(remain - divisions, 0)
        }

        this.characterPage(0)

        return this
    }

    progressBar(width, percent) {
        // There are:
        // - 7 possible steps for the starting part
        // - 9 possible steps for each intermediate part
        // - 6 possible steps for the ending part
        const totalStartSteps = 7
        const totalMiddleSteps = 9
        const totalEndSteps = 6
        const totalSteps = totalStartSteps + (width - 2) * totalMiddleSteps + totalEndSteps

        const steps = Math.round(percent * totalSteps)
        const startSteps = steps < totalStartSteps ? steps : 6

        this.characterPage(4)
            .print(String.fromCharCode(0x40 + startSteps))

        let remainingSteps = steps - startSteps
        for (let i = 0; i < width - 2; i++) {
            if (remainingSteps == 0) {
                this.print(String.fromCharCode(0x47))
            } else if (remainingSteps >= totalMiddleSteps) {
                this.print(String.fromCharCode(0x4f))
            } else {
                this.print(String.fromCharCode(0x47 + remainingSteps))
            }

            remainingSteps = Math.max(remainingSteps - totalMiddleSteps, 0)
        }

        this.print(String.fromCharCode(0x50 + remainingSteps))
            .characterPage(0)

        return this
    }

    repeat(character, count) {
        return this.print(character.repeat(count))
    }

    print(string) {
        this.string += string
        return this
    }
}

class MyTerminalChar {
    constructor(byte) {
        this.char = String.fromCharCode(byte)
    }
    
    toString() {
        return this.char
    }
}

class MyTerminalKeyModifiers {
    constructor(byte) {
        this.meta = (byte & 0x10) !== 0
        this.altgr = (byte & 0x08) !== 0
        this.alt = (byte & 0x04) !== 0
        this.ctrl = (byte & 0x02) !== 0
        this.shift = (byte & 0x01) !== 0
    }

    toString() {
        const modifiers = []
        if (this.meta) modifiers.push("meta")
        if (this.altgr) modifiers.push("altgr")
        if (this.alt) modifiers.push("alt")
        if (this.ctrl) modifiers.push("ctrl")
        if (this.shift) modifiers.push("shift")
    
        return "[" + modifiers.join(', ') + "]"
    }
}

class MyTerminalKey {
    static INSERT = 0xe0
    static HOME = 0xe1
    static PAGE_UP = 0xe2
    static DELETE = 0xe3
    static END = 0xe4
    static PAGE_DOWN = 0xe5
    static UP = 0xe6
    static LEFT = 0xe7
    static DOWN = 0xe8
    static RIGHT = 0xe9
    static CONTEXTUAL = 0xea
    static PAUSE = 0xeb
    static SCROLL = 0xf0
    static F1 = 0xf1
    static F2 = 0xf2
    static F3 = 0xf3
    static F4 = 0xf4
    static F5 = 0xf5
    static F6 = 0xf6
    static F7 = 0xf7
    static F8 = 0xf8
    static F9 = 0xf9
    static F10 = 0xfa
    static F11 = 0xfb
    static F12 = 0xfc
    static PRNT_SCR = 0xff

    static NAMES = {
        0xe0: "INSERT",
        0xe1: "HOME",
        0xe2: "PAGE_UP",
        0xe3: "DELETE",
        0xe4: "END",
        0xe5: "PAGE_DOWN",
        0xe6: "UP",
        0xe7: "LEFT",
        0xe8: "DOWN",
        0xe9: "RIGHT",
        0xea: "CONTEXTUAL",
        0xeb: "PAUSE",
        0xf0: "SCROLL",
        0xf1: "F1",
        0xf2: "F2",
        0xf3: "F3",
        0xf4: "F4",
        0xf5: "F5",
        0xf6: "F6",
        0xf7: "F7",
        0xf8: "F8",
        0xf9: "F9",
        0xfa: "F10",
        0xfb: "F11",
        0xfc: "F12",
        0xff: "PRNT_SCR"
    }

    constructor(byte1, byte2) {
        this.key = byte2
        this.modifiers = new MyTerminalKeyModifiers(byte1)
    }

    toString() {
        return MyTerminalKey.NAMES[this.key] + this.modifiers.toString()
    }
}

class MyTerminalMouseModifiers {
    constructor(byte) {
        this.meta = (byte & 0x40) !== 0
        this.alt = (byte & 0x20) !== 0
        this.ctrl = (byte & 0x10) !== 0
        this.shift = (byte & 0x08) !== 0
        this.middle = (byte & 0x04) !== 0
        this.right = (byte & 0x02) !== 0
        this.left = (byte & 0x01) !== 0
    }

    toString() {
        const modifiers = []
        if (this.meta) modifiers.push("meta")
        if (this.altgr) modifiers.push("altgr")
        if (this.alt) modifiers.push("alt")
        if (this.ctrl) modifiers.push("ctrl")
        if (this.shift) modifiers.push("shift")
    
        return "[" + modifiers.join(', ') + "]"
    }
}

class MyTerminalMouse {
    constructor(byte1, byte2, byte3) {
        this.x = byte1 & 0x7F
        this.y = byte2 & 0x7F
        this.modifiers = new MyTerminalMouseModifiers(byte3)
    }

    toString() {
        return '(' + this.x + ', ' + this.y + ')' + this.modifiers.toString()
    }
}

class MyTerminalTransformer {
    static STATE_INIT = 0
    static STATE_EXTENDED_KEY_1 = 1
    static STATE_EXTENDED_KEY_2 = 2
    static STATE_MOUSE_X = 3
    static STATE_MOUSE_Y = 4
    static STATE_MOUSE_MODIFIERS = 5

    static START_EXTENDED_KEY = 0x1f
    static START_MOUSE = 0x1e

    constructor() {
        this.state = MyTerminalTransformer.STATE_INIT
        this.resetBytes()
    }

    start() {
        // Nothing to do
    }

    resetBytes() {
        this.byte2 = 0
        this.byte3 = 0
    }

    readByte(byte, controller) {
        if (this.state === MyTerminalTransformer.STATE_INIT) {
            this.resetBytes()

            if (byte === MyTerminalTransformer.START_MOUSE) {
                this.state = MyTerminalTransformer.STATE_MOUSE_X
            } else if (byte === MyTerminalTransformer.START_EXTENDED_KEY) {
                this.state = MyTerminalTransformer.STATE_EXTENDED_KEY_1
            } else {
                controller.enqueue(new MyTerminalChar(byte))
                this.state = MyTerminalTransformer.STATE_INIT
            }
        } else if (this.state === MyTerminalTransformer.STATE_EXTENDED_KEY_1) {
            this.byte2 = byte
            this.state = MyTerminalTransformer.STATE_EXTENDED_KEY_2
        } else if (this.state === MyTerminalTransformer.STATE_EXTENDED_KEY_2) {
            controller.enqueue(new MyTerminalKey(this.byte2, byte))
            this.state = MyTerminalTransformer.STATE_INIT
        } else if (this.state === MyTerminalTransformer.STATE_MOUSE_X) {
            this.byte2 = byte
            this.state = MyTerminalTransformer.STATE_MOUSE_Y
        } else if (this.state === MyTerminalTransformer.STATE_MOUSE_Y) {
            this.byte3 = byte
            this.state = MyTerminalTransformer.STATE_MOUSE_MODIFIERS
        } else if (this.state === MyTerminalTransformer.STATE_MOUSE_MODIFIERS) {
            controller.enqueue(
                new MyTerminalMouse(this.byte2, this.byte3, byte)
            )
            this.state = MyTerminalTransformer.STATE_INIT
        }
    }

    transform(chunk, controller) {
        chunk.forEach(byte => { return this.readByte(byte, controller) } )
    }

    flush() {
        // Nothing to do
    }
}

class MyTerminal {
    static BAUDRATE = 3000000
    static FLOWCONTROL = "hardware"

    constructor() {
        this.serialPort = null
        this.writer = null
        this.reader = null
        this.onInput = null
    }    

    async connect() {
        if (this.serialPort == null) {
            this.serialPort = await navigator.serial.requestPort()
            await this.serialPort.open({
                baudRate: MyTerminal.BAUDRATE,
                flowControl: MyTerminal.FLOWCONTROL,
            })
            this.writer = this.serialPort.writable.getWriter()
            this.reader = this.serialPort.readable
              .pipeThrough(new TransformStream(new MyTerminalTransformer()))
              .getReader()

            this.listen()
        }
    }

    async listen() {
        try {
            while (true) {
                const { value, done } = await this.reader.read()
                if (!done && this.onInput != null) this.onInput(value)
            }
        } catch (error) {
            console.log(error)
        } finally {
            this.reader.releaseLock()
        }
    }

    write(myCode) {
        try {
            this.writer.write(myCode.getArrayBuffer())
        } catch (error) {
            console.log(error)
        }
    }
}

function myCode() {
    return new MyCode()
}
