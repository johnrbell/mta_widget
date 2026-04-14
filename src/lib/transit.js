const severityOrder = [
	'No Scheduled Service',
	'Station Notice',
	'Boarding Change',
	'Special Schedule',
	'Extra Service',
	'Planned - Stops Skipped',
	'Planned - Express to Local',
	'Planned - Reroute',
	'Planned - Part Suspended',
	'Planned - Suspended',
	'Reduced Service',
	'Slow Speeds',
	'Delays',
	'Severe Delays'
];

function pickWorst(alerts) {
	let worst = alerts[0];
	let worstIndex = severityOrder.indexOf(worst.type);
	for (const a of alerts) {
		const idx = severityOrder.indexOf(a.type);
		if (idx > worstIndex) {
			worst = a;
			worstIndex = idx;
		}
	}
	return worst;
}

function mapStatus(status) {
	switch (status) {
		case 'Planned - Suspended':
			return 'planned - suspended.';
		case 'Planned - Part Suspended':
			return 'planned - part suspended.';
		case 'Planned - Reroute':
			return 'planned - reroute.';
		case 'Planned - Stops Skipped':
			return 'planned - stops skipped.';
		case 'Planned - Express to Local':
			return 'planned - express to local.';
		case 'Severe Delays':
		case 'Delays':
			return 'trains cooked.';
		case 'Slow Speeds':
		case 'Reduced Service':
			return 'sorta cooked.';
		case 'No Scheduled Service':
			return 'no service.';
		case 'Boarding Change':
			return 'boarding change.';
		case 'Extra Service':
			return 'extra service.';
		case 'Station Notice':
			return 'station notice.';
		case 'Special Schedule':
			return 'special schedule.';
		default:
			if (status.startsWith('Planned')) return 'planned work.';
			return status.toLowerCase() + '.';
	}
}

export const allRoutes = [
	'1', '2', '3', '4', '5', '6', '7',
	'A', 'C', 'E', 'B', 'D', 'F', 'M',
	'G', 'J', 'Z', 'L', 'N', 'Q', 'R', 'W',
	'GS', 'FS', 'H', 'SI'
];

const sortOrder = {
	'1': 0, '2': 1, '3': 2, '4': 3, '5': 4, '6': 5, '7': 6,
	'A': 7, 'C': 8, 'E': 9, 'B': 10, 'D': 11, 'F': 12, 'M': 13,
	'G': 14, 'J': 15, 'Z': 16, 'L': 17, 'N': 18, 'Q': 19, 'R': 20, 'W': 21,
	'GS': 22, 'FS': 23, 'H': 24, 'SI': 25
};

function headerText(alert) {
	const translations = alert.header_text?.translation;
	if (!translations) return null;
	const en = translations.find((t) => t.language === 'en');
	return (en || translations[0])?.text || null;
}

export function processAlerts(feedData) {
	const now = Date.now() / 1000;
	const activeAlerts = {};
	const upcomingAlerts = {};

	for (const e of feedData.entity || []) {
		const alert = e.alert;
		const mercury = alert['transit_realtime.mercury_alert'];
		const alertType = mercury ? mercury.alert_type : null;
		if (!alertType) continue;

		const periods = alert.active_period || [];
		const isActive = periods.some((p) => {
			const start = p.start || 0;
			const end = p.end || Infinity;
			return now >= start && now <= end;
		});

		const isPlanned = alertType.startsWith('Planned');
		const upcomingHorizon = 6 * 60 * 60;
		const hasUpcoming = isPlanned && periods.some((p) => {
			const start = p.start || 0;
			return start > now && start <= now + upcomingHorizon;
		});

		if (!isActive && !hasUpcoming) continue;

		const detail = headerText(alert);

		for (const ie of alert.informed_entity || []) {
			if (ie.route_id && allRoutes.includes(ie.route_id)) {
				const bucket = isActive ? activeAlerts : upcomingAlerts;
				if (!bucket[ie.route_id]) bucket[ie.route_id] = [];
				bucket[ie.route_id].push({ type: alertType, detail });
			}
		}
	}

	const trains = [];
	for (const route of allRoutes) {
		const active = activeAlerts[route] || [];
		const upcoming = upcomingAlerts[route] || [];

		let status;
		let alertType = null;
		let alertDetail = null;
		if (active.length > 0) {
			const worst = pickWorst(active);
			alertType = worst.type;
			alertDetail = worst.detail;
			status = mapStatus(alertType);
		} else if (upcoming.length > 0) {
			const worst = pickWorst(upcoming);
			alertType = worst.type;
			alertDetail = worst.detail;
			status = mapStatus(alertType);
		} else {
			status = 'all good.';
		}

		trains[sortOrder[route]] = { route, status, alertType, alertDetail };
	}

	return { trains, cacheTime: new Date() };
}

export const TRANSIT_ALERTS_URL =
	'https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/camsys%2Fsubway-alerts.json';
