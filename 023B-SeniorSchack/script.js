const args = process.argv.slice(2);
const input = JSON.parse(args[0]);  // Deserialisera JSON-strängen

function processInput(data) {
    return `Message: ${data.message}${data.message}, Count: ${data.count + data.count}`;
}

console.log(processInput(input));
