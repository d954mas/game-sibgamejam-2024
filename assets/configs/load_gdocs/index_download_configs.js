const fs = require('fs');
const express = require("express");
const {google} = require('googleapis');
const gdoc = require("./gdoc");

function assert(condition, message) {
    if (!condition) {
        throw new Error(message || "Assertion failed");
    }
}


//4/0AZEOvhVPZC8ONAa2wX3cZfOxYE2jUqauI1kO8nyJrwTJGzRkAWnS7ZSbLawT8JPlOg1E_w
// Load client secrets from a local file.
fs.readFile('credentials.json', (err, content) => {
    if (err) return console.log('Error loading client secret file:', err);
    // Authorize a client with credentials, then call the Google Sheets API.
    gdoc.authorize(JSON.parse(content), main);
});

const ALPHABET = [
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P"
    , "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
]

const NAME_TO_IDX = {}
const IDX_TO_NAME = {}

const TYPES = {
    number: {
        parse: function (value){
            //console.log(value)
            value = value.replaceAll(",","")
            return parseFloat(value);
        }
    },
    percent: {
        parse: function (percent) {
            assert(percent.search("%"), "not percent string:" + percent)
            return parseFloat(percent) / 100;
        }
    },
    price: {
        parse: function (price) {
            assert(price.search("$"), "not dollar string:" + price)
            if (price === ' $ -   ') return 0;
            price = price.replaceAll(",","")
            price = price.substring(2).trim()
            return parseFloat(price);
        }
    },
    duration: {
        parse: function (duration) {
            var a = duration.split(':'); // split it at the colons
            // minutes are worth 60 seconds. Hours are worth 60 minutes.
            return (+a[0]) * 60 * 60 + (+a[1]) * 60 + (+a[2]);
        }
    },
    string: {
        parse: function (string) {
            return string.toString()
        }
    },
     vector3: {
            parse: function (str) {
               const array = str.split(',').map(Number);
               // Asserts that the array must have exactly 3 elements
               if (array.length !== 3) {
                   throw new Error("Array must have exactly 3 elements.");
               }

               // Asserts that all elements in the array are numbers
               if (!array.every(element => typeof element === 'number' && !isNaN(element))) {
                   throw new Error("All elements must be numbers.");
               }

               return array;
            }
        },
}

function init_name_to_idx() {
    let idx = 0
    for (letter of ALPHABET) {
        NAME_TO_IDX[letter] = idx
		IDX_TO_NAME[idx]=letter
        idx++;
    }
    for (letter1 of ALPHABET) {
        for (letter2 of ALPHABET) {
            NAME_TO_IDX[letter1 + letter2] = idx
			IDX_TO_NAME[idx]=letter1 + letter2
            idx++;
        }
    }
    // console.log(NAME_TO_IDX)
}

init_name_to_idx()

function parse_table(rows) {
    let table_headers = []
    let row_ids = rows[0];
    let row_type = rows[1];
    assert(row_ids.length === row_type.length)
	console.log(rows)
    for (let i = 0; i < row_ids.length; i++) {
        let id = row_ids[i];
        let type = row_type[i];
        if (id !== "") {
            assert(TYPES[type], "unknown type:" + type);
            table_headers.push({
                id: id, type: type, idx: i
            })
        }
    }
    let result = [];
    for (let i = 2; i < rows.length; i++) {
        let row = rows[i];
        let item = {}
        for (header of table_headers) {
            item[header.id] = TYPES[header.type].parse(row[header.idx]);
        }
        result.push(item)
    }
    return result
}

async function download_levels(sheets, auth, spreadsheetid) {
	console.log("******LEVELS  PARSE BEGIN******")
	let rows = await gdoc.get(sheets, auth, spreadsheetid, "levels!" + "A3:C1000")
	let rows_result = parse_table(rows)
	let result = []
	for (let i = 0; i < rows_result.length; i++) {
		assert(rows_result[i].level === i + 1, " no level:" + i)
		delete rows_result[i].level
		result[i] = [rows_result[i].exp,rows_result[i].reward]
	}
	console.log("levels:" + rows_result.length);
	console.log("******LEVELS PARSE FINISH******")
	return result;
}

