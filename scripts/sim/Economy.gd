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
@export var monthly_goal_bonus_base := 1800.0
@export var monthly_goal_penalty_base := 850.0
@export var milestone_check_interval_s := 1.0
@export var service_contract_check_interval_s := 1.0
@export var service_contract_duration_s := 150.0
@export var service_contract_cooldown_s := 45.0
@export var service_contract_reward_base := 2600.0
@export var service_contract_penalty_base := 900.0
var _monthly_income_categories := {}
var _monthly_expense_categories := {}
var _last_month_report := {}
var _finance_history: Array[Dictionary] = []
var _current_period_label := "May 1900"
var _track_builder: Node
var _town_manager: Node
var _corridor: Node
var _stop_placer: Node
var _passenger_manager: Node
var _current_goal := {}
var _last_goal_result := {}
var _goal_banner_text := ""
var _goal_banner_age_s := 999.0
var _milestone_check_accum := 0.0
var _service_contract_check_accum := 0.0
var _service_contract_cooldown_remaining_s := 8.0
var _active_service_contract := {}
var _earned_milestones := {}
var _baseline_metrics := {}

func _ready() -> void:
	_resolve_world_nodes()
	_start_new_month()
	_baseline_metrics = _network_metrics()

func _process(delta: float) -> void:
	if delta <= 0.0:
		return
	_goal_banner_age_s += delta
	_milestone_check_accum += delta
	_service_contract_check_accum += delta
	if not _active_service_contract.is_empty():
		_active_service_contract["age_s"] = float(_active_service_contract.get("age_s", 0.0)) + delta
	elif _service_contract_cooldown_remaining_s > 0.0:
		_service_contract_cooldown_remaining_s = maxf(0.0, _service_contract_cooldown_remaining_s - delta)
	if _milestone_check_accum >= maxf(milestone_check_interval_s, 0.2):
		_milestone_check_accum = 0.0
		_check_progression_milestones()
	if _service_contract_check_accum >= maxf(service_contract_check_interval_s, 0.2):
		_service_contract_check_accum = 0.0
		_check_service_contract()

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
	_evaluate_monthly_goal()
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
		"Pricing", "Operations":
			return _operations_tab_payload(report)
		_:
			return _overview_tab_payload(report)

func get_finance_snapshot() -> Dictionary:
	return _finance_report_for_display()

func get_monthly_goal_payload() -> Dictionary:
	if _current_goal.is_empty():
		return {}
	var payload: Dictionary = _current_goal.duplicate(true)
	var progress: Dictionary = _evaluate_goal_progress(_current_goal)
	for key_variant in progress.keys():
		payload[key_variant] = progress[key_variant]
	if not _last_goal_result.is_empty():
		payload["last_result"] = _last_goal_result.duplicate(true)
	return payload

func get_service_contract_payload() -> Dictionary:
	if _active_service_contract.is_empty():
		return {}
	var payload: Dictionary = _active_service_contract.duplicate(true)
	var progress: Dictionary = _evaluate_service_contract_progress(_active_service_contract, _network_metrics(), _passenger_snapshot())
	for key_variant in progress.keys():
		payload[key_variant] = progress[key_variant]
	return payload

func get_gameplay_banner_payload() -> Dictionary:
	if _goal_banner_text != "" and _goal_banner_age_s <= 16.0:
		return {"text": _goal_banner_text}
	var contract: Dictionary = get_service_contract_payload()
	if not contract.is_empty():
		return {
			"text": "Contract: %s (%s)" % [
				String(contract.get("short_text", "Keep service moving")),
				String(contract.get("progress_text", ""))
			]
		}
	if _current_goal.is_empty():
		return {}
	var goal: Dictionary = get_monthly_goal_payload()
	if goal.is_empty():
		return {}
	return {
		"text": "Monthly goal: %s (%s)" % [
			String(goal.get("short_text", "Keep the road busy")),
			String(goal.get("progress_text", ""))
		]
	}

