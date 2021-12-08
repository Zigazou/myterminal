/* exported MyTerminalEditor */
class MyTerminalEditor {
    constructor() {
        this.memory = new MyTerminalMemory()
        this.myTerminal = null
        this.rows = 51
        this.columns = 80
    }

    connect(myTerminal) {
        this.write = (value) => {
            myTerminal.write(value)
        }

        myTerminal.onInput = (value) => {
            this.onMyTerminalInput(value)
        }

        this.init()
    }

    init() {
        this.write(
            myCode()
                .resetAttributes()
                .foreground(15)
                .background(0)
                .clearScreen()
                .cursor(true)
        )

        this.x = 0
        this.y = 0
        this.size = MyCode.SIZE_NORMAL
        this.foreground = 15
        this.background = 0
        this.func = MyCode.FUNCTION_AND
        this.pattern = 0
        this.underline = false
        this.inverse = false
        this.blink = 0
        this.charPage = 0
        this.selectedCharX = 0
        this.selectedCharY = 0
        this.mask = 0
    }

    onMyTerminalInput(value) {
        if (value instanceof MyTerminalKey) {
            switch (value.key) {
                case MyTerminalKey.HOME:
                    this.setPosition(0, this.y)
                    break

                case MyTerminalKey.END:
                    this.setPosition(this.columns - 1, this.y)
                    break

                case MyTerminalKey.PAGE_UP:
                    this.setPosition(this.x, 0)
                    break

                case MyTerminalKey.PAGE_DOWN:
                    this.setPosition(this.x, this.rows - 1)
                    break

                case MyTerminalKey.UP:
                    if (value.modifiers.ctrl) {
                        this.setSelectedChar(
                            this.selectedCharX,
                            this.selectedCharY - 1
                        )
                    } else {
                        this.setPosition(this.x, this.y - 1)
                    }
                    break

                case MyTerminalKey.DOWN:
                    if (value.modifiers.ctrl) {
                        this.setSelectedChar(
                            this.selectedCharX,
                            this.selectedCharY + 1
                        )
                    } else {
                        this.setPosition(this.x, this.y + 1)
                    }
                    break

                case MyTerminalKey.LEFT:
                    if (value.modifiers.ctrl) {
                        this.setSelectedChar(
                            this.selectedCharX - 1,
                            this.selectedCharY
                        )
                    } else {
                        this.setPosition(this.x - 1, this.y)
                    }
                    break

                case MyTerminalKey.RIGHT:
                    if (value.modifiers.ctrl) {
                        this.setSelectedChar(
                            this.selectedCharX + 1,
                            this.selectedCharY
                        )
                    } else {
                        this.setPosition(this.x + 1, this.y)
                    }
                    break

                case MyTerminalKey.F1:
                case MyTerminalKey.F2:
                case MyTerminalKey.F3:
                case MyTerminalKey.F4:
                    if (value.modifiers.meta) {
                        this.setPattern(value.key - MyTerminalKey.F1)
                    } else if (value.modifiers.ctrl) {
                        this.setCharPage(value.key - MyTerminalKey.F1 + 1)
                    } else if (value.modifiers.alt) {
                        this.setMask(6 - (value.key - MyTerminalKey.F1))
                    } else {
                        this.setSize(value.key - MyTerminalKey.F1)
                    }
                    break

                case MyTerminalKey.F5:
                case MyTerminalKey.F6:
                case MyTerminalKey.F7:
                case MyTerminalKey.F8:
                case MyTerminalKey.F9:
                case MyTerminalKey.F10:
                case MyTerminalKey.F11:
                case MyTerminalKey.F12:
                    if (value.modifiers.meta) {
                        this.setPattern(value.key - MyTerminalKey.F1)
                    } else if (value.modifiers.alt && value.key <= MyTerminalKey.F7) {
                        this.setMask(6 - (value.key - MyTerminalKey.F1))
                    } else {
                        this.setColor(
                            value.modifiers.ctrl,
                            value.modifiers.shift,
                            value.key - MyTerminalKey.F5 + 8
                        )
                    }
                    break
                case MyTerminalKey.PRNT_SCR:
                    if (value.modifiers.meta) {
                        this.setPattern(12)
                    } else {
                        this.setFunction(0)
                    }
                    break

                case MyTerminalKey.SCROLL:
                    if (value.modifiers.meta) {
                        this.setPattern(13)
                    } else {
                        this.setFunction(1)
                    }
                    break

                case MyTerminalKey.PAUSE:
                    if (value.modifiers.meta) {
                        this.setPattern(14)
                    } else {
                        this.setFunction(2)
                    }
                    break

                case MyTerminalKey.INSERT:
                    if (value.modifiers.alt) {
                        this.applyAttributes()
                    } else {
                        this.print(
                            String.fromCharCode(
                                0x20 +
                                this.selectedCharX * 16 +
                                this.selectedCharY
                            )
                        )
                    }
            }
        } else if (value instanceof MyTerminalChar) {
            switch (value.char) {
                case "\x02": // CTRL+b
                    this.setBlink(!this.blink)
                    break

                case "\x09": // CTRL+i
                    this.setInverse(!this.inverse)
                    break

                case "\x15": // CTRL+u
                    this.setUnderline(!this.underline)
                    break

                case "\x1b": // ESC
                    this.setCharPage(0)
                    break

                default:
                    if (value.char >= " ") {
                        this.print(value)
                    }
            }
        }
    }

