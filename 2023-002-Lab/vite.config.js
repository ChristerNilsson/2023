import { sveltekit } from '@sveltejs/kit/vite'
// import ViteYaml from '@modyfi/vite-plugin-yaml'

const config = {
	plugins: [
		sveltekit(),
    // ViteYaml({include: /\.yaml/}), 
	]
};

export default config;