func get_advisor_payload() -> Dictionary:
	var report := _finance_report_for_display()
	var metrics: Dictionary = report.get("network_metrics", _network_metrics())
	var snapshot: Dictionary = report.get("passenger_snapshot", _passenger_snapshot())
	var goal: Dictionary = report.get("goal", get_monthly_goal_payload())
	var contract: Dictionary = report.get("service_contract", get_service_contract_payload())
	var next_milestone: Dictionary = _next_milestone_payload(metrics, snapshot)
	var stop_count := int(metrics.get("stop_count", 0))
	var fleet_count := int(metrics.get("fleet_count", 0))
	var depot_count := int(metrics.get("depot_count", 0))
	var track_miles := float(metrics.get("track_length_m", 0.0)) / 1609.344
	var average_rating := float(snapshot.get("average_rating", 75.0))
	var overcrowded_stop_count := int(snapshot.get("overcrowded_stop_count", 0))
	var severe_stop_count := int(snapshot.get("severe_stop_count", 0))
	var worst_stop_name := String(snapshot.get("worst_stop_name", ""))
	var line_pressure := _line_capacity_pressure_payload()
	var recommendation := "Expand toward new riders or tighten headways on the busiest line."
	var short_recommendation := "Expand or tighten service"
	var headline := "Network in good order"
	var severity := "good"
	if stop_count <= 0:
		severity = "setup"
		headline = "Start the railway"
		recommendation = "Open Build and place at least one stop so the rest of the systems have something to serve."
		short_recommendation = "Build a stop"
	elif depot_count <= 0:
		severity = "setup"
		headline = "No depot in service"
		recommendation = "Build a depot so you can launch, store, and recover trolleys without hunting around the map."
		short_recommendation = "Build a depot"
	elif severe_stop_count > 0:
		severity = "urgent"
		headline = "Relieve crowding now"
		recommendation = "Add more cars or tighter headways near %s before service quality collapses." % (worst_stop_name if worst_stop_name != "" else "the busiest stop")
		short_recommendation = "Relieve crowding"
	elif overcrowded_stop_count > 0:
		severity = "watch"
		headline = "Crowding is building"
		recommendation = "Use Routes to lower headways on the busiest segments before the queues spill over."
		short_recommendation = "Tighten headways"
	elif average_rating < 72.0:
		severity = "watch"
		headline = "Service feels unreliable"
		recommendation = "Keep pickups closer together and avoid long waits until the average stop rating climbs."
		short_recommendation = "Raise stop rating"
	elif not line_pressure.is_empty() and float(line_pressure.get("pressure", 0.0)) >= 0.26:
		severity = "watch"
		headline = "Line capacity is tight"
		recommendation = "%s on %s. This is the fastest way to cut waits without laying new track." % [
			String(line_pressure.get("recommendation", "Add service")),
			String(line_pressure.get("line_name", "the busiest line"))
		]
		short_recommendation = String(line_pressure.get("recommendation", "Add service"))
	elif not contract.is_empty():
		headline = "Work the active contract"
		recommendation = String(contract.get("guidance", recommendation))
		short_recommendation = String(contract.get("short_text", "Finish contract"))
	elif not next_milestone.is_empty():
		headline = "Push the next milestone"
		recommendation = String(next_milestone.get("guidance", recommendation))
		short_recommendation = String(next_milestone.get("label", short_recommendation))
	if not goal.is_empty() and contract.is_empty() and severity == "good":
		headline = "Push the monthly goal"
		recommendation = "Current goal: %s. Keep service steady while you expand." % String(goal.get("short_text", "Keep the road busy"))
		short_recommendation = "Hit the monthly goal"
	var goal_text := "Goal: none yet"
	if not goal.is_empty():
		goal_text = "Goal: %s (%s)" % [
			String(goal.get("short_text", "Keep the road busy")),
			String(goal.get("progress_text", ""))
		]
	var milestone_text := "Next milestone: none"
	if not next_milestone.is_empty():
		milestone_text = "Next milestone: %s (%s, +%s)" % [
			String(next_milestone.get("short_text", "")),
			String(next_milestone.get("progress_text", "")),
			_money_text(float(next_milestone.get("bonus", 0.0)))
		]
	var contract_text := "Contract: none"
	if not contract.is_empty():
		contract_text = "Contract: %s (%s, +%s)" % [
			String(contract.get("short_text", "")),
			String(contract.get("progress_text", "")),
			_money_text(float(contract.get("reward", 0.0)))
		]
	return {
		"severity": severity,
		"headline": headline,
		"summary_text": "%d stops | %d cars | %d depots | %.1f mi | %.0f avg stop rating" % [stop_count, fleet_count, depot_count, track_miles, average_rating],
		"recommendation_text": recommendation,
		"short_recommendation": short_recommendation,
		"goal_text": goal_text,
		"goal_progress_ratio": float(goal.get("progress_ratio", 0.0)),
		"contract_text": contract_text,
		"contract_progress_ratio": float(contract.get("progress_ratio", 0.0)),
		"service_contract": contract.duplicate(true),
		"milestone_text": milestone_text,
		"milestone_progress_ratio": float(next_milestone.get("progress_ratio", 0.0)),
		"next_milestone": next_milestone.duplicate(true)
	}

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
	_passenger_manager = world_root.get_node_or_null("PassengerManager")

func _start_new_month() -> void:
	monthly_revenue = 0.0
	monthly_expenses = 0.0
	_monthly_income_categories.clear()
	_monthly_expense_categories.clear()
	_ensure_reporting_categories()
	_resolve_world_nodes()
	_apply_monthly_operating_budget()
	_seed_monthly_goal()