    setSize(size) {
        this.size = size
        this.write(myCode().size(size))
    }

    setColor(ofBackground, halfbrite, color) {
        if (halfbrite) color = color - 8

        if (ofBackground) {
            document
                .getElementById("background-" + this.background.toString())
                .classList.remove("selected")

            document
                .getElementById("background-" + color.toString())
                .classList.add("selected")

            this.background = color
            this.write(myCode().background(color))
        } else {
            document
                .getElementById("foreground-" + this.foreground.toString())
                .classList.remove("selected")

            document
                .getElementById("foreground-" + color.toString())
                .classList.add("selected")

            this.foreground = color
            this.write(myCode().foreground(color))
        }
    }

    setCharPage(page) {
        document
            .getElementById("charpage" + this.charPage.toString())
            .classList.remove("selected")

        document
            .getElementById("charpage" + page.toString())
            .classList.add("selected")

        this.charPage = page
        this.write(myCode().characterPage(page))
    }

    setPosition(x, y) {
        this.y = Math.min(Math.max(y, 0), this.rows - 1)
        this.x = Math.min(Math.max(x, 0), this.columns - 1)
        this.write(myCode().locate(this.x, this.y))
    }

    setSelectedChar(x, y) {
        this.selectedCharY = Math.min(Math.max(y, 0), 15)
        this.selectedCharX = Math.min(Math.max(x, 0), 13)
        const selectedChar = document.getElementById("selected-char")
        selectedChar.style.setProperty("--selected-char-y", this.selectedCharY)
        selectedChar.style.setProperty("--selected-char-x", this.selectedCharX)
    }

    setUnderline(underline) {
        this.underline = underline
        this.write(myCode().underline(this.underline))
    }

    setInverse(inverse) {
        this.inverse = inverse
        this.write(myCode().reverse(this.inverse))
    }

    setBlink(blink) {
        this.blink = blink
        this.write(myCode().blink(this.blink))
    }

    setPattern(pattern) {
        document
            .getElementById("pattern" + this.pattern.toString().padStart(2, '0'))
            .classList.remove("selected")

        document
            .getElementById("pattern" + pattern.toString().padStart(2, '0'))
            .classList.add("selected")

        this.pattern = pattern

        this.write(myCode().applyPattern(this.pattern, this.func))
    }

    setFunction(func) {
        this.func = func
        this.write(myCode().applyPattern(this.pattern, this.func))
    }

    setMask(bit) {
        this.mask = this.mask ^ (1 << bit)

        document.getElementById("mask-background").checked = this.mask & 0x40
        document.getElementById("mask-foreground").checked = this.mask & 0x20
        document.getElementById("mask-pattern").checked = this.mask & 0x10
        document.getElementById("mask-function").checked = this.mask & 0x08
        document.getElementById("mask-underline").checked = this.mask & 0x04
        document.getElementById("mask-invert").checked = this.mask & 0x02
        document.getElementById("mask-blink").checked = this.mask & 0x01

        this.write(myCode().mask(this.mask))
    }

    updateCell(cell) {
        if (this.mask & 0x40) cell.background = this.background
        if (this.mask & 0x20) cell.foreground = this.foreground
        if (this.mask & 0x10) cell.pattern = this.pattern
        if (this.mask & 0x08) cell.func = this.func
        if (this.mask & 0x04) cell.underline = this.underline
        if (this.mask & 0x02) cell.invert = this.invert
        if (this.mask & 0x01) cell.blink = this.blink
    }

