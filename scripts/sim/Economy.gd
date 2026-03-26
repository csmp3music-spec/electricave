extends Node
class_name Economy

signal monthly_report_generated(report: Dictionary)

@export var cash := 500000.0
@export var monthly_revenue := 0.0
@export var monthly_expenses := 0.0
@export var bond_interest_rate := 0.05
@export var bond_principal := 175000.0
@export var base_overhead_per_month := 2200.0
@export var track_upkeep_per_meter_month := 0.18
@export var stop_lease_per_month := 110.0
@export var trolley_crew_wage_per_month := 820.0
@export var trolley_power_cost_per_month := 360.0
@export var trolley_maintenance_per_month := 540.0
@export var depot_upkeep_per_month := 340.0
@export var signal_upkeep_per_month := 42.0
@export var finance_history_limit := 18
var _monthly_income_categories := {}
var _monthly_expense_categories := {}
var _last_month_report := {}
var _finance_history: Array[Dictionary] = []
var _current_period_label := "May 1900"
var _track_builder: Node
var _town_manager: Node
var _corridor: Node
var _stop_placer: Node

func _ready() -> void:
	_resolve_world_nodes()
	_start_new_month()

func can_afford(amount: float) -> bool:
	return cash >= maxf(amount, 0.0)

func apply_revenue(amount: float, category: String = "Passenger fares") -> void:
	if amount <= 0.0:
		return
	_record_income(category, amount)
	cash += amount

func apply_expense(amount: float, category: String = "Operating expense") -> void:
	if amount <= 0.0:
		return
	_record_expense(category, amount)
	cash -= amount

func spend_capital(amount: float, category: String = "Capital spend") -> bool:
	if amount <= 0.0:
		return true
	if not can_afford(amount):
		return false
	_record_expense(category, amount)
	cash -= amount
	return true

func refund_capital(amount: float, category: String = "Capital refunds") -> void:
	if amount <= 0.0:
		return
	_record_income(category, amount)
	cash += amount

func end_month() -> void:
	_last_month_report = _build_finance_report(_current_period_label)
	_append_finance_history(_last_month_report)
	emit_signal("monthly_report_generated", _last_month_report)
	_start_new_month()

func get_finance_tab_payload(tab_name: String) -> Dictionary:
	var report := _finance_report_for_display()
	match tab_name:
		"Revenue":
			return _category_tab_payload("Revenue", report.get("income", {}), Color("3c9154"))
		"Expenses":
			return _category_tab_payload("Operating costs", report.get("expenses", {}), Color("b34a3f"))
		"Pricing":
			return _pricing_tab_payload(report)
		_:
			return _overview_tab_payload(report)

func get_finance_snapshot() -> Dictionary:
	return _finance_report_for_display()

func get_finance_history() -> Array[Dictionary]:
	var history: Array[Dictionary] = []
	for entry in _finance_history:
		history.append(entry.duplicate(true))
	var current_report := _build_finance_report(_current_period_label + " (live)")
	history.append({
		"period": String(current_report.get("title", _current_period_label)),
		"revenue": float(current_report.get("monthly_revenue", 0.0)),
		"expenses": float(current_report.get("monthly_expenses", 0.0)),
		"net": float(current_report.get("net", 0.0)),
		"cash": float(current_report.get("cash", cash))
	})
	while history.size() > finance_history_limit:
		history.remove_at(0)
	return history

func set_reporting_period(year: int, month: int) -> void:
	_current_period_label = "%s %d" % [_month_name(month), year]

func _resolve_world_nodes() -> void:
	var world_root := get_parent()
	if world_root == null:
		return
	_track_builder = world_root.get_node_or_null("TrackNetwork")
	_town_manager = world_root.get_node_or_null("TownGrowthManager")
	_corridor = world_root.get_node_or_null("CorridorSeed")
	_stop_placer = world_root.get_node_or_null("StopPlacer")