func _ensure_reporting_categories() -> void:
	for category in ["Urban passenger", "Interurban passenger", "Excursion traffic", "Passenger fares", "Capital refunds", "Operating bonus", "Milestone bonus", "Service contract bonus"]:
		_monthly_income_categories[category] = float(_monthly_income_categories.get(category, 0.0))
	for category in ["Crew wages", "Power & substations", "Track upkeep", "Car maintenance", "Right-of-way leases", "Debt interest", "Capital spend", "Service claims", "Contract damages"]:
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
	var passenger_snapshot := _passenger_snapshot()
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
		"network_metrics": metrics,
		"passenger_snapshot": passenger_snapshot,
		"goal": get_monthly_goal_payload(),
		"service_contract": get_service_contract_payload()
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
	var goal: Dictionary = report.get("goal", get_monthly_goal_payload())
	var track_miles := float(metrics.get("track_length_m", 0.0)) / 1609.344
	var stop_count := int(metrics.get("stop_count", 0))
	var fleet_count := int(metrics.get("fleet_count", 0))
	var goal_label := "Stops / cars"
	var goal_amount := "%d / %d" % [stop_count, fleet_count]
	var goal_value := clampf(float(fleet_count) / maxf(float(stop_count), 1.0), 0.0, 1.0)
	if not goal.is_empty():
		goal_label = String(goal.get("short_label", "Monthly goal"))
		goal_amount = String(goal.get("progress_text", ""))
		goal_value = float(goal.get("progress_ratio", 0.0))
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
			_entry(goal_label, goal_amount, goal_value, Color("3f8a8a"))
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

func _operations_tab_payload(report: Dictionary) -> Dictionary:
	var passenger_snapshot: Dictionary = report.get("passenger_snapshot", {})
	var average_stop_rating := float(passenger_snapshot.get("average_rating", float(report.get("service_rating", 78.0))))
	var overcrowded_stop_count := int(passenger_snapshot.get("overcrowded_stop_count", 0))
	var worst_stop_name := String(passenger_snapshot.get("worst_stop_name", ""))
	var worst_stop_waiting := int(passenger_snapshot.get("worst_stop_waiting", 0))
	var goal: Dictionary = report.get("goal", get_monthly_goal_payload())
	var contract: Dictionary = report.get("service_contract", get_service_contract_payload())
	var advisor: Dictionary = get_advisor_payload()
	var next_milestone: Dictionary = advisor.get("next_milestone", {})
	var metrics: Dictionary = report.get("network_metrics", {})
	var severity := String(advisor.get("severity", "good"))
	var crowding_value := clampf(float(overcrowded_stop_count) / 5.0, 0.0, 1.0)
	var crowding_text := "%d stops" % overcrowded_stop_count
	if worst_stop_name != "":
		crowding_text = "%d stops | %s %d" % [overcrowded_stop_count, worst_stop_name, worst_stop_waiting]
	var goal_text := String(goal.get("progress_text", "Not set"))
	var goal_ratio := float(goal.get("progress_ratio", 0.0))
	var milestone_text := String(next_milestone.get("progress_text", "No milestone"))
	var milestone_ratio := float(next_milestone.get("progress_ratio", 0.0))
	var contract_text := String(contract.get("progress_text", "No active contract"))
	var contract_ratio := float(contract.get("progress_ratio", 0.0))
	var line_pressure := _line_capacity_pressure_payload()
	var line_text := "No line pressure"
	var line_ratio := 1.0
	if not line_pressure.is_empty():
		line_text = "%s | %d/%d cars | %.1f min | %s" % [
			String(line_pressure.get("line_name", "")),
			int(line_pressure.get("fleet_count", 0)),
			int(line_pressure.get("suggested_cars", 1)),
			float(line_pressure.get("average_headway_min", 0.0)),
			String(line_pressure.get("recommendation", "Stable"))
		]
		line_ratio = 1.0 - clampf(float(line_pressure.get("pressure", 0.0)), 0.0, 1.0)
	var severity_color := _advisor_severity_color(severity)
	var severity_value := _advisor_severity_value(severity)
	return {
		"title": "Operations & guidance",
		"rows": [
			_entry("Priority", String(advisor.get("headline", "Network in good order")), severity_value, severity_color),
			_entry("Current goal", goal_text, goal_ratio, Color("3f8a8a")),
			_entry("Service contract", contract_text, contract_ratio, Color("8c6a4a")),
			_entry("Line capacity", line_text, line_ratio, Color("3f8a8a")),
			_entry("Crowding hot spots", crowding_text, 1.0 - crowding_value, Color("caa76a"))
		],
		"summary": [
			_entry("Action", String(advisor.get("short_recommendation", "Expand")), severity_value, severity_color),
			_entry("Next milestone", milestone_text, milestone_ratio, Color("3f8a8a"))
		]
	}

