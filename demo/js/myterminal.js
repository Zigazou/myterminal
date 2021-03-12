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

class MyTerminal {
    static BAUDRATE = 3000000

    constructor() {
        this.serialPort = null
        this.writer = null
    }    

    async connect() {
        if (this.serialPort == null) {
            this.serialPort = await navigator.serial.requestPort()
            await this.serialPort.open({ baudRate: MyTerminal.BAUDRATE })
            this.writer = this.serialPort.writable.getWriter()
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