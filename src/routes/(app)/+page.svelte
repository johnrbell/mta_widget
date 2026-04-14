<script>
	import { lineColors } from '$lib/colors.js';

	let { data } = $props();

	let flipped = $state({});

	function toggle(route) {
		flipped = flipped[route] ? {} : { [route]: true };
	}

	const lineGroups = [
		['1', '2', '3'],
		['4', '5', '6'],
		['7'],
		['A', 'C', 'E'],
		['B', 'D', 'F', 'M'],
		['G'],
		['J', 'Z'],
		['L'],
		['N', 'Q', 'R', 'W'],
		['GS', 'FS', 'H'],
		['SI'],
	];

	function byRoute(trains) {
		const map = {};
		for (const t of trains) {
			if (t) map[t.route] = t;
		}
		return map;
	}

	let trainMap = $derived(byRoute(data.trains));
</script>

<svelte:head>
	<title>NYC Transit</title>
</svelte:head>

<div class="container">
	{#each lineGroups as group}
		{@const members = group.map(r => trainMap[r]).filter(Boolean)}
		<div class="row">
			{#each members as train}
				{@const hasAlert = !!train.alertType}
				<div class="train">
					<!-- svelte-ignore a11y_no_static_element_interactions -->
					<div
						class="circle-container"
						class:flipped={flipped[train.route]}
						onclick={hasAlert ? () => toggle(train.route) : undefined}
						onkeydown={hasAlert ? (e) => { if (e.key === 'Enter') toggle(train.route); } : undefined}
						role={hasAlert ? 'button' : undefined}
						tabindex={hasAlert ? 0 : undefined}
					>
						<div class="circle-inner">
							<div class="circle front" style="background-color: {lineColors[train.route] || '#888'}">
								<span class="letter">{['GS', 'FS', 'H'].includes(train.route) ? 'S' : train.route}</span>
							</div>
							<div class="circle back" style="background-color: {lineColors[train.route] || '#888'}">
								<span class="back-text">{train.alertDetail ?? ''}</span>
							</div>
						</div>
					</div>
					<div class="status">{train.status}</div>
				</div>
			{/each}
		</div>
	{/each}
</div>

<style>
	.container {
		position: relative;
		max-width: 1200px;
		margin: 10px auto 0 auto;
	}

	.row {
		display: flex;
		justify-content: flex-start;
		gap: 2px;
		margin-bottom: 20px;
		flex-wrap: wrap;
	}

	.train {
		display: inline-flex;
		flex-direction: column;
		align-items: center;
		width: 78px;
	}

	.circle-container {
		perspective: 400px;
		width: 65px;
		height: 65px;
		cursor: default;
	}

	.circle-container[role="button"] {
		cursor: pointer;
	}

	.circle-container:focus-visible {
		outline: 2px solid rgba(255, 255, 255, 0.6);
		outline-offset: 2px;
		border-radius: 50%;
	}

	.circle-inner {
		position: relative;
		width: 100%;
		height: 100%;
		transform-style: preserve-3d;
		transition: transform 0.5s cubic-bezier(0.4, 0.0, 0.2, 1);
	}

	.flipped .circle-inner {
		transform: rotateY(180deg);
	}

	.circle {
		position: absolute;
		inset: 0;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		backface-visibility: hidden;
		-webkit-backface-visibility: hidden;
	}

	.front {
		z-index: 1;
	}

	.back {
		transform: rotateY(180deg);
		padding: 6px;
	}

	.letter {
		font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
		font-weight: 500;
		font-size: 43px;
		color: #fff;
		line-height: 1;
	}

	.back-text {
		font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
		font-weight: 700;
		font-size: 10px;
		color: #fff;
		text-align: center;
		line-height: 1.2;
		overflow: hidden;
		display: -webkit-box;
		-webkit-line-clamp: 3;
		-webkit-box-orient: vertical;
	}

	.status {
		font-size: 15px;
		font-weight: 700;
		color: rgba(255, 255, 255, 0.85);
		margin-top: 4px;
		text-align: center;
		line-height: 1.2;
	}

	@media (max-width: 767px) {
		.train {
			width: calc(25% - 2px);
		}
		.circle-container {
			width: 85%;
			height: unset;
			aspect-ratio: 1;
		}
		.letter {
			font-size: 11vw;
		}
	}

	@media (min-width: 890px) {
		.row {
			gap: 16px;
			margin-bottom: 40px;
		}
		.train {
			width: 100px;
		}
		.circle-container {
			width: 75px;
			height: 75px;
		}
		.letter {
			font-size: 52px;
		}
		.back-text {
			font-size: 11px;
		}
		.status {
			font-size: 18px;
			margin-top: 7px;
		}
	}
</style>