func _line_operations_snapshot() -> Array[Dictionary]:
	if _corridor != null and _corridor.has_method("get_line_operations_snapshot"):
		var snapshot: Variant = _corridor.call("get_line_operations_snapshot")
		if snapshot is Array:
			var lines: Array[Dictionary] = []
			for line_variant in snapshot:
				if line_variant is Dictionary:
					lines.append(line_variant)
			return lines
	return []

func _line_capacity_pressure_payload() -> Dictionary:
	var lines := _line_operations_snapshot()
	var worst := {}
	var worst_pressure := -1.0
	for line_variant in lines:
		var line: Dictionary = line_variant
		var pressure := float(line.get("capacity_pressure", 0.0))
		if pressure > worst_pressure:
			worst_pressure = pressure
			worst = line
	if worst.is_empty():
		return {}
	return {
		"line_id": String(worst.get("line_id", "")),
		"line_name": String(worst.get("name", "")),
		"pressure": clampf(float(worst.get("capacity_pressure", 0.0)), 0.0, 1.0),
		"fleet_count": int(worst.get("fleet_count", 0)),
		"suggested_cars": int(worst.get("suggested_cars", 1)),
		"average_headway_min": float(worst.get("average_headway_min", 0.0)),
		"recommendation": String(worst.get("recommendation", "Service stable"))
	}

func _passenger_snapshot() -> Dictionary:
	if _passenger_manager != null and _passenger_manager.has_method("get_network_gameplay_snapshot"):
		var snapshot: Dictionary = _passenger_manager.call("get_network_gameplay_snapshot")
		return snapshot
	return {}

func _seed_monthly_goal() -> void:
	_resolve_world_nodes()
	var metrics := _network_metrics()
	var snapshot := _passenger_snapshot()
	var stop_count := int(metrics.get("stop_count", 0))
	if stop_count <= 0:
		_current_goal = {}
		return
	var selector: int = abs(_current_period_label.hash()) % 3
	match selector:
		0:
			var target_rating := clampf(round(maxf(68.0, float(snapshot.get("average_rating", 72.0)) + 4.0)), 70.0, 88.0)
			_current_goal = {
				"kind": "service_rating",
				"short_label": "Stop rating",
				"short_text": "Average stop rating >= %.0f" % target_rating,
				"description": "Keep pickup intervals tight and platforms under control.",
				"target": target_rating,
				"bonus": monthly_goal_bonus_base + float(stop_count) * 90.0,
				"penalty": monthly_goal_penalty_base + float(stop_count) * 35.0
			}
		1:
			var current_hotspots := int(snapshot.get("overcrowded_stop_count", 0))
			var target_hotspots := maxi(0, mini(current_hotspots, maxi(1, stop_count / 6)))
			_current_goal = {
				"kind": "crowding",
				"short_label": "Crowding",
				"short_text": "Overcrowded stops <= %d" % target_hotspots,
				"description": "Prevent platform buildup at the busiest stations.",
				"target": target_hotspots,
				"bonus": monthly_goal_bonus_base + float(stop_count) * 110.0,
				"penalty": monthly_goal_penalty_base + float(stop_count) * 42.0
			}
		_:
			var reserve_target := maxf(220000.0 + float(stop_count) * 3500.0, cash * 0.92)
			_current_goal = {
				"kind": "cash_reserve",
				"short_label": "Cash reserve",
				"short_text": "Cash reserve >= %s" % _money_text(reserve_target),
				"description": "Finish the month with enough cash to extend and maintain service.",
				"target": reserve_target,
				"bonus": monthly_goal_bonus_base + float(int(metrics.get("fleet_count", 0))) * 140.0,
				"penalty": monthly_goal_penalty_base + float(stop_count) * 28.0
			}

func _evaluate_monthly_goal() -> void:
	if _current_goal.is_empty():
		return
	var progress: Dictionary = _evaluate_goal_progress(_current_goal)
	var achieved := bool(progress.get("achieved", false))
	var amount := float(_current_goal.get("bonus", 0.0)) if achieved else float(_current_goal.get("penalty", 0.0))
	if achieved and amount > 0.0:
		apply_revenue(amount, "Operating bonus")
	elif amount > 0.0:
		apply_expense(amount, "Service claims")
	_last_goal_result = {
		"period": _current_period_label,
		"achieved": achieved,
		"short_text": String(_current_goal.get("short_text", "")),
		"progress_text": String(progress.get("progress_text", "")),
		"amount": amount
	}
	_show_gameplay_banner("Goal met: %s (+%s)" % [String(_current_goal.get("short_text", "")), _money_text(amount)] if achieved else "Goal missed: %s (-%s)" % [String(_current_goal.get("short_text", "")), _money_text(amount)])

