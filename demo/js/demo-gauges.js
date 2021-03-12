function demoGauges(myTerminal) {
    myTerminal.write(myCode()
        .resetAttributes()
        .cursor(false)
        .background(2)
        .foreground(15)
        .clearScreen()
        .background(4)
        .clearEndOfLine()
        .print("Examples of gauges and progress bars\n")
        .background(2)
        .characterPage(3)
        .print("P".repeat(80))
        .characterPage(0)
    )

    for (let i = 0; i < 47; i++) {
        myTerminal.write(myCode()
            .locate(15, 2 + i)
            .characterPage(3)
            .foreground(15)
            .print(String.fromCharCode(0xb1))
            .characterPage(0)
            .foreground(7)
            .applyPattern(i % 15, 0)
            .gauge(10, i / 47, EAST, false)
            .stopPattern()
            .print(String(i))
        )
    }

    for (let i = 0; i < 47; i++) {
        myTerminal.write(myCode()
            .locate(30, 2 + i)
            .foreground(7)
            .progressBar(10, i / 47)
        )
    }
}
