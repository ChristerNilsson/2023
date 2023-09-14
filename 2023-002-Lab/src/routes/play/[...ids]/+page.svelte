<script>
	import {selection} from '$lib/stores.js'
	import { Body } from 'svelte-body'
	import { fade } from 'svelte/transition'
	import _ from 'lodash'

	const SIZE = 'large'
	let delay = 5 // s
	const DURATION = 1000 // ms
	const GAP = 30
	let i=0
	let paused = false

	$: n = $selection.length
	$: data = $selection[i]
	$: bw = data[3] // -3
	$: bh = data[4] // -3
	$: md5 = data[5]
	$: path = data[6]
	$: href = '/' + SIZE + '/' + md5 + '.jpg'
	$: key = _.last(path.split('/')).replaceAll('_',' ').replace('.jpg','').replace('Vy-','')

	const f = () => {
		i = paused ? i : (i+1) % n
		setTimeout(f,delay*1000)
	}

	setTimeout(f,delay*1000)

	$: skala  = Math.min((innerHeight-GAP)/bh, (innerWidth)/bw)
	$: width  = Math.round(bw * skala * 0.95)
	$: height = Math.round(bh * skala * 0.95)
	$: left   = Math.round((innerWidth - width)/2)
	$: top    = GAP

	function keydown(event) {
		const key = event.key
		if (key == ' ') paused = ! paused
		if (key == 'ArrowLeft')  i = (i + n-1) % n
		if (key == 'ArrowRight') i = (i + 1) % n
		if (key == 'ArrowUp')   delay++
		if (key == 'ArrowDown') delay = delay < 2 ? delay : delay-1
		if (key == 'Home') i = 0
		if (key == 'End') i = n-1
	}

	window.onscroll = (e)=> {
		e.preventDefault()
		e.stopPropagation()
		return false 
	}

</script>

<svelte:window on:keydown={keydown}/>

<Body style="background-color: black; color:white" />

<div >

	<table width=99%>
		<tr><td style='text-align:left' width=10%>
			#{i}
		</td><td style='text-align:center' width=80%>
			{paused ? 'Paused' : key}
		</td><td style='text-align:right' width=10%>
			{delay}s
		</td></tr>
	</table>

	{#if i%2==0}
		<img id='picture0' transition:fade={{ duration:DURATION}} style="position:absolute;left:{left}px;top:{top}px;" width={width}px  src={href} alt="">
	{:else}
		<img id='picture1' transition:fade={{ duration:DURATION}} style="position:absolute;left:{left}px;top:{top}px;" width={width}px  src={href} alt="">
	{/if}
</div>

<style>
	 img {border-radius: 1%}
</style>
