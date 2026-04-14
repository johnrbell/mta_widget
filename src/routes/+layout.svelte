<script>
	import { beforeNavigate, afterNavigate } from '$app/navigation';
	import { setContext } from 'svelte';

	let { children } = $props();

	$effect(() => {
		document.documentElement.style.backgroundColor = '#000';
		document.body.style.backgroundColor = '#000';
	});

	let loading = $state(false);
	let loadStart = 0;
	const MIN_DURATION = 250;

	function showLoader() {
		loading = true;
		loadStart = Date.now();
	}

	function hideLoader() {
		const elapsed = Date.now() - loadStart;
		const remaining = Math.max(0, MIN_DURATION - elapsed);
		setTimeout(() => { loading = false; }, remaining);
	}

	setContext('loader', { showLoader, hideLoader });

	beforeNavigate(() => showLoader());
	afterNavigate(() => hideLoader());
</script>

{#if loading}
	<div class="signage-loader-overlay">
		<svg class="signage-spinner" viewBox="0 0 50 50">
			<circle cx="25" cy="25" r="20" />
		</svg>
	</div>
{/if}

<div class="content-layer">
	{@render children()}
</div>

<style>
	:global(html), :global(body) {
		margin: 0;
		padding: 0;
		font-family: 'Helvetica Neue', Arial, sans-serif;
		color: white;
		-webkit-tap-highlight-color: transparent;
		-webkit-touch-callout: none;
		-webkit-user-select: none;
		user-select: none;
		overscroll-behavior: none;
	}

	:global(a) {
		color: white;
	}

	.signage-loader-overlay {
		position: fixed;
		inset: 0;
		z-index: 99999;
		background: rgba(0, 0, 0, 0.85);
		display: flex;
		justify-content: center;
		align-items: center;
	}

	.signage-spinner {
		width: 48px;
		height: 48px;
		animation: signage-spin 0.8s linear infinite;
	}

	.signage-spinner circle {
		fill: none;
		stroke: #fff;
		stroke-width: 4;
		stroke-linecap: round;
		stroke-dasharray: 90 126;
	}

	@keyframes signage-spin {
		to { transform: rotate(360deg); }
	}

	.content-layer {
		position: relative;
		z-index: 2;
		min-height: 100vh;
	}
</style>
