import { json, error } from '@sveltejs/kit';
import { env } from '$env/dynamic/private';
import { supabase } from '$lib/supabase.js';
import { processAlerts, MTA_URL } from '$lib/mta.js';

export async function POST({ request }) {
	const auth = request.headers.get('authorization');
	if (auth !== `Bearer ${env.INGEST_API_KEY}`) {
		error(401, 'Unauthorized');
	}

	const res = await fetch(MTA_URL, { signal: AbortSignal.timeout(10000) });
	if (!res.ok) {
		error(502, `MTA API returned ${res.status}`);
	}

	const feedJson = await res.json();
	const { trains } = processAlerts(feedJson);

	const { data: existing } = await supabase
		.from('ios_widget_train_status')
		.select('route, status, alert_type, alert_detail');

	const currentByRoute = {};
	for (const row of existing || []) {
		currentByRoute[row.route] = row;
	}

	const updated = [];
	for (const train of trains) {
		if (!train) continue;
		const cur = currentByRoute[train.route];
		const changed = !cur
			|| cur.status !== train.status
			|| cur.alert_type !== (train.alertType ?? null)
			|| cur.alert_detail !== (train.alertDetail ?? null);

		if (changed) {
			updated.push(train.route);
			await supabase
				.from('ios_widget_train_status')
				.upsert({
					route: train.route,
					status: train.status,
					alert_type: train.alertType ?? null,
					alert_detail: train.alertDetail ?? null,
					updated_at: new Date().toISOString()
				});
		}
	}

	return json({
		updated,
		unchanged: trains.filter(Boolean).length - updated.length
	});
}