async function download_upgrades(sheets, auth, spreadsheetid) {
    let result = {}

    let items = [
        {id: "ATTACK", start: "A", finish: "C", value: "attack"},
        {id: "HP", start: "E", finish: "G", value: "hp"},
    ]
    for (item of items) {
        let rows = await gdoc.get(sheets, auth, spreadsheetid, "Upgrades!" + item.start + "7:" + item.finish, "1000")
        let rows_result = parse_table(rows)
        for (let i = 0; i < rows_result.length; i++) {
            assert(rows_result[i].level === i + 1, "item:" + item.id + " no level:" + i)
            delete rows_result[i].level
            if (i < rows_result.length - 1) {
                assert(rows_result[i + 1][item.value] >= rows_result[i][item.value], "item:" + item.id + " bad value level:" + (i + 1)
                + " " + rows_result[i + 1][item.value] + " < "  +  rows_result[i][item.value])
            }
        }
		//optimize json size
		for (let i = 0; i < rows_result.length; i++) {
			let old_result = rows_result[i];
			rows_result[i] = [old_result[item.value],old_result.cost]
		}
        result[item.id] = {id: item.id, value: item.value, levels: rows_result}

    }

    console.dir(result, {depth: null});
    return result
}


async function download_world(sheets, auth, spreadsheetid, table_name) {
    let result = []
    let rows = await gdoc.get(sheets, auth, spreadsheetid, table_name + "!A3:G1000")
    let rows_result = parse_table(rows)
    console.log(rows_result)

    let waveIdx = -1;
    for (let i = 0; i < rows_result.length; i++) {
        let data = rows_result[i];
        if (data.level) {
            assert(!result[data.level], "level:" + i + " already exist");
            result[data.level-1] = { location: data.location,  waves: []}
            assert(data.wave === 1, "Wave idx should start with 1. waveIdx:" + data.wave)
            waveIdx = 1;
        }
        assert(waveIdx === data.wave || waveIdx+1 === data.wave, "waveIdx:" + waveIdx + " data.wave:" + data.wave)
        waveIdx = data.wave;
        if (!result[result.length- 1].waves[waveIdx-1]) {
            result[result.length- 1].waves[waveIdx-1] = []
        }
        result[result.length- 1].waves[waveIdx-1].push({hp:data.hp,power:data.power,position:data.position,skin:data.skin})
    }

    console.dir(result, {depth: null});
    return result
}

async function download_souls(sheets, auth, spreadsheetid) {
    console.log("******SOULS  PARSE BEGIN******")
    let result = {}

    let start_column = 1
    for (let i = 0; i < 20; i++) {
        let end_column =start_column + 2;
        let rows = await gdoc.get(sheets, auth, spreadsheetid, "souls!" + IDX_TO_NAME[start_column] + "3:" + IDX_TO_NAME[end_column] + "1000")
        if (!rows) { break;}
        let rows_result = parse_table(rows)
        let idx = rows_result[0].name;
        if (!idx) { break;}
        let soul_data = {id: idx, levels: []}
        for (let i = 0; i < rows_result.length; i++) {
                let data = rows_result[i];
                soul_data.levels.push([data.mul,data.cost])
        }
        result[idx] = soul_data;
        start_column += 3;
    }

   // console.dir(result, {depth: null});
    console.log("******SOULS PARSE FINISH******")
    return result
}
async function download_localization(sheets, auth, spreadsheetId) {
    console.log("****** LOCALIZATION PARSE BEGIN ******");
    let range = "localization!A8:L1000";  // Assume data goes up to column Z for future languages
    let rows = await gdoc.get(sheets, auth, spreadsheetId, range);
    let headers = rows[0];
    let result = {};

    // Initialize language keys dynamically from header row
    for (let j = 2; j < headers.length; j++) {
        let lang = headers[j];
        result[lang] = {};
    }

    // Parse all rows for localization entries
    let currentKey = "";
    rows.slice(1).forEach(row => {
        let key = row[0].trim();
        let plural = row[1].trim();
        if (key) currentKey = key;  // Update current key if it's not empty

        // Iterate over each language column based on header setup
        for (let j = 2; j < headers.length; j++) {
            let lang = headers[j];
            let text = row[j]
            if (!text) continue;  // Skip empty translations
             text = text.trim();  // Text for current cell

            if (!result[lang][currentKey]) result[lang][currentKey] = {};

            if (plural) {
                result[lang][currentKey][plural] = text;
            } else {
                result[lang][currentKey] = text;  // Direct assignment if no plural form
            }
        }
    });

    console.log("****** LOCALIZATION PARSE FINISHED ******");
    console.log(result);
    return result;
}

