const fs = require('fs');
const readline = require('readline')

async function extractTests() {
    let testsFile = __dirname + '/testsToRun.txt';
    await fs.promises.writeFile(testsFile, '');

    const lines = readline.createInterface({
        input: fs.createReadStream(__dirname + '/pr_body.txt'),
        crlfDelay: Infinity
    });

    for await (const line of lines) {
        if (line.includes('Apex::[') && line.includes(']::Apex')) {
            let testClassStartIndex = line.indexOf('Apex::[');
            let testClassEndIndex = line.indexOf(']::Apex');
            let testsToRun = line.substring(testClassStartIndex + 'Apex::['.length, testClassEndIndex);
            await fs.promises.writeFile(testsFile, testsToRun);
            await fs.promises.appendFile(testsFile, '\n');
        }
    }
}

extractTests();