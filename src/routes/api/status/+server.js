import { json } from '@sveltejs/kit';
import { supabase } from '$lib/supabase.js';
import { allRoutes } from '$lib/transit.js';

export async function GET() {
	const { data, error } = await supabase
		.from('ios_widget_train_status')
		.select('route, status, alert_detail, updated_at')
		.in('route', allRoutes);

	if (error) {
		return json({ trains: [], cacheTime: new Date().toISOString() }, { status: 500 });
	}

	const latestUpdate = data.reduce(
		(max, r) => (r.updated_at > max ? r.updated_at : max),
		data[0]?.updated_at ?? new Date().toISOString()
	);

	return json({
		trains: data.map((r) => ({
			route: r.route,
			statusSummary: r.status,
			alertDetail: r.alert_detail ?? ''
		})),
		cacheTime: latestUpdate
	});
}