func _evaluate_goal_progress(goal: Dictionary) -> Dictionary:
	if goal.is_empty():
		return {}
	var kind := String(goal.get("kind", ""))
	match kind:
		"service_rating":
			var snapshot := _passenger_snapshot()
			var value := float(snapshot.get("average_rating", 75.0))
			var target := float(goal.get("target", 75.0))
			return {
				"achieved": value >= target,
				"progress_ratio": clampf(value / maxf(target, 1.0), 0.0, 1.0),
				"progress_text": "%.0f / %.0f" % [value, target]
			}
		"crowding":
			var snapshot := _passenger_snapshot()
			var value := int(snapshot.get("overcrowded_stop_count", 0))
			var target := int(goal.get("target", 0))
			var range_scale := maxf(2.0, float(target + 2))
			return {
				"achieved": value <= target,
				"progress_ratio": clampf(1.0 - float(maxi(0, value - target)) / range_scale, 0.0, 1.0),
				"progress_text": "%d / %d hot spots" % [value, target]
			}
		"cash_reserve":
			var value := cash
			var target := float(goal.get("target", cash))
			return {
				"achieved": value >= target,
				"progress_ratio": clampf(value / maxf(target, 1.0), 0.0, 1.0),
				"progress_text": "%s / %s" % [_money_text(value), _money_text(target)]
			}
	return {}

func _check_service_contract() -> void:
	_resolve_world_nodes()
	var metrics := _network_metrics()
	var snapshot := _passenger_snapshot()
	if _active_service_contract.is_empty():
		if _service_contract_cooldown_remaining_s > 0.0 or int(metrics.get("stop_count", 0)) <= 0:
			return
		_active_service_contract = _build_next_service_contract(metrics, snapshot)
		_service_contract_cooldown_remaining_s = service_contract_cooldown_s
		if not _active_service_contract.is_empty():
			_show_gameplay_banner("New contract: %s (+%s)" % [
				String(_active_service_contract.get("short_text", "Service order")),
				_money_text(float(_active_service_contract.get("reward", 0.0)))
			])
		return
	var progress := _evaluate_service_contract_progress(_active_service_contract, metrics, snapshot)
	for key_variant in progress.keys():
		_active_service_contract[key_variant] = progress[key_variant]
	if bool(progress.get("achieved", false)):
		var reward := float(_active_service_contract.get("reward", 0.0))
		if reward > 0.0:
			apply_revenue(reward, "Service contract bonus")
		_show_gameplay_banner("Contract complete: %s (+%s)" % [
			String(_active_service_contract.get("short_text", "Service order")),
			_money_text(reward)
		])
		_active_service_contract.clear()
		_service_contract_cooldown_remaining_s = service_contract_cooldown_s
	elif float(progress.get("time_left_s", 0.0)) <= 0.0:
		var penalty := float(_active_service_contract.get("penalty", 0.0))
		if penalty > 0.0:
			apply_expense(penalty, "Contract damages")
		_show_gameplay_banner("Contract expired: %s (-%s)" % [
			String(_active_service_contract.get("short_text", "Service order")),
			_money_text(penalty)
		])
		_active_service_contract.clear()
		_service_contract_cooldown_remaining_s = service_contract_cooldown_s

func _build_next_service_contract(metrics: Dictionary, snapshot: Dictionary) -> Dictionary:
	var stop_count := int(metrics.get("stop_count", 0))
	if stop_count <= 0:
		return {}
	var fleet_count := int(metrics.get("fleet_count", 0))
	var depot_count := int(metrics.get("depot_count", 0))
	var average_rating := float(snapshot.get("average_rating", 75.0))
	var overcrowded_stop_count := int(snapshot.get("overcrowded_stop_count", 0))
	var severe_stop_count := int(snapshot.get("severe_stop_count", 0))
	var worst_stop_name := String(snapshot.get("worst_stop_name", ""))
	var worst_stop_waiting := int(snapshot.get("worst_stop_waiting", 0))
	var reward := service_contract_reward_base + float(stop_count) * 95.0 + float(fleet_count) * 180.0
	var penalty := service_contract_penalty_base + float(stop_count) * 24.0
	if depot_count <= 0:
		return _service_contract_payload(
			"open_depot",
			"Carhouse grant",
			"Build 1 depot",
			"Build a depot so cars can launch, recover, and stop deadheading around the map.",
			reward + 1200.0,
			penalty,
			{"target_depots": 1}
		)
	if severe_stop_count > 0 and worst_stop_name != "":
		var target_waiting := maxi(8, mini(14, int(round(float(worst_stop_waiting) * 0.55))))
		return _service_contract_payload(
			"relieve_hotspot",
			"Relief service order",
			"Relieve %s" % worst_stop_name,
			"Put more cars or better headways on %s until the waiting crowd drops below the target." % worst_stop_name,
			reward + float(worst_stop_waiting) * 70.0,
			penalty + float(severe_stop_count) * 280.0,
			{
				"target_stop": worst_stop_name,
				"start_waiting": worst_stop_waiting,
				"target_waiting": target_waiting,
				"target_rating": 68.0
			}
		)
	var target_fleet := maxi(fleet_count + 1, int(ceil(float(stop_count) / 3.0)))
	if fleet_count < target_fleet:
		return _service_contract_payload(
			"build_capacity",
			"Capacity grant",
			"Run %d cars" % target_fleet,
			"Launch another car and keep the busiest platforms from absorbing the whole timetable.",
			reward + 900.0,
			penalty,
			{"target_fleet": target_fleet}
		)
	if stop_count >= 4 and fleet_count > 0:
		var link_contract := _build_link_service_contract(reward, penalty)
		if not link_contract.is_empty():
			return link_contract
	var target_rating := clampf(round(maxf(76.0, average_rating + 5.0)), 76.0, 90.0)
	return _service_contract_payload(
		"quality_service",
		"Reliability bonus",
		"Reach %.0f stop rating" % target_rating,
		"Keep wait times low and prevent crowding so the public service board releases the bonus.",
		reward + 700.0,
		penalty + float(overcrowded_stop_count) * 120.0,
		{
			"target_rating": target_rating,
			"max_hotspots": maxi(0, mini(overcrowded_stop_count, 1))
		}
	)

