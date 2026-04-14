import { supabase } from '$lib/supabase.js';

export async function load() {
	const { data, error } = await supabase
		.from('ios_widget_train_status')
		.select('route, status, alert_type, alert_detail, updated_at');

	if (error || !data) {
		return { trains: [], cacheTime: new Date().toISOString() };
	}

	const latestUpdate = data.reduce(
		(max, r) => (r.updated_at > max ? r.updated_at : max),
		data[0]?.updated_at ?? new Date().toISOString()
	);

	return {
		trains: data.map((r) => ({
			route: r.route,
			status: r.status,
			alertType: r.alert_type,
			alertDetail: r.alert_detail
		})),
		cacheTime: latestUpdate
	};
}