// Modify the function to exclude specific languages if provided
function prepare_symbols_file(localization, excludeLanguages = []) {
    let result = "";
    let add_symbols = ["/","_", "+", "-", "~",":","0","1","2","3","4","5","6","7","8","9","%"];
    let symbols = {};

    // Add all English alphabet characters to the symbols dictionary
    for (let ch = 65; ch <= 90; ch++) {  // ASCII values for 'A' to 'Z'
        symbols[String.fromCharCode(ch)] = true;  // Uppercase letters
        symbols[String.fromCharCode(ch + 32)] = true;  // Lowercase letters
    }

    // Add additional specified symbols to the dictionary
    add_symbols.forEach(symbol => {
        symbols[symbol] = true;
    });

    // Process localization data to add any additional unique characters used
    Object.keys(localization).forEach(lang => {
        if (!excludeLanguages.includes(lang)) {
            extractSymbols(localization[lang], symbols);
        }
    });

    // Compile all unique symbols into a single string result
    Object.keys(symbols).forEach(symbol => {
        result += symbol;
    });

    console.log("Compiled Symbols for " + (excludeLanguages.length ? "excluding " + excludeLanguages.join(", ") : "all languages") + ": " + result);
    return result;
}

function extractSymbols(data, symbols) {
    if (typeof data === 'string') {
        // Remove placeholders like %{count} before adding symbols
        data = data.replace(/%\{[^}]+\}/g, ''); // Correct regex to remove placeholders
        Array.from(data).forEach(char => {
            if (!symbols[char]) {
                symbols[char] = true;
            }
        });
    } else if (typeof data === 'object') {
        Object.values(data).forEach(value => {
            extractSymbols(value, symbols);
        });
    }
}

function generateFontForgeScript(inputText) {
    const maxParamsPerLine = 16;  // Define max number of parameters per SelectSingletons/SelectMoreSingletons call
    let unicodePoints = Array.from(inputText).map(char => {
        let hex = char.charCodeAt(0).toString(16).toUpperCase();
        return `"u${hex.padStart(4, '0')}"`;
    });

    // Prepare the initial part of the FontForge script with batches of selections
    let scriptParts = [];
    for (let i = 0; i < unicodePoints.length; i += maxParamsPerLine) {
        let batch = unicodePoints.slice(i, i + maxParamsPerLine);
        if (i === 0) {
            scriptParts.push(`SelectSingletons(${batch.join(", ")});`);
        } else {
            scriptParts.push(`SelectMoreSingletons(${batch.join(", ")});`);
        }
    }

    // Complete the script with the inversion and deletion commands
    scriptParts.push("SelectInvert();");
    scriptParts.push("DetachAndRemoveGlyphs();");
    scriptParts.push("Reencode(\"compacted\");");

    return scriptParts.join("\n");
}







async function download_rebirth(sheets, auth, spreadsheetid) {
	console.log("******REBIRTH  PARSE BEGIN******")
	let rows = await gdoc.get(sheets, auth, spreadsheetid, "rebirth!" + "A3:C1000")
	let rows_result = parse_table(rows)
	let result = []
	for (let i = 0; i < rows_result.length; i++) {
		assert(rows_result[i].level === i + 1, " no level:" + i)
		delete rows_result[i].level
		result[i] = [rows_result[i].mul, rows_result[i].cost]
	}
	console.log("rebirth:" + rows_result.length);
	console.log("******REBIRTH PARSE FINISH******")
	return result;
}

function  save_file(data,path){
    fs.writeFile(path, JSON.stringify(data), (err) => {
        if (err) {
            console.log(err);
            throw(err);
        } else {
            console.log("File saved:" + path);
        }
    });
}

async function main(auth) {
    console.log("start");
    const sheets = google.sheets({version: 'v4', auth});
    const config_sheet = "1O0HVP7Hd2MTZWMV3RJ8x7vG6RkFXz1MV0bmrgugZPLI"

    let levels = await download_levels(sheets, auth, config_sheet);
   // let upgrades = await download_upgrades(sheets, auth, config_sheet);
    let rebirth = await download_rebirth(sheets, auth, config_sheet);
    let souls = await download_souls(sheets, auth, config_sheet);
    let localization = await download_localization(sheets, auth, config_sheet);

    let symbols_list_all = await prepare_symbols_file(localization)
    console.log(generateFontForgeScript(symbols_list_all));


    let symbols_list_small = await prepare_symbols_file(localization,['zh', 'ja', 'ko'])
    console.log(generateFontForgeScript(symbols_list_small));

    save_file(levels,"./configs/levels.json")
    //save_file(upgrades,"./configs/upgrades.json")
    save_file(rebirth,"./configs/rebirth.json")
    save_file(souls,"./configs/souls.json")
    save_file(localization,"./configs/localization.json")

   // save_file(await download_world(sheets, auth, config_sheet, "world_1"),"./configs/world_1.json")

    console.log("finish");

}