func _build_link_service_contract(reward: float, penalty: float) -> Dictionary:
	var stop_names := _service_contract_stop_names()
	if stop_names.size() < 2:
		return {}
	var seed_text := _current_period_label + "_link_" + str(Time.get_ticks_msec() / 1000)
	var seed: int = int(seed_text.hash())
	if seed < 0:
		seed = -seed
	var stop_count: int = stop_names.size()
	var origin_idx: int = seed % stop_count
	var min_gap: int = maxi(1, mini(stop_count - 1, int(stop_count / 3)))
	var span: int = maxi(1, stop_count - min_gap)
	var offset_seed: int = int(float(seed) / float(maxi(1, stop_count)))
	var destination_idx: int = (origin_idx + min_gap + (offset_seed % span)) % stop_count
	if destination_idx == origin_idx:
		destination_idx = (origin_idx + min_gap) % stop_count
	var origin_stop := String(stop_names[origin_idx])
	var destination_stop := String(stop_names[destination_idx])
	if origin_stop == "" or destination_stop == "" or origin_stop == destination_stop:
		return {}
	var difficulty_bonus := clampf(float(abs(destination_idx - origin_idx)) / maxf(float(stop_count - 1), 1.0), 0.25, 1.0)
	return _service_contract_payload(
		"link_service",
		"Municipal route subsidy",
		"Serve %s -> %s" % [origin_stop, destination_stop],
		"Run the controlled car through %s, then reach %s before the offer expires." % [origin_stop, destination_stop],
		reward + 1200.0 + difficulty_bonus * 1600.0,
		penalty + 450.0 + difficulty_bonus * 650.0,
		{
			"origin_stop": origin_stop,
			"destination_stop": destination_stop,
			"origin_served": false,
			"destination_served": false
		}
	)

func _service_contract_stop_names() -> Array[String]:
	_resolve_world_nodes()
	var names: Array[String] = []
	if _town_manager == null or not _has_property(_town_manager, "stops"):
		return names
	var stops: Array = _town_manager.get("stops")
	for stop in stops:
		if stop == null:
			continue
		var name := String(stop.town_name)
		if name == "" or names.has(name):
			continue
		names.append(name)
	return names

func _service_contract_payload(kind: String, label: String, short_text: String, guidance: String, reward: float, penalty: float, extra: Dictionary) -> Dictionary:
	var payload := {
		"id": "%s_%d" % [kind, Time.get_ticks_msec()],
		"kind": kind,
		"label": label,
		"short_text": short_text,
		"guidance": guidance,
		"reward": reward,
		"penalty": penalty,
		"duration_s": service_contract_duration_s,
		"age_s": 0.0,
		"progress_ratio": 0.0,
		"progress_text": ""
	}
	for key_variant in extra.keys():
		payload[key_variant] = extra[key_variant]
	return payload

