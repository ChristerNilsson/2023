### Svelte Component
```c
<!-- Widget.svelte -->
<script>
  export let textValue
</script>

<div class="container">
  {textValue}
</div>

<style>
.container {
  color: blue;
}
</style>

<!-- App.svelte -->
<script>
  import Widget from './Widget.svelte'
  const title = 'App'
</script>

<header>{title}</header>

<Widget textValue="I'm a svelte component" />
```

### Expressions
```c
<script>
  let isShowing = true
  let cat = 'cat'
  let user = {name: 'John Wick'}
  let email = 'professionalkiller@gmail.com'
</script>

<p>2 + 2 = {2 + 2}</p>
   
<p on:click={() => isShowing = !isShowing}>
  {isShowing 
    ? 'NOW YOU SEE ME 👀' 
    : 'NOW YOU DON`T SEE ME 🙈'}
</p>

<p>My e-mail is {email}</p>
<p>{user.name}</p>
<p>{cat + `s`}</p>
<p>{`name ${user.name}`}</p>
```

###  Simple Bind
```
//MyLink.svelte
<script>
    export let href = ''
    export let title = ''
    export let color = ''
</script>

<a href={href} style="color: {color}" >
  {title}
</a>

// Shorthand
<a {href} style="color: {color}" >
  {title}
</a>

<script>
  import MyLink from "./components/MyLink";
  let link = {
    href: "http://www.mysite.com",
    title: "My Site",
    color: "#ff3300"
  };
</script>

<MyLink {...link} />
```

