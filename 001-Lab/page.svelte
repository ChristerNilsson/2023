<script>
	import _ from 'lodash' 
	import {menu} from '$lib/stores.js'
	import { log } from '$lib/utils.js'
	import { goto } from '$app/navigation'
	import { browser } from '$app/environment'

	// export let data

	// function push(key) {
	// 	$stack = (_.concat($stack,[[key,_.last($stack)[1][key]]]))
	// 	goto(path($stack))
	// }	

	// function pop() {
	// 	if ($stack.length <= 1) return 
	// 	$stack = _.dropRight($stack)
	// 	goto(path($stack))
	// }

	 
	// $stack = [['Home',items]]	
	
	// const display = (stack) => _.map(stack, ([lbl,obj]) => lbl).join(' | ')
	// const path = (stack) => _.map(stack.slice(1), ([lbl,obj]) => lbl).join('/')

	// $: crumbnail = data.slug

	let url = ""
	if (browser) {
		url = window.location.href.slice(22)
	}

</script>


{url}
<!-- {$menu[url]} -->
<!-- {data.slug} <br><br> -->


<!-- {#each $menu[url] as key}
<p>
	<a href = {window.location.href +"/" + key}>{key}</a>
	{key}
</p>
{/each} -->


<!-- <div>
	<main><slot /></main>
</div> -->
