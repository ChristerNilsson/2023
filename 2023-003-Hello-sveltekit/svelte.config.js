import adapter from '@sveltejs/adapter-static';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		adapter: adapter(),
		appDir: 'app',
		// paths: {
		// 	base: process.env.NODE_ENV === "production" ? "/2023-003-Hello-sveltekit" : "",
		// },
}};

export default config;
