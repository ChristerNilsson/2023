import _ from 'lodash'

export const log = console.log

// $: log(menu)

export function assert (msg,a,b) {
	if (!_.isEqual(a,b)) {
		log('Assert',msg, 'failed')
		log('  a:',a)
		log('  b:',b)
	} else {
		// log('Assert',msg,'ok')
	}
}

export const splitPath = (s) => s=='' ? [] : s.split('/')
assert('mI1',splitPath(''),     [] )
assert('mI2',splitPath('a'),    ['a'] )
assert('mI3',splitPath('a/a1'), ['a','a1'] )

export function getChildren(curr,path) {
	if (_.size(curr)==0) return []
	for (const item of splitPath(path)) curr = curr[item]
	return _.keys(curr)
}
// assert('B',getChildren(menu,''), ['a','b'])
// assert('C',getChildren(menu,'a'), ['a1', 'a2', 'a3'])
// assert('D',getChildren(menu,'a/a1'), ['a11','a12'])

// Söker upp en bild från roten, givet path
export function fetchSubTree(curr,path) {
	// log('fetchSubTree in',{curr},{path})
	if (_.size(curr)==0) return curr
	for (const item of splitPath(path)) curr = curr[item]
	// log('fetchSubTree out',{curr})
	return curr
}

// export function getObject(curr,path) {
// 	curr = fetchSubTree(curr,path)
// }

// Hämtar det tillplattade subträdet. 
// Returnerar en lista av [sw,sh,bs,bw,md5,path,key]
// ej filtrerat på söksträngen
export function selectImages(curr,path,sokruta) {
	const selected = []
	// const folders = []
	function recurse(curr,path,key) {
		// log('recurse',{curr,path,key})
		if (path.toLowerCase().endsWith('.jpg')) {
			if (path.includes(sokruta)) {
				// log({curr})
				if (path.startsWith('/')) {
					selected.push(curr.concat(path.slice(1)))
				} else {
					selected.push(curr.concat(path))
				}
			}
		} else {
			for (const k of _.keys(curr)) {
				// if (!k.toLowerCase().endsWith('.jpg')) log(path + '/' + k)
				recurse(curr[k],path + '/' + k,k)
			}
		}
	}
	// log('folders',folders)
	log(path)
	recurse(curr,path)
	log({selected})
	return selected
}

// export function selectImages(curr,path,sokruta) {
// 	const selected = []
// 	// const folders = []
// 	function recurse(curr,path,key) {
// 		log('recurse',{curr,path,key})
// 		if (path.toLowerCase().endsWith('.jpg')) {
// 			// if (path.toLowerCase().endsWith('.jpg') && path.includes(sokruta)) {
// 				// const data = curr[key]
// 			// log({data})
// 			if (path.startsWith('/')) {
// 				selected.push(path.slice(1))
// 			} else {
// 				selected.push(path)
// 			}
// 		} else {
// 			for (const k of _.keys(curr)) {
// 				// if (!k.toLowerCase().endsWith('.jpg')) log(path + '/' + k)
// 				recurse(curr[key],path + '/' + k,k)
// 			}
// 		}
// 	}
// 	// log('folders',folders)
// 	log(path)
// 	recurse(fetchSubTree(curr,path),path,"")
// 	log({selected})
// 	return selected
// }


export function clean(a,b) {
	if (!a.startsWith('/')) a = '/' + a
	return a.endsWith('/') || b.startsWith('/') ? a + b : a + '/' + b
}
assert('C1', clean('/','2011'),'/2011')
assert('C2', clean('/2022', '2022--2023 Allsvenskan Division III_T10438'),'/2022/2022--2023 Allsvenskan Division III_T10438')
assert('C3', clean('/2022/2022-07-02_Schack-SM Uppsala_I10044',"Weekend-2"), "/2022/2022-07-02_Schack-SM Uppsala_I10044/Weekend-2")

// assert(0,'Ab'.toLowerCase(), 'ab')
// assert(1,'Ab'.toUpperCase(), 'AB')
// for (const item in "ab") log(item) 0,1
// for (const item of "ab") log(item) a,b

// keyword|for (item in IN)|for item in IN:|a,b|a,b
// keyword|for (item of IN)|for item in range(len(IN)):|a,b|0,1
// keyword|for (item in IN)|for item in IN:|a:3,b:4|a,b
// keyword|for (item in IN)|for item in range(len(IN)):|a:3,b:4|3,4