    applyAttributes() {
        switch (this.size) {
            case MyTerminalCell.SIZE_NORMAL:
                const cell = this.memory.getCell(this.x, this.y)
                this.updateCell(cell)
                this.x++
                this.write(myCode().repeatAttributes(1))
                break

            case MyTerminalCell.SIZE_DOUBLE_WIDTH:
                const cell_left = this.memory.getCell(this.x, this.y)
                const cell_right = this.memory.getCell(this.x + 1, this.y)
                this.updateCell(cell_left)
                this.updateCell(cell_right)
                this.x += 2
                this.write(myCode().repeatAttributes(2))
                break

            case MyTerminalCell.SIZE_DOUBLE_HEIGHT:
                const cell_top = this.memory.getCell(this.x, this.y)
                const cell_bottom = this.memory.getCell(this.x, this.y + 1)
                this.updateCell(cell_top)
                this.updateCell(cell_bottom)
                this.x++
                this.write(
                    myCode()
                        .repeatAttributes(1)
                        .moveLeft()
                        .moveDown()
                        .repeatAttributes(1)
                        .moveUp()
                )
                break

            case MyTerminalCell.SIZE_DOUBLE:
                const cell_top_left = this.memory.getCell(this.x, this.y)
                const cell_top_right = this.memory.getCell(this.x + 1, this.y)
                const cell_bottom_left = this.memory.getCell(this.x, this.y + 1)
                const cell_bottom_right = this.memory.getCell(this.x + 1, this.y + 1)
                this.updateCell(cell_top_left)
                this.updateCell(cell_bottom_left)
                this.updateCell(cell_top_right)
                this.updateCell(cell_bottom_right)
                this.x += 2
                this.write(
                    myCode()
                        .repeatAttributes(2)
                        .moveLeft()
                        .moveLeft()
                        .moveDown()
                        .repeatAttributes(2)
                        .moveUp()
                )
                break
        }
    }

    generateCell(ord) {
        const cell = new MyTerminalCell()
        cell.foreground = this.foreground
        cell.background = this.background
        cell.pattern = this.pattern
        cell.func = this.func
        cell.underline = this.underline
        cell.invert = this.invert
        cell.blink = this.blink
        cell.ord = ord
        cell.charPage = this.charPage
        cell.size = this.size
        cell.part = MyTerminalCell.PART_TOP_LEFT

        return cell
    }

    print(value) {
        const ord = value.char.charCodeAt(0)
        switch (this.size) {
            case MyTerminalCell.SIZE_NORMAL:
                const cell = this.generateCell(ord)
                this.memory.setCell(this.x, this.y, cell)
                this.x++
                break

            case MyTerminalCell.SIZE_DOUBLE_WIDTH:
                const cell_left = this.generateCell(ord)
                const cell_right = this.generateCell(ord)
                cell_right.part = MyTerminalCell.PART_TOP_RIGHT
                this.memory.setCell(this.x, this.y, cell_left)
                this.memory.setCell(this.x + 1, this.y, cell_right)
                this.x += 2
                break

            case MyTerminalCell.SIZE_DOUBLE_HEIGHT:
                const cell_top = this.generateCell(ord)
                const cell_bottom = this.generateCell(ord)
                cell_bottom.part = MyTerminalCell.PART_BOTTOM_LEFT
                this.memory.setCell(this.x, this.y, cell_top)
                this.memory.setCell(this.x, this.y + 1, cell_bottom)
                this.x++
                break

            case MyTerminalCell.SIZE_DOUBLE:
                const cell_top_left = this.generateCell(ord)
                const cell_top_right = this.generateCell(ord)
                const cell_bottom_left = this.generateCell(ord)
                const cell_bottom_right = this.generateCell(ord)
                cell_top_right.part = MyTerminalCell.PART_TOP_RIGTH
                cell_bottom_left.part = MyTerminalCell.PART_BOTTOM_LEFT
                cell_bottom_right.part = MyTerminalCell.PART_BOTTOM_RIGHT
                this.memory.setCell(this.x, this.y, cell_top_left)
                this.memory.setCell(this.x + 1, this.y, cell_top_right)
                this.memory.setCell(this.x, this.y + 1, cell_bottom_left)
                this.memory.setCell(this.x + 1, this.y + 1, cell_bottom_right)
                this.x += 2
                break
        }

        this.write(myCode().print(value))
    }

    export() {
        return this.memory.export()
    }
}