func _start_new_month() -> void:
	monthly_revenue = 0.0
	monthly_expenses = 0.0
	_monthly_income_categories.clear()
	_monthly_expense_categories.clear()
	_ensure_reporting_categories()
	_resolve_world_nodes()
	_apply_monthly_operating_budget()

func _ensure_reporting_categories() -> void:
	for category in ["Urban passenger", "Interurban passenger", "Excursion traffic", "Passenger fares", "Capital refunds"]:
		_monthly_income_categories[category] = float(_monthly_income_categories.get(category, 0.0))
	for category in ["Crew wages", "Power & substations", "Track upkeep", "Car maintenance", "Right-of-way leases", "Debt interest", "Capital spend"]:
		_monthly_expense_categories[category] = float(_monthly_expense_categories.get(category, 0.0))

func _apply_monthly_operating_budget() -> void:
	var metrics := _network_metrics()
	var track_length_m := float(metrics.get("track_length_m", 0.0))
	var stop_count := int(metrics.get("stop_count", 0))
	var fleet_count := int(metrics.get("fleet_count", 0))
	var depot_count := int(metrics.get("depot_count", 0))
	var signal_count := int(metrics.get("signal_count", 0))
	_charge_monthly_expense("Crew wages", float(fleet_count) * trolley_crew_wage_per_month)
	_charge_monthly_expense("Power & substations", float(fleet_count) * trolley_power_cost_per_month)
	_charge_monthly_expense("Track upkeep", track_length_m * track_upkeep_per_meter_month)
	_charge_monthly_expense("Car maintenance", float(fleet_count) * trolley_maintenance_per_month + float(depot_count) * depot_upkeep_per_month)
	_charge_monthly_expense("Right-of-way leases", base_overhead_per_month + float(stop_count) * stop_lease_per_month + float(signal_count) * signal_upkeep_per_month)
	_charge_monthly_expense("Debt interest", (bond_principal * bond_interest_rate) / 12.0)

func _network_metrics() -> Dictionary:
	var track_length_m := 0.0
	var stop_count := 0
	var fleet_count := 0
	var depot_count := 0
	var signal_count := 0
	if _track_builder != null and _track_builder.has_method("get_total_track_length"):
		track_length_m = float(_track_builder.call("get_total_track_length"))
	if _town_manager != null and _has_property(_town_manager, "stops"):
		var stops: Array = _town_manager.get("stops")
		stop_count = stops.size()
	if _corridor != null and _corridor.has_method("get_fleet_size"):
		fleet_count = int(_corridor.call("get_fleet_size"))
	if _stop_placer != null and _stop_placer.has_method("get_manual_build_counts"):
		var counts: Dictionary = _stop_placer.call("get_manual_build_counts")
		depot_count = int(counts.get("depot", 0))
		signal_count = int(counts.get("signal", 0))
	return {
		"track_length_m": track_length_m,
		"stop_count": stop_count,
		"fleet_count": fleet_count,
		"depot_count": depot_count,
		"signal_count": signal_count
	}

func _record_income(category: String, amount: float) -> void:
	if amount <= 0.0:
		return
	monthly_revenue += amount
	_monthly_income_categories[category] = float(_monthly_income_categories.get(category, 0.0)) + amount

func _record_expense(category: String, amount: float) -> void:
	if amount <= 0.0:
		return
	monthly_expenses += amount
	_monthly_expense_categories[category] = float(_monthly_expense_categories.get(category, 0.0)) + amount

func _charge_monthly_expense(category: String, amount: float) -> void:
	if amount <= 0.0:
		return
	_record_expense(category, amount)
	cash -= amount

func _finance_report_for_display() -> Dictionary:
	if monthly_revenue <= 0.01 and monthly_expenses <= 0.01 and not _last_month_report.is_empty():
		return _last_month_report
	return _build_finance_report("This month")

