function demoColors(myTerminal) {
    myTerminal.write(myCode()
        .resetAttributes()
        .cursor(false)
        .background(2)
        .foreground(15)
        .clearScreen()
        .background(4)
        .clearEndOfLine()
        .print("List of colors\n")
        .background(2)
        .characterPage(3)
        .print("P".repeat(80))
        .characterPage(0)
    )

    for (let i = 0; i < 16; i++) {
        myTerminal.write(myCode()
            .resetAttributes()
            .size(3)
            .locate(i > 9 ? 29 : 30, 2 + i * 3)
            .background(i)
            .foreground(i > 6 && i != 12 ? 0 : 15)
            .print(" Color " + i + " ")
        )
    }
}
