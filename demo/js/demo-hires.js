/* exported demoHires */
function BMFastPixelArtLine(ctx, x1, y1, x2, y2) {
    x1 = Math.round(x1);
    y1 = Math.round(y1);
    x2 = Math.round(x2);
    y2 = Math.round(y2);
    const dx = Math.abs(x2 - x1);
    const sx = x1 < x2 ? 1 : -1;
    const dy = Math.abs(y2 - y1);
    const sy = y1 < y2 ? 1 : -1;
    var error, len, rev, count = dx;
    ctx.beginPath();
    if (dx > dy) {
        error = dx / 2;
        rev = x1 > x2 ? 1 : 0;
        if (dy > 1) {
            error = 0;
            count = dy - 1;
            do {
                len = error / dy + 2 | 0;
                ctx.rect(x1 - len * rev, y1, len, 1);
                x1 += len * sx;
                y1 += sy;
                error -= len * dy - dx;
            } while (count--);
        }
        if (error > 0) {ctx.rect(x1, y2, x2 - x1, 1) }
    } else if (dx < dy) {
        error = dy / 2;
        rev = y1 > y2 ? 1 : 0;
        if (dx > 1) {
            error = 0;
            count --;
            do {
                len = error / dx + 2 | 0;
                ctx.rect(x1 ,y1 - len * rev, 1, len);
                y1 += len * sy;
                x1 += sx;
                error -= len * dx - dy;
            } while (count--);
        }
        if (error > 0) { ctx.rect(x2, y1, 1, y2 - y1) }
    } else {
        do {
            ctx.rect(x1, y1, 1, 1);
            x1 += sx;
            y1 += sy;
        } while (count --); 
    }
    ctx.fill();
}

function updateGraph(myTerminal) {
    const aCanvas = document.createElement('canvas')
    aCanvas.width = 240
    aCanvas.height = 200

    const ctx = aCanvas.getContext('2d')
    ctx.imageSmoothingEnabled = false

    ctx.beginPath()
    ctx.fillStyle = '#007f00'
    ctx.rect(0, 0, aCanvas.width, aCanvas.height)
    ctx.fill()

    ctx.beginPath()
    ctx.fillStyle = '#ffffff'
    BMFastPixelArtLine(
        ctx,
        0, aCanvas.height - 5,
        aCanvas.width, aCanvas.height - 5
    )

    BMFastPixelArtLine(
        ctx,
        3, 0,
        3, aCanvas.height - 1
    )

    let px = 4
    let py = Math.floor((aCanvas.height - 5) * Math.random())
    let y = 0
    ctx.fillStyle = '#ffff00'
    for (let x = px + 5; x < aCanvas.width; x += 5) {
        y = Math.max(
            0,
            Math.min(
                aCanvas.height - 6,
                Math.floor(py + (0.5 - Math.random()) * aCanvas.height / 3)
            )
        )

        BMFastPixelArtLine(ctx, px, py, x, y)
        px = x
        py = y
    }


    px = 4
    py = Math.floor((aCanvas.height - 5) * Math.random())
    y = 0
    ctx.fillStyle = '#ff00ff'
    for (let x = px + 5; x < aCanvas.width; x += 5) {
        y = Math.max(
            0,
            Math.min(
                aCanvas.height - 6,
                Math.floor(py + (0.5 - Math.random()) * aCanvas.height / 3)
            )
        )

        BMFastPixelArtLine(ctx, px, py, x, y)
        px = x
        py = y
    }

    const hires = new MyTerminalHiRes(8, 5, aCanvas.width, aCanvas.height)
    const raw = hires.convert(ctx)

    myTerminal.write(new RawCode(raw))
}

function demoHires(myTerminal) {
    myTerminal.write(myCode()
        .resetAttributes()
        .cursor(false)
        .background(2)
        .foreground(15)
        .clearScreen()
        .background(4)
        .clearEndOfLine()
        .print("Example hi-resolution graphics\n")
        .background(2)
        .characterPage(3)
        .print("P".repeat(80))
        .characterPage(0)
        .locate(70, 5)
        .size(MyCode.SIZE_DOUBLE_HEIGHT)
        .reverse(true)
        .print("Refresh")
        .resetAttributes()
        .mouse(true)
    )

    updateGraph(myTerminal)
}
