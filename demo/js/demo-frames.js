/* exported demoFrames */
function demoFrames(myTerminal) {
    myTerminal.write(myCode()
        .resetAttributes()
        .cursor(false)
        .background(2)
        .foreground(15)
        .clearScreen()
        .background(4)
        .clearEndOfLine()
        .print("Examples of frames and patterns\n")
        .background(2)
        .characterPage(3)
        .print("P".repeat(80))
        .characterPage(0)
    )

    const interestingForLight = [ 0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 12 ]
    const interestingForStrong = [ 0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 13 ]
    const interestingForDouble = [ 0, 1, 2, 3, 7, 8 ]

    for (let patternId = 0; patternId < 15; patternId++) {
        myTerminal.write(myCode()
            .locate(4 + patternId*5, 2)
            .foreground(15)
            .size(1)
            .print(String(patternId))
            .size(0)
        )

        myTerminal.write(myCode()
            .foreground(interestingForLight.includes(patternId) ? 15 : 10)
            .applyPattern(patternId, MyCode.FUNCTION_AND)
            .lightFrame(3 + patternId*5, 3, 5, 3)
            .stopPattern()
            .locate(3 + patternId*5 + 1, 4)
            .print("LIT")
        )

        myTerminal.write(myCode()
            .foreground(interestingForStrong.includes(patternId) ? 15 : 10)
            .applyPattern(patternId, MyCode.FUNCTION_AND)
            .strongFrame(3 + patternId*5, 6, 5, 3)
            .stopPattern()
            .locate(3 + patternId*5 + 1, 7)
            .print("STR")
        )

        myTerminal.write(myCode()
            .foreground(interestingForDouble.includes(patternId) ? 15 : 10)
            .applyPattern(patternId, MyCode.FUNCTION_AND)
            .doubleFrame(3 + patternId*5, 9, 5, 3)
            .stopPattern()
            .locate(3 + patternId*5 + 1, 10)
            .print("DBL")
        )

    }

    myTerminal.write(myCode()
        .background(2)
        .foreground(10)
        .bubble(MyCode.NOT_FILLED, 30, 13, 19, 2, 5, MyCode.NORTH)
        .locate(30, 13)
        .print("These combinations")
        .locate(30, 14)
        .print("are not interesting")
    )

    myTerminal.write(myCode()
        .background(2)
        .foreground(15)
        .bubble(MyCode.FILLED, 5, 13, 23, 2, 5, MyCode.NORTH)
        .reverse(true)
        .locate(5, 13)
        .print("These combinations give")
        .locate(5, 14)
        .print("interesting results")
        .reverse(false)
    )
}