func _evaluate_service_contract_progress(contract: Dictionary, metrics: Dictionary, snapshot: Dictionary) -> Dictionary:
	if contract.is_empty():
		return {}
	var kind := String(contract.get("kind", ""))
	var age := float(contract.get("age_s", 0.0))
	var duration := maxf(1.0, float(contract.get("duration_s", service_contract_duration_s)))
	var time_left := maxf(0.0, duration - age)
	var result := {
		"achieved": false,
		"progress_ratio": 0.0,
		"progress_text": "",
		"time_left_s": time_left
	}
	match kind:
		"open_depot":
			var depot_count := int(metrics.get("depot_count", 0))
			var target_depots := int(contract.get("target_depots", 1))
			result["achieved"] = depot_count >= target_depots
			result["progress_ratio"] = clampf(float(depot_count) / maxf(float(target_depots), 1.0), 0.0, 1.0)
			result["progress_text"] = "%d / %d depots | %.0fs" % [depot_count, target_depots, time_left]
		"build_capacity":
			var fleet_count := int(metrics.get("fleet_count", 0))
			var target_fleet := int(contract.get("target_fleet", 1))
			result["achieved"] = fleet_count >= target_fleet
			result["progress_ratio"] = clampf(float(fleet_count) / maxf(float(target_fleet), 1.0), 0.0, 1.0)
			result["progress_text"] = "%d / %d cars | %.0fs" % [fleet_count, target_fleet, time_left]
		"relieve_hotspot":
			var stop_name := String(contract.get("target_stop", ""))
			var stop_snapshot := {}
			if _passenger_manager != null and _passenger_manager.has_method("get_stop_service_snapshot"):
				stop_snapshot = _passenger_manager.call("get_stop_service_snapshot", stop_name)
			var waiting := int(stop_snapshot.get("waiting", int(snapshot.get("worst_stop_waiting", 0))))
			var rating := float(stop_snapshot.get("rating", float(snapshot.get("average_rating", 75.0))))
			var target_waiting := int(contract.get("target_waiting", 12))
			var start_waiting := maxi(target_waiting + 1, int(contract.get("start_waiting", waiting)))
			var target_rating := float(contract.get("target_rating", 68.0))
			var wait_ratio := clampf(1.0 - float(maxi(0, waiting - target_waiting)) / maxf(1.0, float(start_waiting - target_waiting)), 0.0, 1.0)
			var rating_ratio := clampf(rating / maxf(target_rating, 1.0), 0.0, 1.0)
			result["achieved"] = waiting <= target_waiting and rating >= target_rating
			result["progress_ratio"] = clampf((wait_ratio + rating_ratio) * 0.5, 0.0, 1.0)
			result["progress_text"] = "%s %d/%d waiting | %.0fs" % [stop_name, waiting, target_waiting, time_left]
		"quality_service":
			var average_rating := float(snapshot.get("average_rating", 75.0))
			var overcrowded_stop_count := int(snapshot.get("overcrowded_stop_count", 0))
			var target_rating := float(contract.get("target_rating", 78.0))
			var max_hotspots := int(contract.get("max_hotspots", 1))
			var rating_ratio := clampf(average_rating / maxf(target_rating, 1.0), 0.0, 1.0)
			var hotspot_ratio := clampf(1.0 - float(maxi(0, overcrowded_stop_count - max_hotspots)) / 4.0, 0.0, 1.0)
			result["achieved"] = average_rating >= target_rating and overcrowded_stop_count <= max_hotspots
			result["progress_ratio"] = clampf((rating_ratio + hotspot_ratio) * 0.5, 0.0, 1.0)
			result["progress_text"] = "%.0f/%.0f rating | %d/%d hot spots | %.0fs" % [average_rating, target_rating, overcrowded_stop_count, max_hotspots, time_left]
		"link_service":
			var origin_stop := String(contract.get("origin_stop", ""))
			var destination_stop := String(contract.get("destination_stop", ""))
			var origin_served := bool(contract.get("origin_served", false))
			var destination_served := bool(contract.get("destination_served", false))
			var recent_station := _recent_driver_service_station()
			if not origin_served and recent_station == origin_stop:
				origin_served = true
			elif origin_served and not destination_served and recent_station == destination_stop:
				destination_served = true
			result["origin_served"] = origin_served
			result["destination_served"] = destination_served
			result["achieved"] = origin_served and destination_served
			result["progress_ratio"] = (0.5 if origin_served else 0.0) + (0.5 if destination_served else 0.0)
			var origin_text := "done" if origin_served else "start"
			var destination_text := "done" if destination_served else "target"
			result["progress_text"] = "%s %s -> %s %s | %.0fs" % [origin_stop, origin_text, destination_stop, destination_text, time_left]
	return result

func _recent_driver_service_station(max_age_s: float = 8.0) -> String:
	if _corridor == null or not is_instance_valid(_corridor):
		_resolve_world_nodes()
	if _corridor == null or not _corridor.has_method("get_driver_passenger_status"):
		return ""
	var payload: Dictionary = _corridor.call("get_driver_passenger_status")
	if float(payload.get("last_service_age_s", 999.0)) > max_age_s:
		return ""
	return String(payload.get("last_service_station", ""))

