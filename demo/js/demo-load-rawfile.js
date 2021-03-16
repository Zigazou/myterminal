function loadRawFile(myTerminal, fileList) {
    if (fileList.length !== 1) return;

    const rawFile = fileList[0];
    const reader = new FileReader();

    reader.onload = (event) => {
        const bytes = new Uint8Array(
            event.target.result
        );

        myTerminal.write(new RawCode(bytes));
    };

    reader.readAsArrayBuffer(rawFile);
}