func _build_finance_report(title: String) -> Dictionary:
	var net := monthly_revenue - monthly_expenses
	var operating_ratio := monthly_expenses / maxf(monthly_revenue, 1.0)
	var metrics := _network_metrics()
	var service_rating := 78.0
	var fare_multiplier := 1.0
	var load_factor := 0.0
	var headway_target := 0.0
	var headway_ahead := -1.0
	if _corridor != null and _corridor.has_method("get_driver_service_status"):
		var service_payload: Dictionary = _corridor.call("get_driver_service_status")
		service_rating = float(service_payload.get("rating", service_rating))
		fare_multiplier = float(service_payload.get("fare_multiplier", fare_multiplier))
		headway_target = float(service_payload.get("headway_target_m", 0.0))
		headway_ahead = float(service_payload.get("headway_ahead_m", -1.0))
	if _corridor != null and _corridor.has_method("get_driver_passenger_status"):
		var passenger_payload: Dictionary = _corridor.call("get_driver_passenger_status")
		var onboard := float(passenger_payload.get("onboard", 0))
		var capacity := maxf(1.0, float(passenger_payload.get("capacity", 1)))
		load_factor = onboard / capacity
	return {
		"title": title,
		"income": _monthly_income_categories.duplicate(true),
		"expenses": _monthly_expense_categories.duplicate(true),
		"net": net,
		"cash": cash,
		"monthly_revenue": monthly_revenue,
		"monthly_expenses": monthly_expenses,
		"operating_ratio": operating_ratio,
		"service_rating": service_rating,
		"fare_multiplier": fare_multiplier,
		"load_factor": load_factor,
		"headway_target_m": headway_target,
		"headway_ahead_m": headway_ahead,
		"network_metrics": metrics
	}

func _append_finance_history(report: Dictionary) -> void:
	_finance_history.append({
		"period": String(report.get("title", _current_period_label)),
		"revenue": float(report.get("monthly_revenue", 0.0)),
		"expenses": float(report.get("monthly_expenses", 0.0)),
		"net": float(report.get("net", 0.0)),
		"cash": float(report.get("cash", cash))
	})
	while _finance_history.size() > finance_history_limit:
		_finance_history.remove_at(0)

func _overview_tab_payload(report: Dictionary) -> Dictionary:
	var revenue := float(report.get("monthly_revenue", 0.0))
	var expenses := float(report.get("monthly_expenses", 0.0))
	var net := float(report.get("net", 0.0))
	var cash_value := float(report.get("cash", cash))
	var service_rating := float(report.get("service_rating", 78.0))
	var metrics: Dictionary = report.get("network_metrics", {})
	var track_miles := float(metrics.get("track_length_m", 0.0)) / 1609.344
	var stop_count := int(metrics.get("stop_count", 0))
	var fleet_count := int(metrics.get("fleet_count", 0))
	return {
		"title": String(report.get("title", "This month")),
		"rows": [
			_entry("Revenue", _money_text(revenue), revenue / maxf(revenue + expenses, 1.0), Color("3c9154")),
			_entry("Expenses", _money_text(expenses), expenses / maxf(revenue + expenses, 1.0), Color("b34a3f")),
			_entry("Net result", _signed_money_text(net), absf(net) / maxf(absf(net) + expenses, 1.0), Color("3c9154") if net >= 0.0 else Color("b34a3f")),
			_entry("Cash on hand", _money_text(cash_value), clampf(cash_value / 750000.0, 0.0, 1.0), Color("3f8a8a")),
			_entry("Service rating", "%.0f / 100" % service_rating, clampf(service_rating / 100.0, 0.0, 1.0), Color("6f8b52"))
		],
		"summary": [
			_entry("Route length", "%.1f mi" % track_miles, clampf(track_miles / 55.0, 0.0, 1.0), Color("8c6a4a")),
			_entry("Stops / cars", "%d / %d" % [stop_count, fleet_count], clampf(float(fleet_count) / maxf(float(stop_count), 1.0), 0.0, 1.0), Color("8c6a4a"))
		]
	}

