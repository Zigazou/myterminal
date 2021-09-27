class MyTerminalHiRes {
    constructor(column, row, width, height) {
        this.column = 0
        this.row = 0
        this.width = 4
        this.height = 5
        this.setPosition(column, row)
        this.setSize(width, height)
    }

    setPosition(column, row) {
        this.column = Math.max(0, Math.min(79, column))
        this.row = Math.max(0, Math.min(50, row))
        this.setSize(this.width, this.height)
    }

    setSize(width, height) {
        width = Math.floor(Math.max(4, width) / 4) * 4
        height = Math.floor(Math.max(5, height) / 5) * 5

        if (this.column + width / 4 > 80) {
            this.width = (80 - this.column) * 4
        } else {
            this.width = width
        }

        if (this.row + height / 5 > 51) {
            this.height = (51 - this.row) * 5
        } else {
            this.height = height
        }
    }

    convert(context) {
        const textWidth = this.width / 4
        const textHeight = this.height / 5

        let sequences = []

        let oldFront = -1
        let oldBack = -1
        let sequence = []
        for (let height = 0; height < textHeight; height++) {
            sequence = [ 0x18 ]

            for (let width = 0; width < textWidth; width++) {
                let imageData = context.getImageData(
                    width * 4, height * 5, 4, 5
                ).data

                let pixels = []
                for (let i = 0; i < imageData.length; i += 4) {
                    pixels.push(
                        MyTerminalHiRes.findClosestInPalette([
                            imageData[i],
                            imageData[i + 1],
                            imageData[i + 2]
                        ])
                    )
                }

                let [back, front] = MyTerminalHiRes.twoColors(pixels)

                let twoColorsPixels = []
                for (let i = 0; i < pixels.length; i++) {
                    twoColorsPixels.push(
                        MyTerminalHiRes.backOrFront(pixels[i], back, front)
                    )
                }

                let byte0 = 
                    128 +
                    twoColorsPixels[0] * 64 +
                    twoColorsPixels[1] * 32 +
                    twoColorsPixels[2] * 16 +
                    twoColorsPixels[3] * 8 +
                    twoColorsPixels[4] * 4 +
                    twoColorsPixels[5] * 2 +
                    twoColorsPixels[6]

                let byte1 = 
                    128 +
                    twoColorsPixels[7] * 64 +
                    twoColorsPixels[8] * 32 +
                    twoColorsPixels[9] * 16 +
                    twoColorsPixels[10] * 8 +
                    twoColorsPixels[11] * 4 +
                    twoColorsPixels[12] * 2 +
                    twoColorsPixels[13]

                let byte2 =
                    128 +
                    twoColorsPixels[14] * 32 +
                    twoColorsPixels[15] * 16 +
                    twoColorsPixels[16] * 8 +
                    twoColorsPixels[17] * 4 +
                    twoColorsPixels[18] * 2 +
                    twoColorsPixels[19]

                if (oldBack != back) {
                    sequence.push(0x02)
                    sequence.push(0x50 + back)
                    oldBack = back
                }

                if (oldFront != front) {
                    sequence.push(0x02)
                    sequence.push(0x40 + front)
                    oldFront = front
                }

                sequence.push(byte0)
                sequence.push(byte1)
                sequence.push(byte2)
            }

            sequences.push(sequence)
        }

        const output = []
        let row = this.row
        sequences.forEach(sequence => {
            output.push(0x04)
            output.push(0x30 + row)
            output.push(0x30 + this.column)
            sequence.forEach(byte => {
                output.push(byte)
            })
            row++
        })

        return new Uint8Array(output)
    }
}

MyTerminalHiRes.PALETTE = [
    [ 0, 0, 0 ],
    [ 128, 0, 0 ],
    [ 0, 128, 0 ],
    [ 128, 128, 0 ],
    [ 0, 0, 128 ],
    [ 128, 0, 128 ],
    [ 0, 128, 128 ],
    [ 192, 192, 192 ],
    [ 128, 128, 128 ],
    [ 255, 0, 0 ],
    [ 0, 255, 0 ],
    [ 255, 255, 0 ],
    [ 0, 0, 255 ],
    [ 255, 0, 255 ],
    [ 0, 255, 255 ],
    [ 255, 255, 255 ]
]

MyTerminalHiRes.colorDistance =
    (color1, color2) => Math.pow(color1[0] - color2[0], 2) +
                        Math.pow(color1[1] - color2[1], 2) +
                        Math.pow(color1[2] - color2[2], 2)

MyTerminalHiRes.findClosestInPalette = function (color) {
    let bestDistance = 3 * Math.pow(256, 2)
    let bestIndex = -1

    for (let index = 0; index < 16; index++) {
        let distance = MyTerminalHiRes.colorDistance(
            color,
            MyTerminalHiRes.PALETTE[index]
        )

        if (distance < bestDistance) {
            bestDistance = distance
            bestIndex = index
        }
    }

    return bestIndex
}

MyTerminalHiRes.twoColors = function(colors) {
    const levels = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
    let firstColor = -1
    let secondColor = -1

    colors.forEach(color => { levels[color]++ })

    levels.forEach((count, color) => {
        if (firstColor == -1 || count > levels[firstColor]) {
            secondColor = firstColor
            firstColor = color
        } else if (secondColor == -1 || count > levels[secondColor]) {
            secondColor = color
        }
    })

    return [ firstColor, secondColor ]
}

MyTerminalHiRes.backOrFront = (color, back, front) => {
    return (Math.abs(back - color) < Math.abs(front - color)) ? 0 : 1
}
