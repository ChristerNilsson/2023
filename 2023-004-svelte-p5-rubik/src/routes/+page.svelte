<script>
	import P5 from 'p5-svelte'
	import easyCam from '$lib/easycam'
	// import {dev} from '$app/environment'
	import _ from 'lodash'
	const range = _.range
	const log = console.log

	const COLORS = "#FFF #00F #FF0 #0F0 #FA5 #F00".split(' ') // W B Y G O R
	const ALPHABET = 'abcdefgh jklmnopq ABCDEFGH JKLMNOPQ STUVWXYZ stuvwxyz'
	const SWAPS = { // See README.md
		W: 'aceg bdfh wjWN xkXO ylYP',
		B: 'lnpj moqk euAY fvBZ gwCS',
		Y: 'GECA HFDB nsJS otKT puLU',
		G: 'PNLJ QOMK EyaU FzbV GscW',
		O: 'YWUS ZXVT ajGJ hqHQ gpAP',
		R: 'suwy tvxz LClc MDmd NEne'
	}

	const cube = _.map(range(54), (i)=> Math.floor(i/9))
	const R = 60
	const sketch = (p5) => {

		p5.setup = () => {
			p5.createCanvas(800, 800, p5.WEBGL)
			for (const letter of "") {
				const LETTER = letter.toUpperCase()
				if (!(LETTER in SWAPS)) return
				for (const word of SWAPS[LETTER].split(' ')) {
					const [i,j,k,l] = _.map(word, (w) => ALPHABET.indexOf(w))
					const [a,b,c,d] = LETTER == letter ? [l,i,j,k] : [j,k,l,i]
					cube[a] = cube[i]
					cube[b] = cube[j]
					cube[c] = cube[k]
					cube[d] = cube[l]
				}
			}
		}
		p5.draw = function() {
			p5.background(0)
			p5.orbitControl(4,4,4) // speed
			for (const side in range(6)) { // cube
				p5.rotateX(p5.HALF_PI * [1,1,1,1,0,0][side])
				p5.rotateZ(p5.HALF_PI * [0,0,0,0,1,2][side])
				for (const k of range(9)) {
					const [i,j] = [[0,0],[2,0],[4,0],[4,2],[4,4],[2,4],[0,4],[0,2],[2,2]][k]  // side
					// console.log(i,j)
					p5.beginShape()
					p5.fill(COLORS[cube[9*side+k]])
					p5.strokeWeight(3)
					_.map([[0,0],[2,0],[2,2],[0,2]], ([x,z]) => p5.vertex(R*(i+x-3), 3*R, R*(j+z-3)))
					p5.endShape()
				}
			}
			// log(p5.rotationX,p5.rotationY,p5.rotationZ)
		}
	}
</script>

<P5 {sketch} />
