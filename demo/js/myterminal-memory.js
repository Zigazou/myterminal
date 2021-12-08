/* exported MyTerminalCell, MyTerminalMemory */
class MyTerminalCell {
    constructor() {
        this.foreground = 15
        this.background = 0
        this.pattern = 0
        this.func = MyTerminalCell.FUNC_AND
        this.underline = false
        this.invert = false
        this.blink = MyTerminalCell.BLINK_NONE
        this.ord = 32
        this.charPage = MyTerminalCell.CHAR_PAGE_0
        this.size = MyTerminalCell.SIZE_NORMAL
        this.part = MyTerminalCell.PART_TOP_LEFT
    }
}

MyTerminalCell.SIZE_NORMAL = 0
MyTerminalCell.SIZE_DOUBLE_WIDTH = 1
MyTerminalCell.SIZE_DOUBLE_HEIGHT = 2
MyTerminalCell.SIZE_DOUBLE = 3

MyTerminalCell.PART_TOP_LEFT = 0
MyTerminalCell.PART_TOP_RIGHT = 1
MyTerminalCell.PART_BOTTOM_LEFT = 2
MyTerminalCell.PART_BOTTOM_RIGHT = 3

MyTerminalCell.FUNC_AND = 0
MyTerminalCell.FUNC_OR = 1
MyTerminalCell.FUNC_XOR = 2
MyTerminalCell.FUNC_BORDER = 3

MyTerminalCell.BLINK_NONE = 0
MyTerminalCell.BLINK_SLOW = 1
MyTerminalCell.BLINK_NORMAL = 2
MyTerminalCell.BLINK_FAST = 3

MyTerminalCell.CHAR_PAGE_0 = 0
MyTerminalCell.CHAR_PAGE_1 = 1
MyTerminalCell.CHAR_PAGE_2 = 2 
MyTerminalCell.CHAR_PAGE_3 = 3 
MyTerminalCell.CHAR_PAGE_4 = 4 

class MyTerminalMemory {
    constructor() {
        this.memory = []
        this.rows = 51
        this.columns = 80
        this.reset()
    }

    reset() {
        this.memory = []
        for (let row = 0; row < this.rows; row++) {
            this.memory[row] = []
            for (let column = 0; column < this.columns; column++) {
                this.memory[row][column] = new MyTerminalCell()
            }
        }
    }

    setCell(column, row, cell) {
        this.memory[row][column] = cell
    }

    getCell(column, row) {
        return this.memory[row][column]
    }

    export() {
        const rawMemory = new Uint8Array(this.rows * this.columns * 4)

        for (let row = 0; row < this.rows; row++) {
            for (let column = 0; column < this.columns; column++) {
                let offset = row * this.columns * 4 + column * 4
                let cell = this.memory[row][column]
                let charCode

                switch (cell.charPage) {
                    case MyTerminalCell.CHAR_PAGE_0:
                        charCode = ((0x00 << 5) + cell.ord) % 1024
                        break

                    case MyTerminalCell.CHAR_PAGE_1:
                        charCode = ((0x04 << 5) + cell.ord) % 1024
                        break

                    case MyTerminalCell.CHAR_PAGE_2:
                        charCode = ((0x0b << 5) + cell.ord) % 1024
                        break

                    case MyTerminalCell.CHAR_PAGE_3:
                        charCode = ((0x12 << 5) + cell.ord) % 1024
                        break

                    case MyTerminalCell.CHAR_PAGE_4:
                        charCode = ((0x19 << 5) + cell.ord) % 1024
                        break
                }

                rawMemory[offset + 0] = cell.background << 4
                                      | cell.foreground
                rawMemory[offset + 1] = cell.pattern << 4
                                      | cell.func << 2
                                      | (cell.underline ? 1 : 0) << 1
                                      | (cell.invert ? 1 : 0)
                rawMemory[offset + 2] = cell.blink << 6
                                      | cell.part << 4
                                      | cell.size << 2
                                      | (charCode & 0x300) >> 8
                rawMemory[offset + 3] = charCode & 0xff
            }
        }

        return rawMemory
    }
}