func _check_progression_milestones() -> void:
	_resolve_world_nodes()
	var metrics := _network_metrics()
	if _baseline_metrics.is_empty():
		_baseline_metrics = metrics.duplicate(true)
	var snapshot := _passenger_snapshot()
	for milestone_variant in _build_milestone_payloads(metrics, snapshot):
		var milestone: Dictionary = milestone_variant
		var milestone_id := String(milestone.get("id", ""))
		if milestone_id == "" or _earned_milestones.has(milestone_id):
			continue
		if not bool(milestone.get("achieved", false)):
			continue
		_earned_milestones[milestone_id] = milestone.duplicate(true)
		var bonus := float(milestone.get("bonus", 0.0))
		if bonus > 0.0:
			apply_revenue(bonus, "Milestone bonus")
		_show_gameplay_banner("Milestone: %s (+%s)" % [String(milestone.get("label", "Expansion")), _money_text(bonus)])

func _build_milestone_payloads(metrics: Dictionary, snapshot: Dictionary) -> Array[Dictionary]:
	var milestones: Array[Dictionary] = []
	var baseline_stop_count := int(_baseline_metrics.get("stop_count", 0))
	var baseline_depot_count := int(_baseline_metrics.get("depot_count", 0))
	var baseline_track_length_m := float(_baseline_metrics.get("track_length_m", 0.0))
	var stop_count := int(metrics.get("stop_count", 0))
	var depot_count := int(metrics.get("depot_count", 0))
	var track_length_m := float(metrics.get("track_length_m", 0.0))
	var new_stops := maxi(0, stop_count - baseline_stop_count)
	var new_depots := maxi(0, depot_count - baseline_depot_count)
	var new_track_m := maxf(0.0, track_length_m - baseline_track_length_m)
	var average_rating := float(snapshot.get("average_rating", 75.0))
	var overcrowded_stop_count := int(snapshot.get("overcrowded_stop_count", 0))
	milestones.append({
		"id": "new_stop",
		"label": "Open a new stop",
		"short_text": "Add 1 new stop",
		"guidance": "Use Build and place one more stop so the line keeps reaching fresh riders.",
		"bonus": 2200.0,
		"achieved": new_stops >= 1,
		"progress_ratio": clampf(float(new_stops), 0.0, 1.0),
		"progress_text": "%d / 1 new stops" % new_stops
	})
	milestones.append({
		"id": "new_depot",
		"label": "Build a new depot",
		"short_text": "Add 1 depot",
		"guidance": "Build a depot so the Operations window can actually help you manage launches and storage.",
		"bonus": 3200.0,
		"achieved": new_depots >= 1,
		"progress_ratio": clampf(float(new_depots), 0.0, 1.0),
		"progress_text": "%d / 1 depots" % new_depots
	})
	milestones.append({
		"id": "track_extension",
		"label": "Push the line outward",
		"short_text": "Add 500m of track",
		"guidance": "Lay more track to reach a new market or to give the current service more room to run.",
		"bonus": 4500.0,
		"achieved": new_track_m >= 500.0,
		"progress_ratio": clampf(new_track_m / 500.0, 0.0, 1.0),
		"progress_text": "%.0f / 500m new track" % new_track_m
	})
	var service_ratio := clampf(average_rating / 80.0, 0.0, 1.0)
	var hotspot_ratio := clampf(1.0 - float(maxi(0, overcrowded_stop_count - 1)) / 4.0, 0.0, 1.0)
	milestones.append({
		"id": "steady_service",
		"label": "Run a steady railway",
		"short_text": "Reach 80 stop rating",
		"guidance": "Use Routes and faster pickups to reach an 80 average stop rating while keeping crowding under control.",
		"bonus": 5200.0,
		"achieved": average_rating >= 80.0 and overcrowded_stop_count <= 1,
		"progress_ratio": clampf((service_ratio + hotspot_ratio) * 0.5, 0.0, 1.0),
		"progress_text": "%.0f / 80 rating | %d hot spots" % [average_rating, overcrowded_stop_count]
	})
	return milestones

func _next_milestone_payload(metrics: Dictionary, snapshot: Dictionary) -> Dictionary:
	for milestone_variant in _build_milestone_payloads(metrics, snapshot):
		var milestone: Dictionary = milestone_variant
		if _earned_milestones.has(String(milestone.get("id", ""))):
			continue
		return milestone
	return {}

func _show_gameplay_banner(text: String) -> void:
	if text == "":
		return
	_goal_banner_text = text
	_goal_banner_age_s = 0.0

func _advisor_severity_color(severity: String) -> Color:
	match severity:
		"setup":
			return Color("8c6a4a")
		"watch":
			return Color("caa76a")
		"urgent":
			return Color("b34a3f")
		_:
			return Color("6f8b52")

func _advisor_severity_value(severity: String) -> float:
	match severity:
		"setup":
			return 0.45
		"watch":
			return 0.62
		"urgent":
			return 0.92
		_:
			return 0.84

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
