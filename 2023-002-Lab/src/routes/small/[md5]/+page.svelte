<script>
	// import _ from 'lodash'
	// import {goto} from '$app/navigation'
	import {page} from '$app/stores'
	
	// import menu from '$lib/bilder.json'
	// import menu from '$lib/bilder_tom.json'
	// const menu = {}

	// import {clean,getChildren,getLeaves,log,traverse} from '$lib/utils.js'

	// export const prerender = true

	// log($page)

	const href =  "/small/" + $page.params.md5 + ".jpg"
	// $: url = $page.url
	// $: pathname = decodeURI(url.pathname.slice(1)) // ta bort inledande /. Kan finnas %20 och andra tecken.
	// $: children = getChildren(menu,pathname) // De omedelbara barnen till en nod.
	// $: leaves = getLeaves(menu,pathname)
	// $: log(leaves)

	// $: pathnames = leaves.filter((leaf => leaf.includes(sokruta)))
	// for (const pathname in leaves) {
	// 	if (pathname.includes(sokruta)) pathnames.push(pathname)
	// }
	// log(pathnames)

	// sök igenom leaves efter träff på sokrutan

	// const sokruta = 'Numa'
</script>

{href}

<!-- {#each children as key}
	{@const name = clean(pathname,key)} 
	<button on:click={()=>goto(name)}>{key}</button><br>
{/each}

{sokruta} {pathnames.length} <br>
{#each pathnames as pn} 
	{#if pn.endsWith('.jpg')}
		{#if pn.includes(sokruta)}
			{@const data = traverse(menu,pathname)}
			{@const href = "/image/" + data[5]}
			{pn} 
			{data} <br>
			{data[5]} 
			<img src={href} alt="">
		{/if} <br>
	{/if}
{/each} -->

<a href="{href}">image</a>

<!-- <style> button {width:650px; text-align:left}</style>  -->
