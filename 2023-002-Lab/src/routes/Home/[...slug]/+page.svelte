<script>
	import _ from 'lodash'
	import countapi from 'countapi-js'
	import {goto} from '$app/navigation'
	import {page} from '$app/stores'
	import {clean,getChildren,selectImages,log,fetchSubTree} from '$lib/utils.js'
	import {selection} from '$lib/stores.js'

	// export const prerender = true

	let bilder = {}  // innehåll json-trädet

	async function fetchData() {
		const res = await fetch('/json/bilder.json')
		// const res = await fetch('/json/bilder.json')
		const data = await res.json()
		if (res.ok) {
			bilder = data
			return data
		} else {
			throw new Error(data)
		}
	}

	// let sokruta = $page.url.searchParams.get('s')
	let sokruta = 'Numa'
	$: log(sokruta)

	// $: $page.url.searchParams.set('s', sokruta)

	// $: goto($page.url.href + $page.url.searchParams.toString())

	$: url = $page.url
	$: pathname = decodeURI(url.pathname.split('/').slice(2).join('/')) // ta bort inledande /. Kan finnas %20 och andra tecken.
	$: subtree = fetchSubTree(bilder,pathname)
	$: children = getChildren(bilder,pathname) // De omedelbara barnen till en nod.
	// $: selection = selectImages(bilder,pathname,sokruta)
	$: $selection = selectImages(subtree,pathname,sokruta).slice(0,10)

	// $: log($page.url)
	// $: log($page.url.searchParams.get('s'))

	// $: log($page)
	// $: log({children})
	// $: log({pathname})
	$: log({subtree})
	// $: log({url})
	// $:log(url.pathname.split('/').slice(2))
	$: log({$selection})

	// $: pathnames = selection.slice(0,10) //.filter((leaf => leaf.includes(sokruta))).slice(0,100)
	

	countapi.visits('bildbanken2.com','mainpage').then((result) => {console.log('countapi',result.value)})
	//https://api.countapi.xyz/hit/bildbanken2.com/click

</script>

<input type="text" bind:value={sokruta}>

<button on:click={()=>goto($page.url.origin + $page.url.pathname + '?s=' + sokruta)}>Share</button><br>
<button on:click={()=>goto('/play')}>Play</button><br>

{$selection.length} <br>

{#await fetchData()}
	<p>loading</p>
{:then xxx}

	{#each children as key}
		{@const name = clean(pathname,key)} 
		<button on:click={()=>goto('/Home' + name)}>{key}</button><br>
	{/each}

	{#each $selection as data}
		{@const path = data[6]}
		{@const md5 = data[5]}
		{@const href = "/small/" + md5 + '.jpg' }
		<img src={href} alt="">
	{/each}

{:catch error}
	<p style="color: red">{error.message}</p>
{/await}

<style> button {width:650px; text-align:left}</style>