func _category_tab_payload(title: String, categories: Dictionary, color: Color) -> Dictionary:
	var rows := []
	var summary_total := 0.0
	var sorted_names := categories.keys()
	sorted_names.sort_custom(func(a, b): return float(categories[a]) > float(categories[b]))
	for name_variant in sorted_names:
		var name := String(name_variant)
		var amount := float(categories.get(name, 0.0))
		summary_total += amount
	var divisor := maxf(1.0, summary_total)
	for name_variant in sorted_names:
		var name := String(name_variant)
		var amount := float(categories.get(name, 0.0))
		rows.append(_entry(name, _money_text(amount), amount / divisor, color))
	while rows.size() < 5:
		rows.append(_entry("Unused", "$0", 0.0, color.darkened(0.25)))
	return {
		"title": title,
		"rows": rows.slice(0, 5),
		"summary": [
			_entry("Monthly total", _money_text(summary_total), 1.0 if summary_total > 0.0 else 0.0, color),
			_entry("Largest line item", _money_text(_largest_category_amount(categories)), clampf(_largest_category_amount(categories) / maxf(summary_total, 1.0), 0.0, 1.0), color)
		]
	}

func _pricing_tab_payload(report: Dictionary) -> Dictionary:
	var load_factor := float(report.get("load_factor", 0.0))
	var fare_multiplier := float(report.get("fare_multiplier", 1.0))
	var service_rating := float(report.get("service_rating", 78.0))
	var headway_target := float(report.get("headway_target_m", 0.0))
	var headway_ahead := float(report.get("headway_ahead_m", -1.0))
	var headway_text := "No live spacing data"
	var headway_ratio := 0.0
	if headway_target > 0.0 and headway_ahead >= 0.0:
		headway_text = "%.0f / %.0fm" % [headway_ahead, headway_target]
		headway_ratio = clampf(1.0 - absf(headway_ahead - headway_target) / maxf(headway_target, 1.0), 0.0, 1.0)
	return {
		"title": "Service metrics",
		"rows": [
			_entry("Fare multiplier", "x%.2f" % fare_multiplier, clampf((fare_multiplier - 0.85) / 0.30, 0.0, 1.0), Color("3f8a8a")),
			_entry("Load factor", "%.0f%%" % (load_factor * 100.0), clampf(load_factor, 0.0, 1.0), Color("3c9154")),
			_entry("Service rating", "%.0f / 100" % service_rating, clampf(service_rating / 100.0, 0.0, 1.0), Color("6f8b52")),
			_entry("Headway ahead", headway_text, headway_ratio, Color("caa76a")),
			_entry("Bond interest", "%.1f%%" % (bond_interest_rate * 100.0), clampf(bond_interest_rate / 0.10, 0.0, 1.0), Color("8c6a4a"))
		],
		"summary": [
			_entry("Bond principal", _money_text(bond_principal), clampf(bond_principal / 250000.0, 0.0, 1.0), Color("8c6a4a")),
			_entry("Cash reserve", _money_text(float(report.get("cash", cash))), clampf(float(report.get("cash", cash)) / 750000.0, 0.0, 1.0), Color("3f8a8a"))
		]
	}

func _entry(label: String, amount: String, value: float, color: Color) -> Dictionary:
	return {
		"label": label,
		"amount": amount,
		"value": clampf(value, 0.0, 1.0),
		"color": color
	}

func _largest_category_amount(categories: Dictionary) -> float:
	var best := 0.0
	for amount_variant in categories.values():
		best = maxf(best, float(amount_variant))
	return best

func _money_text(amount: float) -> String:
	return "$%s" % String.num(amount, 0)

func _signed_money_text(amount: float) -> String:
	return ("+$%s" % String.num(amount, 0)) if amount >= 0.0 else ("-$%s" % String.num(absf(amount), 0))

func _month_name(month: int) -> String:
	var names := [
		"", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
		"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
	]
	if month < 1 or month >= names.size():
		return "Month"
	return names[month]

func _has_property(target: Object, prop_name: String) -> bool:
	if target == null:
		return false
	for prop in target.get_property_list():
		if String(prop.get("name", "")) == prop_name:
			return true
	return false
