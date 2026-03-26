extends Node3D
class_name VehicleSim

class VehicleState:
	var id: int
	var capacity: int
	var speed: float
	var power_draw_kw: float
	var reliability: float
	var maintenance_cost: float
	var position := Vector3.ZERO
	var route_id := ""

var vehicles: Array[VehicleState] = []

func spawn_vehicle(data: Dictionary) -> VehicleState:
	var vehicle := VehicleState.new()
	vehicle.id = data.get("id", vehicles.size())
	vehicle.capacity = data.get("capacity", 40)
	vehicle.speed = data.get("speed", 12.0)
	vehicle.power_draw_kw = data.get("power_draw_kw", 180.0)
	vehicle.reliability = data.get("reliability", 0.95)
	vehicle.maintenance_cost = data.get("maintenance_cost", 40.0)
	vehicle.route_id = data.get("route_id", "")
	vehicles.append(vehicle)
	return vehicle

func _process(delta: float) -> void:
	# Placeholder: advance vehicles along assigned routes.
	pass
