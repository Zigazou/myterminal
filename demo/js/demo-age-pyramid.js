function demoAgePyramid(myTerminal) {
    function center(string, width) {
        if (string.length >= width) {
            return string.substr(0, width)
        } else {
            const remain = width - string.length
            return (
                " ".repeat(Math.ceil(remain / 2)) +
                string +
                " ".repeat(Math.floor(remain / 2))
            )
        }
    }

    myTerminal.write(myCode()
        .resetAttributes()
        .cursor(false)
        .background(2)
        .foreground(15)
        .clearScreen()
        .background(4)
        .clearEndOfLine()
        .print("Age pyramid demo\n")
        .background(2)
        .characterPage(3)
        .print("P".repeat(80))
        .characterPage(0)
    )

    const francePopulation2020 = {
        labels: [
            '0-2', '3-5', '6-8', '9-11', '12-14', '15-17', '18-20', '21-23', 
            '24-26', '27-29', '30-32', '33-35', '36-38', '39-41', '42-44', 
            '45-47', '48-50', '51-53', '54-56', '57-59', '60-62', '63-65', 
            '66-68', '69-71', '72-74', '75-77', '78-80', '81-83', '84-86', 
            '87-89', '90-92', '93-95', '96-98', '99-101', '102-104', '105+'
        ],
        male: [
            1046287, 1129544, 1196617, 1234467, 1226853, 1217031, 1209184, 
            1102825, 1039280, 1096544, 1137220, 1161074, 1201592, 1198524, 
            1163001, 1291079, 1302411, 1257024, 1267809, 1206140, 1157727, 
            1105011, 1066195, 1055731, 880102, 629904, 505173, 452227, 353248, 
            253110, 139091, 65673, 24264, 5436, 820, 638
        ],
        female: [
            1003575, 1085380, 1142765, 1179592, 1171898, 1155076, 1143048, 
            1072415, 1044378, 1122848, 1196731, 1228878, 1259057, 1245324, 
            1188265, 1315829, 1322722, 1296911, 1326992, 1278948, 1259236, 
            1230655, 1196366, 1204031, 1029874, 767440, 663365, 650340, 
            584712, 491668, 332318, 199331, 95523, 26715, 4832, 2060
        ],
    }

    const width = 27
    const maximum = Math.max(
        Math.max(...francePopulation2020.male),
        Math.max(...francePopulation2020.female)
    )

        const vpos = 4

    for (let i = 0; i < francePopulation2020.labels.length; i++) {
        let malePercent = francePopulation2020.male[i] / maximum
        let femalePercent = francePopulation2020.female[i] / maximum
        myTerminal.write(myCode()
            .foreground(11)
            .locate(35, vpos + francePopulation2020.labels.length - i)
            .gauge(width, malePercent, WEST, false)
            .foreground(14)
            .locate(45, vpos + francePopulation2020.labels.length - i)
            .gauge(width, femalePercent, EAST, false)
            .foreground(7)
            .locate(35 - 6 - width * malePercent, vpos + francePopulation2020.labels.length - i)
            .print(String(francePopulation2020.male[i]).padStart(7))
            .foreground(7)
            .locate(45 + 1 + width * femalePercent, vpos + francePopulation2020.labels.length - i)
            .print(String(francePopulation2020.female[i]))
            .foreground(9)
            .locate(37, vpos + francePopulation2020.labels.length - i)
            .print(center(francePopulation2020.labels[i], 7))
        )
    }

    myTerminal.write(myCode()
        .locate(23 , vpos + francePopulation2020.labels.length + 2)
        .size(SIZE_DOUBLE)
        .foreground(15)
        .print("FRANCE POPULATION")
        .locate(25 , vpos + francePopulation2020.labels.length + 4)
        .size(SIZE_DOUBLE_WIDTH)
        .foreground(7)
        .print("January 1, 2020")
        .locate(5, vpos + francePopulation2020.labels.length + 5)
        .size(SIZE_NORMAL)
        .foreground(10)
        .print("Source: Insee, estimations de population ")
        .print("(résultats arrêtés fin 2019)")
    )
}
