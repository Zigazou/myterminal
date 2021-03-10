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
            try {
                this.serialPort = await navigator.serial.requestPort()
                await this.serialPort.open({ baudRate: MyTerminal.BAUDRATE })
                this.writer = this.serialPort.writable.getWriter()
            } catch (error) {
                console.log(error)
            }
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
