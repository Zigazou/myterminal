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

    let y
    for (let i = 0; i < 16; i++) {
        y = 2 + i * 3

        myTerminal.write(myCode()
            .resetAttributes()
            .foreground(i)
            .background(2)
            .size(3)
            .characterPage(4)
        )

        myTerminal.write(myCode()
            .locate(1, y)
            .applyPattern(11, FUNCTION_AND)
            .print(String.fromCharCode(0xdf).repeat(10))
            .stopPattern()
            .print(String.fromCharCode(0xdf).repeat(19))
            .applyPattern(11, FUNCTION_AND)
            .print(String.fromCharCode(0xdf).repeat(10))
            .stopPattern()
        )

        myTerminal.write(myCode()
            .characterPage(0)
            .locate(i > 9 ? 30 : 31, y)
            .background(i)            
            .foreground(i > 6 && i != 12 ? 0 : 15)
            .print(" Color " + i + " ")
        )
    }
}
