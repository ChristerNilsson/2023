// import {range,isEqual} from ../node_modules/lodash-es/lodash.js

const ass = (a,b) => {
	if (!_.isEqual(a,b)) {
		console.log('assert failure')
		console.log('  ',a)
		return console.log('  ',b)
	};return
}

ass(2, 2)
ass([1,2,], [1,2])
ass([0,1,2,3], _.range(4))

console.log('Ready!')

// Lägg upp assert för alla exempel.

// Frågor:
// Hur koppla till JSX och Solid?
// Varför så långsamt?
