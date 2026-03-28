extends Node
class_name CorridorSeed

const METERS_PER_MILE := 1609.344
const GeoProjectorScript := preload("res://scripts/geo/GeoProjector.gd")
const PCCCarScenePath := "res://scenes/transit/PCCCar.tscn"
const Type5CarScenePath := "res://scenes/transit/Type5Car.tscn"
const AtlanticElCarScenePath := "res://scenes/transit/AtlanticElCar.tscn"
const WashingtonTunnelTrainScenePath := "res://scenes/transit/WashingtonTunnelTrain.tscn"
const CambridgeDorchesterCarScenePath := "res://scenes/transit/CambridgeDorchesterCar.tscn"
const BlueLineCarScenePath := "res://scenes/transit/BlueLineCar.tscn"
const SnowPlowCarScenePath := "res://scenes/transit/SnowPlowCar.tscn"
const TrackBlendShader := preload("res://shaders/TrackBlend.gdshader")
const MainLineServiceId := "mainline"
const GreenAServiceId := "green_a"
const GreenBServiceId := "green_b"
const GreenCServiceId := "green_c"
const GreenDServiceId := "green_d"
const GreenEServiceId := "green_e"
const OrangeServiceId := "orange"
const BlueServiceId := "blue"
const AtlanticServiceId := "atlantic"
const WashingtonServiceId := "washington"
const CambridgeServiceId := "cambridge"
const MattapanServiceId := "mattapan"
const BallastAlbedoPath := "res://assets/textures/track_materials/clean_pebbles/clean_pebbles_diff_1k.jpg"
const BallastRoughnessPath := "res://assets/textures/track_materials/clean_pebbles/clean_pebbles_rough_1k.jpg"
const SleeperAlbedoPath := "res://assets/textures/track_materials/weathered_planks/weathered_planks_diff_1k.jpg"
const SleeperRoughnessPath := "res://assets/textures/track_materials/weathered_planks/weathered_planks_rough_1k.jpg"
const RailAlbedoPath := "res://assets/textures/track_materials/metal_plate_02/metal_plate_02_diff_1k.jpg"
const RailRoughnessPath := "res://assets/textures/track_materials/metal_plate_02/metal_plate_02_rough_1k.jpg"
const BrickAlbedoPath := "res://assets/textures/period_boston/castle_brick_02_red/castle_brick_02_red_diff_1k.jpg"
const BrickRoughnessPath := "res://assets/textures/period_boston/castle_brick_02_red/castle_brick_02_red_rough_1k.jpg"
const BrickNormalPath := "res://assets/textures/period_boston/castle_brick_02_red/castle_brick_02_red_nor_gl_1k.jpg"
const PlasterAlbedoPath := "res://assets/textures/period_boston/worn_plaster_wall/worn_plaster_wall_diff_1k.jpg"
const PlasterRoughnessPath := "res://assets/textures/period_boston/worn_plaster_wall/worn_plaster_wall_rough_1k.jpg"
const PlasterNormalPath := "res://assets/textures/period_boston/worn_plaster_wall/worn_plaster_wall_nor_gl_1k.jpg"
const TileAlbedoPath := "res://assets/textures/period_boston/worn_tile_floor/worn_tile_floor_diff_1k.jpg"
const TileRoughnessPath := "res://assets/textures/period_boston/worn_tile_floor/worn_tile_floor_rough_1k.jpg"
const TileNormalPath := "res://assets/textures/period_boston/worn_tile_floor/worn_tile_floor_nor_gl_1k.jpg"
const CobbleAlbedoPath := "res://assets/textures/period_boston/cobblestone_floor_04/cobblestone_floor_04_diff_1k.jpg"
const CobbleRoughnessPath := "res://assets/textures/period_boston/cobblestone_floor_04/cobblestone_floor_04_rough_1k.jpg"
const CobbleNormalPath := "res://assets/textures/period_boston/cobblestone_floor_04/cobblestone_floor_04_nor_gl_1k.jpg"
const AsphaltAlbedoPath := "res://assets/textures/period_boston/asphalt_02/asphalt_02_diff_1k.jpg"
const AsphaltRoughnessPath := "res://assets/textures/period_boston/asphalt_02/asphalt_02_rough_1k.jpg"
const AsphaltNormalPath := "res://assets/textures/period_boston/asphalt_02/asphalt_02_nor_gl_1k.jpg"

@export var town_manager_path: NodePath
@export var track_builder_path: NodePath
@export var auto_seed := true
@export var frequency := 6.0
@export var total_length_m := 67592.0
@export var anchor_at_first_stop := true
@export var line_name := "Boston–Worcester Air Line (Route 9)"
@export var use_geo_path := true
@export var bounds: Resource = preload("res://data/ma_bounds.tres")
@export var world_size_m := Vector2(350000.0, 240000.0)
@export var reset_network := true
@export var build_subway_design := true
@export var subway_root_name := "BostonSubway"
@export var subway_depth := -8.0
@export var subway_tunnel_height := 6.2
@export var subway_wall_thickness := 0.9
@export var subway_roof_thickness := 0.8
@export var subway_floor_thickness := 0.8
@export var subway_track_bed_height := 0.45
@export var subway_light_spacing := 30.0
@export var subway_ring_spacing := 18.0
@export var subway_column_spacing := 20.0
@export var subway_service_walkway_width := 1.15
@export var subway_cover_margin := 7.0
@export var subway_cover_thickness := 0.85
@export var subway_shaft_width := 4.8
@export var subway_shaft_length := 5.4
@export var subway_bore_inner_width := 8.4
@export var subway_tile_band_height := 1.3
@export var subway_wire_height := 1.55
@export var subway_platform_canopy_height := 2.65
@export var subway_platform_canopy_width := 3.6
@export var subway_bench_length := 3.8
@export var subway_segment_end_open_length := 18.0
@export var subway_junction_extra_open_length := 16.0
@export var subway_junction_wall_push := 4.5
@export var subway_station_names := PackedStringArray([
	"Park Street",
	"Boylston",
	"Arlington",
	"Copley",
	"Massachusetts Avenue",
	"Kenmore"
])
@export var build_north_terminal_extension := true
@export var north_terminal_root_name := "NorthTerminalExtension"
@export var north_subway_station_names := PackedStringArray([
	"Park Street",
	"Scollay Square",
	"Adams Square",
	"Haymarket",
	"Friend Street",
	"North Station"
])
@export var north_subway_geo := PackedVector2Array([
	Vector2(-71.0628, 42.3564), # Park Street
	Vector2(-71.0595, 42.3595), # Scollay Square / Government Center
	Vector2(-71.0580, 42.3608), # Adams Square
	Vector2(-71.0583, 42.3626), # Haymarket
	Vector2(-71.0600, 42.3642), # Friend Street
	Vector2(-71.0614, 42.3656)  # North Station / Causeway
])
@export var build_elevated_layer := true
@export var elevated_root_name := "LechmereElevated"
@export var elevated_deck_height := 8.5
@export var elevated_station_names := PackedStringArray([
	"Lechmere",
	"Science Museum"
])
@export var elevated_geo := PackedVector2Array([
	Vector2(-71.0766, 42.3705), # Lechmere
	Vector2(-71.0705, 42.3674)  # Science Museum / Charles approach
])
@export var lechmere_turnback_tail_m := 140.0
@export var build_atlantic_avenue_elevated := true
@export var atlantic_elevated_root_name := "AtlanticAvenueElevated"
@export var atlantic_elevated_deck_height := 10.0
@export var atlantic_elevated_station_names := PackedStringArray([
	"North Station (Atlantic)",
	"Battery",
	"State (Atlantic)",
	"Rowes Wharf",
	"South Station (Atlantic)",
	"Beach"
])
@export var atlantic_elevated_geo := PackedVector2Array([
	Vector2(-71.0602, 42.3656),
	Vector2(-71.0557, 42.3627),
	Vector2(-71.0538, 42.3588),
	Vector2(-71.0518, 42.3557),
	Vector2(-71.0549, 42.3522),
	Vector2(-71.0569, 42.3497)
])
@export var build_orange_line_elevated := true
@export var orange_line_root_name := "OrangeMainLineElevated"
@export var orange_elevated_deck_height := 10.4
@export var orange_north_station_names := PackedStringArray([
	"Sullivan Square",
	"City Square",
	"North Station"
])
@export var orange_north_geo := PackedVector2Array([
	Vector2(-71.0765, 42.3830),
	Vector2(-71.0671, 42.3750),
	Vector2(-71.0602, 42.3656)
])
@export var orange_south_station_names := PackedStringArray([
	"Dover",
	"Northampton",
	"Dudley",
	"Egleston",
	"Green Street",
	"Forest Hills"
])
@export var orange_south_geo := PackedVector2Array([
	Vector2(-71.0637, 42.3497),
	Vector2(-71.0784, 42.3384),
	Vector2(-71.0837, 42.3287),
	Vector2(-71.0955, 42.3151),
	Vector2(-71.1073, 42.3100),
	Vector2(-71.1138, 42.3007)
])
@export var build_washington_street_tunnel := true
@export var washington_street_root_name := "WashingtonStreetTunnel"
@export var washington_street_station_names := PackedStringArray([
	"Haymarket (Wash)",
	"State (Wash)",
	"Summer",
	"Essex",
	"Dover"
])
@export var washington_street_geo := PackedVector2Array([
	Vector2(-71.0583, 42.3626),
	Vector2(-71.0572, 42.3590),
	Vector2(-71.0605, 42.3555),
	Vector2(-71.0620, 42.3519),
	Vector2(-71.0637, 42.3497)
])
@export var build_cambridge_dorchester_tunnel := true
@export var cambridge_dorchester_root_name := "CambridgeDorchesterTunnel"
@export var cambridge_dorchester_station_names := PackedStringArray([
	"Harvard",
	"Central",
	"Kendall",
	"Charles",
	"Park Street Under",
	"Washington",
	"South Station Under",
	"Broadway",
	"Andrew",
	"Columbia",
	"Savin Hill",
	"Fields Corner",
	"Shawmut",
	"Ashmont"
])
@export var cambridge_dorchester_geo := PackedVector2Array([
	Vector2(-71.1189, 42.3734),
	Vector2(-71.1038, 42.3655),
	Vector2(-71.0862, 42.3625),
	Vector2(-71.0708, 42.3612),
	Vector2(-71.0628, 42.3564),
	Vector2(-71.0605, 42.3555),
	Vector2(-71.0552, 42.3523),
	Vector2(-71.0569, 42.3427),
	Vector2(-71.0577, 42.3302),
	Vector2(-71.0529, 42.3207),
	Vector2(-71.0533, 42.3113),
	Vector2(-71.0617, 42.3001),
	Vector2(-71.0657, 42.2931),
	Vector2(-71.0645, 42.2847)
])
@export var build_mattapan_extension := true
@export var mattapan_root_name := "MattapanHighSpeedLine"
@export var mattapan_track_height := 1.15
@export var mattapan_station_names := PackedStringArray([
	"Ashmont",
	"Cedar Grove",
	"Butler",
	"Milton",
	"Central Avenue",
	"Valley Road",
	"Capen Street",
	"Mattapan"
])
@export var mattapan_geo := PackedVector2Array([
	Vector2(-71.0645, 42.2847), # Ashmont
	Vector2(-71.0633, 42.2794), # Cedar Grove
	Vector2(-71.0661, 42.2751), # Butler
	Vector2(-71.0672, 42.2711), # Milton
	Vector2(-71.0738, 42.2693), # Central Avenue
	Vector2(-71.0812, 42.2674), # Valley Road
	Vector2(-71.0874, 42.2670), # Capen Street
	Vector2(-71.0922, 42.2676)  # Mattapan
])
@export var build_blue_line_phase := true
@export var blue_line_root_name := "EastBostonTunnelPhase"
@export var blue_line_depth := -11.5
@export var blue_line_harbor_depth := -18.0
@export var blue_line_surface_track_height := 0.85
@export var blue_line_tunnel_station_count := 5
@export var blue_line_station_names := PackedStringArray([
	"Bowdoin",
	"Government Center",
	"State",
	"Aquarium",
	"Maverick",
	"Airport",
	"Wood Island",
	"Orient Heights",
	"Suffolk Downs",
	"Beachmont",
	"Revere Beach",
	"Wonderland",
	"Lynn",
	"Salem"
])
@export var blue_line_geo := PackedVector2Array([
	Vector2(-71.0622, 42.3611),
	Vector2(-71.0591, 42.3598),
	Vector2(-71.0573, 42.3589),
	Vector2(-71.0518, 42.3598),
	Vector2(-71.0394, 42.3691),
	Vector2(-71.0302, 42.3743),
	Vector2(-71.0229, 42.3797),
	Vector2(-71.0047, 42.3868),
	Vector2(-70.9978, 42.3905),
	Vector2(-70.9923, 42.3975),
	Vector2(-70.9925, 42.4078),
	Vector2(-70.9910, 42.4134),
	Vector2(-70.9496, 42.4653),
	Vector2(-70.8958, 42.5248)
])
@export var portal_fraction_1 := 0.22
@export var portal_fraction_2 := 0.46
@export var portal_fraction_3 := 0.68
@export var mainline_mileposts := PackedFloat32Array([
	0.0,    # Park Street
	0.35,   # Boylston
	0.75,   # Arlington
	1.20,   # Copley
	1.85,   # Massachusetts Avenue
	2.35,   # Kenmore
	4.00,   # Brookline
	6.50,   # Chestnut Hill
	9.00,   # Newton Centre
	14.50,  # Wellesley Center
	17.50,  # Natick Center
	19.10,  # Framingham Junction / Hastingsville
	21.00,  # Framingham Center
	25.00,  # Fayville (Southborough)
	28.00,  # Whites Corner
	30.50,  # Westborough Center
	34.50,  # Grafton Center
	37.00,  # Shrewsbury Center
	38.00,  # White City
	40.00,  # Belmont Street
	42.00   # Lincoln Square (Worcester)
])
@export var mainline_geo := PackedVector2Array([
	Vector2(-71.0628, 42.3564), # Park Street, Boston
	Vector2(-71.0648, 42.3532), # Boylston
	Vector2(-71.0705, 42.3519), # Arlington
	Vector2(-71.0775, 42.3500), # Copley
	Vector2(-71.0873, 42.3474), # Massachusetts Avenue / Hynes
	Vector2(-71.0952, 42.3489), # Kenmore
	Vector2(-71.1115, 42.3442), # Brookline
	Vector2(-71.1647, 42.3265), # Chestnut Hill
	Vector2(-71.1937, 42.3301), # Newton Centre
	Vector2(-71.2925, 42.2965), # Wellesley Center
	Vector2(-71.3466, 42.2850), # Natick Center
	Vector2(-71.3839, 42.2864), # Framingham Junction / Hastingsville
	Vector2(-71.4162, 42.2793), # Framingham Center
	Vector2(-71.5211, 42.3023), # Fayville (Southborough)
	Vector2(-71.6025, 42.2695), # Whites Corner (Westborough)
	Vector2(-71.6165, 42.2698), # Westborough Center
	Vector2(-71.6847, 42.2060), # Grafton Center
	Vector2(-71.7140, 42.2950), # Shrewsbury Center
	Vector2(-71.7775, 42.2748), # White City
	Vector2(-71.7830, 42.2656), # Belmont Street
	Vector2(-71.8015, 42.2746)  # Lincoln Square (Worcester)
])
@export var build_mainline_path := true
@export var path_name := "MainlinePath"
@export var path_parent_path: NodePath
@export var spawn_trolleys := true
@export var trolley_count := 4
@export var trolley_speed_mps := 14.0
@export var trolley_max_speed_mps := 26.0
@export var driver_trolley_index := 0
@export var driver_start_speed_mps := 9.0
@export var driver_start_station := "Park Street"
@export var driver_camera_height := 2.05
@export var driver_camera_forward := 5.8
@export var driver_camera_fov := 72.0
@export var chase_surface_camera_offset := Vector3(2.5, 5.2, 12.5)
@export var chase_surface_camera_pitch_deg := -10.0
@export var chase_subway_camera_offset := Vector3(0.7, 2.15, 8.0)
@export var chase_subway_camera_pitch_deg := -4.5
@export var chase_subway_depth_threshold := -2.0
@export var build_signal_posts := true
@export var signal_block_spacing_m := 320.0
@export var signal_post_side_offset_m := 3.2
@export var signal_post_height_m := 3.7
@export var signal_subway_post_height_m := 2.9
@export var signal_refresh_seconds := 0.2
@export var signal_caution_distance_m := 140.0
@export var signal_stop_distance_m := 60.0
@export var collision_distance_m := 9.0
@export var derail_curve_radius_threshold_m := 72.0
@export var derail_speed_margin_mps := 4.8
@export var derail_overspeed_hold_seconds := 1.25
@export var derail_min_excess_mps := 2.4
@export var derail_speed_ratio_threshold := 1.24
@export var derail_min_speed_mps := 8.5
@export var incident_service_penalty := 10.0
@export var station_arrival_radius_m := 72.0
@export var driver_service_stop_speed_threshold_mps := 2.2
@export var driver_station_dwell_seconds := 2.0
@export var automated_station_approach_radius_m := 86.0
@export var automated_station_stop_radius_m := 16.0
@export var automated_station_slow_speed_mps := 4.8
@export var automated_station_dwell_seconds := 3.4
@export var driver_headway_hold_max_seconds := 4.5
@export var driver_passenger_capacity := 42
@export var average_fare_per_passenger := 0.10
@export var driver_service_status_hold_seconds := 7.0
@export var driver_service_rating_decay_per_second := 0.04
@export var driver_skip_penalty_base := 3.0
@export var driver_headway_bonus_good := 1.6
@export var driver_headway_penalty_bad := 2.4
@export var station_announcement_approach_distance_m := 260.0
@export var station_announcement_voice := "Samantha"
@export var station_system_tts_enabled := true
@export var station_ambience_enabled := true
@export_file("*.ogg", "*.wav", "*.mp3") var station_ambience_loop_path := "res://assets/audio/station/platform_ambience_loop.wav"
@export_file("*.ogg", "*.wav", "*.mp3") var station_chime_path := "res://assets/audio/station/platform_chime.wav"
@export var driver_audio_enabled := true
@export_file("*.ogg", "*.wav", "*.mp3") var trolley_motor_loop_path := "res://assets/audio/trolley/droning_train_motor_on_halt.ogg"
@export_file("*.ogg", "*.wav", "*.mp3") var trolley_track_loop_path := "res://assets/audio/trolley/wws_102n_tram_front.ogg"
@export var trolley_motor_idle_volume_db := -33.0
@export var trolley_motor_max_volume_db := -19.0
@export var trolley_track_idle_volume_db := -46.0
@export var trolley_track_max_volume_db := -24.0
@export var trolley_motor_idle_pitch := 0.8
@export var trolley_motor_max_pitch := 1.24
@export var trolley_track_idle_pitch := 0.84
@export var trolley_track_max_pitch := 1.12
@export var trolley_audio_blend_speed := 18.0
@export var main_camera_path: NodePath
@export var toggle_driver_action := "toggle_driver_view"
@export var cycle_service_line_action := "cycle_service_line"
@export var cycle_trolley_type_action := "cycle_trolley_type"
@export var recover_incident_action := "recover_incident"
@export var available_trolley_scene_paths: Array[String] = [
	"res://scenes/transit/Type5Car.tscn",
	"res://scenes/transit/PCCCar.tscn"
]
@export var default_player_trolley_scene_path := Type5CarScenePath
@export var depot_purchase_cost := 26000.0
@export var depot_initial_type5_stock := 1
@export var depot_initial_pcc_stock := 1
@export var depot_operation_radius_m := 120.0
@export var timetable_subway_headway_min := 4.0
@export var timetable_inner_headway_min := 7.0
@export var timetable_outer_headway_min := 10.0
@export var timetable_north_headway_min := 5.0
@export var atlantic_service_car_count := 3
@export var washington_service_car_count := 4
@export var cambridge_service_car_count := 6
@export var blue_service_car_count := 6
@export var mattapan_service_car_count := 4
@export var green_branch_service_car_count := 4
@export var atlantic_service_headway_min := 4.0
@export var washington_service_headway_min := 4.0
@export var cambridge_service_headway_min := 5.0
@export var blue_service_headway_min := 5.0
@export var mattapan_service_headway_min := 6.0
@export var green_branch_service_headway_min := 6.0
@export var green_surface_track_height := 0.42
@export var snow_plow_speed_mps := 7.0
@export var snow_speed_limit_mps := 4.8
@export var origin := Vector3(65005.4, 0.0, -43256.5) # Park St (42.3564, -71.0628) projected into world coords
@export var direction := Vector3(-0.9851, 0.0, 0.1721) # Unit vector toward Lincoln Square Worcester
@export var mainline_towns := PackedStringArray([
	"Park Street",
	"Boylston",
	"Arlington",
	"Copley",
	"Massachusetts Avenue",
	"Kenmore",
	"Brookline",
	"Chestnut Hill",
	"Newton Centre",
	"Wellesley Center",
	"Natick Center",
	"Framingham Junction",
	"Framingham Center",
	"Fayville",
	"Whites Corner",
	"Westborough Center",
	"Grafton Center",
	"Shrewsbury Center",
	"White City",
	"Belmont Street",
	"Lincoln Square"
])
@export var branch_from := PackedStringArray([
	"Natick Center",
	"Framingham Junction",
	"Grafton Center",
	"Whites Corner"
])
@export var branch_to := PackedStringArray([
	"Saxonville",
	"South Framingham",
	"Upton",
	"Marlborough"
])
@export var branch_distance_m := PackedFloat32Array([5200.0, 2600.0, 9500.0, 12000.0])
@export var branch_side := PackedFloat32Array([1.0, -1.0, -1.0, 1.0])
@export var branch_kind := PackedStringArray([
	"regular",
	"regular",
	"regular",
	"regular"
])

# Post-1912 leisure spur to Norumbega Park (Auburndale/Charles River)
@export var park_from := PackedStringArray([
	"Newton Centre"
])
@export var park_to := PackedStringArray([
	"Norumbega Park"
])
@export var park_distance_m := PackedFloat32Array([4800.0])
@export var park_side := PackedFloat32Array([1.0])

var _seeded := false
var _driver_camera: Camera3D
var _chase_camera: Camera3D
var _main_camera: Camera3D
var _driver_active := false
var _town_manager_cached
var _view_mode := 1 # 0 = cab, 1 = chase
var _fleet: Array[TrolleyMover] = []
var _driver_trolley: TrolleyMover
var _player_trolley_scene_index := 0
var _driver_route_stops: Array[Dictionary] = []
var _driver_motor_audio: AudioStreamPlayer
var _driver_track_audio: AudioStreamPlayer
var _station_ambience_audio: AudioStreamPlayer
var _station_chime_audio: AudioStreamPlayer
var _signal_path: Path3D
var _signal_root: Node3D
var _signal_posts: Array[Dictionary] = []
var _signal_refresh_accum := 0.0
var _system_route_points := PackedVector3Array()
var _track_surface_material: ShaderMaterial
var _track_rail_material: StandardMaterial3D
var _pbr_material_cache := {}
var _passenger_manager: Node
var _economy: Node
var _stop_placer: Node
var _weather_controller: Node
var _driver_onboard_passengers := 0
var _driver_station_presence_name := ""
var _driver_station_serviced := false
var _driver_last_boarded := 0
var _driver_last_alighted := 0
var _driver_last_waiting_after := 0
var _driver_last_service_station := ""
var _driver_last_service_age_s := 999.0
var _driver_last_revenue := 0.0
var _driver_service_rating := 78.0
var _driver_served_stop_count := 0
var _driver_skipped_stop_count := 0
var _driver_service_streak := 0
var _driver_last_service_delta := 0.0
var _driver_last_service_event := "Line settling"
var _driver_last_service_event_age_s := 999.0
var _driver_last_headway_target_m := 0.0
var _driver_last_headway_ahead_m := -1.0
var _driver_last_headway_behind_m := -1.0
var _announcement_text := ""
var _announcement_age_s := 999.0
var _driver_last_announced_next_stop := ""
var _driver_last_announced_arrival := ""
var _driver_station_dwell_s := 0.0
var _driver_station_target_dwell_s := 0.0
var _depot_inventory := {}
var _timetable_segments: Array[Dictionary] = []
var _service_lines := {}
var _driver_line_id := MainLineServiceId
var _driver_manual_control_enabled := true
var _weather_payload := {}
var _snow_plows := {}
var _line_snow_cleared := {}
var _line_snow_depth := {}
var _driver_curve_overspeed_s := 0.0

func _ready() -> void:
	if main_camera_path != NodePath(""):
		_main_camera = get_node(main_camera_path) as Camera3D
	_resolve_gameplay_dependencies()
	_set_default_player_trolley_scene_index()
	_setup_driver_audio()
	_setup_station_audio()
	if not auto_seed:
		return
	call_deferred("_seed_corridor")

func _process(delta: float) -> void:
	_driver_last_service_age_s += delta
	_driver_last_service_event_age_s += delta
	_announcement_age_s += delta
	_driver_service_rating = maxf(25.0, _driver_service_rating - driver_service_rating_decay_per_second * delta)
	_update_chase_camera_pose()
	_update_driver_audio(delta)
	_update_station_ambience(delta)
	_update_weather_gameplay(delta)
	_update_automated_service_lines(delta)
	_signal_refresh_accum += delta
	if _signal_refresh_accum >= signal_refresh_seconds:
		_signal_refresh_accum = 0.0
		_update_signal_posts()
	_update_driver_incident_gameplay()
	_update_driver_station_gameplay(delta)
	_update_driver_station_announcements()
	if toggle_driver_action != "" and Input.is_action_just_pressed(toggle_driver_action):
		if _driver_camera != null and _main_camera != null:
			if _driver_active and _view_mode == 1:
				_view_mode = 0
			elif _driver_active and _view_mode == 0:
				_view_mode = 1
			_driver_active = not _driver_active
			_update_active_camera()
			_main_camera.current = not _driver_active
	if cycle_service_line_action != "" and Input.is_action_just_pressed(cycle_service_line_action):
		_cycle_service_line()
	if cycle_trolley_type_action != "" and Input.is_action_just_pressed(cycle_trolley_type_action):
		cycle_player_trolley_type()
	if recover_incident_action != "" and Input.is_action_just_pressed(recover_incident_action):
		_recover_driver_incident()

func _seed_corridor() -> void:
	if _seeded:
		return
	var town_manager: Node = _get_town_manager()
	var track_builder: Node = _get_track_builder()
	if town_manager == null or track_builder == null:
		return
	_town_manager_cached = town_manager
	if mainline_towns.size() < 2:
		return
	var town_positions := {}
	var stop_points := _mainline_stop_points()
	if stop_points.is_empty():
		return
	var route_points := _route_points(stop_points)
	if route_points.is_empty():
		return
	_system_route_points = route_points
	_service_lines.clear()
	_driver_line_id = MainLineServiceId
	var dir := (route_points[route_points.size() - 1] - route_points[0]).normalized()
	if dir.length() < 0.01:
		dir = direction.normalized()
	if dir.length() < 0.01:
		dir = Vector3.RIGHT
	if reset_network and track_builder.has_method("clear_network"):
		track_builder.clear_network()
	for i in range(stop_points.size()):
		var town_name := mainline_towns[i]
		var pos := stop_points[i]
		town_positions[town_name] = pos
		town_manager.AddTransitStop(pos, frequency, town_name)
	track_builder.add_segment(route_points)
	_configure_main_camera(route_points)
	_build_subway_design(stop_points, route_points, track_builder)
	_build_north_terminal_extension(track_builder)
	_build_blue_line_phase(track_builder)
	_build_elevated_layer(track_builder)
	_build_atlantic_avenue_elevated(track_builder)
	_build_washington_street_tunnel(track_builder)
	_build_cambridge_dorchester_tunnel(track_builder)
	_build_mattapan_extension(track_builder)
	var path := _build_mainline_path(route_points, track_builder)
	_build_driver_route_stops(path, stop_points)
	_build_timetable_segments()
	_build_signal_system(path)
	_spawn_trolley_fleet(path)
	_register_current_line(
		MainLineServiceId,
		"Green Line F - %s" % line_name,
		_corridor_theme("tremont").get("line_color", Color("2d8f45"))
	)
	_build_operational_historical_lines(track_builder, town_manager)
	_activate_service_line(MainLineServiceId)
	_seed_initial_towns(town_manager)

	var left := Vector3(-dir.z, 0.0, dir.x).normalized()
	for i in range(branch_to.size()):
		if i >= branch_from.size():
			break
		if i >= branch_distance_m.size():
			break
		if i >= branch_side.size():
			break
		var from_name := branch_from[i]
		if not town_positions.has(from_name):
			continue
		var to_name := branch_to[i]
		if town_positions.has(to_name):
			continue
		var side := branch_side[i]
		var length := branch_distance_m[i]
		var from_pos: Vector3 = town_positions[from_name]
		var end_pos := from_pos + left * (length * side)
		var branch_points := PackedVector3Array()
		branch_points.append(from_pos)
		branch_points.append(end_pos)
		track_builder.add_segment(branch_points)
		town_positions[to_name] = end_pos
		var kind := "regular"
		if i < branch_kind.size():
			kind = branch_kind[i]
		town_manager.AddTransitStop(end_pos, frequency, to_name, kind)

	for i in range(park_to.size()):
		if i >= park_from.size():
			break
		if i >= park_distance_m.size():
			break
		if i >= park_side.size():
			break
		var from_name := park_from[i]
		if not town_positions.has(from_name):
			continue
		var to_name := park_to[i]
		if town_positions.has(to_name):
			continue
		var side := park_side[i]
		var length := park_distance_m[i]
		var from_pos: Vector3 = town_positions[from_name]
		var end_pos := from_pos + left * (length * side)
		var branch_points := PackedVector3Array()
		branch_points.append(from_pos)
		branch_points.append(end_pos)
		track_builder.add_segment(branch_points)
		town_positions[to_name] = end_pos
		town_manager.AddTransitStop(end_pos, frequency, to_name, "park")
	_build_framingham_landmarks(town_positions, track_builder)
	_seeded = true

func _build_mainline_path(points: PackedVector3Array, track_builder: Node) -> Path3D:
	return _build_service_path(path_name, points, track_builder)

func _build_service_path(path_node_name: String, points: PackedVector3Array, track_builder: Node) -> Path3D:
	if not build_mainline_path:
		return null
	var parent := _get_path_parent(track_builder)
	if parent == null:
		return null
	var existing := parent.get_node_or_null(path_node_name)
	if existing:
		existing.queue_free()
	var path := Path3D.new()
	path.name = path_node_name
	var curve := Curve3D.new()
	for p in points:
		curve.add_point(p)
	path.curve = curve
	parent.add_child(path)
	return path

func _build_framingham_landmarks(town_positions: Dictionary, track_builder: Node) -> void:
	var parent := _get_path_parent(track_builder)
	if parent == null:
		return
	var existing := parent.get_node_or_null("FraminghamLandmarks")
	if existing:
		existing.queue_free()
	if not town_positions.has("Framingham Junction"):
		return
	var root := Node3D.new()
	root.name = "FraminghamLandmarks"
	parent.add_child(root)
	var junction: Vector3 = town_positions.get("Framingham Junction", Vector3.ZERO)
	var framingham_center: Vector3 = town_positions.get("Framingham Center", junction)
	var natick_center: Vector3 = town_positions.get("Natick Center", framingham_center)
	var south_framingham: Vector3 = town_positions.get("South Framingham", framingham_center + Vector3(0.0, 0.0, 120.0))
	var main_forward := (framingham_center - natick_center).normalized()
	if main_forward.length() < 0.01:
		main_forward = (framingham_center - junction).normalized()
	if main_forward.length() < 0.01:
		main_forward = direction.normalized()
	if main_forward.length() < 0.01:
		main_forward = Vector3.RIGHT
	var main_right := Vector3(-main_forward.z, 0.0, main_forward.x).normalized()
	var branch_forward := (south_framingham - junction).normalized()
	if branch_forward.length() < 0.01:
		branch_forward = -main_right
	var branch_right := Vector3(-branch_forward.z, 0.0, branch_forward.x).normalized()
	var brick := _ensure_period_material("brick")
	var plaster := _ensure_period_material("plaster")
	var steel := _ensure_period_material("steel_dark", Color("645a50"))
	var timber := _ensure_period_material("timber")

	var office_anchor := junction + main_right * 34.0 + Vector3(0.0, 0.2, 0.0)
	_add_box_with_material(root, Vector3(26.0, 8.8, 14.0), office_anchor + Vector3(0.0, 4.4, 0.0), main_forward, brick)
	_add_box_with_material(root, Vector3(18.0, 3.8, 10.5), office_anchor + Vector3(0.0, 9.9, 0.0), main_forward, plaster)
	_add_box_with_material(root, Vector3(28.0, 0.8, 16.0), office_anchor + Vector3(0.0, 8.7, 0.0), main_forward, steel)
	_add_box_with_material(root, Vector3(18.4, 0.55, 10.8), office_anchor + Vector3(0.0, 12.0, 0.0), main_forward, steel)
	_add_box_with_material(root, Vector3(8.0, 2.2, 5.4), office_anchor - main_forward * 10.2 + Vector3(0.0, 1.1, 0.0), main_forward, brick)
	_add_landmark_label(root, "Framingham Junction HQ", office_anchor + Vector3(0.0, 13.2, 0.0), -main_forward, 0.85)

	var station_house := junction - main_right * 10.0 - main_forward * 8.0
	_add_box_with_material(root, Vector3(10.0, 3.8, 5.0), station_house + Vector3(0.0, 1.9, 0.0), main_forward, plaster)
	_add_box_with_material(root, Vector3(11.2, 0.55, 6.0), station_house + Vector3(0.0, 4.15, 0.0), main_forward, steel)
	_add_landmark_label(root, "Framingham Junction", station_house + Vector3(0.0, 5.4, 0.0), -main_forward, 0.75)

	var barn_anchor := junction.lerp(south_framingham, 0.36) + branch_right * 24.0 + Vector3(0.0, 0.2, 0.0)
	_add_box_with_material(root, Vector3(46.0, 7.4, 19.0), barn_anchor + Vector3(0.0, 3.7, 0.0), branch_forward, brick)
	_add_box_with_material(root, Vector3(48.5, 0.9, 21.5), barn_anchor + Vector3(0.0, 7.9, 0.0), branch_forward, steel)
	_add_box_with_material(root, Vector3(44.0, 0.45, 18.5), barn_anchor + Vector3(0.0, 8.85, 0.0), branch_forward, timber)
	for bay in [-12.0, 0.0, 12.0]:
		_add_box_with_material(root, Vector3(0.35, 5.2, 4.4), barn_anchor - branch_forward * 9.0 + branch_right * bay + Vector3(0.0, 2.6, 0.0), branch_forward, timber)
		_add_track_surface_box(root, Vector3(3.0, 0.18, 26.0), barn_anchor - branch_forward * 9.0 + branch_right * bay + Vector3(0.0, 0.12, 0.0), branch_forward)
		_add_rail_box(root, Vector3(0.14, 0.14, 26.0), barn_anchor - branch_forward * 9.0 + branch_right * (bay - 0.72) + Vector3(0.0, 0.24, 0.0), branch_forward)
		_add_rail_box(root, Vector3(0.14, 0.14, 26.0), barn_anchor - branch_forward * 9.0 + branch_right * (bay + 0.72) + Vector3(0.0, 0.24, 0.0), branch_forward)
	_add_landmark_label(root, "Trolley Square Car Barn", barn_anchor + Vector3(0.0, 9.8, 0.0), -branch_forward, 0.95)

func _add_landmark_label(parent: Node3D, text: String, position: Vector3, forward: Vector3, scale_factor: float = 1.0) -> void:
	var label := Label3D.new()
	label.text = text
	label.font_size = int(round(28.0 * scale_factor))
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.modulate = Color("f1ebdc")
	label.outline_modulate = Color(0.08, 0.06, 0.05, 1.0)
	label.position = position
	label.rotation = Vector3(0.0, atan2(forward.x, forward.z), 0.0)
	parent.add_child(label)

func _register_current_line(line_id: String, display_name: String, line_color: Color) -> void:
	_register_service_line(
		line_id,
		display_name,
		_active_service_path(),
		_driver_route_stops.duplicate(true),
		_fleet.duplicate(),
		_signal_root,
		_signal_posts.duplicate(true),
		_timetable_segments.duplicate(true),
		_system_route_points.duplicate(),
		line_color
	)

func _register_service_line(line_id: String, display_name: String, path: Path3D, route_stops: Array[Dictionary], fleet: Array[TrolleyMover], signal_root: Node3D, signal_posts: Array[Dictionary], timetable_segments: Array[Dictionary], route_points: PackedVector3Array, line_color: Color) -> void:
	if line_id == "" or path == null or path.curve == null:
		return
	path.set_meta("service_line_id", line_id)
	path.set_meta("service_line_name", display_name)
	_service_lines[line_id] = {
		"id": line_id,
		"name": display_name,
		"path": path,
		"route_stops": route_stops,
		"fleet": fleet,
		"signal_path": path,
		"signal_root": signal_root,
		"signal_posts": signal_posts,
		"timetable_segments": timetable_segments,
		"route_points": route_points,
		"line_color": line_color
	}

func _service_line_entry(line_id: String) -> Dictionary:
	return _service_lines.get(line_id, {})

func _service_line_ids_sorted() -> Array[String]:
	var ids: Array[String] = []
	for line_id_variant in _service_lines.keys():
		ids.append(String(line_id_variant))
	var preferred_order := [
		GreenAServiceId,
		GreenBServiceId,
		GreenCServiceId,
		GreenDServiceId,
		GreenEServiceId,
		MainLineServiceId,
		AtlanticServiceId,
		WashingtonServiceId,
		CambridgeServiceId,
		BlueServiceId,
		MattapanServiceId
	]
	var ordered: Array[String] = []
	for preferred_id in preferred_order:
		if ids.has(preferred_id):
			ordered.append(preferred_id)
			ids.erase(preferred_id)
	ids.sort()
	for line_id in ids:
		ordered.append(line_id)
	ids = ordered
	return ids

func _activate_service_line(line_id: String) -> void:
	if line_id == "":
		return
	_sync_current_line_state()
	var entry := _service_line_entry(line_id)
	if entry.is_empty():
		return
	_driver_line_id = line_id
	_fleet = entry.get("fleet", [])
	_driver_route_stops = entry.get("route_stops", [])
	_signal_path = entry.get("signal_path", null)
	_signal_root = entry.get("signal_root", null)
	_signal_posts = entry.get("signal_posts", [])
	_timetable_segments = entry.get("timetable_segments", [])
	_driver_station_presence_name = ""
	_driver_station_serviced = false
	_driver_station_dwell_s = 0.0
	_driver_station_target_dwell_s = 0.0
	_driver_last_announced_next_stop = ""
	_driver_last_announced_arrival = ""

func _sync_current_line_state() -> void:
	if _driver_line_id == "" or not _service_lines.has(_driver_line_id):
		return
	var entry: Dictionary = _service_lines.get(_driver_line_id, {})
	entry["fleet"] = _fleet
	entry["route_stops"] = _driver_route_stops
	entry["signal_path"] = _signal_path
	entry["signal_root"] = _signal_root
	entry["signal_posts"] = _signal_posts
	entry["timetable_segments"] = _timetable_segments
	_service_lines[_driver_line_id] = entry

func _line_id_for_trolley(trolley: TrolleyMover) -> String:
	if trolley == null or not is_instance_valid(trolley):
		return MainLineServiceId
	var line_id := String(trolley.get_meta("service_line_id", ""))
	if line_id != "":
		return line_id
	var parent_path := trolley.get_parent()
	if parent_path != null:
		line_id = String(parent_path.get_meta("service_line_id", ""))
		if line_id != "":
			return line_id
	return MainLineServiceId

func _line_fleet(line_id: String) -> Array:
	var entry := _service_line_entry(line_id)
	return entry.get("fleet", [])

func _build_operational_historical_lines(track_builder: Node, town_manager: Node) -> void:
	_build_green_branch_services(track_builder, town_manager)
	_build_operational_service_line(
		BlueServiceId,
		"Blue Line North Shore",
		_build_blue_salem_route_points(),
		blue_line_station_names,
		blue_service_car_count,
		BlueLineCarScenePath,
		blue_service_headway_min,
		_corridor_theme("blue").get("line_color", Color("3a7dbf")),
		track_builder,
		town_manager,
		_build_blue_salem_station_points()
	)
	_build_operational_service_line(
		AtlanticServiceId,
		"Atlantic Avenue Elevated",
		_build_atlantic_service_points(),
		atlantic_elevated_station_names,
		atlantic_service_car_count,
		PCCCarScenePath,
		atlantic_service_headway_min,
		_corridor_theme("atlantic_elevated").get("line_color", Color("9c8a62")),
		track_builder,
		town_manager
	)
	_build_operational_service_line(
		WashingtonServiceId,
		"Washington Street Tunnel",
		_build_historical_subway_service_points(washington_street_geo),
		washington_street_station_names,
		washington_service_car_count,
		WashingtonTunnelTrainScenePath,
		washington_service_headway_min,
		_corridor_theme("washington").get("line_color", Color("c86d2c")),
		track_builder,
		town_manager
	)
	_build_operational_service_line(
		CambridgeServiceId,
		"Cambridge-Dorchester Tunnel",
		_build_historical_subway_service_points(cambridge_dorchester_geo),
		cambridge_dorchester_station_names,
		cambridge_service_car_count,
		CambridgeDorchesterCarScenePath,
		cambridge_service_headway_min,
		_corridor_theme("cambridge").get("line_color", Color("d04b41")),
		track_builder,
		town_manager
	)
	if build_mattapan_extension:
		_build_operational_service_line(
			MattapanServiceId,
			"Mattapan High-Speed Line",
			_build_mattapan_service_points(),
			mattapan_station_names,
			mattapan_service_car_count,
			PCCCarScenePath,
			mattapan_service_headway_min,
			_corridor_theme("mattapan").get("line_color", Color("d04b41")),
			track_builder,
			town_manager
		)

func _build_operational_service_line(line_id: String, display_name: String, points: PackedVector3Array, stop_names: PackedStringArray, car_count: int, scene_path: String, default_headway_min: float, line_color: Color, track_builder: Node, town_manager: Node, stop_positions: PackedVector3Array = PackedVector3Array()) -> void:
	if points.size() < 2 or stop_names.size() < 2:
		return
	var path := _build_service_path("%sServicePath" % line_id.capitalize(), points, track_builder)
	if path == null or path.curve == null:
		return
	if stop_positions.is_empty():
		stop_positions = points
	var route_stops := _build_route_stops_for_points(path.curve, stop_names, stop_positions)
	var signal_data := _build_line_signal_system(line_id, path)
	var fleet := _spawn_line_fleet(path, line_id, car_count, scene_path)
	_configure_service_line_fleet(line_id, fleet)
	var segments := _build_line_timetable_segments(line_id, display_name, route_stops, default_headway_min)
	_register_service_line(
		line_id,
		display_name,
		path,
		route_stops,
		fleet,
		signal_data.get("root", null),
		signal_data.get("posts", []),
		segments,
		points,
		line_color
	)
	_add_line_stops_to_town_manager(town_manager, route_stops)

func _configure_service_line_fleet(line_id: String, fleet: Array[TrolleyMover]) -> void:
	var profile := {
		"cruise": trolley_speed_mps,
		"max": trolley_max_speed_mps,
		"accel": 5.0,
		"brake": 9.0
	}
	match line_id:
		GreenAServiceId, GreenBServiceId, GreenCServiceId:
			profile = {"cruise": 10.5, "max": 15.5, "accel": 4.2, "brake": 8.6}
		GreenDServiceId:
			profile = {"cruise": 12.5, "max": 18.5, "accel": 4.4, "brake": 8.8}
		GreenEServiceId:
			profile = {"cruise": 10.8, "max": 16.0, "accel": 4.2, "brake": 8.8}
		AtlanticServiceId:
			profile = {"cruise": 11.0, "max": 15.5, "accel": 4.4, "brake": 8.2}
		WashingtonServiceId:
			profile = {"cruise": 14.5, "max": 19.5, "accel": 4.8, "brake": 9.2}
		CambridgeServiceId:
			profile = {"cruise": 15.5, "max": 21.0, "accel": 5.0, "brake": 9.6}
		BlueServiceId:
			profile = {"cruise": 16.5, "max": 22.5, "accel": 5.2, "brake": 9.8}
		MattapanServiceId:
			profile = {"cruise": 10.5, "max": 14.5, "accel": 4.3, "brake": 8.8}
	for trolley in fleet:
		if trolley == null or not is_instance_valid(trolley):
			continue
		trolley.max_speed_mps = float(profile.get("max", trolley_max_speed_mps))
		trolley.accel_mps2 = float(profile.get("accel", trolley.accel_mps2))
		trolley.brake_mps2 = float(profile.get("brake", trolley.brake_mps2))
		trolley.target_speed_mps = float(profile.get("cruise", trolley_speed_mps))
		trolley.speed_mps = move_toward(trolley.speed_mps, trolley.target_speed_mps, 2.0)
		trolley.set_meta("service_cruise_speed_mps", float(profile.get("cruise", trolley_speed_mps)))

func _build_atlantic_service_points() -> PackedVector3Array:
	var points := _project_geo_points(atlantic_elevated_geo)
	var elevated := PackedVector3Array()
	for point in points:
		elevated.append(point + Vector3(0.0, atlantic_elevated_deck_height, 0.0))
	return elevated

func _build_historical_subway_service_points(geo_points: PackedVector2Array) -> PackedVector3Array:
	var points := _project_geo_points(geo_points)
	var tunnel_points := PackedVector3Array()
	for point in points:
		tunnel_points.append(_subway_track_point(point))
	return tunnel_points

func _green_trunk_stop_names(shared_stop_count: int) -> PackedStringArray:
	var names := PackedStringArray()
	for i in range(min(shared_stop_count, mainline_towns.size())):
		names.append(mainline_towns[i])
	return names

func _green_trunk_stop_positions(shared_stop_count: int) -> PackedVector3Array:
	var positions := PackedVector3Array()
	var stop_points := _mainline_stop_points()
	for i in range(min(shared_stop_count, stop_points.size())):
		var stop_pos := _subway_track_point(stop_points[i]) if i <= _last_subway_station_index() else stop_points[i]
		positions.append(stop_pos)
	return positions

func _green_a_route_geo() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-71.1196, 42.3517),
		Vector2(-71.1425, 42.3493),
		Vector2(-71.1568, 42.3494),
		Vector2(-71.1702, 42.3558),
		Vector2(-71.1844, 42.3641)
	])

func _green_a_stop_names() -> PackedStringArray:
	return PackedStringArray(["Packards Corner", "Brighton Center", "Oak Square", "Watertown"])

func _green_a_stop_geo() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-71.1196, 42.3517),
		Vector2(-71.1425, 42.3493),
		Vector2(-71.1568, 42.3494),
		Vector2(-71.1844, 42.3641)
	])

func _green_b_route_geo() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-71.1196, 42.3517),
		Vector2(-71.1274, 42.3502),
		Vector2(-71.1402, 42.3488),
		Vector2(-71.1502, 42.3468),
		Vector2(-71.1620, 42.3434),
		Vector2(-71.1706, 42.3402)
	])

func _green_b_stop_names() -> PackedStringArray:
	return PackedStringArray(["Packards Corner", "Harvard Avenue", "Warren Street", "Washington Street", "Boston College"])

func _green_b_stop_geo() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-71.1196, 42.3517),
		Vector2(-71.1274, 42.3502),
		Vector2(-71.1402, 42.3488),
		Vector2(-71.1502, 42.3468),
		Vector2(-71.1706, 42.3402)
	])

func _green_c_route_geo() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-71.1078, 42.3457),
		Vector2(-71.1219, 42.3420),
		Vector2(-71.1359, 42.3396),
		Vector2(-71.1488, 42.3360)
	])

func _green_c_stop_names() -> PackedStringArray:
	return PackedStringArray(["Saint Mary's Street", "Coolidge Corner", "Washington Square", "Cleveland Circle"])

func _green_c_stop_geo() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-71.1078, 42.3457),
		Vector2(-71.1219, 42.3420),
		Vector2(-71.1359, 42.3396),
		Vector2(-71.1488, 42.3360)
	])

func _green_d_route_geo() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-71.1048, 42.3454),
		Vector2(-71.1239, 42.3328),
		Vector2(-71.1422, 42.3355),
		Vector2(-71.1937, 42.3301),
		Vector2(-71.2520, 42.3376)
	])

func _green_d_stop_names() -> PackedStringArray:
	return PackedStringArray(["Fenway", "Brookline Village", "Reservoir", "Newton Centre", "Riverside"])

func _green_d_stop_geo() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-71.1048, 42.3454),
		Vector2(-71.1239, 42.3328),
		Vector2(-71.1422, 42.3355),
		Vector2(-71.1937, 42.3301),
		Vector2(-71.2520, 42.3376)
	])

func _green_e_route_geo() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-71.0813, 42.3453),
		Vector2(-71.0855, 42.3427),
		Vector2(-71.0957, 42.3371),
		Vector2(-71.1039, 42.3341),
		Vector2(-71.1108, 42.3283),
		Vector2(-71.1184, 42.3221),
		Vector2(-71.1174, 42.3142),
		Vector2(-71.1157, 42.3071),
		Vector2(-71.1137, 42.3008)
	])

func _green_e_stop_names() -> PackedStringArray:
	return PackedStringArray(["Prudential", "Symphony", "Museum of Fine Arts", "Brigham Circle", "Heath Street", "Jamaica Plain", "Arborway"])

func _green_e_stop_geo() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(-71.0813, 42.3453),
		Vector2(-71.0855, 42.3427),
		Vector2(-71.0957, 42.3371),
		Vector2(-71.1039, 42.3341),
		Vector2(-71.1108, 42.3283),
		Vector2(-71.1184, 42.3221),
		Vector2(-71.1137, 42.3008)
	])

func _build_green_branch_services(track_builder: Node, town_manager: Node) -> void:
	var green_color: Color = _corridor_theme("tremont").get("line_color", Color("2d8f45"))
	_build_green_surface_branch_service(
		GreenAServiceId,
		"Green Line A - Watertown",
		"GreenLineABranch",
		6,
		_green_a_route_geo(),
		_green_a_stop_names(),
		_green_a_stop_geo(),
		Type5CarScenePath,
		green_color,
		track_builder,
		town_manager
	)
	_build_green_surface_branch_service(
		GreenBServiceId,
		"Green Line B - Boston College",
		"GreenLineBBranch",
		6,
		_green_b_route_geo(),
		_green_b_stop_names(),
		_green_b_stop_geo(),
		Type5CarScenePath,
		green_color,
		track_builder,
		town_manager
	)
	_build_green_surface_branch_service(
		GreenCServiceId,
		"Green Line C - Cleveland Circle",
		"GreenLineCBranch",
		6,
		_green_c_route_geo(),
		_green_c_stop_names(),
		_green_c_stop_geo(),
		Type5CarScenePath,
		green_color,
		track_builder,
		town_manager
	)
	_build_green_surface_branch_service(
		GreenDServiceId,
		"Green Line D - Riverside",
		"GreenLineDBranch",
		6,
		_green_d_route_geo(),
		_green_d_stop_names(),
		_green_d_stop_geo(),
		Type5CarScenePath,
		green_color,
		track_builder,
		town_manager
	)
	_build_green_surface_branch_service(
		GreenEServiceId,
		"Green Line E - Arborway",
		"GreenLineEBranch",
		4,
		_green_e_route_geo(),
		_green_e_stop_names(),
		_green_e_stop_geo(),
		PCCCarScenePath,
		green_color,
		track_builder,
		town_manager
	)

func _build_green_surface_branch_service(line_id: String, display_name: String, root_name: String, shared_stop_count: int, branch_route_geo: PackedVector2Array, branch_stop_names: PackedStringArray, branch_stop_geo: PackedVector2Array, scene_path: String, line_color: Color, track_builder: Node, town_manager: Node) -> void:
	if branch_route_geo.size() < 2 or branch_stop_names.is_empty() or branch_stop_names.size() != branch_stop_geo.size():
		return
	var trunk_stop_names := _green_trunk_stop_names(shared_stop_count)
	var trunk_stop_positions := _green_trunk_stop_positions(shared_stop_count)
	if trunk_stop_names.size() != trunk_stop_positions.size() or trunk_stop_names.is_empty():
		return
	var route_points := PackedVector3Array()
	var stop_positions := PackedVector3Array()
	var stop_names := PackedStringArray()
	for i in range(trunk_stop_positions.size()):
		route_points.append(trunk_stop_positions[i])
		stop_positions.append(trunk_stop_positions[i])
		stop_names.append(trunk_stop_names[i])
	var branch_route_points := PackedVector3Array()
	for point in _project_geo_points(branch_route_geo):
		branch_route_points.append(Vector3(point.x, green_surface_track_height, point.z))
	var branch_stop_points := PackedVector3Array()
	for point in _project_geo_points(branch_stop_geo):
		branch_stop_points.append(Vector3(point.x, green_surface_track_height, point.z))
	var shared_point := trunk_stop_positions[trunk_stop_positions.size() - 1]
	var first_branch_point := branch_route_points[0]
	if shared_point.distance_to(first_branch_point) > 6.0:
		route_points.append(shared_point.lerp(first_branch_point, 0.34))
		route_points.append(shared_point.lerp(first_branch_point, 0.68))
	for point in branch_route_points:
		route_points.append(point)
	for i in range(branch_stop_points.size()):
		stop_positions.append(branch_stop_points[i])
		stop_names.append(branch_stop_names[i])
	_build_operational_service_line(
		line_id,
		display_name,
		route_points,
		stop_names,
		green_branch_service_car_count,
		scene_path,
		green_branch_service_headway_min,
		line_color,
		track_builder,
		town_manager,
		stop_positions
	)
	_build_green_surface_branch_geometry(root_name, shared_point, branch_route_points, branch_stop_points, branch_stop_names, track_builder)

func _build_green_surface_branch_geometry(root_name: String, shared_tunnel_point: Vector3, branch_route_points: PackedVector3Array, branch_stop_points: PackedVector3Array, branch_stop_names: PackedStringArray, track_builder: Node) -> void:
	if branch_route_points.is_empty():
		return
	var parent := _get_path_parent(track_builder)
	if parent == null:
		return
	var existing := parent.get_node_or_null(root_name)
	if existing:
		existing.queue_free()
	var root := Node3D.new()
	root.name = root_name
	parent.add_child(root)
	var portal_root := _make_subway_section(root, "Portal")
	var segment_root := _make_subway_section(root, "Segments")
	var station_root := _make_subway_section(root, "Stations")
	_build_green_branch_portal(portal_root, shared_tunnel_point, branch_route_points[0])
	for i in range(branch_route_points.size() - 1):
		_add_surface_rapid_segment(segment_root, branch_route_points[i], branch_route_points[i + 1], "tremont")
	for i in range(min(branch_stop_points.size(), branch_stop_names.size())):
		_add_surface_rapid_station(station_root, branch_stop_points[i], _station_forward(branch_stop_points, i), branch_stop_names[i], "tremont")

func _build_green_branch_portal(parent: Node3D, tunnel_point: Vector3, surface_point: Vector3) -> void:
	var p1 := tunnel_point.lerp(surface_point, 0.34)
	var p2 := tunnel_point.lerp(surface_point, 0.68)
	_add_portal_section(parent, tunnel_point, p1, 13.0, 5.8, true)
	_add_portal_section(parent, p1, p2, 13.8, 4.8, true)
	_add_portal_section(parent, p2, surface_point, 14.6, 3.6, false)

func _build_mattapan_service_points() -> PackedVector3Array:
	var surface_points := _project_geo_points(mattapan_geo)
	var route := PackedVector3Array()
	for point in surface_points:
		route.append(point + Vector3(0.0, mattapan_track_height, 0.0))
	return route

func _build_blue_salem_station_points() -> PackedVector3Array:
	var surface_points := _project_geo_points(blue_line_geo)
	var station_points := PackedVector3Array()
	for i in range(surface_points.size()):
		var point := surface_points[i]
		if i < blue_line_tunnel_station_count:
			station_points.append(Vector3(point.x, blue_line_depth, point.z))
		else:
			station_points.append(Vector3(point.x, blue_line_surface_track_height, point.z))
	return station_points

func _build_blue_salem_route_points() -> PackedVector3Array:
	var surface_points := _project_geo_points(blue_line_geo)
	var station_points := _build_blue_salem_station_points()
	var route := PackedVector3Array()
	if station_points.is_empty():
		return route
	for i in range(station_points.size()):
		route.append(station_points[i])
		if i == 3 and i + 1 < surface_points.size():
			var harbor_mid := surface_points[i].lerp(surface_points[i + 1], 0.5)
			route.append(Vector3(harbor_mid.x, blue_line_harbor_depth, harbor_mid.z))
		if i == blue_line_tunnel_station_count - 1 and i + 1 < surface_points.size():
			var portal_a := surface_points[i]
			var portal_b := surface_points[i + 1]
			route.append(_portal_blend(portal_a, portal_b, 0.22, blue_line_depth * 0.7))
			route.append(_portal_blend(portal_a, portal_b, 0.48, blue_line_depth * 0.24))
			route.append(_portal_blend(portal_a, portal_b, 0.72, blue_line_surface_track_height))
	return route

func _build_route_stops_for_points(curve: Curve3D, stop_names: PackedStringArray, points: PackedVector3Array) -> Array[Dictionary]:
	var route_stops: Array[Dictionary] = []
	if curve == null:
		return route_stops
	for i in range(min(stop_names.size(), points.size())):
		_append_route_stop_entry(route_stops, String(stop_names[i]), points[i], curve)
	route_stops.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("offset", 0.0)) < float(b.get("offset", 0.0))
	)
	return route_stops

func _append_route_stop_entry(target: Array[Dictionary], name: String, position: Vector3, curve: Curve3D) -> void:
	if name == "" or curve == null:
		return
	var offset := float(curve.get_closest_offset(position))
	for entry in target:
		if String(entry.get("name", "")) == name and absf(float(entry.get("offset", 0.0)) - offset) <= 12.0:
			return
	target.append({
		"name": name,
		"offset": offset,
		"position": position
	})

func _build_line_timetable_segments(line_id: String, display_name: String, route_stops: Array[Dictionary], default_headway_min: float) -> Array[Dictionary]:
	var segments: Array[Dictionary] = []
	if route_stops.size() < 2:
		return segments
	var start_entry: Dictionary = route_stops.front()
	var end_entry: Dictionary = route_stops.back()
	var start_offset := float(start_entry.get("offset", 0.0))
	var end_offset := float(end_entry.get("offset", 0.0))
	segments.append({
		"id": "%s__full" % line_id,
		"name": display_name,
		"line_id": line_id,
		"line_name": display_name,
		"start_name": String(start_entry.get("name", "")),
		"end_name": String(end_entry.get("name", "")),
		"start_offset": minf(start_offset, end_offset),
		"end_offset": maxf(start_offset, end_offset),
		"length_m": absf(end_offset - start_offset),
		"headway_min": maxf(2.0, default_headway_min)
	})
	return segments

func _add_line_stops_to_town_manager(town_manager: Node, route_stops: Array[Dictionary]) -> void:
	if town_manager == null:
		return
	for stop in route_stops:
		town_manager.AddTransitStop(stop.get("position", Vector3.ZERO), frequency, String(stop.get("name", "")), "urban")

func _build_signal_system(path: Path3D) -> void:
	var signal_data := _build_line_signal_system(MainLineServiceId, path)
	_signal_path = path
	_signal_root = signal_data.get("root", null)
	_signal_posts = signal_data.get("posts", [])
	_update_signal_posts()

func _build_line_signal_system(line_id: String, path: Path3D) -> Dictionary:
	var posts: Array[Dictionary] = []
	var root: Node3D = null
	if not build_signal_posts or path == null or path.curve == null:
		return {"root": root, "posts": posts}
	var curve := path.curve
	var path_length := float(curve.get_baked_length())
	if path_length <= signal_block_spacing_m:
		return {"root": root, "posts": posts}
	var parent := path.get_parent()
	if parent == null:
		parent = self
	root = Node3D.new()
	root.name = "%sSignalSystem" % line_id.capitalize()
	parent.add_child(root)
	var margin := maxf(24.0, signal_block_spacing_m * 0.45)
	var offset := margin
	while offset < path_length - margin:
		_add_signal_post(root, curve, offset, 1.0, posts)
		_add_signal_post(root, curve, offset, -1.0, posts)
		offset += signal_block_spacing_m
	return {"root": root, "posts": posts}

func _add_signal_post(parent: Node3D, curve: Curve3D, offset: float, direction_sign: float, target_posts: Array[Dictionary]) -> void:
	if parent == null or curve == null:
		return
	var path_length := float(curve.get_baked_length())
	var sample_offset := clampf(offset, 0.0, path_length)
	var sample_pos := curve.sample_baked(sample_offset)
	var step := minf(4.0, maxf(1.0, signal_block_spacing_m * 0.08))
	var ahead_offset := clampf(sample_offset + direction_sign * step, 0.0, path_length)
	var ahead_pos := curve.sample_baked(ahead_offset)
	var forward := (ahead_pos - sample_pos).normalized()
	if forward.length() < 0.01:
		forward = Vector3.FORWARD
	var right := Vector3(-forward.z, 0.0, forward.x).normalized()
	if right.length() < 0.01:
		right = Vector3.RIGHT
	var in_subway := sample_pos.y <= chase_subway_depth_threshold
	var post_height := signal_subway_post_height_m if in_subway else signal_post_height_m
	var mast_root := Node3D.new()
	mast_root.name = "Signal_%s_%04d" % ["NB" if direction_sign >= 0.0 else "SB", int(round(sample_offset))]
	mast_root.position = sample_pos + right * (signal_post_side_offset_m * direction_sign)
	parent.add_child(mast_root)

	var pole := MeshInstance3D.new()
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.08
	pole_mesh.bottom_radius = 0.1
	pole_mesh.height = post_height
	pole.mesh = pole_mesh
	var pole_mat := StandardMaterial3D.new()
	pole_mat.albedo_color = Color("2d2b28")
	pole_mat.roughness = 0.82
	pole.set_surface_override_material(0, pole_mat)
	pole.position = Vector3(0.0, post_height * 0.5, 0.0)
	mast_root.add_child(pole)

	var head := MeshInstance3D.new()
	var head_mesh := BoxMesh.new()
	head_mesh.size = Vector3(0.42, 0.9, 0.26)
	head.mesh = head_mesh
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color("141414")
	head_mat.roughness = 0.55
	head_mat.metallic = 0.18
	head.set_surface_override_material(0, head_mat)
	head.position = Vector3(0.0, post_height - 0.45, 0.0)
	mast_root.add_child(head)

	var face_target := mast_root.global_position - forward * direction_sign
	mast_root.look_at(face_target, Vector3.UP, true)

	var colors := {
		"RED": Color("d24d43"),
		"YELLOW": Color("e0bd5e"),
		"GREEN": Color("6fbd63")
	}
	var lamp_positions := {
		"RED": Vector3(0.0, post_height - 0.18, 0.15),
		"YELLOW": Vector3(0.0, post_height - 0.45, 0.15),
		"GREEN": Vector3(0.0, post_height - 0.72, 0.15)
	}
	var lamp_materials := {}
	var lamp_lights := {}
	for aspect in ["RED", "YELLOW", "GREEN"]:
		var bulb := MeshInstance3D.new()
		var bulb_mesh := SphereMesh.new()
		bulb_mesh.radius = 0.1
		bulb_mesh.height = 0.2
		bulb.mesh = bulb_mesh
		var bulb_mat := StandardMaterial3D.new()
		var lamp_color: Color = colors[aspect]
		bulb_mat.albedo_color = lamp_color.darkened(0.72)
		bulb_mat.roughness = 0.24
		bulb_mat.emission_enabled = true
		bulb_mat.emission = lamp_color
		bulb_mat.emission_energy_multiplier = 0.04
		bulb.set_surface_override_material(0, bulb_mat)
		bulb.position = lamp_positions[aspect]
		mast_root.add_child(bulb)
		lamp_materials[aspect] = bulb_mat

		var glow := OmniLight3D.new()
		glow.light_color = lamp_color
		glow.light_energy = 0.0
		glow.omni_range = 7.0 if in_subway else 10.0
		glow.omni_attenuation = 2.2
		glow.shadow_enabled = false
		glow.position = lamp_positions[aspect] + Vector3(0.0, 0.0, 0.06)
		mast_root.add_child(glow)
		lamp_lights[aspect] = glow

	target_posts.append({
		"offset": sample_offset,
		"direction": direction_sign,
		"materials": lamp_materials,
		"lights": lamp_lights
	})

func _get_path_parent(track_builder: Node) -> Node:
	if path_parent_path != NodePath(""):
		var node := get_node_or_null(path_parent_path)
		if node != null:
			return node
	if track_builder != null:
		return track_builder
	return self

func _spawn_trolley_fleet(path: Path3D) -> void:
	_fleet = _spawn_line_fleet(path, MainLineServiceId, trolley_count, "")
	_driver_trolley = null
	_driver_camera = null
	_chase_camera = null
	if driver_trolley_index >= 0 and driver_trolley_index < _fleet.size():
		_set_driver_trolley(_fleet[driver_trolley_index], driver_trolley_index)
	else:
		_update_active_camera()

func _spawn_line_fleet(path: Path3D, line_id: String, car_count: int, scene_path_override: String) -> Array[TrolleyMover]:
	if not spawn_trolleys:
		return []
	if path == null or car_count <= 0:
		return []
	var curve := path.curve
	if curve == null:
		return []
	var fleet: Array[TrolleyMover] = []
	var length := float(curve.get_baked_length())
	if length <= 1.0:
		return fleet
	var spacing := length / float(car_count)
	for i in range(car_count):
		var trolley := TrolleyMover.new()
		trolley.speed_mps = trolley_speed_mps
		trolley.max_speed_mps = trolley_max_speed_mps
		trolley.progress = spacing * float(i)
		trolley.loop_path = false
		trolley.ping_pong = true
		trolley.set_meta("service_line_id", line_id)
		if scene_path_override != "":
			trolley.set_meta("scene_path_override", scene_path_override)
		if line_id == MainLineServiceId and i == driver_trolley_index:
			trolley.speed_mps = driver_start_speed_mps if driver_start_speed_mps > 0.0 else max(6.0, trolley_speed_mps * 0.65)
			trolley.progress = _driver_start_offset(curve)
		path.add_child(trolley)
		fleet.append(trolley)
		_attach_trolley_body(trolley, i)
	return fleet

func _driver_start_offset(curve: Curve3D) -> float:
	if curve == null:
		return 0.0
	var anchor := _driver_start_point()
	if anchor == Vector3.ZERO:
		return 0.0
	return float(curve.get_closest_offset(anchor))

func _driver_start_point() -> Vector3:
	if driver_start_station == "Park Street":
		var park_points := _mainline_stop_points()
		if not park_points.is_empty():
			return _subway_track_point(park_points[0])
	var stop_idx := mainline_towns.find(driver_start_station)
	if stop_idx != -1:
		var mainline_points := _mainline_stop_points()
		if stop_idx < mainline_points.size():
			if stop_idx <= _last_subway_station_index():
				return _subway_track_point(mainline_points[stop_idx])
			return mainline_points[stop_idx]
	return Vector3.ZERO

func _attach_trolley_body(trolley: Node3D, car_index: int = 0) -> void:
	var mount := _get_trolley_visual_root(trolley)
	for child in mount.get_children():
		child.queue_free()
	var scene_path := _scene_path_for_trolley(trolley, car_index)
	if ResourceLoader.exists(scene_path):
		var scene := load(scene_path) as PackedScene
		if scene != null:
			var model := scene.instantiate()
			mount.add_child(model)
			var headlight := OmniLight3D.new()
			headlight.light_energy = 0.8
			headlight.light_color = Color(1.0, 0.95, 0.82)
			headlight.position = Vector3(0.0, 1.8, -6.4)
			mount.add_child(headlight)
			return

	var lower := MeshInstance3D.new()
	var lower_mesh := BoxMesh.new()
	lower_mesh.size = Vector3(6.4, 1.2, 13.6)
	lower.mesh = lower_mesh
	var lower_mat := StandardMaterial3D.new()
	lower_mat.albedo_color = Color("bf2d1d") # Type 5 body red
	lower_mat.metallic = 0.12
	lower_mat.roughness = 0.32
	lower.set_surface_override_material(0, lower_mat)
	lower.position = Vector3(0.0, 0.9, 0.0)
	mount.add_child(lower)

	var belt := MeshInstance3D.new()
	var belt_mesh := BoxMesh.new()
	belt_mesh.size = Vector3(6.6, 0.25, 13.8)
	belt.mesh = belt_mesh
	var belt_mat := StandardMaterial3D.new()
	belt_mat.albedo_color = Color("1e1a1a") # dark trim
	belt_mat.metallic = 0.18
	belt_mat.roughness = 0.28
	belt.set_surface_override_material(0, belt_mat)
	belt.position = Vector3(0.0, 1.55, 0.0)
	mount.add_child(belt)

	var windows := MeshInstance3D.new()
	var windows_mesh := BoxMesh.new()
	windows_mesh.size = Vector3(6.0, 1.1, 13.0)
	windows.mesh = windows_mesh
	var win_mat := StandardMaterial3D.new()
	win_mat.albedo_color = Color(0.78, 0.87, 0.96, 0.18)
	win_mat.metallic = 0.02
	win_mat.roughness = 0.08
	win_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	win_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	windows.set_surface_override_material(0, win_mat)
	windows.position = Vector3(0.0, 2.2, 0.0)
	mount.add_child(windows)

	var roof := MeshInstance3D.new()
	var roof_mesh := BoxMesh.new()
	roof_mesh.size = Vector3(6.8, 0.4, 12.6)
	roof.mesh = roof_mesh
	var roof_mat := StandardMaterial3D.new()
	roof_mat.albedo_color = Color("2c2521")
	roof_mat.metallic = 0.1
	roof_mat.roughness = 0.28
	roof.set_surface_override_material(0, roof_mat)
	roof.position = Vector3(0.0, 2.9, 0.0)
	mount.add_child(roof)

	var pole := MeshInstance3D.new()
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.07
	pole_mesh.bottom_radius = 0.07
	pole_mesh.height = 2.8
	pole.mesh = pole_mesh
	var pole_mat := StandardMaterial3D.new()
	pole_mat.albedo_color = Color("202020")
	pole.set_surface_override_material(0, pole_mat)
	pole.position = Vector3(0.0, 3.4, -2.8)
	mount.add_child(pole)

	var headlight := OmniLight3D.new()
	headlight.light_energy = 0.8
	headlight.light_color = Color(1.0, 0.95, 0.82)
	headlight.transform.origin = Vector3(0.0, 1.2, -7.2)
	mount.add_child(headlight)

func cycle_player_trolley_type() -> void:
	var scene_paths := _valid_trolley_scene_paths()
	if scene_paths.size() < 2:
		return
	if _driver_trolley == null or not is_instance_valid(_driver_trolley):
		return
	_player_trolley_scene_index = (_player_trolley_scene_index + 1) % scene_paths.size()
	_attach_trolley_body(_driver_trolley, driver_trolley_index)

func _cycle_service_line() -> void:
	var ids := _service_line_ids_sorted()
	if ids.size() < 2:
		return
	var current_idx := maxi(ids.find(_driver_line_id), 0)
	for step in range(1, ids.size() + 1):
		var next_line_id := ids[(current_idx + step) % ids.size()]
		if _try_driver_branch_switch(next_line_id):
			return
		var fleet: Array = _line_fleet(next_line_id)
		if fleet.is_empty():
			continue
		var trolley := fleet[0] as TrolleyMover
		if trolley == null or not is_instance_valid(trolley):
			continue
		_activate_service_line(next_line_id)
		_set_driver_trolley(trolley, 0)
		return

func get_service_line_choices() -> Array:
	var choices: Array = []
	for line_id in _service_line_ids_sorted():
		var entry := _service_line_entry(line_id)
		choices.append({
			"id": line_id,
			"name": String(entry.get("name", line_id))
		})
	return choices

func get_active_service_line_id() -> String:
	return _driver_line_id

func set_active_service_line(line_id: String) -> bool:
	var entry := _service_line_entry(line_id)
	if entry.is_empty():
		return false
	if _try_driver_branch_switch(line_id):
		return true
	var fleet: Array = entry.get("fleet", [])
	for fleet_index in range(fleet.size()):
		var trolley := fleet[fleet_index] as TrolleyMover
		if trolley == null or not is_instance_valid(trolley):
			continue
		_activate_service_line(line_id)
			_set_driver_trolley(trolley, fleet_index)
			return true
	return false

func _route_stop_named(route_stops: Array, stop_name: String) -> Dictionary:
	for stop_variant in route_stops:
		var stop: Dictionary = stop_variant
		if String(stop.get("name", "")) == stop_name:
			return stop
	return {}

func _try_driver_branch_switch(target_line_id: String) -> bool:
	if target_line_id == "" or target_line_id == _driver_line_id:
		return false
	if _driver_trolley == null or not is_instance_valid(_driver_trolley):
		return false
	var current_stop := String(_driver_station_payload().get("current", ""))
	if current_stop == "" or absf(_driver_trolley.speed_mps) > driver_service_stop_speed_threshold_mps + 0.35:
		return false
	var target_entry := _service_line_entry(target_line_id)
	if target_entry.is_empty():
		return false
	var target_stop := _route_stop_named(target_entry.get("route_stops", []), current_stop)
	if target_stop.is_empty():
		return false
	var target_path := target_entry.get("path", null) as Path3D
	if target_path == null or target_path.curve == null:
		return false
	var current_entry := _service_line_entry(_driver_line_id)
	var current_fleet: Array = current_entry.get("fleet", [])
	current_fleet.erase(_driver_trolley)
	current_entry["fleet"] = current_fleet
	_service_lines[_driver_line_id] = current_entry
	var parent := _driver_trolley.get_parent()
	if parent != null:
		parent.remove_child(_driver_trolley)
	target_path.add_child(_driver_trolley)
	_driver_trolley.progress = float(target_stop.get("offset", 0.0))
	_driver_trolley.speed_mps = 0.0
	_driver_trolley.target_speed_mps = 0.0
	_driver_trolley.set_meta("service_line_id", target_line_id)
	var target_fleet: Array = target_entry.get("fleet", [])
	if not target_fleet.has(_driver_trolley):
		target_fleet.append(_driver_trolley)
	target_entry["fleet"] = target_fleet
	_service_lines[target_line_id] = target_entry
	_activate_service_line(target_line_id)
	_set_driver_trolley(_driver_trolley, maxi(0, target_fleet.find(_driver_trolley)))
	return true

func set_driver_manual_control(enabled: bool) -> void:
	_driver_manual_control_enabled = enabled
	if _driver_trolley != null and is_instance_valid(_driver_trolley):
		if _driver_trolley.has_method("set_manual_control_enabled"):
			_driver_trolley.call("set_manual_control_enabled", enabled)
		if not enabled:
			_resume_ai_trolley(_driver_trolley)

func is_driver_manual_control_enabled() -> bool:
	return _driver_manual_control_enabled

func toggle_driver_manual_control() -> void:
	set_driver_manual_control(not _driver_manual_control_enabled)

func set_controlled_trolley_index(car_index: int) -> bool:
	var global_index := 1
	for line_id in _service_line_ids_sorted():
		var fleet: Array = _line_fleet(line_id)
		for fleet_index in range(fleet.size()):
			var trolley := fleet[fleet_index] as TrolleyMover
			if trolley == null or not is_instance_valid(trolley):
				continue
			if global_index == car_index:
				_activate_service_line(line_id)
				_set_driver_trolley(trolley, fleet_index)
				return true
			global_index += 1
	return false

func get_fleet_size() -> int:
	var total := 0
	for line_id in _service_line_ids_sorted():
		total += _line_fleet(line_id).size()
	return total

func get_timetable_segments() -> Array[Dictionary]:
	var payload: Array[Dictionary] = []
	for line_id in _service_line_ids_sorted():
		var entry := _service_line_entry(line_id)
		var segments: Array = entry.get("timetable_segments", [])
		for segment_variant in segments:
			var segment: Dictionary = segment_variant
			var active_cars := _active_cars_in_segment(segment, line_id)
			var suggested_cars := _suggested_cars_for_segment(segment)
			payload.append({
				"id": String(segment.get("id", "")),
				"name": String(segment.get("name", "")),
				"line_name": String(segment.get("line_name", entry.get("name", line_id))),
				"headway_min": float(segment.get("headway_min", 0.0)),
				"start_name": String(segment.get("start_name", "")),
				"end_name": String(segment.get("end_name", "")),
				"length_m": float(segment.get("length_m", 0.0)),
				"active_cars": active_cars,
				"suggested_cars": suggested_cars
			})
	return payload

func adjust_timetable_segment_headway(segment_id: String, delta_minutes: float) -> Dictionary:
	if segment_id == "":
		return {"ok": false, "message": "No segment selected."}
	for line_id in _service_line_ids_sorted():
		var entry: Dictionary = _service_line_entry(line_id)
		var segments: Array = entry.get("timetable_segments", [])
		for i in range(segments.size()):
			var segment: Dictionary = segments[i]
			if String(segment.get("id", "")) != segment_id:
				continue
			var next_headway := clampf(float(segment.get("headway_min", 6.0)) + delta_minutes, 2.0, 20.0)
			segment["headway_min"] = next_headway
			segments[i] = segment
			entry["timetable_segments"] = segments
			_service_lines[line_id] = entry
			if line_id == _driver_line_id:
				_timetable_segments = segments
			return {"ok": true, "message": "%s headway set to %.0f min." % [String(segment.get("name", segment_id)), next_headway]}
	return {"ok": false, "message": "Segment not found."}

func get_depot_operations_snapshot() -> Array[Dictionary]:
	_sync_depot_inventory()
	var payload: Array[Dictionary] = []
	var depot_ids := _depot_inventory.keys()
	depot_ids.sort()
	for depot_id_variant in depot_ids:
		var depot_id := String(depot_id_variant)
		var entry: Dictionary = _depot_inventory.get(depot_id, {})
		var stored: Dictionary = entry.get("stored", {})
		var distance_to_driver := _driver_distance_to_depot(entry)
		payload.append({
			"id": depot_id,
			"name": String(entry.get("name", depot_id)),
			"stored_total": _depot_total_stock(stored),
			"type5": int(stored.get(Type5CarScenePath, 0)),
			"pcc": int(stored.get(PCCCarScenePath, 0)),
			"distance_to_driver_m": distance_to_driver,
			"launch_ready": _depot_total_stock(stored) > 0 or (_economy != null and _economy.has_method("can_afford") and bool(_economy.call("can_afford", depot_purchase_cost))),
			"store_ready": _fleet.size() > 1 and _driver_trolley != null and is_instance_valid(_driver_trolley) and distance_to_driver <= maxf(40.0, depot_operation_radius_m)
		})
	return payload

func launch_trolley_from_depot(depot_id: String) -> Dictionary:
	_sync_depot_inventory()
	if not _depot_inventory.has(depot_id):
		return {"ok": false, "message": "Depot not found."}
	var path := _active_service_path()
	if path == null or path.curve == null:
		return {"ok": false, "message": "No live route is available."}
	var entry: Dictionary = _depot_inventory.get(depot_id, {})
	var scene_path := _take_depot_stock(depot_id)
	var purchased := false
	if scene_path == "":
		scene_path = _default_purchase_scene_path()
		if _economy != null and _economy.has_method("spend_capital"):
			if not bool(_economy.call("spend_capital", depot_purchase_cost, "Capital spend")):
				return {"ok": false, "message": "Not enough cash to buy another car."}
		purchased = true
	var trolley := TrolleyMover.new()
	trolley.speed_mps = 0.0
	trolley.max_speed_mps = trolley_max_speed_mps
	trolley.loop_path = false
	trolley.ping_pong = true
	trolley.target_speed_mps = 0.0
	trolley.set_meta("scene_path_override", scene_path)
	trolley.set_meta("service_line_id", _driver_line_id)
	var depot_position: Vector3 = entry.get("position", Vector3.ZERO)
	trolley.progress = float(path.curve.get_closest_offset(depot_position))
	path.add_child(trolley)
	_fleet.append(trolley)
	var fleet_index := _fleet.size() - 1
	_attach_trolley_body(trolley, fleet_index)
	_set_player_scene_index_for_path(scene_path)
	_set_driver_trolley(trolley, fleet_index)
	_refresh_fleet_visuals()
	_sync_current_line_state()
	var label := "Purchased and launched" if purchased else "Launched stored car"
	return {"ok": true, "message": "%s from %s." % [label, String(entry.get("name", depot_id))]}

func store_controlled_trolley_at_depot(depot_id: String) -> Dictionary:
	_sync_depot_inventory()
	if not _depot_inventory.has(depot_id):
		return {"ok": false, "message": "Depot not found."}
	if _driver_trolley == null or not is_instance_valid(_driver_trolley):
		return {"ok": false, "message": "No controlled trolley to store."}
	if _fleet.size() <= 1:
		return {"ok": false, "message": "At least one car must stay in service."}
	var entry: Dictionary = _depot_inventory.get(depot_id, {})
	if _driver_distance_to_depot(entry) > maxf(40.0, depot_operation_radius_m):
		return {"ok": false, "message": "Bring the controlled car onto the depot lead first."}
	var stored_scene_path := _current_driver_scene_path()
	_add_depot_stock(depot_id, stored_scene_path, 1)
	var retiring_trolley := _driver_trolley
	var retiring_index := _fleet.find(retiring_trolley)
	var replacement_index := 0 if retiring_index != 0 else 1
	var replacement := _fleet[replacement_index]
	_fleet.remove_at(retiring_index)
	retiring_trolley.queue_free()
	if replacement_index > retiring_index:
		replacement_index -= 1
	_set_driver_trolley(replacement, replacement_index)
	_refresh_fleet_visuals()
	_sync_current_line_state()
	return {"ok": true, "message": "Stored current car at %s." % String(_depot_inventory[depot_id].get("name", depot_id))}

func _build_timetable_segments() -> void:
	if _driver_line_id != MainLineServiceId:
		var active_entry := _service_line_entry(_driver_line_id)
		_timetable_segments = active_entry.get("timetable_segments", [])
		return
	if _driver_route_stops.is_empty():
		_timetable_segments.clear()
		return
	var previous_headways := {}
	for segment in _timetable_segments:
		previous_headways[String(segment.get("id", ""))] = float(segment.get("headway_min", 6.0))
	var segment_specs: Array[Dictionary] = []
	if build_north_terminal_extension:
		segment_specs.append({
			"id": "north_terminal",
			"name": "North Terminal",
			"start_name": "Lechmere",
			"end_name": "Park Street",
			"default_headway_min": timetable_north_headway_min
		})
	segment_specs.append({
		"id": "downtown_subway",
		"name": "Downtown Subway",
		"start_name": "Park Street",
		"end_name": "Kenmore",
		"default_headway_min": timetable_subway_headway_min
	})
	segment_specs.append({
		"id": "route9_inner",
		"name": "Route 9 Inner",
		"start_name": "Kenmore",
		"end_name": "Framingham Center",
		"default_headway_min": timetable_inner_headway_min
	})
	segment_specs.append({
		"id": "route9_outer",
		"name": "Route 9 Outer",
		"start_name": "Framingham Center",
		"end_name": "Lincoln Square",
		"default_headway_min": timetable_outer_headway_min
	})
	var rebuilt: Array[Dictionary] = []
	for spec in segment_specs:
		var segment := _build_timetable_segment_from_spec(spec, previous_headways)
		if not segment.is_empty():
			rebuilt.append(segment)
	if rebuilt.is_empty():
		rebuilt.append(_fallback_timetable_segment(previous_headways))
	_timetable_segments = rebuilt
	_sync_current_line_state()

func _build_timetable_segment_from_spec(spec: Dictionary, previous_headways: Dictionary) -> Dictionary:
	var start_name := String(spec.get("start_name", ""))
	var end_name := String(spec.get("end_name", ""))
	var start_entry := _route_stop_entry_by_name(start_name)
	var end_entry := _route_stop_entry_by_name(end_name)
	if start_entry.is_empty() or end_entry.is_empty():
		return {}
	var start_offset := float(start_entry.get("offset", 0.0))
	var end_offset := float(end_entry.get("offset", 0.0))
	var min_offset := minf(start_offset, end_offset)
	var max_offset := maxf(start_offset, end_offset)
	if max_offset - min_offset < 20.0:
		return {}
	var segment_id := String(spec.get("id", "segment"))
	var default_headway := float(spec.get("default_headway_min", 6.0))
	return {
		"id": segment_id,
		"name": String(spec.get("name", segment_id)),
		"line_id": _driver_line_id,
		"line_name": _service_line_entry(_driver_line_id).get("name", line_name),
		"start_name": start_name,
		"end_name": end_name,
		"start_offset": min_offset,
		"end_offset": max_offset,
		"length_m": max_offset - min_offset,
		"headway_min": float(previous_headways.get(segment_id, default_headway))
	}

func _fallback_timetable_segment(previous_headways: Dictionary) -> Dictionary:
	var start_entry: Dictionary = _driver_route_stops.front() if not _driver_route_stops.is_empty() else {}
	var end_entry: Dictionary = _driver_route_stops.back() if not _driver_route_stops.is_empty() else {}
	var start_offset := float(start_entry.get("offset", 0.0))
	var end_offset := float(end_entry.get("offset", 0.0))
	var min_offset := minf(start_offset, end_offset)
	var max_offset := maxf(start_offset, end_offset)
	return {
		"id": "main_line",
		"name": "Main Line",
		"line_id": _driver_line_id,
		"line_name": _service_line_entry(_driver_line_id).get("name", line_name),
		"start_name": String(start_entry.get("name", "Origin")),
		"end_name": String(end_entry.get("name", "Terminal")),
		"start_offset": min_offset,
		"end_offset": max_offset,
		"length_m": max_offset - min_offset,
		"headway_min": float(previous_headways.get("main_line", 8.0))
	}

func _route_stop_entry_by_name(stop_name: String) -> Dictionary:
	for entry in _driver_route_stops:
		if String(entry.get("name", "")) == stop_name:
			return entry
	return {}

func _segment_for_progress(progress: float) -> Dictionary:
	_build_timetable_segments()
	var best_match := {}
	var best_distance := INF
	for segment in _timetable_segments:
		var start_offset := float(segment.get("start_offset", 0.0))
		var end_offset := float(segment.get("end_offset", 0.0))
		if progress >= start_offset and progress <= end_offset:
			return segment
		var distance := minf(absf(progress - start_offset), absf(progress - end_offset))
		if distance < best_distance:
			best_distance = distance
			best_match = segment
	return best_match

func _segment_target_spacing_m(segment: Dictionary) -> float:
	var headway_min := maxf(2.0, float(segment.get("headway_min", 6.0)))
	return maxf(200.0, _average_service_speed_mps() * headway_min * 60.0)

func _average_service_speed_mps() -> float:
	return clampf(trolley_speed_mps * 0.78, 6.0, 15.0)

func _active_cars_in_segment(segment: Dictionary, line_id: String = "") -> int:
	if line_id == "":
		line_id = String(segment.get("line_id", _driver_line_id))
	var start_offset := float(segment.get("start_offset", 0.0))
	var end_offset := float(segment.get("end_offset", 0.0))
	var count := 0
	for trolley in _line_fleet(line_id):
		if trolley == null or not is_instance_valid(trolley):
			continue
		if trolley.progress >= start_offset and trolley.progress <= end_offset:
			count += 1
	return count

func _suggested_cars_for_segment(segment: Dictionary) -> int:
	var length_m := maxf(1.0, float(segment.get("length_m", 0.0)))
	return maxi(1, int(ceil(length_m / maxf(1.0, _segment_target_spacing_m(segment)))))

func _sync_depot_inventory() -> void:
	if _stop_placer == null or not is_instance_valid(_stop_placer):
		_resolve_gameplay_dependencies()
	if _stop_placer == null or not _stop_placer.has_method("get_manual_depots"):
		_depot_inventory.clear()
		return
	var manual_depots: Array[Dictionary] = _stop_placer.call("get_manual_depots")
	var live_ids := {}
	for depot in manual_depots:
		var depot_id := String(depot.get("id", ""))
		if depot_id == "":
			continue
		live_ids[depot_id] = true
		var entry: Dictionary = _depot_inventory.get(depot_id, {})
		var stored: Dictionary = entry.get("stored", {})
		if entry.is_empty():
			stored = {}
			if depot_initial_type5_stock > 0:
				stored[Type5CarScenePath] = depot_initial_type5_stock
			if depot_initial_pcc_stock > 0:
				stored[PCCCarScenePath] = depot_initial_pcc_stock
		entry["id"] = depot_id
		entry["name"] = String(depot.get("name", depot_id))
		entry["position"] = depot.get("position", Vector3.ZERO)
		entry["stored"] = stored
		_depot_inventory[depot_id] = entry
	for depot_id_variant in _depot_inventory.keys():
		var depot_id := String(depot_id_variant)
		if not live_ids.has(depot_id):
			_depot_inventory.erase(depot_id)

func _depot_total_stock(stored: Dictionary) -> int:
	var total := 0
	for amount_variant in stored.values():
		total += int(amount_variant)
	return total

func _take_depot_stock(depot_id: String) -> String:
	if not _depot_inventory.has(depot_id):
		return ""
	var entry: Dictionary = _depot_inventory.get(depot_id, {})
	var stored: Dictionary = entry.get("stored", {})
	var preferred_paths: Array[String] = []
	var current_player_path := _default_purchase_scene_path()
	if current_player_path != "":
		preferred_paths.append(current_player_path)
	for scene_path in [Type5CarScenePath, PCCCarScenePath]:
		if not preferred_paths.has(scene_path):
			preferred_paths.append(scene_path)
	for scene_path in stored.keys():
		var candidate := String(scene_path)
		if not preferred_paths.has(candidate):
			preferred_paths.append(candidate)
	for scene_path in preferred_paths:
		var count := int(stored.get(scene_path, 0))
		if count <= 0:
			continue
		stored[scene_path] = count - 1
		entry["stored"] = stored
		_depot_inventory[depot_id] = entry
		return scene_path
	return ""

func _default_purchase_scene_path() -> String:
	var scene_paths := _valid_trolley_scene_paths()
	if scene_paths.is_empty():
		return ""
	return scene_paths[clampi(_player_trolley_scene_index, 0, scene_paths.size() - 1)]

func _set_player_scene_index_for_path(scene_path: String) -> void:
	var scene_paths := _valid_trolley_scene_paths()
	for i in range(scene_paths.size()):
		if scene_paths[i] == scene_path:
			_player_trolley_scene_index = i
			return

func _active_service_path() -> Path3D:
	if _signal_path != null and is_instance_valid(_signal_path) and _signal_path.curve != null:
		return _signal_path
	var active_entry := _service_line_entry(_driver_line_id)
	var active_path := active_entry.get("path", null) as Path3D
	if active_path != null and is_instance_valid(active_path) and active_path.curve != null:
		return active_path
	var parent := _get_path_parent(_get_track_builder())
	if parent == null:
		return null
	return parent.get_node_or_null(path_name) as Path3D

func _current_driver_scene_path() -> String:
	if _driver_trolley == null or not is_instance_valid(_driver_trolley):
		return _default_purchase_scene_path()
	return _scene_path_for_trolley(_driver_trolley, maxi(driver_trolley_index, 0))

func _add_depot_stock(depot_id: String, scene_path: String, amount: int) -> void:
	if amount <= 0 or scene_path == "" or not _depot_inventory.has(depot_id):
		return
	var entry: Dictionary = _depot_inventory.get(depot_id, {})
	var stored: Dictionary = entry.get("stored", {})
	stored[scene_path] = int(stored.get(scene_path, 0)) + amount
	entry["stored"] = stored
	_depot_inventory[depot_id] = entry

func _driver_distance_to_depot(entry: Dictionary) -> float:
	if _driver_trolley == null or not is_instance_valid(_driver_trolley):
		return INF
	var depot_position: Vector3 = entry.get("position", Vector3.ZERO)
	return _driver_trolley.global_position.distance_to(depot_position)

func _refresh_fleet_visuals() -> void:
	for line_id in _service_line_ids_sorted():
		var fleet: Array = _line_fleet(line_id)
		for i in range(fleet.size()):
			var trolley := fleet[i] as TrolleyMover
			if trolley == null or not is_instance_valid(trolley):
				continue
			_attach_trolley_body(trolley, i)

func _set_default_player_trolley_scene_index() -> void:
	var scene_paths := _valid_trolley_scene_paths()
	_player_trolley_scene_index = 0
	for i in range(scene_paths.size()):
		if scene_paths[i] == default_player_trolley_scene_path:
			_player_trolley_scene_index = i
			return

func _valid_trolley_scene_paths() -> Array[String]:
	var scene_paths: Array[String] = []
	for raw_path in available_trolley_scene_paths:
		var scene_path := String(raw_path)
		if scene_path == "":
			continue
		if not ResourceLoader.exists(scene_path):
			continue
		if scene_paths.has(scene_path):
			continue
		scene_paths.append(scene_path)
	if scene_paths.is_empty():
		for fallback_path in [Type5CarScenePath, PCCCarScenePath]:
			var scene_path := String(fallback_path)
			if scene_path == "":
				continue
			if not ResourceLoader.exists(scene_path):
				continue
			if scene_paths.has(scene_path):
			continue
			scene_paths.append(scene_path)
	return scene_paths

func _is_green_service_line(line_id: String) -> bool:
	return line_id in [
		MainLineServiceId,
		GreenAServiceId,
		GreenBServiceId,
		GreenCServiceId,
		GreenDServiceId,
		GreenEServiceId
	]

func _preferred_scene_path_for_line(line_id: String) -> String:
	match line_id:
		GreenAServiceId, GreenBServiceId, GreenCServiceId, GreenDServiceId, MainLineServiceId:
			return Type5CarScenePath
		GreenEServiceId, MattapanServiceId:
			return PCCCarScenePath
		AtlanticServiceId:
			return AtlanticElCarScenePath
		WashingtonServiceId:
			return WashingtonTunnelTrainScenePath
		CambridgeServiceId:
			return CambridgeDorchesterCarScenePath
		BlueServiceId:
			return BlueLineCarScenePath
		_:
			return default_player_trolley_scene_path

func _scene_path_for_trolley(trolley: Node3D, car_index: int) -> String:
	var scene_paths := _valid_trolley_scene_paths()
	if scene_paths.is_empty():
		return ""
	var override_path := String(trolley.get_meta("scene_path_override", ""))
	var line_id := _line_id_for_trolley(trolley as TrolleyMover if trolley is TrolleyMover else null)
	if trolley is TrolleyMover and (trolley as TrolleyMover).controlled and _is_green_service_line(line_id):
		return scene_paths[clampi(_player_trolley_scene_index, 0, scene_paths.size() - 1)]
	if override_path != "" and ResourceLoader.exists(override_path):
		return override_path
	var preferred_path := _preferred_scene_path_for_line(line_id)
	if preferred_path != "" and ResourceLoader.exists(preferred_path):
		return preferred_path
	return scene_paths[car_index % scene_paths.size()]

func _get_trolley_visual_root(trolley: Node3D) -> Node3D:
	var mount := trolley
	if trolley is TrolleyMover:
		mount = (trolley as TrolleyMover).get_attachment_root()
	var visual_root := mount.get_node_or_null("VisualRoot") as Node3D
	if visual_root == null:
		visual_root = Node3D.new()
		visual_root.name = "VisualRoot"
		mount.add_child(visual_root)
	return visual_root

func _attach_driver_camera(trolley: Node3D) -> Camera3D:
	var mount := trolley
	if trolley is TrolleyMover:
		mount = (trolley as TrolleyMover).get_attachment_root()
	var cam := Camera3D.new()
	cam.fov = driver_camera_fov
	cam.near = 0.05
	cam.current = false
	cam.position = Vector3(0.0, driver_camera_height, -driver_camera_forward)
	cam.rotation_degrees = Vector3(-3.5, 0.0, 0.0)
	mount.add_child(cam)
	return cam

func _attach_chase_camera(trolley: Node3D) -> Camera3D:
	var mount := trolley
	if trolley is TrolleyMover:
		mount = (trolley as TrolleyMover).get_attachment_root()
	var cam := Camera3D.new()
	cam.fov = 62.0
	cam.near = 0.05
	cam.current = false
	cam.position = chase_surface_camera_offset
	cam.rotation_degrees = Vector3(chase_surface_camera_pitch_deg, 0.0, 0.0)
	mount.add_child(cam)
	return cam

func _set_driver_trolley(trolley: TrolleyMover, fleet_index: int) -> void:
	if trolley == null or not is_instance_valid(trolley):
		return
	var next_line_id := _line_id_for_trolley(trolley)
	_activate_service_line(next_line_id)
	var previous := _driver_trolley
	if previous != null and is_instance_valid(previous) and previous != trolley:
		var previous_index := _local_fleet_index(_line_id_for_trolley(previous), previous)
		previous.controlled = false
		if previous.has_method("set_manual_control_enabled"):
			previous.call("set_manual_control_enabled", false)
		_resume_ai_trolley(previous)
		if previous_index >= 0:
			_attach_trolley_body(previous, previous_index)
	_driver_trolley = trolley
	driver_trolley_index = fleet_index
	_driver_trolley.controlled = true
	if _driver_trolley.has_method("set_manual_control_enabled"):
		_driver_trolley.call("set_manual_control_enabled", _driver_manual_control_enabled)
	if not _driver_manual_control_enabled:
		_resume_ai_trolley(_driver_trolley)
	_rebind_driver_cameras(_driver_trolley)
	_attach_trolley_body(_driver_trolley, driver_trolley_index)
	_driver_station_presence_name = ""
	_driver_station_serviced = false
	_driver_station_dwell_s = 0.0
	_driver_station_target_dwell_s = 0.0
	_update_chase_camera_pose()
	_update_active_camera()
	_sync_current_line_state()

func _local_fleet_index(line_id: String, trolley: TrolleyMover) -> int:
	return _line_fleet(line_id).find(trolley)

func _resume_ai_trolley(trolley: TrolleyMover) -> void:
	if trolley == null or not is_instance_valid(trolley):
		return
	var cruise_speed := maxf(6.0, trolley_speed_mps)
	if absf(trolley.speed_mps) < 0.4:
		trolley.speed_mps = cruise_speed * (1.0 if trolley.travel_direction >= 0.0 else -1.0)
	if absf(trolley.target_speed_mps) < 0.4:
		trolley.target_speed_mps = trolley.speed_mps

func _rebind_driver_cameras(trolley: TrolleyMover) -> void:
	if trolley == null or not is_instance_valid(trolley):
		return
	var mount: Node3D = trolley.get_attachment_root() if trolley.has_method("get_attachment_root") else trolley
	if _driver_camera == null or not is_instance_valid(_driver_camera):
		_driver_camera = _attach_driver_camera(trolley)
	else:
		var parent := _driver_camera.get_parent()
		if parent != null:
			parent.remove_child(_driver_camera)
		mount.add_child(_driver_camera)
		_driver_camera.position = Vector3(0.0, driver_camera_height, -driver_camera_forward)
		_driver_camera.rotation_degrees = Vector3(-3.5, 0.0, 0.0)
	if _chase_camera == null or not is_instance_valid(_chase_camera):
		_chase_camera = _attach_chase_camera(trolley)
	else:
		var chase_parent := _chase_camera.get_parent()
		if chase_parent != null:
			chase_parent.remove_child(_chase_camera)
		mount.add_child(_chase_camera)
		_chase_camera.position = chase_surface_camera_offset
		_chase_camera.rotation_degrees = Vector3(chase_surface_camera_pitch_deg, 0.0, 0.0)

func _update_chase_camera_pose() -> void:
	if _chase_camera == null or _driver_trolley == null or not is_instance_valid(_driver_trolley):
		return
	var is_subway := _driver_trolley.global_position.y <= chase_subway_depth_threshold
	_chase_camera.position = chase_subway_camera_offset if is_subway else chase_surface_camera_offset
	_chase_camera.rotation_degrees = Vector3(chase_subway_camera_pitch_deg if is_subway else chase_surface_camera_pitch_deg, 0.0, 0.0)

func _update_active_camera() -> void:
	if _driver_camera == null and _chase_camera == null:
		return
	if not _driver_active:
		if _driver_camera:
			_driver_camera.current = false
		if _chase_camera:
			_chase_camera.current = false
		if _main_camera:
			_main_camera.current = true
		return
	if _view_mode == 0:
		if _driver_camera:
			_driver_camera.current = true
		if _chase_camera:
			_chase_camera.current = false
	else:
		if _chase_camera:
			_chase_camera.current = true
		if _driver_camera:
			_driver_camera.current = false

func _setup_driver_audio() -> void:
	if not driver_audio_enabled:
		return
	_driver_motor_audio = _ensure_driver_audio_player("DriverMotorAudio", trolley_motor_loop_path)
	_driver_track_audio = _ensure_driver_audio_player("DriverTrackAudio", trolley_track_loop_path)

func _setup_station_audio() -> void:
	if not station_ambience_enabled:
		return
	_station_ambience_audio = _ensure_audio_player("StationAmbienceAudio", station_ambience_loop_path, true)
	_station_chime_audio = _ensure_audio_player("StationChimeAudio", station_chime_path, false)

func _ensure_driver_audio_player(player_name: String, stream_path: String) -> AudioStreamPlayer:
	return _ensure_audio_player(player_name, stream_path, true)

func _ensure_audio_player(player_name: String, stream_path: String, loop_enabled: bool) -> AudioStreamPlayer:
	if stream_path == "":
		return null
	var player := get_node_or_null(player_name) as AudioStreamPlayer
	if player == null:
		player = AudioStreamPlayer.new()
		player.name = player_name
		add_child(player)
	player.bus = &"Master"
	player.autoplay = false
	player.volume_db = -80.0
	player.pitch_scale = 1.0
	player.stream = _load_audio_stream(stream_path, loop_enabled)
	return player

func _load_audio_stream(stream_path: String, loop_enabled: bool) -> AudioStream:
	if stream_path == "" or not ResourceLoader.exists(stream_path):
		return null
	var base_stream := load(stream_path) as AudioStream
	if base_stream == null:
		return null
	var stream := base_stream.duplicate() as AudioStream
	if stream == null:
		stream = base_stream
	if loop_enabled:
		for property in stream.get_property_list():
			if String(property.get("name", "")) == "loop":
				stream.set("loop", true)
				break
	return stream

func _update_driver_audio(delta: float) -> void:
	if not driver_audio_enabled:
		return
	if _driver_motor_audio == null and _driver_track_audio == null:
		_setup_driver_audio()
	var speed_ratio := 0.0
	var throttle_ratio := 0.0
	if _driver_trolley != null and is_instance_valid(_driver_trolley):
		var max_speed := maxf(1.0, _driver_trolley.max_speed_mps)
		speed_ratio = clampf(absf(_driver_trolley.speed_mps) / max_speed, 0.0, 1.0)
		throttle_ratio = clampf(absf(_driver_trolley.target_speed_mps) / max_speed, 0.0, 1.0)
	var motor_mix := clampf(maxf(throttle_ratio, speed_ratio * 0.7), 0.0, 1.0)
	var track_mix := clampf((speed_ratio - 0.04) / 0.96, 0.0, 1.0)
	var motor_db := lerpf(trolley_motor_idle_volume_db, trolley_motor_max_volume_db, motor_mix)
	var track_db := lerpf(trolley_track_idle_volume_db, trolley_track_max_volume_db, track_mix)
	var motor_pitch := lerpf(trolley_motor_idle_pitch, trolley_motor_max_pitch, clampf(throttle_ratio * 0.75 + speed_ratio * 0.25, 0.0, 1.0))
	var track_pitch := lerpf(trolley_track_idle_pitch, trolley_track_max_pitch, speed_ratio)
	_apply_driver_audio_state(_driver_motor_audio, motor_db, motor_pitch, delta)
	_apply_driver_audio_state(_driver_track_audio, track_db, track_pitch, delta)

func _update_station_ambience(delta: float) -> void:
	if not station_ambience_enabled or _station_ambience_audio == null or _station_ambience_audio.stream == null:
		return
	var payload := _driver_station_payload()
	var current_name := String(payload.get("current", ""))
	var distance_m := float(payload.get("distance_m", -1.0))
	var target_presence := 0.0
	var waiting_weight := 0.0
	if current_name != "":
		target_presence = 1.0
		waiting_weight = clampf(float(payload.get("current_waiting", 0)) / 12.0, 0.0, 1.0)
	elif distance_m >= 0.0 and distance_m <= station_announcement_approach_distance_m:
		target_presence = 1.0 - clampf(distance_m / station_announcement_approach_distance_m, 0.0, 1.0)
		waiting_weight = clampf(float(payload.get("next_waiting", 0)) / 12.0, 0.0, 1.0)
	var target_db := -80.0
	if target_presence > 0.02:
		target_db = lerpf(-34.0, -24.0, waiting_weight) + lerpf(-8.0, 0.0, target_presence)
	if not _station_ambience_audio.playing and target_db > -70.0:
		_station_ambience_audio.play()
		_station_ambience_audio.volume_db = target_db
	var target_pitch := lerpf(0.94, 1.04, waiting_weight)
	_station_ambience_audio.volume_db = move_toward(_station_ambience_audio.volume_db, target_db, 24.0 * delta)
	_station_ambience_audio.pitch_scale = move_toward(_station_ambience_audio.pitch_scale, target_pitch, 0.7 * delta)

func _apply_driver_audio_state(player: AudioStreamPlayer, target_db: float, target_pitch: float, delta: float) -> void:
	if player == null or player.stream == null:
		return
	if not player.playing:
		player.volume_db = target_db
		player.pitch_scale = target_pitch
		player.play()
		return
	player.volume_db = move_toward(player.volume_db, target_db, trolley_audio_blend_speed * delta)
	player.pitch_scale = move_toward(player.pitch_scale, target_pitch, 1.5 * delta)

func _configure_main_camera(points: PackedVector3Array) -> void:
	if _main_camera == null or points.is_empty():
		return
	var rig := _main_camera.get_parent()
	if rig == null or not rig.has_method("set_focus_points"):
		return
	var map_focus := _average_points(points)
	var street_focus := _driver_start_point()
	var street_forward := Vector3.RIGHT
	if street_focus == Vector3.ZERO and points.size() > 1:
		street_focus = points[0].lerp(points[1], 0.5)
	var stop_points := _mainline_stop_points()
	if stop_points.size() > 1:
		street_forward = (stop_points[1] - stop_points[0]).normalized()
	elif points.size() > 1:
		street_forward = (points[1] - points[0]).normalized()
	rig.call("set_focus_points", map_focus, street_focus, street_forward)
	if rig.has_method("set_subway_focus_points"):
		var subway_station_idx := _subway_station_indices()
		if subway_station_idx.size() > 1:
			var subway_stop_points := _mainline_stop_points()
			var first_idx: int = subway_station_idx[0]
			var second_idx: int = subway_station_idx[1]
			var subway_focus := _subway_track_point(subway_stop_points[first_idx].lerp(subway_stop_points[second_idx], 0.55))
			var subway_forward := (subway_stop_points[second_idx] - subway_stop_points[first_idx]).normalized()
			rig.call("set_subway_focus_points", subway_focus, subway_forward)
			if rig.has_method("set_subway_view_points"):
				rig.call("set_subway_view_points", _subway_camera_views(subway_stop_points))

func get_mainline_points() -> PackedVector3Array:
	return _mainline_stop_points()

func get_system_route_points() -> PackedVector3Array:
	return _system_route_points

func get_driver_station_status() -> Dictionary:
	return _driver_station_payload()

func get_driver_passenger_status() -> Dictionary:
	return {
		"onboard": _driver_onboard_passengers,
		"capacity": driver_passenger_capacity,
		"last_boarded": _driver_last_boarded,
		"last_alighted": _driver_last_alighted,
		"last_service_station": _driver_last_service_station,
		"last_service_age_s": _driver_last_service_age_s,
		"last_revenue": _driver_last_revenue
	}

func get_driver_service_status() -> Dictionary:
	var drive_status := {}
	if _driver_trolley != null and is_instance_valid(_driver_trolley) and _driver_trolley.has_method("get_manual_drive_status"):
		drive_status = _driver_trolley.call("get_manual_drive_status")
	return {
		"line_id": _driver_line_id,
		"line_name": String(_service_line_entry(_driver_line_id).get("name", line_name)),
		"rating": _driver_service_rating,
		"served_stops": _driver_served_stop_count,
		"skipped_stops": _driver_skipped_stop_count,
		"streak": _driver_service_streak,
		"last_delta": _driver_last_service_delta,
		"last_event": _driver_last_service_event,
		"last_event_age_s": _driver_last_service_event_age_s,
		"headway_target_m": _driver_last_headway_target_m,
		"headway_ahead_m": _driver_last_headway_ahead_m,
		"headway_behind_m": _driver_last_headway_behind_m,
		"fare_multiplier": _fare_multiplier_from_service_rating(),
		"manual_control_enabled": _driver_manual_control_enabled,
		"drive": drive_status
	}

func get_driver_announcement_status() -> Dictionary:
	return {
		"text": _announcement_text,
		"age_s": _announcement_age_s
	}

func get_driver_incident_status() -> Dictionary:
	if _driver_trolley == null or not is_instance_valid(_driver_trolley):
		return {"active": false}
	if _driver_trolley.has_method("get_failure_payload"):
		return _driver_trolley.call("get_failure_payload")
	return {"active": false}

func get_driver_hud_status() -> Dictionary:
	var speed_mps := 0.0
	var target_speed_mps := 0.0
	if _driver_trolley != null and is_instance_valid(_driver_trolley):
		speed_mps = absf(_driver_trolley.speed_mps)
		target_speed_mps = absf(_driver_trolley.target_speed_mps)
	var station_payload := get_driver_station_status()
	var signal_payload := get_driver_signal_status()
	var service_payload := get_driver_service_status()
	var current_name := String(station_payload.get("current", ""))
	var next_name := String(station_payload.get("next", ""))
	var route_text := "Route settling"
	if current_name != "" and next_name != "":
		route_text = "%s to %s" % [current_name, next_name]
	elif next_name != "":
		route_text = "Approaching %s" % next_name
	elif current_name != "":
		route_text = "Standing at %s" % current_name
	var speed_limit_mps := _line_speed_limit_mps(_driver_line_id)
	if not is_finite(speed_limit_mps):
		speed_limit_mps = maxf(trolley_max_speed_mps, 22.0)
	var weather_text := String(_weather_payload.get("hud_text", "Weather: Clear"))
	var drive_payload: Dictionary = service_payload.get("drive", {})
	var curve_payload := _driver_curve_warning_payload()
	var weather_lamp_payload := _driver_weather_lamp_payload()
	var braking := bool(drive_payload.get("braking", false))
	var stop_distance_m := float(station_payload.get("distance_m", -1.0))
	var brake_ratio := 0.88 if braking else 0.18
	var control_text := "%s | %s" % [
		"Manual controller" if _driver_manual_control_enabled else "Automatic block control",
		"Brake applied" if braking else _driver_dashboard_notch_text(drive_payload)
	]
	return {
		"active": _driver_active,
		"speed_mph": speed_mps * 2.23694,
		"target_speed_mph": target_speed_mps * 2.23694,
		"speed_limit_mph": speed_limit_mps * 2.23694,
		"signal_aspect": String(signal_payload.get("aspect", "GREEN")),
		"signal_text": "Signal %s" % String(signal_payload.get("message", "Proceed")),
		"line_name": String(service_payload.get("line_name", line_name)),
		"route_text": route_text,
		"control_text": control_text,
		"weather_text": weather_text,
		"stop_distance_m": stop_distance_m,
		"onboard": int(station_payload.get("onboard", _driver_onboard_passengers)),
		"capacity": int(station_payload.get("capacity", driver_passenger_capacity)),
		"manual_enabled": _driver_manual_control_enabled,
		"power_notch": int(drive_payload.get("power_notch", 0)),
		"controller_ratio": _driver_dashboard_controller_ratio(drive_payload),
		"brake_ratio": brake_ratio,
		"service_rating": _driver_service_rating,
		"curve_lamp": String(curve_payload.get("lamp", "OFF")),
		"curve_text": String(curve_payload.get("text", "Track steady")),
		"curve_level": float(curve_payload.get("level", 0.0)),
		"weather_lamp": String(weather_lamp_payload.get("lamp", "OFF")),
		"weather_signal_text": String(weather_lamp_payload.get("text", weather_text))
	}

func _driver_dashboard_notch_text(drive_payload: Dictionary) -> String:
	var power_notch := int(drive_payload.get("power_notch", 0))
	if power_notch > 0:
		return "Power notch %d" % power_notch
	if power_notch < 0:
		return "Reverse notch %d" % abs(power_notch)
	return "Controller in coast"

func _driver_dashboard_controller_ratio(drive_payload: Dictionary) -> float:
	var power_notch := int(drive_payload.get("power_notch", 0))
	if power_notch > 0:
		var forward_notches := maxi(1, int(drive_payload.get("forward_notches", 1)))
		return clampf(float(power_notch) / float(forward_notches), 0.0, 1.0)
	if power_notch < 0:
		var reverse_notches := maxi(1, int(drive_payload.get("reverse_notches", 1)))
		return -clampf(float(abs(power_notch)) / float(reverse_notches), 0.0, 1.0)
	return 0.0

func _driver_curve_warning_payload() -> Dictionary:
	if _driver_trolley == null or not is_instance_valid(_driver_trolley) or not _driver_trolley.has_method("get_curve_dynamics"):
		return {"lamp": "OFF", "text": "Track steady", "level": 0.0}
	var payload: Dictionary = _driver_trolley.call("get_curve_dynamics")
	var radius_m := float(payload.get("radius_m", INF))
	var safe_speed_mps := float(payload.get("safe_speed_mps", trolley_max_speed_mps))
	var turn_angle_deg := float(payload.get("turn_angle_deg", 0.0))
	var actual_speed_mps := absf(_driver_trolley.speed_mps)
	if not is_finite(radius_m) or radius_m > derail_curve_radius_threshold_m * 1.8 or turn_angle_deg < 4.5:
		return {"lamp": "OFF", "text": "Track steady", "level": 0.0}
	var overspeed_mps := actual_speed_mps - safe_speed_mps
	var caution_speed_mps := maxf(0.0, safe_speed_mps - 0.9)
	var level := clampf((actual_speed_mps - caution_speed_mps) / maxf(1.0, derail_speed_margin_mps + 1.6), 0.0, 1.0)
	if overspeed_mps > maxf(derail_speed_margin_mps * 0.8, derail_min_excess_mps):
		return {"lamp": "RED", "text": "Severe curve overspeed", "level": level}
	if actual_speed_mps > caution_speed_mps:
		return {"lamp": "YELLOW", "text": "Ease off for curve", "level": maxf(0.2, level)}
	return {"lamp": "GREEN", "text": "Curve ahead", "level": level * 0.45}

func _driver_weather_lamp_payload() -> Dictionary:
	var storminess := float(_weather_payload.get("storminess", 0.0))
	var wetness := float(_weather_payload.get("surface_wetness", 0.0))
	var snow_cover := float(_weather_payload.get("snow_cover", 0.0))
	var alert_names_variant: Variant = _weather_payload.get("alert_names", [])
	var alert_names: Array = alert_names_variant if alert_names_variant is Array else []
	if not alert_names.is_empty() or storminess >= 0.82:
		return {"lamp": "RED", "text": "Storm order active"}
	if snow_cover >= 0.18:
		return {"lamp": "YELLOW", "text": "Snow on the rail"}
	if wetness >= 0.45 or storminess >= 0.48:
		return {"lamp": "YELLOW", "text": "Wet rail"}
	return {"lamp": "OFF", "text": "Weather steady"}

func get_weather_status() -> Dictionary:
	if _weather_controller != null and is_instance_valid(_weather_controller) and _weather_controller.has_method("get_weather_payload"):
		_weather_payload = _weather_controller.call("get_weather_payload")
	return _weather_payload.duplicate(true)

func get_driver_world_position() -> Vector3:
	if _driver_trolley == null or not is_instance_valid(_driver_trolley):
		return Vector3.ZERO
	return _driver_trolley.global_position

func _driver_station_payload() -> Dictionary:
	if _driver_trolley == null or not is_instance_valid(_driver_trolley) or _driver_route_stops.is_empty():
		return {}
	var progress := _driver_trolley.progress
	var motion_dir := _driver_motion_direction()
	var nearest_idx := -1
	var nearest_dist := INF
	var next_idx := -1
	var next_gap := INF
	for i in range(_driver_route_stops.size()):
		var stop_offset := float(_driver_route_stops[i].get("offset", 0.0))
		var distance := absf(stop_offset - progress)
		if distance < nearest_dist:
			nearest_dist = distance
			nearest_idx = i
		var gap := (stop_offset - progress) * motion_dir
		if gap >= 0.0 and gap < next_gap:
			next_gap = gap
			next_idx = i
	var current_name := ""
	if nearest_idx != -1 and nearest_dist <= station_arrival_radius_m:
		current_name = String(_driver_route_stops[nearest_idx].get("name", ""))
		if next_idx == nearest_idx:
			next_idx = _adjacent_route_stop_index(nearest_idx, motion_dir)
			if next_idx != -1:
				next_gap = absf(float(_driver_route_stops[next_idx].get("offset", progress)) - progress)
	if current_name == "" and next_idx == -1 and nearest_idx != -1:
		next_idx = nearest_idx
		next_gap = absf(float(_driver_route_stops[nearest_idx].get("offset", progress)) - progress)
	var next_name := ""
	if next_idx != -1:
		next_name = String(_driver_route_stops[next_idx].get("name", ""))
	var current_waiting := 0
	var next_waiting := 0
	if _passenger_manager == null or not is_instance_valid(_passenger_manager):
		_resolve_gameplay_dependencies()
	if _passenger_manager != null and _passenger_manager.has_method("get_waiting_count_for_stop"):
		if current_name != "":
			current_waiting = int(_passenger_manager.call("get_waiting_count_for_stop", current_name))
		if next_name != "":
			next_waiting = int(_passenger_manager.call("get_waiting_count_for_stop", next_name))
	return {
		"current": current_name,
		"next": next_name,
		"distance_m": next_gap if next_idx != -1 else -1.0,
		"current_waiting": current_waiting,
		"next_waiting": next_waiting,
		"onboard": _driver_onboard_passengers,
		"capacity": driver_passenger_capacity,
		"can_board": current_name != "" and absf(_driver_trolley.speed_mps) <= driver_service_stop_speed_threshold_mps,
		"needs_slowdown": current_name != "" and absf(_driver_trolley.speed_mps) > driver_service_stop_speed_threshold_mps,
		"last_boarded": _driver_last_boarded,
		"last_alighted": _driver_last_alighted,
		"last_waiting_after": _driver_last_waiting_after,
		"last_service_station": _driver_last_service_station,
		"last_service_age_s": _driver_last_service_age_s,
		"last_revenue": _driver_last_revenue,
		"service_rating": _driver_service_rating,
		"fare_multiplier": _fare_multiplier_from_service_rating(),
		"dwell_seconds": _driver_station_dwell_s,
		"target_dwell_seconds": _driver_station_target_dwell_s,
		"hold_for_headway": _driver_station_target_dwell_s > driver_station_dwell_seconds + 0.25
	}

func get_driver_signal_status() -> Dictionary:
	if _driver_trolley == null or not is_instance_valid(_driver_trolley):
		return _signal_payload("GREEN", "Proceed", Color("6f8b52"))
	if _is_line_weather_closed(_driver_line_id):
		return _signal_payload("RED", _line_weather_closure_reason(_driver_line_id), Color("b34a3f"))
	if _line_speed_limit_mps(_driver_line_id) < INF:
		return _signal_payload("YELLOW", "Snow order %.0f mph until plow clears line" % (_line_speed_limit_mps(_driver_line_id) * 2.23694), Color("caa76a"))
	return _signal_status_for_progress(_driver_trolley.progress, _driver_motion_direction())

func get_system_map_snapshot() -> Dictionary:
	var route_points := _system_route_points
	if route_points.is_empty():
		route_points = _route_points(_mainline_stop_points())
	var all_points := PackedVector3Array()
	var route_payload: Array[Dictionary] = []
	for line_id in _service_line_ids_sorted():
		var entry := _service_line_entry(line_id)
		var line_points: PackedVector3Array = entry.get("route_points", PackedVector3Array())
		if line_points.is_empty():
			continue
		for point in line_points:
			all_points.append(point)
		route_payload.append({
			"line_id": line_id,
			"name": String(entry.get("name", line_id)),
			"color": entry.get("line_color", Color("6f8b52")),
			"points": line_points
		})
	if all_points.is_empty():
		all_points = route_points
	var bounds := _map_bounds(all_points)
	var trolley_payload: Array[Dictionary] = []
	var global_car_index := 1
	for line_id in _service_line_ids_sorted():
		var entry := _service_line_entry(line_id)
		for i in range(_line_fleet(line_id).size()):
			var trolley := _line_fleet(line_id)[i] as TrolleyMover
			if trolley == null or not is_instance_valid(trolley):
				continue
			trolley_payload.append({
				"position": trolley.global_position,
				"car_index": global_car_index,
				"line_id": line_id,
				"line_name": String(entry.get("name", line_id)),
				"controlled": trolley == _driver_trolley
			})
			global_car_index += 1
	var stop_payload: Array[Dictionary] = []
	for line_id in _service_line_ids_sorted():
		var entry := _service_line_entry(line_id)
		for stop_entry in entry.get("route_stops", []):
			stop_payload.append({
				"name": String(stop_entry.get("name", "")),
				"position": stop_entry.get("position", Vector3.ZERO),
				"line_id": line_id,
				"line_name": String(entry.get("name", line_id))
			})
	return {
		"routes": route_payload,
		"route_points": route_points,
		"bounds_min": bounds.get("min", Vector3.ZERO),
		"bounds_max": bounds.get("max", Vector3.ONE),
		"trolleys": trolley_payload,
		"stops": stop_payload
	}

func _nearest_trolley_ahead() -> Dictionary:
	if _driver_trolley == null or not is_instance_valid(_driver_trolley):
		return {}
	return _nearest_trolley_from_progress(_driver_trolley.progress, _driver_motion_direction(), _driver_trolley, _driver_line_id)

func _nearest_trolley_from_progress(progress: float, motion_dir: float, exclude: TrolleyMover = null, line_id: String = "") -> Dictionary:
	if line_id == "":
		line_id = _driver_line_id
	var best_gap := INF
	var best_index := -1
	var fleet: Array = _line_fleet(line_id)
	for i in range(fleet.size()):
		var trolley := fleet[i] as TrolleyMover
		if trolley == null or not is_instance_valid(trolley) or trolley == exclude:
			continue
		var gap := (trolley.progress - progress) * motion_dir
		if gap <= 0.25:
			continue
		if gap < best_gap:
			best_gap = gap
			best_index = i
	if best_index == -1:
		return {}
	return {
		"gap_m": best_gap,
		"car_index": best_index
	}

func _signal_status_for_progress(progress: float, motion_dir: float, line_id: String = "") -> Dictionary:
	var ahead := _nearest_trolley_from_progress(progress, motion_dir, null, line_id)
	if ahead.is_empty():
		return _signal_payload("GREEN", "Proceed", Color("6f8b52"))
	var gap_m := float(ahead.get("gap_m", 0.0))
	var car_index := int(ahead.get("car_index", -1))
	var red_limit := maxf(signal_stop_distance_m, signal_block_spacing_m * 1.05)
	var yellow_limit := maxf(signal_caution_distance_m, signal_block_spacing_m * 2.05)
	if gap_m <= red_limit:
		return _signal_payload("RED", "Car %d ahead %.0fm" % [car_index + 1, gap_m], Color("b34a3f"))
	if gap_m <= yellow_limit:
		return _signal_payload("YELLOW", "Car %d ahead %.0fm" % [car_index + 1, gap_m], Color("caa76a"))
	return _signal_payload("GREEN", "Proceed - car %d ahead %.0fm" % [car_index + 1, gap_m], Color("6f8b52"))

func _signal_payload(aspect: String, message: String, color: Color) -> Dictionary:
	return {
		"aspect": aspect,
		"message": message,
		"color": color
	}

func _update_signal_posts() -> void:
	for line_id in _service_line_ids_sorted():
		var entry := _service_line_entry(line_id)
		var signal_posts: Array = entry.get("signal_posts", [])
		for post_variant in signal_posts:
			var post: Dictionary = post_variant
			if _is_line_weather_closed(line_id):
				_apply_signal_post_visuals(post, "RED")
				continue
			var payload := _signal_status_for_progress(float(post.get("offset", 0.0)), float(post.get("direction", 1.0)), line_id)
			_apply_signal_post_visuals(post, String(payload.get("aspect", "GREEN")))

func _apply_signal_post_visuals(entry: Dictionary, active_aspect: String) -> void:
	var colors := {
		"RED": Color("d24d43"),
		"YELLOW": Color("e0bd5e"),
		"GREEN": Color("6fbd63")
	}
	var materials: Dictionary = entry.get("materials", {})
	var lights: Dictionary = entry.get("lights", {})
	for aspect in ["RED", "YELLOW", "GREEN"]:
		var material := materials.get(aspect) as StandardMaterial3D
		var light := lights.get(aspect) as OmniLight3D
		if material == null:
			continue
		var active: bool = String(aspect) == active_aspect
		var lamp_color: Color = colors[String(aspect)]
		material.albedo_color = lamp_color if active else lamp_color.darkened(0.72)
		material.emission = lamp_color
		material.emission_energy_multiplier = 2.6 if active else 0.04
		if light != null:
			light.light_energy = 1.5 if active else 0.0

func _update_weather_gameplay(delta: float) -> void:
	if _weather_controller == null or not is_instance_valid(_weather_controller):
		_resolve_gameplay_dependencies()
	if _weather_controller != null and _weather_controller.has_method("get_weather_payload"):
		_weather_payload = _weather_controller.call("get_weather_payload")
	var snow_present := bool(_weather_payload.get("snow_active", false)) or float(_weather_payload.get("snow_cover", 0.0)) > 0.02
	if snow_present:
		_prepare_snow_operations()
		_update_line_snow_depth(delta)
		_update_snow_plows(delta)
	else:
		_clear_snow_plows()
		_line_snow_cleared.clear()
		_line_snow_depth.clear()
	_sync_track_weather_state()
	if _driver_trolley != null and is_instance_valid(_driver_trolley):
		if _is_line_weather_closed(_driver_line_id):
			_driver_trolley.target_speed_mps = move_toward(_driver_trolley.target_speed_mps, 0.0, 18.0 * delta)
			_driver_trolley.speed_mps = move_toward(_driver_trolley.speed_mps, 0.0, 18.0 * delta)
		else:
			var speed_limit := _line_speed_limit_mps(_driver_line_id)
			if speed_limit < INF:
				_enforce_trolley_speed_limit(_driver_trolley, speed_limit, delta)

func _prepare_snow_operations() -> void:
	var seed_depth := clampf(float(_weather_payload.get("snow_cover", 0.0)) * 0.82 + float(_weather_payload.get("intensity", 0.0)) * 0.22, 0.0, 1.0)
	for line_id in _snow_exposed_line_ids():
		if not _line_snow_cleared.has(line_id):
			_line_snow_cleared[line_id] = false
		if not _line_snow_depth.has(line_id):
			_line_snow_depth[line_id] = seed_depth

func _update_line_snow_depth(delta: float) -> void:
	var snowing := bool(_weather_payload.get("snow_active", false))
	var target_depth := clampf(float(_weather_payload.get("snow_cover", 0.0)) * 0.84 + float(_weather_payload.get("intensity", 0.0)) * 0.26, 0.0, 1.0)
	for line_id in _snow_exposed_line_ids():
		var depth := float(_line_snow_depth.get(line_id, 0.0))
		if snowing:
			depth = move_toward(depth, maxf(0.22, target_depth), delta * (0.05 + float(_weather_payload.get("intensity", 0.0)) * 0.11))
			_line_snow_cleared[line_id] = false
		elif bool(_line_snow_cleared.get(line_id, false)):
			depth = move_toward(depth, 0.0, delta * 0.22)
		else:
			depth = move_toward(depth, target_depth * 0.35, delta * 0.08)
		_line_snow_depth[line_id] = clampf(depth, 0.0, 1.0)

func _snow_exposed_line_ids() -> Array[String]:
	return [MainLineServiceId, AtlanticServiceId, BlueServiceId, MattapanServiceId]

func _is_line_weather_closed(line_id: String) -> bool:
	if line_id == "" or _weather_controller == null or not is_instance_valid(_weather_controller):
		return false
	if _weather_controller.has_method("is_line_portal_closed"):
		return bool(_weather_controller.call("is_line_portal_closed", line_id))
	return false

func _line_weather_closure_reason(line_id: String) -> String:
	if line_id == "":
		return "Weather closure"
	if _weather_controller != null and is_instance_valid(_weather_controller) and _weather_controller.has_method("get_line_closure_reason"):
		var reason := String(_weather_controller.call("get_line_closure_reason", line_id))
		if reason != "":
			return reason
	return "%s closed by weather" % String(_service_line_entry(line_id).get("name", line_id))

func _line_speed_limit_mps(line_id: String) -> float:
	if float(_line_snow_depth.get(line_id, 0.0)) <= 0.08:
		return INF
	if not _snow_exposed_line_ids().has(line_id):
		return INF
	if bool(_line_snow_cleared.get(line_id, false)):
		return INF
	var snow_depth := float(_line_snow_depth.get(line_id, 0.0))
	return lerpf(maxf(snow_speed_limit_mps, trolley_speed_mps * 0.7), snow_speed_limit_mps, clampf(snow_depth, 0.0, 1.0))

func _enforce_trolley_speed_limit(trolley: TrolleyMover, speed_limit_mps: float, delta: float) -> void:
	if trolley == null or not is_instance_valid(trolley) or speed_limit_mps >= INF:
		return
	var limited_target := clampf(trolley.target_speed_mps, -speed_limit_mps, speed_limit_mps)
	trolley.target_speed_mps = limited_target
	if absf(trolley.speed_mps) > speed_limit_mps:
		var limited_speed := clampf(trolley.speed_mps, -speed_limit_mps, speed_limit_mps)
		trolley.speed_mps = move_toward(trolley.speed_mps, limited_speed, 10.0 * delta)

func _update_snow_plows(delta: float) -> void:
	for line_id in _snow_exposed_line_ids():
		if _is_line_weather_closed(line_id) or bool(_line_snow_cleared.get(line_id, false)):
			continue
		var plow := _ensure_snow_plow(line_id)
		if plow == null or not is_instance_valid(plow):
			continue
		plow.target_speed_mps = snow_plow_speed_mps
		plow.speed_mps = move_toward(plow.speed_mps, snow_plow_speed_mps, 5.0 * delta)
		var entry := _service_line_entry(line_id)
		var path := entry.get("path", null) as Path3D
		if path == null or path.curve == null:
			continue
		var path_length := float(path.curve.get_baked_length())
		var current_depth := float(_line_snow_depth.get(line_id, 0.0))
		current_depth = maxf(0.0, current_depth - delta * 0.18)
		_line_snow_depth[line_id] = current_depth
		if path_length > 0.0 and plow.progress >= path_length - 12.0:
			_line_snow_cleared[line_id] = true
			_line_snow_depth[line_id] = minf(current_depth, 0.05)
			plow.target_speed_mps = 0.0
			plow.speed_mps = 0.0

func _sync_track_weather_state() -> void:
	var track_builder := _get_track_builder()
	if track_builder == null or not track_builder.has_method("set_weather_surface_state"):
		return
	var visible_snow := 0.0
	for line_id in _snow_exposed_line_ids():
		if bool(_line_snow_cleared.get(line_id, false)):
			continue
		visible_snow = maxf(visible_snow, float(_line_snow_depth.get(line_id, 0.0)))
	track_builder.call("set_weather_surface_state", visible_snow, float(_weather_payload.get("surface_wetness", 0.0)))

func _ensure_snow_plow(line_id: String) -> TrolleyMover:
	var existing := _snow_plows.get(line_id, null) as TrolleyMover
	if existing != null and is_instance_valid(existing):
		return existing
	var entry := _service_line_entry(line_id)
	var path := entry.get("path", null) as Path3D
	if path == null or path.curve == null:
		return null
	var plow := TrolleyMover.new()
	plow.speed_mps = 0.0
	plow.max_speed_mps = maxf(snow_plow_speed_mps, 10.0)
	plow.loop_path = false
	plow.ping_pong = true
	plow.progress = 0.0
	plow.set_meta("service_line_id", line_id)
	plow.set_meta("scene_path_override", SnowPlowCarScenePath)
	plow.set_meta("weather_plow", true)
	path.add_child(plow)
	_attach_trolley_body(plow, 0)
	_snow_plows[line_id] = plow
	return plow

func _clear_snow_plows() -> void:
	for line_id_variant in _snow_plows.keys():
		var line_id := String(line_id_variant)
		var plow := _snow_plows.get(line_id, null) as TrolleyMover
		if plow != null and is_instance_valid(plow):
			plow.queue_free()
	_snow_plows.clear()

func _update_automated_service_lines(delta: float) -> void:
	for line_id in _service_line_ids_sorted():
		var route_stops: Array = _service_line_entry(line_id).get("route_stops", [])
		if route_stops.is_empty():
			continue
		for trolley_variant in _line_fleet(line_id):
			var trolley := trolley_variant as TrolleyMover
			if trolley == null or not is_instance_valid(trolley):
				continue
			if trolley == _driver_trolley and _driver_manual_control_enabled:
				continue
			if _is_line_weather_closed(line_id):
				trolley.target_speed_mps = 0.0
				trolley.speed_mps = move_toward(trolley.speed_mps, 0.0, 12.0 * delta)
				continue
			_update_automated_trolley(trolley, route_stops, delta)

func _update_automated_trolley(trolley: TrolleyMover, route_stops: Array, delta: float) -> void:
	if trolley.has_method("has_incident") and bool(trolley.call("has_incident")):
		return
	var dwell_remaining := float(trolley.get_meta("auto_dwell_s", 0.0))
	if dwell_remaining > 0.0:
		dwell_remaining = maxf(0.0, dwell_remaining - delta)
		trolley.set_meta("auto_dwell_s", dwell_remaining)
		trolley.speed_mps = 0.0
		trolley.target_speed_mps = 0.0
		return
	var cruise_speed := float(trolley.get_meta("service_cruise_speed_mps", trolley_speed_mps))
	if not trolley.has_meta("service_cruise_speed_mps"):
		cruise_speed = maxf(7.0, trolley_speed_mps * 0.9)
		trolley.set_meta("service_cruise_speed_mps", cruise_speed)
	var next_stop := _next_route_stop_for_trolley(trolley, route_stops)
	if next_stop.is_empty():
		trolley.speed_mps = move_toward(trolley.speed_mps, cruise_speed * _trolley_motion_direction(trolley), 6.0 * delta)
		trolley.target_speed_mps = trolley.speed_mps
		return
	var gap_m := float(next_stop.get("gap_m", INF))
	var motion_sign := _trolley_motion_direction(trolley)
	if gap_m <= automated_station_stop_radius_m and absf(trolley.speed_mps) <= automated_station_slow_speed_mps + 0.75:
		trolley.set_meta("auto_dwell_s", automated_station_dwell_seconds)
		trolley.speed_mps = 0.0
		trolley.target_speed_mps = 0.0
		return
	if gap_m <= automated_station_approach_radius_m:
		var target := automated_station_slow_speed_mps * motion_sign
		trolley.speed_mps = move_toward(trolley.speed_mps, target, 7.0 * delta)
		trolley.target_speed_mps = target
		var stop_limit := _line_speed_limit_mps(_line_id_for_trolley(trolley))
		if stop_limit < INF:
			_enforce_trolley_speed_limit(trolley, stop_limit, delta)
		return
	var cruise_target := cruise_speed * motion_sign
	trolley.speed_mps = move_toward(trolley.speed_mps, cruise_target, 5.0 * delta)
	trolley.target_speed_mps = cruise_target
	var speed_limit := _line_speed_limit_mps(_line_id_for_trolley(trolley))
	if speed_limit < INF:
		_enforce_trolley_speed_limit(trolley, speed_limit, delta)

func _next_route_stop_for_trolley(trolley: TrolleyMover, route_stops: Array) -> Dictionary:
	if trolley == null or not is_instance_valid(trolley) or route_stops.is_empty():
		return {}
	var motion_sign := _trolley_motion_direction(trolley)
	var best_gap := INF
	var best_entry := {}
	for entry_variant in route_stops:
		var entry: Dictionary = entry_variant
		var gap := (float(entry.get("offset", 0.0)) - trolley.progress) * motion_sign
		if gap < -2.0:
			continue
		if gap < best_gap:
			best_gap = gap
			best_entry = entry
	if best_entry.is_empty():
		return {}
	best_entry["gap_m"] = best_gap
	return best_entry

func _trolley_motion_direction(trolley: TrolleyMover) -> float:
	if trolley == null or not is_instance_valid(trolley):
		return 1.0
	if absf(trolley.speed_mps) > 0.05:
		return 1.0 if trolley.speed_mps >= 0.0 else -1.0
	if absf(trolley.target_speed_mps) > 0.05:
		return 1.0 if trolley.target_speed_mps >= 0.0 else -1.0
	return 1.0 if trolley.travel_direction >= 0.0 else -1.0

func _driver_motion_direction() -> float:
	return _trolley_motion_direction(_driver_trolley)

func _update_driver_incident_gameplay() -> void:
	if _driver_trolley == null or not is_instance_valid(_driver_trolley):
		_driver_curve_overspeed_s = 0.0
		return
	if _driver_trolley.has_method("has_incident") and bool(_driver_trolley.call("has_incident")):
		_driver_curve_overspeed_s = 0.0
		return
	_check_driver_curve_derailment(get_process_delta_time())
	if _driver_trolley.has_method("has_incident") and bool(_driver_trolley.call("has_incident")):
		return
	_check_driver_collisions()

func _check_driver_curve_derailment(delta: float) -> void:
	if not _driver_trolley.has_method("get_curve_dynamics"):
		_driver_curve_overspeed_s = 0.0
		return
	var payload: Dictionary = _driver_trolley.call("get_curve_dynamics")
	var radius_m := float(payload.get("radius_m", INF))
	var safe_speed_mps := float(payload.get("safe_speed_mps", trolley_max_speed_mps))
	var turn_angle_deg := float(payload.get("turn_angle_deg", 0.0))
	var actual_speed_mps := absf(_driver_trolley.speed_mps)
	var braking := false
	if _driver_trolley.has_method("get_manual_drive_status"):
		var drive_payload: Dictionary = _driver_trolley.call("get_manual_drive_status")
		braking = bool(drive_payload.get("braking", false))
	if not is_finite(radius_m):
		_driver_curve_overspeed_s = 0.0
		return
	if radius_m > derail_curve_radius_threshold_m or turn_angle_deg < 8.5 or actual_speed_mps < derail_min_speed_mps:
		_driver_curve_overspeed_s = maxf(0.0, _driver_curve_overspeed_s - delta * 1.8)
		return
	var overspeed_mps := actual_speed_mps - safe_speed_mps
	var overspeed_ratio := actual_speed_mps / maxf(1.0, safe_speed_mps)
	var required_overspeed := maxf(derail_speed_margin_mps, derail_min_excess_mps, safe_speed_mps * 0.24)
	if braking:
		required_overspeed += 0.8
	if overspeed_mps <= required_overspeed or overspeed_ratio <= derail_speed_ratio_threshold:
		_driver_curve_overspeed_s = maxf(0.0, _driver_curve_overspeed_s - delta * 2.2)
		return
	_driver_curve_overspeed_s += delta * (0.55 if braking else 1.0)
	if _driver_curve_overspeed_s < derail_overspeed_hold_seconds:
		return
	_driver_curve_overspeed_s = 0.0
	var mph := actual_speed_mps * 2.23694
	var safe_mph := safe_speed_mps * 2.23694
	_trigger_incident(_driver_trolley, "DERAILMENT", "Overspeed on a tight curve (%.0f mph in a %.0f mph curve)." % [mph, safe_mph], 14.0, 3.0)

func _check_driver_collisions() -> void:
	var ahead := _nearest_trolley_ahead()
	if ahead.is_empty():
		return
	var gap_m := float(ahead.get("gap_m", INF))
	var car_index := int(ahead.get("car_index", -1))
	if car_index < 0 or car_index >= _fleet.size():
		return
	var other := _fleet[car_index]
	if other == null or not is_instance_valid(other):
		return
	var relative_speed_mps := absf(_driver_trolley.speed_mps - other.speed_mps)
	var red_signal := String(get_driver_signal_status().get("aspect", "GREEN")) == "RED"
	if gap_m > collision_distance_m:
		return
	if relative_speed_mps < 1.2 and not red_signal:
		return
	_trigger_incident(_driver_trolley, "CRASH", "Rear-end collision with car %d." % [car_index + 1], 7.0, 8.0, other)

func _trigger_incident(trolley: TrolleyMover, state: String, message: String, roll_deg: float, pitch_deg: float, other_trolley: TrolleyMover = null) -> void:
	if trolley == null or not is_instance_valid(trolley):
		return
	if trolley.has_method("trigger_incident"):
		trolley.call("trigger_incident", state, message, roll_deg, pitch_deg)
	if other_trolley != null and is_instance_valid(other_trolley) and other_trolley.has_method("trigger_incident"):
		var other_message := "Impact with car %d." % [_fleet.find(trolley) + 1]
		other_trolley.call("trigger_incident", state, other_message, roll_deg * 0.45, -pitch_deg * 0.45, -0.35, -0.08)
	_apply_driver_service_rating_delta(-incident_service_penalty, message)

func _recover_driver_incident() -> void:
	if _driver_trolley == null or not is_instance_valid(_driver_trolley):
		return
	if not _driver_trolley.has_method("has_incident") or not bool(_driver_trolley.call("has_incident")):
		return
	_driver_trolley.call("clear_incident")
	_apply_driver_service_rating_delta(-0.5, "Incident cleared")

func _resolve_gameplay_dependencies() -> void:
	var world_root := get_parent()
	if world_root == null:
		return
	_passenger_manager = world_root.get_node_or_null("PassengerManager")
	_economy = world_root.get_node_or_null("Economy")
	_stop_placer = world_root.get_node_or_null("StopPlacer")
	_weather_controller = world_root.get_node_or_null("Weather")

func _update_driver_station_gameplay(delta: float) -> void:
	if _driver_trolley == null or not is_instance_valid(_driver_trolley):
		return
	if _driver_trolley.has_method("has_incident") and bool(_driver_trolley.call("has_incident")):
		return
	var payload := _driver_station_payload()
	var current_name := String(payload.get("current", ""))
	if current_name != _driver_station_presence_name:
		if _driver_station_presence_name != "" and not _driver_station_serviced:
			_handle_driver_station_departure(_driver_station_presence_name)
		_driver_station_presence_name = current_name
		_driver_station_serviced = false
		_driver_station_dwell_s = 0.0
		_driver_station_target_dwell_s = 0.0
	if current_name == "":
		_driver_station_dwell_s = 0.0
		_driver_station_target_dwell_s = 0.0
		return
	if _driver_station_serviced:
		return
	if absf(_driver_trolley.speed_mps) > driver_service_stop_speed_threshold_mps:
		_driver_station_dwell_s = 0.0
		_driver_station_target_dwell_s = _recommended_station_dwell_seconds()
		return
	_driver_station_target_dwell_s = _recommended_station_dwell_seconds()
	_driver_station_dwell_s = minf(_driver_station_target_dwell_s, _driver_station_dwell_s + maxf(delta, 0.0))
	if _driver_station_dwell_s + 0.01 < _driver_station_target_dwell_s:
		return
	_service_driver_station(current_name)

func _service_driver_station(station_name: String) -> void:
	if _passenger_manager == null or not is_instance_valid(_passenger_manager):
		_resolve_gameplay_dependencies()
	var alighted := _estimate_driver_alighting(station_name)
	_driver_onboard_passengers = maxi(0, _driver_onboard_passengers - alighted)
	var headway_score := _score_driver_headway()
	var boarded := 0
	var waiting_after := 0
	if _passenger_manager != null and _passenger_manager.has_method("service_stop_by_name"):
		var free_capacity := maxi(0, driver_passenger_capacity - _driver_onboard_passengers)
		var result: Dictionary = _passenger_manager.call("service_stop_by_name", station_name, free_capacity)
		boarded = int(result.get("boarded", 0))
		waiting_after = int(result.get("waiting", 0))
	_driver_onboard_passengers = clampi(_driver_onboard_passengers + boarded, 0, driver_passenger_capacity)
	var revenue := float(boarded) * average_fare_per_passenger * _fare_multiplier_from_service_rating()
	if boarded > 0 and _economy != null and _economy.has_method("apply_revenue"):
		_economy.call("apply_revenue", revenue, _revenue_category_for_station(station_name))
	var boarding_bonus := minf(2.0, float(boarded) * 0.10)
	var waiting_penalty := minf(1.8, float(waiting_after) * 0.06)
	var rating_delta := float(headway_score.get("delta", 0.0)) + boarding_bonus - waiting_penalty
	_apply_driver_service_rating_delta(rating_delta, String(headway_score.get("message", "Platform served")))
	_driver_last_boarded = boarded
	_driver_last_alighted = alighted
	_driver_last_waiting_after = waiting_after
	_driver_last_service_station = station_name
	_driver_last_service_age_s = 0.0
	_driver_last_revenue = revenue
	_driver_station_serviced = true
	_driver_served_stop_count += 1
	_driver_service_streak += 1
	_driver_last_announced_arrival = station_name
	_announce_station("Now arriving: %s" % station_name, "Now arriving at %s." % station_name, true)

func _estimate_driver_alighting(station_name: String) -> int:
	if _driver_onboard_passengers <= 0:
		return 0
	var ratio := 0.16 + float(abs(station_name.hash()) % 18) / 100.0
	if station_name in ["Park Street", "North Station", "Lechmere", "Brookline", "Lincoln Square"]:
		ratio += 0.10
	return clampi(int(round(float(_driver_onboard_passengers) * ratio)), 0, _driver_onboard_passengers)

func _handle_driver_station_departure(station_name: String) -> void:
	if station_name == "":
		return
	var waiting := 0
	if _passenger_manager != null and _passenger_manager.has_method("get_waiting_count_for_stop"):
		waiting = int(_passenger_manager.call("get_waiting_count_for_stop", station_name))
	if waiting <= 0:
		return
	_driver_skipped_stop_count += 1
	_driver_service_streak = 0
	var penalty := driver_skip_penalty_base + minf(4.0, float(waiting) * 0.25)
	_apply_driver_service_rating_delta(-penalty, "Skipped %s" % station_name)

func _apply_driver_service_rating_delta(delta: float, event_message: String) -> void:
	_driver_service_rating = clampf(_driver_service_rating + delta, 0.0, 100.0)
	_driver_last_service_delta = delta
	_driver_last_service_event = event_message
	_driver_last_service_event_age_s = 0.0

func _revenue_category_for_station(station_name: String) -> String:
	if station_name in ["Park Street", "Boylston", "Arlington", "Copley", "North Station", "Lechmere", "Ashmont", "Mattapan"]:
		return "Urban passenger"
	if station_name in ["Norumbega Park", "White City"]:
		return "Excursion traffic"
	if station_name in ["Framingham Junction", "Framingham Center", "Natick Center", "Wellesley Center", "Lincoln Square"]:
		return "Interurban passenger"
	return "Passenger fares"

func _recommended_station_dwell_seconds() -> float:
	var target := _route_headway_target_m()
	var ahead := _nearest_trolley_from_progress(_driver_trolley.progress, _driver_motion_direction(), _driver_trolley)
	var ahead_gap := float(ahead.get("gap_m", target))
	var crowd_factor := clampf(float(_driver_station_payload().get("current_waiting", 0)) / 16.0, 0.0, 1.0)
	var crowd_seconds := crowd_factor * 1.1
	var hold_seconds := 0.0
	if target > 0.0 and ahead_gap < target * 0.72:
		var bunch_ratio := 1.0 - clampf(ahead_gap / maxf(target * 0.72, 1.0), 0.0, 1.0)
		hold_seconds = driver_headway_hold_max_seconds * bunch_ratio
	return driver_station_dwell_seconds + crowd_seconds + hold_seconds

func _score_driver_headway() -> Dictionary:
	var target := _route_headway_target_m()
	var motion_dir := _driver_motion_direction()
	var ahead := _nearest_trolley_from_progress(_driver_trolley.progress, motion_dir, _driver_trolley)
	var behind := _nearest_trolley_from_progress(_driver_trolley.progress, -motion_dir, _driver_trolley)
	var ahead_gap := float(ahead.get("gap_m", target))
	var behind_gap := float(behind.get("gap_m", target))
	_driver_last_headway_target_m = target
	_driver_last_headway_ahead_m = ahead_gap
	_driver_last_headway_behind_m = behind_gap
	var smallest_ratio := minf(ahead_gap, behind_gap) / maxf(1.0, target)
	var imbalance := absf(ahead_gap - behind_gap) / maxf(1.0, target)
	if smallest_ratio < 0.58:
		return {"delta": -driver_headway_penalty_bad, "message": "Bunching detected"}
	if imbalance < 0.30:
		return {"delta": driver_headway_bonus_good, "message": "Headway steady"}
	if imbalance < 0.65:
		return {"delta": 0.6, "message": "Headway acceptable"}
	return {"delta": -1.2, "message": "Spacing uneven"}

func _route_headway_target_m() -> float:
	if _driver_trolley != null and is_instance_valid(_driver_trolley):
		var segment := _segment_for_progress(_driver_trolley.progress)
		if not segment.is_empty():
			return _segment_target_spacing_m(segment)
	if _signal_path != null and _signal_path.curve != null and _fleet.size() > 0:
		return float(_signal_path.curve.get_baked_length()) / float(_fleet.size())
	return maxf(200.0, signal_block_spacing_m * 1.5)

func _fare_multiplier_from_service_rating() -> float:
	return lerpf(0.85, 1.15, clampf(_driver_service_rating / 100.0, 0.0, 1.0))

func _update_driver_station_announcements() -> void:
	var payload := _driver_station_payload()
	var current_name := String(payload.get("current", ""))
	var next_name := String(payload.get("next", ""))
	var distance_m := float(payload.get("distance_m", -1.0))
	if current_name != "":
		_driver_last_announced_next_stop = current_name
		return
	if next_name == "" or distance_m < 0.0 or distance_m > station_announcement_approach_distance_m:
		return
	if next_name == _driver_last_announced_next_stop:
		return
	_driver_last_announced_next_stop = next_name
	_announce_station("Next stop: %s" % next_name, "Next stop, %s." % next_name, true)

func _announce_station(display_text: String, spoken_text: String, play_chime: bool) -> void:
	_announcement_text = display_text
	_announcement_age_s = 0.0
	if play_chime and _station_chime_audio != null and _station_chime_audio.stream != null:
		_station_chime_audio.stop()
		_station_chime_audio.volume_db = -17.0
		_station_chime_audio.play()
	if station_system_tts_enabled and OS.get_name() == "macOS":
		OS.create_process("/usr/bin/say", ["-v", station_announcement_voice, spoken_text])

func _build_driver_route_stops(path: Path3D, stop_points: PackedVector3Array) -> void:
	_driver_route_stops.clear()
	if path == null or path.curve == null:
		return
	var curve := path.curve
	if build_north_terminal_extension:
		var north_surface := _north_subway_surface_points()
		var elevated_surface := _elevated_surface_points()
		if elevated_surface.size() >= 2:
			_append_driver_route_stop(elevated_station_names[0], elevated_surface[0] + Vector3(0.0, elevated_deck_height, 0.0), curve)
			_append_driver_route_stop(elevated_station_names[1], elevated_surface[1] + Vector3(0.0, elevated_deck_height, 0.0), curve)
		for i in range(min(north_subway_station_names.size(), north_surface.size())):
			_append_driver_route_stop(north_subway_station_names[i], _subway_track_point(north_surface[i]), curve)
	for i in range(min(mainline_towns.size(), stop_points.size())):
		var stop_pos := _subway_track_point(stop_points[i]) if i <= _last_subway_station_index() else stop_points[i]
		_append_driver_route_stop(mainline_towns[i], stop_pos, curve)
	_driver_route_stops.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("offset", 0.0)) < float(b.get("offset", 0.0))
	)

func _append_driver_route_stop(name: String, position: Vector3, curve: Curve3D) -> void:
	if name == "" or curve == null:
		return
	var offset := float(curve.get_closest_offset(position))
	for entry in _driver_route_stops:
		if String(entry.get("name", "")) == name and absf(float(entry.get("offset", 0.0)) - offset) <= 12.0:
			return
	_driver_route_stops.append({
		"name": name,
		"offset": offset,
		"position": position
	})

func _adjacent_route_stop_index(index: int, motion_dir: float) -> int:
	if _driver_route_stops.is_empty():
		return -1
	var delta := 1 if motion_dir >= 0.0 else -1
	var next_idx := index + delta
	if next_idx < 0 or next_idx >= _driver_route_stops.size():
		return -1
	return next_idx

func _project_geo_points(points: PackedVector2Array) -> PackedVector3Array:
	var projected := PackedVector3Array()
	var b = _geo_bounds()
	if b == null:
		return projected
	for ll in points:
		projected.append(GeoProjectorScript.lon_lat_to_world(ll.x, ll.y, b, world_size_m))
	return projected

func _build_blue_line_phase(track_builder: Node) -> void:
	if not build_blue_line_phase:
		return
	var parent := _get_path_parent(track_builder)
	if parent == null:
		return
	var existing := parent.get_node_or_null(blue_line_root_name)
	if existing:
		existing.queue_free()
	var points := _project_geo_points(blue_line_geo)
	if points.size() < 2:
		return
	var root := Node3D.new()
	root.name = blue_line_root_name
	parent.add_child(root)
	var surface_root := _make_subway_section(root, "StreetDeck")
	var tunnel_root := _make_subway_section(root, "TunnelSegments")
	var portal_root := _make_subway_section(root, "PortalSegments")
	var surface_track_root := _make_subway_section(root, "SurfaceSegments")
	var station_root := _make_subway_section(root, "Stations")
	var track_points := _build_blue_salem_station_points()
	for i in range(points.size() - 1):
		if i < blue_line_tunnel_station_count - 1:
			var depth := blue_line_harbor_depth if i == blue_line_tunnel_station_count - 2 else blue_line_depth
			_build_blue_phase_segment(tunnel_root, surface_root, blue_line_station_names[i], blue_line_station_names[i + 1], points[i], points[i + 1], depth)
		elif i == blue_line_tunnel_station_count - 1:
			_build_blue_surface_portal(portal_root, surface_root, points[i], points[i + 1])
		else:
			_add_surface_rapid_segment(surface_track_root, track_points[i], track_points[i + 1], "blue")
	for i in range(points.size()):
		if i < blue_line_tunnel_station_count:
			_build_blue_phase_station(station_root, surface_root, points, track_points, i)
		else:
			_add_surface_rapid_station(station_root, track_points[i], _station_forward(track_points, i), blue_line_station_names[i], "blue")

func _build_blue_phase_segment(parent: Node3D, surface_parent: Node3D, a_name: String, b_name: String, a: Vector3, b: Vector3, segment_depth: float = -11.5) -> void:
	var forward := (b - a).normalized()
	if forward.length() < 0.01:
		return
	var right := Vector3(-forward.z, 0.0, forward.x).normalized()
	var length := a.distance_to(b)
	var width := 20.0
	var center := (a + b) * 0.5 + Vector3(0.0, segment_depth, 0.0)
	var segment_root := _make_subway_section(parent, "%s_to_%s" % [_section_name(a_name), _section_name(b_name)])
	var start_junction := _station_has_junction_geometry(_station_spec(a_name))
	var end_junction := _station_has_junction_geometry(_station_spec(b_name))
	var shell_span := _trimmed_segment_span(
		center,
		forward,
		length,
		_segment_end_open_length(length, start_junction),
		_segment_end_open_length(length, end_junction)
	)
	_add_surface_alignment(surface_parent, a, b, width * 0.56, Color("5a4d43"), "blue")
	_add_tunnel_shell(segment_root, shell_span["center"], forward, right, width, shell_span["length"], 2, not (start_junction or end_junction), "blue")
	for offset in [-2.9, 2.9]:
		_add_box(segment_root, Vector3(2.0, subway_track_bed_height, length), center + right * offset + Vector3(0.0, -1.85, 0.0), forward, Color("4a4743"))
		_add_box(segment_root, Vector3(0.16, 0.12, length), center + right * (offset - 0.72) + Vector3(0.0, -1.48, 0.0), forward, Color("b7b0a1"))
		_add_box(segment_root, Vector3(0.16, 0.12, length), center + right * (offset + 0.72) + Vector3(0.0, -1.48, 0.0), forward, Color("b7b0a1"))
	_add_tunnel_track_details(segment_root, shell_span["center"], forward, right, [-2.9, 2.9], shell_span["length"])
	_add_tunnel_lights(segment_root, shell_span["center"], forward, shell_span["length"])

func _build_blue_phase_station(parent: Node3D, surface_parent: Node3D, points: PackedVector3Array, track_points: PackedVector3Array, idx: int) -> void:
	var station_name := blue_line_station_names[idx]
	var spec := _station_spec(station_name)
	var forward := _station_forward(points, idx)
	var right := Vector3(-forward.z, 0.0, forward.x).normalized()
	var width := _resolved_station_width(spec, float(spec.get("width", 24.0)), int(spec.get("tracks", 2)))
	var length := float(spec.get("length", 118.0))
	var platform_width := float(spec.get("platform_width", 6.0))
	var center := track_points[idx]
	var root := _make_subway_section(parent, _section_name(station_name))
	_add_surface_alignment(surface_parent, points[maxi(0, idx - 1)], points[mini(points.size() - 1, idx + 1)], width * 0.44, Color("52453a"), "blue")
	_add_station_shell(root, center, forward, right, width, length, spec, int(spec.get("tracks", 2)), "blue", station_name)
	for offset in _track_offsets_for_spec(spec, int(spec.get("tracks", 2))):
		_add_track_surface_box(root, Vector3(2.0, subway_track_bed_height, length), center + right * offset + Vector3(0.0, -1.85, 0.0), forward)
	_add_station_platforms(root, center, forward, right, width, length, platform_width, spec, String(spec.get("layout", "side")), "blue")
	_add_station_mezzanines(root, center, forward, right, width, float(spec.get("mezzanine_length", length * 0.5)), spec)
	_add_station_extra_boxes(root, center, forward, right, spec)
	_add_station_lights(root, center, forward, right, length, width)
	_add_station_name_boards(root, center, forward, right, width, length, station_name, "blue")
	_add_station_surface_boxes(surface_parent, center + Vector3(0.0, subway_depth - blue_line_depth, 0.0), forward, right, spec, "blue")
	_add_headhouse(surface_parent, center + Vector3(0.0, subway_depth - blue_line_depth, 0.0), forward, right, station_name, spec, "blue")

func _build_blue_surface_portal(parent: Node3D, surface_parent: Node3D, maverick_surface: Vector3, airport_surface: Vector3) -> void:
	var forward := (airport_surface - maverick_surface).normalized()
	if forward.length() < 0.01:
		return
	var portal_root := _make_subway_section(parent, "MaverickPortal")
	var p1 := _portal_blend(maverick_surface, airport_surface, 0.24, blue_line_depth * 0.72)
	var p2 := _portal_blend(maverick_surface, airport_surface, 0.52, blue_line_depth * 0.18)
	var p3 := _portal_blend(maverick_surface, airport_surface, 0.78, blue_line_surface_track_height)
	var portal_top := airport_surface + Vector3(0.0, blue_line_surface_track_height, 0.0)
	_add_surface_alignment(surface_parent, maverick_surface, airport_surface, 10.4, Color("5b4e43"), "blue")
	_add_portal_section(portal_root, Vector3(maverick_surface.x, blue_line_depth, maverick_surface.z), p1, 12.8, 5.6, true)
	_add_portal_section(portal_root, p1, p2, 13.2, 4.8, true)
	_add_portal_section(portal_root, p2, p3, 13.8, 4.0, false)
	_add_portal_section(portal_root, p3, portal_top, 14.4, 3.2, false)

func _add_surface_rapid_segment(parent: Node3D, a: Vector3, b: Vector3, style_id: String = "blue") -> void:
	var forward := (b - a).normalized()
	if forward.length() < 0.01:
		return
	var right := Vector3(-forward.z, 0.0, forward.x).normalized()
	var length := a.distance_to(b)
	var center := (a + b) * 0.5
	var theme := _corridor_theme(style_id)
	var shoulder_color: Color = theme.get("trim_color", Color("6b6157"))
	_add_box(parent, Vector3(15.0, 0.8, length), center + Vector3(0.0, -0.55, 0.0), forward, Color("6d665d"))
	_add_track_surface_box(parent, Vector3(8.4, 0.26, length), center + Vector3(0.0, -0.06, 0.0), forward)
	for offset in [-3.0, 3.0]:
		_add_rail_box(parent, Vector3(0.18, 0.18, length), center + right * offset + Vector3(0.0, 0.12, 0.0), forward)
	var sleeper_count := maxi(6, int(round(length / 2.4)))
	for i in range(sleeper_count):
		var t := 0.0 if sleeper_count <= 1 else float(i) / float(sleeper_count - 1)
		var sleeper_pos := a.lerp(b, t) + Vector3(0.0, 0.02, 0.0)
		_add_box_with_material(parent, Vector3(0.34, 0.16, 7.2), sleeper_pos, right, _ensure_period_material("timber"))
	for side in [-1.0, 1.0]:
		_add_box(parent, Vector3(0.18, 0.8, length), center + right * side * 6.4 + Vector3(0.0, 0.26, 0.0), forward, shoulder_color)

func _add_surface_rapid_station(parent: Node3D, point: Vector3, forward: Vector3, station_name: String, style_id: String = "blue") -> void:
	var right := Vector3(-forward.z, 0.0, forward.x).normalized()
	var center := point
	var theme := _corridor_theme(style_id)
	var line_color: Color = theme.get("line_color", Color("3a7dbf"))
	for side in [-1.0, 1.0]:
		var platform_center: Vector3 = center + right * side * 6.2 + Vector3(0.0, 0.38, 0.0)
		_add_box(parent, Vector3(3.8, 0.48, 54.0), platform_center, forward, Color("d8ddd8"))
		_add_box(parent, Vector3(0.28, 0.12, 54.0), platform_center - right * side * 1.6 + Vector3(0.0, 0.16, 0.0), forward, line_color.lightened(0.22))
		_add_platform_canopy(parent, platform_center + Vector3(0.0, 0.7, 0.0), forward, 3.4, 46.0, style_id)
	_add_box(parent, Vector3(10.8, 2.8, 7.4), center + right * 10.0 + Vector3(0.0, 1.4, 0.0), forward, Color("7e7466"))
	_add_box(parent, Vector3(11.8, 0.42, 8.4), center + right * 10.0 + Vector3(0.0, 2.96, 0.0), forward, Color("4b4d52"))
	var label := Label3D.new()
	label.text = _station_display_name(station_name)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 26
	label.modulate = Color(0.95, 0.97, 0.99, 1.0)
	label.position = center + Vector3(0.0, 3.5, 0.0)
	parent.add_child(label)

func _build_north_terminal_extension(track_builder: Node) -> void:
	if not build_north_terminal_extension:
		return
	var parent := _get_path_parent(track_builder)
	if parent == null:
		return
	var existing := parent.get_node_or_null(north_terminal_root_name)
	if existing:
		existing.queue_free()
	var subway_points := _north_subway_surface_points()
	var elevated_points := _elevated_surface_points()
	if subway_points.size() < 2 or elevated_points.size() < 2:
		return
	var root := Node3D.new()
	root.name = north_terminal_root_name
	parent.add_child(root)
	var surface_root := _make_subway_section(root, "StreetDeck")
	var tunnel_root := _make_subway_section(root, "TunnelSegments")
	var station_root := _make_subway_section(root, "Stations")
	var portal_root := _make_subway_section(root, "CausewayPortal")
	for i in range(subway_points.size() - 1):
		var a_name := north_subway_station_names[i]
		var b_name := north_subway_station_names[i + 1]
		var seg_tracks := maxi(int(_station_spec(a_name).get("tracks", 2)), int(_station_spec(b_name).get("tracks", 2)))
		var start_junction := _station_has_junction_geometry(_station_spec(a_name))
		var end_junction := _station_has_junction_geometry(_station_spec(b_name))
		_build_subway_segment(
			tunnel_root,
			surface_root,
			"%s_to_%s" % [_section_name(a_name), _section_name(b_name)],
			subway_points[i],
			subway_points[i + 1],
			seg_tracks,
			start_junction,
			end_junction,
			"tremont"
		)
	for i in range(subway_points.size()):
		var station_name := north_subway_station_names[i]
		if subway_station_names.has(station_name):
			continue
		_build_named_subway_station(station_root, surface_root, subway_points, i, station_name, "tremont")
	_build_causeway_portal(portal_root, surface_root, subway_points[subway_points.size() - 1], elevated_points[1])

func _build_elevated_layer(track_builder: Node) -> void:
	if not build_elevated_layer:
		return
	var parent := _get_path_parent(track_builder)
	if parent == null:
		return
	var existing := parent.get_node_or_null(elevated_root_name)
	if existing:
		existing.queue_free()
	var points := _project_geo_points(elevated_geo)
	if points.size() < 2:
		return
	var root := Node3D.new()
	root.name = elevated_root_name
	parent.add_child(root)
	var segment_root := _make_subway_section(root, "Segments")
	var station_root := _make_subway_section(root, "Stations")
	for i in range(points.size() - 1):
		_add_elevated_segment(segment_root, points[i], points[i + 1])
	if lechmere_turnback_tail_m > 0.0 and points.size() >= 2:
		_add_elevated_segment(segment_root, points[0], _lechmere_turnback_surface_point(points))
	for i in range(points.size()):
		var forward := _station_forward(points, i)
		_add_elevated_station(station_root, points[i], forward, elevated_station_names[min(i, elevated_station_names.size() - 1)])

func _add_elevated_segment(parent: Node3D, a: Vector3, b: Vector3) -> void:
	var forward := (b - a).normalized()
	if forward.length() < 0.01:
		return
	var right := Vector3(-forward.z, 0.0, forward.x).normalized()
	var length := a.distance_to(b)
	var center := (a + b) * 0.5 + Vector3(0.0, elevated_deck_height, 0.0)
	_add_box(parent, Vector3(14.0, 0.75, length), center, forward, Color("5b4a3c"))
	_add_box(parent, Vector3(11.6, 0.3, length), center + Vector3(0.0, 0.42, 0.0), forward, Color("7c6d5b"))
	for offset in [-3.0, 3.0]:
		_add_box(parent, Vector3(0.16, 0.12, length), center + right * (offset - 0.72) + Vector3(0.0, 0.56, 0.0), forward, Color("b7b0a1"))
		_add_box(parent, Vector3(0.16, 0.12, length), center + right * (offset + 0.72) + Vector3(0.0, 0.56, 0.0), forward, Color("b7b0a1"))
	for side in [-1.0, 1.0]:
		_add_box(parent, Vector3(0.45, 1.2, length), center + right * side * 6.4 + Vector3(0.0, 0.7, 0.0), forward, Color("40362e"))
	var bent_count := maxi(2, int(round(length / 26.0)))
	for i in range(bent_count):
		var t := float(i + 1) / float(bent_count + 1)
		var bent_center := a.lerp(b, t)
		for side in [-1.0, 1.0]:
			_add_box(parent, Vector3(0.7, elevated_deck_height, 0.7), bent_center + right * side * 4.8 + Vector3(0.0, elevated_deck_height * 0.5, 0.0), forward, Color("51443b"))
		_add_box(parent, Vector3(11.0, 0.5, 0.9), bent_center + Vector3(0.0, elevated_deck_height - 0.5, 0.0), right, Color("675649"))

func _add_elevated_station(parent: Node3D, point: Vector3, forward: Vector3, station_name: String) -> void:
	var right := Vector3(-forward.z, 0.0, forward.x).normalized()
	var center := point + Vector3(0.0, elevated_deck_height, 0.0)
	_add_box(parent, Vector3(22.0, 0.8, 34.0), center, forward, Color("6b594a"))
	for side in [-1.0, 1.0]:
		_add_box(parent, Vector3(4.8, 0.6, 30.0), center + right * side * 8.5 + Vector3(0.0, -0.55, 0.0), forward, Color("d1c3a5"))
		_add_box(parent, Vector3(0.4, 1.0, 30.0), center + right * side * 6.1 + Vector3(0.0, 0.2, 0.0), forward, Color("473b31"))
	_add_box(parent, Vector3(12.0, 5.5, 24.0), center + Vector3(0.0, 3.2, 0.0), forward, Color("7d654f"))
	_add_box(parent, Vector3(13.5, 0.7, 25.5), center + Vector3(0.0, 6.4, 0.0), forward, Color("394a39"))
	_add_box(parent, Vector3(2.6, elevated_deck_height, 5.4), point + right * 9.8 + forward * 8.0 + Vector3(0.0, elevated_deck_height * 0.5, 0.0), forward, Color("7f7366"))
	var label := Label3D.new()
	label.text = station_name
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 24
	label.modulate = Color(1.0, 0.97, 0.9, 1.0)
	label.position = center + Vector3(0.0, 7.8, 0.0)
	parent.add_child(label)

func _build_atlantic_avenue_elevated(track_builder: Node) -> void:
	if not build_atlantic_avenue_elevated:
		return
	var parent := _get_path_parent(track_builder)
	if parent == null:
		return
	var existing := parent.get_node_or_null(atlantic_elevated_root_name)
	if existing:
		existing.queue_free()
	var points := _project_geo_points(atlantic_elevated_geo)
	if points.size() < 2:
		return
	var root := Node3D.new()
	root.name = atlantic_elevated_root_name
	parent.add_child(root)
	var segment_root := _make_subway_section(root, "Segments")
	var station_root := _make_subway_section(root, "Stations")
	for i in range(points.size() - 1):
		_add_historical_elevated_segment(segment_root, points[i], points[i + 1], atlantic_elevated_deck_height, "atlantic_elevated")
	for i in range(min(points.size(), atlantic_elevated_station_names.size())):
		_add_historical_elevated_station(station_root, points[i], _station_forward(points, i), atlantic_elevated_station_names[i], atlantic_elevated_deck_height, "atlantic_elevated")

func _build_washington_street_tunnel(track_builder: Node) -> void:
	_build_historical_subway_line(track_builder, washington_street_root_name, washington_street_geo, washington_street_station_names, "washington")

func _build_cambridge_dorchester_tunnel(track_builder: Node) -> void:
	_build_historical_subway_line(track_builder, cambridge_dorchester_root_name, cambridge_dorchester_geo, cambridge_dorchester_station_names, "cambridge")

func _build_mattapan_extension(track_builder: Node) -> void:
	if not build_mattapan_extension:
		return
	var parent := _get_path_parent(track_builder)
	if parent == null:
		return
	var existing := parent.get_node_or_null(mattapan_root_name)
	if existing:
		existing.queue_free()
	var points := _project_geo_points(mattapan_geo)
	if points.size() < 2:
		return
	var root := Node3D.new()
	root.name = mattapan_root_name
	parent.add_child(root)
	var segment_root := _make_subway_section(root, "Segments")
	var station_root := _make_subway_section(root, "Stations")
	var elevated_points := PackedVector3Array()
	for point in points:
		elevated_points.append(point + Vector3(0.0, mattapan_track_height, 0.0))
	for i in range(elevated_points.size() - 1):
		_add_surface_rapid_segment(segment_root, elevated_points[i], elevated_points[i + 1], "mattapan")
	for i in range(min(elevated_points.size(), mattapan_station_names.size())):
		_add_surface_rapid_station(station_root, elevated_points[i], _station_forward(elevated_points, i), mattapan_station_names[i], "mattapan")

func _build_historical_subway_line(track_builder: Node, root_name: String, geo_points: PackedVector2Array, station_names: PackedStringArray, style_id: String) -> void:
	if station_names.is_empty():
		return
	if style_id == "washington" and not build_washington_street_tunnel:
		return
	if style_id == "cambridge" and not build_cambridge_dorchester_tunnel:
		return
	var parent := _get_path_parent(track_builder)
	if parent == null:
		return
	var existing := parent.get_node_or_null(root_name)
	if existing:
		existing.queue_free()
	var points := _project_geo_points(geo_points)
	if points.size() < 2:
		return
	var root := Node3D.new()
	root.name = root_name
	parent.add_child(root)
	var surface_root := _make_subway_section(root, "StreetDeck")
	var tunnel_root := _make_subway_section(root, "TunnelSegments")
	var station_root := _make_subway_section(root, "Stations")
	for i in range(points.size() - 1):
		var a_name := station_names[min(i, station_names.size() - 1)]
		var b_name := station_names[min(i + 1, station_names.size() - 1)]
		var a_spec := _station_spec(a_name)
		var b_spec := _station_spec(b_name)
		_build_subway_segment(
			tunnel_root,
			surface_root,
			"%s_to_%s" % [_section_name(a_name), _section_name(b_name)],
			points[i],
			points[i + 1],
			maxi(int(a_spec.get("tracks", 2)), int(b_spec.get("tracks", 2))),
			_station_has_junction_geometry(a_spec),
			_station_has_junction_geometry(b_spec),
			style_id
		)
	for i in range(min(points.size(), station_names.size())):
		_build_named_subway_station(station_root, surface_root, points, i, station_names[i], style_id)

func _add_historical_elevated_segment(parent: Node3D, a: Vector3, b: Vector3, deck_height: float, style_id: String) -> void:
	var forward := (b - a).normalized()
	if forward.length() < 0.01:
		return
	var right := Vector3(-forward.z, 0.0, forward.x).normalized()
	var length := a.distance_to(b)
	var center := (a + b) * 0.5 + Vector3(0.0, deck_height, 0.0)
	var theme := _corridor_theme(style_id)
	var steel_color: Color = theme.get("steel_color", Color("4e463f"))
	var steel_material := _ensure_period_material("steel_dark", steel_color)
	var timber_material := _ensure_period_material("timber")
	_add_box_with_material(parent, Vector3(13.8, 0.42, length), center + Vector3(0.0, -0.04, 0.0), forward, steel_material)
	_add_box_with_material(parent, Vector3(10.8, 0.34, length), center + Vector3(0.0, 0.28, 0.0), forward, timber_material)
	_add_track_surface_box(parent, Vector3(6.8, 0.18, length), center + Vector3(0.0, 0.42, 0.0), forward)
	for offset in [-3.0, 3.0]:
		_add_rail_box(parent, Vector3(0.18, 0.18, length), center + right * offset + Vector3(0.0, 0.58, 0.0), forward)
	for side in [-1.0, 1.0]:
		_add_box_with_material(parent, Vector3(0.5, 1.5, length), center + right * side * 6.2 + Vector3(0.0, 0.72, 0.0), forward, steel_material)
	var bent_count := maxi(2, int(round(length / 24.0)))
	for i in range(bent_count):
		var t := float(i + 1) / float(bent_count + 1)
		var bent_center := a.lerp(b, t)
		for side in [-1.0, 1.0]:
			var column_center: Vector3 = bent_center + right * side * 4.9 + Vector3(0.0, deck_height * 0.5, 0.0)
			_add_box_with_material(parent, Vector3(0.8, deck_height, 0.8), column_center, forward, steel_material)
		_add_box_with_material(parent, Vector3(11.0, 0.55, 0.9), bent_center + Vector3(0.0, deck_height - 0.5, 0.0), right, steel_material)
		_add_box_with_material(parent, Vector3(0.35, deck_height - 1.2, 0.35), bent_center + right * 3.0 + Vector3(0.0, (deck_height - 1.2) * 0.5, 0.0), forward.rotated(Vector3.UP, deg_to_rad(18.0)), steel_material)
		_add_box_with_material(parent, Vector3(0.35, deck_height - 1.2, 0.35), bent_center - right * 3.0 + Vector3(0.0, (deck_height - 1.2) * 0.5, 0.0), forward.rotated(Vector3.UP, deg_to_rad(-18.0)), steel_material)

func _add_historical_elevated_station(parent: Node3D, point: Vector3, forward: Vector3, station_name: String, deck_height: float, style_id: String) -> void:
	var right := Vector3(-forward.z, 0.0, forward.x).normalized()
	var center := point + Vector3(0.0, deck_height, 0.0)
	var theme := _corridor_theme(style_id)
	var steel_color: Color = theme.get("steel_color", Color("4e463f"))
	var line_color: Color = theme.get("line_color", Color("9c8a62"))
	var sign_text_color: Color = theme.get("sign_text", Color("f5ecd8"))
	var steel_material := _ensure_period_material("steel_dark", steel_color)
	var timber_material := _ensure_period_material("timber")
	var brick_material := _ensure_period_material("brick")
	_add_box_with_material(parent, Vector3(20.0, 0.48, 34.0), center + Vector3(0.0, 0.1, 0.0), forward, steel_material)
	_add_box_with_material(parent, Vector3(16.0, 0.28, 30.0), center + Vector3(0.0, 0.38, 0.0), forward, timber_material)
	for side in [-1.0, 1.0]:
		var platform_center: Vector3 = center + right * side * 6.0 + Vector3(0.0, -0.28, 0.0)
		_add_box_with_material(parent, Vector3(4.6, 0.48, 28.0), platform_center, forward, timber_material)
		_add_box(parent, Vector3(0.24, 0.2, 28.0), platform_center - right * side * 2.0 + Vector3(0.0, 0.2, 0.0), forward, line_color)
	_add_box_with_material(parent, Vector3(11.8, 0.28, 23.0), center + Vector3(0.0, 4.2, 0.0), forward, steel_material)
	for side in [-1.0, 1.0]:
		for longitudinal in [-8.0, 8.0]:
			_add_box_with_material(parent, Vector3(0.22, 4.4, 0.22), center + right * side * 4.4 + forward * longitudinal + Vector3(0.0, 2.05, 0.0), forward, steel_material)
	_add_box_with_material(parent, Vector3(6.4, 3.8, 5.2), point + right * 9.0 + forward * 7.0 + Vector3(0.0, deck_height * 0.5 + 0.8, 0.0), forward, brick_material)
	_add_box_with_material(parent, Vector3(7.4, 0.55, 6.2), point + right * 9.0 + forward * 7.0 + Vector3(0.0, deck_height + 2.9, 0.0), forward, steel_material)
	var label := Label3D.new()
	label.text = _station_display_name(station_name)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 28
	label.modulate = sign_text_color
	label.position = center + Vector3(0.0, 5.5, 0.0)
	parent.add_child(label)

func _build_subway_design(stop_points: PackedVector3Array, _route_points: PackedVector3Array, track_builder: Node) -> void:
	if not build_subway_design:
		return
	var parent := _get_path_parent(track_builder)
	if parent == null:
		return
	var existing := parent.get_node_or_null(subway_root_name)
	if existing:
		existing.queue_free()
	var root := Node3D.new()
	root.name = subway_root_name
	parent.add_child(root)
	var surface_root := _make_subway_section(root, "StreetDeck")
	var tunnel_root := _make_subway_section(root, "TunnelSegments")
	var station_root := _make_subway_section(root, "Stations")
	var portal_root := _make_subway_section(root, "KenmorePortal")
	var station_indices := _subway_station_indices()
	if station_indices.size() < 2:
		return
	for i in range(station_indices.size() - 1):
		var a_idx: int = station_indices[i]
		var b_idx: int = station_indices[i + 1]
		var a_name: String = mainline_towns[a_idx]
		var b_name: String = mainline_towns[b_idx]
		var seg_tracks := maxi(int(_station_spec(a_name).get("tracks", 2)), int(_station_spec(b_name).get("tracks", 2)))
		var start_junction := _station_has_junction_geometry(_station_spec(a_name))
		var end_junction := _station_has_junction_geometry(_station_spec(b_name))
		_build_subway_segment(
			tunnel_root,
			surface_root,
			"%s_to_%s" % [_section_name(a_name), _section_name(b_name)],
			stop_points[a_idx],
			stop_points[b_idx],
			seg_tracks,
			start_junction,
			end_junction,
			"tremont"
		)
	for idx in station_indices:
		_build_subway_station(station_root, surface_root, stop_points, idx)
	_build_portal(portal_root, surface_root, stop_points)

func _subway_station_indices() -> Array[int]:
	var indices: Array[int] = []
	for station_name in subway_station_names:
		var idx := mainline_towns.find(station_name)
		if idx != -1:
			indices.append(idx)
	return indices

func _last_subway_station_index() -> int:
	var indices := _subway_station_indices()
	if indices.is_empty():
		return -1
	return indices[indices.size() - 1]

func _subway_track_point(surface_point: Vector3) -> Vector3:
	return surface_point + Vector3(0.0, subway_depth, 0.0)

func _subway_camera_views(stop_points: PackedVector3Array) -> PackedVector3Array:
	var views := PackedVector3Array()
	var north_surface := _north_subway_surface_points()
	if build_north_terminal_extension and north_surface.size() > 1:
		var elevated_surface := _elevated_surface_points()
		if elevated_surface.size() > 1:
			views.append(elevated_surface[0] + Vector3(0.0, elevated_deck_height, 0.0))
			views.append(elevated_surface[1] + Vector3(0.0, elevated_deck_height, 0.0))
			views.append(_portal_blend(north_surface[north_surface.size() - 1], elevated_surface[1], 0.72, elevated_deck_height * 0.34))
			views.append(_portal_blend(north_surface[north_surface.size() - 1], elevated_surface[1], 0.46, subway_depth * 0.18))
		for i in range(north_surface.size() - 1, -1, -1):
			views.append(_subway_track_point(north_surface[i]))
			if i > 0:
				views.append(_subway_track_point(north_surface[i].lerp(north_surface[i - 1], 0.5)))
	var station_indices := _subway_station_indices()
	for i in range(station_indices.size()):
		var idx: int = station_indices[i]
		views.append(_subway_track_point(stop_points[idx]))
		if i + 1 < station_indices.size():
			var next_idx: int = station_indices[i + 1]
			views.append(_subway_track_point(stop_points[idx].lerp(stop_points[next_idx], 0.5)))
	return views

func _build_subway_segment(parent: Node3D, surface_parent: Node3D, section_name: String, a: Vector3, b: Vector3, tracks: int, start_junction: bool = false, end_junction: bool = false, style_id: String = "") -> void:
	var forward := (b - a).normalized()
	if forward.length() < 0.01:
		return
	var segment_root := _make_subway_section(parent, section_name)
	var right := Vector3(-forward.z, 0.0, forward.x).normalized()
	var length := a.distance_to(b)
	var width := 18.0 if tracks <= 2 else 33.0
	var center := (a + b) * 0.5 + Vector3(0.0, subway_depth, 0.0)
	var shell_span := _trimmed_segment_span(
		center,
		forward,
		length,
		_segment_end_open_length(length, start_junction),
		_segment_end_open_length(length, end_junction)
	)
	_add_surface_alignment(surface_parent, a, b, width * 0.52, Color("695642"), style_id)
	_add_tunnel_shell(segment_root, shell_span["center"], forward, right, width, shell_span["length"], tracks, not (start_junction or end_junction), style_id)
	var track_offsets := _track_offsets(tracks)
	for offset in track_offsets:
		_add_track_surface_box(segment_root, Vector3(2.0, subway_track_bed_height, length), center + right * offset + Vector3(0.0, -1.85, 0.0), forward)
		_add_box(segment_root, Vector3(0.16, 0.12, length), center + right * (offset - 0.72) + Vector3(0.0, -1.48, 0.0), forward, Color("b7b0a1"))
		_add_box(segment_root, Vector3(0.16, 0.12, length), center + right * (offset + 0.72) + Vector3(0.0, -1.48, 0.0), forward, Color("b7b0a1"))
	_add_tunnel_track_details(segment_root, shell_span["center"], forward, right, track_offsets, shell_span["length"])
	_add_tunnel_lights(segment_root, shell_span["center"], forward, shell_span["length"])

func _build_subway_station(parent: Node3D, surface_parent: Node3D, points: PackedVector3Array, idx: int) -> void:
	_build_named_subway_station(parent, surface_parent, points, idx, mainline_towns[idx], "tremont")

func _build_named_subway_station(parent: Node3D, surface_parent: Node3D, points: PackedVector3Array, idx: int, station_name: String, style_id: String = "tremont") -> void:
	var spec := _station_spec(station_name)
	var forward := _station_forward(points, idx)
	var right := Vector3(-forward.z, 0.0, forward.x).normalized()
	var station_root := _make_subway_section(parent, _section_name(station_name))
	var center := points[idx] + Vector3(0.0, subway_depth, 0.0)
	var surface_center := Vector3(points[idx].x, 0.08, points[idx].z)
	var width: float = _resolved_station_width(spec, float(spec.get("width", 22.0)), int(spec.get("tracks", 2)))
	var length: float = float(spec.get("length", 140.0))
	var platform_width: float = float(spec.get("platform_width", 6.5))
	var mezzanine_length: float = float(spec.get("mezzanine_length", length * 0.55))
	var tracks: int = int(spec.get("tracks", 2))
	var layout: String = String(spec.get("layout", "side"))

	_add_surface_alignment(surface_parent, points[maxi(0, idx - 1)], points[mini(points.size() - 1, idx + 1)], width * 0.46, Color("544437"), style_id)
	_add_surface_alignment(surface_parent, surface_center - forward * (length * 0.41), surface_center + forward * (length * 0.41), width * 0.62, Color("544437"), style_id)
	_add_station_shell(station_root, center, forward, right, width, length, spec, tracks, style_id, station_name)
	_add_station_mezzanines(station_root, center, forward, right, width, mezzanine_length, spec)

	for offset in _track_offsets_for_spec(spec, tracks):
		_add_track_surface_box(station_root, Vector3(2.1, subway_track_bed_height, length), center + right * offset + Vector3(0.0, -1.85, 0.0), forward)
		_add_box(station_root, Vector3(0.16, 0.12, length), center + right * (offset - 0.72) + Vector3(0.0, -1.48, 0.0), forward, Color("b7b0a1"))
		_add_box(station_root, Vector3(0.16, 0.12, length), center + right * (offset + 0.72) + Vector3(0.0, -1.48, 0.0), forward, Color("b7b0a1"))

	_add_station_platforms(station_root, center, forward, right, width, length, platform_width, spec, layout, style_id)
	_add_station_extra_boxes(station_root, center, forward, right, spec)
	_add_station_name_boards(station_root, center, forward, right, width, length, station_name, style_id)

	if bool(spec.get("spur", false)):
		var spur_start := center + forward * (length * 0.42)
		var spur_dir := (forward - right).normalized()
		_add_box(station_root, Vector3(10.0, 0.55, 70.0), spur_start + spur_dir * 28.0 + Vector3(0.0, -2.15, 0.0), spur_dir, Color("514c46"))
		var spur_wall := spur_start + spur_dir * 28.0 + right * 4.5
		spur_wall = _push_box_outward_from_center(center, spur_wall, spur_dir, subway_junction_wall_push)
		_add_box(station_root, Vector3(1.0, 4.6, 58.0), spur_wall, spur_dir, Color("80796e"))
	if bool(spec.get("corridor", false)):
		_add_box(station_root, Vector3(5.0, 2.8, 28.0), center + right * (width * 0.5 + 2.4) + Vector3(0.0, 1.2, 0.0), right, Color("b8ae99"))

	_add_station_access_shafts(station_root, center, forward, right, width, station_name, spec)
	_add_station_lights(station_root, center, forward, right, length, width)
	_add_station_surface_boxes(surface_parent, center, forward, right, spec, style_id)
	_add_headhouse(surface_parent, center, forward, right, station_name, spec, style_id)

func _add_headhouse(parent: Node3D, station_center: Vector3, forward: Vector3, right: Vector3, station_name: String, spec: Dictionary = {}, style_id: String = "tremont") -> void:
	var above := station_center - Vector3(0.0, subway_depth, 0.0)
	var theme := _corridor_theme(style_id)
	var sign_text_color: Color = theme.get("sign_text", Color(1.0, 0.97, 0.9, 1.0))
	var steel_color: Color = theme.get("steel_color", Color("4e463f"))
	var base_material := _ensure_period_material(String(theme.get("headhouse_material", "brick")))
	var roof_material := _ensure_period_material(String(theme.get("roof_material", "steel_dark")), steel_color)
	var headhouses: Array = spec.get("headhouses", [])
	if headhouses.is_empty():
		_add_box_with_material(parent, Vector3(10.0, 4.8, 8.0), above + Vector3(0.0, 2.4, 0.0), forward, base_material)
		_add_box_with_material(parent, Vector3(11.0, 0.8, 9.0), above + Vector3(0.0, 5.0, 0.0), forward, roof_material)
	else:
		for entry_variant in headhouses:
			var entry: Dictionary = entry_variant
			var base_size := Vector3(float(entry.get("base_x", 10.0)), float(entry.get("base_y", 4.8)), float(entry.get("base_z", 8.0)))
			var roof_size := Vector3(float(entry.get("roof_x", base_size.x + 1.0)), float(entry.get("roof_y", 0.8)), float(entry.get("roof_z", base_size.z + 1.0)))
			var orient := right if bool(entry.get("orient_right", false)) else forward
			var center_pos := above + right * float(entry.get("right_offset", 0.0)) + forward * float(entry.get("forward_offset", 0.0))
			var base_up := float(entry.get("base_up_offset", 0.0))
			_add_box_with_material(parent, base_size, center_pos + Vector3(0.0, base_up + base_size.y * 0.5, 0.0), orient, _ensure_period_material(String(theme.get("headhouse_material", "brick")), Color(String(entry.get("base_tint", "ffffff")))))
			_add_box_with_material(parent, roof_size, center_pos + Vector3(0.0, base_up + base_size.y + roof_size.y * 0.5, 0.0), orient, _ensure_period_material(String(theme.get("roof_material", "steel_dark")), Color(String(entry.get("roof_tint", "ffffff")))))
	var label := Label3D.new()
	label.text = String(spec.get("display_name", station_name))
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 32
	label.modulate = sign_text_color
	label.position = above + Vector3(0.0, float(spec.get("label_height", 7.0)), 0.0)
	parent.add_child(label)

func _station_spec(station_name: String) -> Dictionary:
	match station_name:
		"North Station":
			return {
				"tracks": 4,
				"layout": "custom",
				"length": 188.0,
				"width": 40.0,
				"platform_width": 6.4,
				"track_offsets": [-11.2, -3.8, 3.8, 11.2],
				"platforms": [
					{"offset": -7.5, "width": 6.4, "length": 176.0},
					{"offset": 7.5, "width": 6.4, "length": 176.0}
				],
				"mezzanines": [
					{"width": 26.0, "height": 0.45, "length": 56.0, "up_offset": 2.25},
					{"width": 16.0, "height": 0.2, "length": 34.0, "up_offset": 1.95}
				],
				"column_offsets": [-14.6, -7.5, 7.5, 14.6],
				"column_height": 4.7,
				"shafts": [
					{"right_offset": -8.0},
					{"right_offset": 8.0},
					{"forward_offset": 24.0}
				],
				"extra_boxes": [
					{"size_x": 2.1, "size_y": 0.55, "size_z": 72.0, "right_offset": 11.2, "forward_offset": -70.0, "up_offset": -2.15, "yaw_deg": 22.0, "color": "514c46"},
					{"size_x": 0.8, "size_y": 3.8, "size_z": 72.0, "right_offset": 15.4, "forward_offset": -70.0, "yaw_deg": 22.0, "color": "7f786f"}
				],
				"headhouses": [
					{"right_offset": -8.0, "forward_offset": -12.0, "base_x": 8.0, "base_y": 4.6, "base_z": 7.0, "roof_x": 9.4, "roof_y": 0.8, "roof_z": 8.2},
					{"right_offset": 8.0, "forward_offset": -12.0, "base_x": 8.0, "base_y": 4.6, "base_z": 7.0, "roof_x": 9.4, "roof_y": 0.8, "roof_z": 8.2}
				]
			}
		"Haymarket":
			return {
				"tracks": 2,
				"layout": "custom",
				"length": 138.0,
				"width": 24.0,
				"platform_width": 7.4,
				"track_offsets": [-4.0, 4.0],
				"platforms": [
					{"offset": 0.0, "width": 7.4, "length": 126.0}
				],
				"mezzanines": [
					{"width": 16.0, "height": 0.45, "length": 26.0, "up_offset": 2.2}
				],
				"column_offsets": [-9.0, 0.0, 9.0],
				"column_height": 4.4,
				"shafts": [
					{"right_offset": -5.2},
					{"right_offset": 5.2}
				],
				"headhouses": [
					{"right_offset": -5.0, "forward_offset": -8.0, "base_x": 6.5, "base_y": 4.0, "base_z": 5.8, "roof_x": 7.6, "roof_y": 0.8, "roof_z": 6.8},
					{"right_offset": 5.0, "forward_offset": -8.0, "base_x": 6.5, "base_y": 4.0, "base_z": 5.8, "roof_x": 7.6, "roof_y": 0.8, "roof_z": 6.8}
				]
			}
		"Friend Street":
			return {
				"tracks": 4,
				"layout": "custom",
				"length": 148.0,
				"width": 34.0,
				"platform_width": 6.0,
				"track_offsets": [-10.8, -3.6, 3.6, 10.8],
				"platforms": [
					{"offset": -7.2, "width": 6.0, "length": 138.0},
					{"offset": 7.2, "width": 6.0, "length": 138.0}
				],
				"mezzanines": [
					{"width": 24.0, "height": 0.45, "length": 40.0, "up_offset": 2.2},
					{"width": 16.0, "height": 0.2, "length": 22.0, "up_offset": 1.92, "forward_offset": -34.0}
				],
				"column_offsets": [-13.4, -7.2, 7.2, 13.4],
				"column_height": 4.6,
				"shafts": [
					{"right_offset": -8.0},
					{"right_offset": 8.0},
					{"forward_offset": -28.0}
				],
				"extra_boxes": [
					{"size_x": 2.1, "size_y": 0.55, "size_z": 84.0, "right_offset": 10.8, "forward_offset": -62.0, "up_offset": -2.15, "yaw_deg": 18.0, "color": "514c46"},
					{"size_x": 0.8, "size_y": 3.8, "size_z": 84.0, "right_offset": 15.0, "forward_offset": -62.0, "yaw_deg": 18.0, "color": "7f786f"}
				],
				"headhouses": [
					{"right_offset": -7.5, "forward_offset": -16.0, "base_x": 6.8, "base_y": 4.2, "base_z": 5.8, "roof_x": 8.0, "roof_y": 0.8, "roof_z": 7.0},
					{"right_offset": 7.5, "forward_offset": -16.0, "base_x": 6.8, "base_y": 4.2, "base_z": 5.8, "roof_x": 8.0, "roof_y": 0.8, "roof_z": 7.0}
				]
			}
		"Adams Square":
			return {
				"tracks": 2,
				"layout": "custom",
				"length": 132.0,
				"width": 24.0,
				"platform_width": 7.2,
				"track_offsets": [-4.0, 4.0],
				"platforms": [
					{"offset": 0.0, "width": 7.2, "length": 120.0}
				],
				"mezzanines": [
					{"width": 15.0, "height": 0.45, "length": 22.0, "up_offset": 2.2}
				],
				"column_offsets": [-8.6, 0.0, 8.6],
				"column_height": 4.4,
				"shafts": [
					{"right_offset": -4.8},
					{"right_offset": 4.8}
				],
				"extra_boxes": [
					{"size_x": 2.1, "size_y": 0.55, "size_z": 58.0, "right_offset": -4.0, "forward_offset": -58.0, "up_offset": -2.15, "yaw_deg": -24.0, "color": "514c46"}
				],
				"headhouses": [
					{"right_offset": -4.8, "forward_offset": 0.0, "base_x": 6.2, "base_y": 4.0, "base_z": 5.6, "roof_x": 7.4, "roof_y": 0.8, "roof_z": 6.6},
					{"right_offset": 4.8, "forward_offset": 0.0, "base_x": 6.2, "base_y": 4.0, "base_z": 5.6, "roof_x": 7.4, "roof_y": 0.8, "roof_z": 6.6}
				]
			}
		"Scollay Square":
			return {
				"tracks": 2,
				"layout": "custom",
				"length": 148.0,
				"width": 26.0,
				"platform_width": 7.8,
				"track_offsets": [-4.2, 4.2],
				"platforms": [
					{"offset": 0.0, "width": 7.8, "length": 136.0}
				],
				"mezzanines": [
					{"width": 18.0, "height": 0.45, "length": 36.0, "up_offset": 2.2}
				],
				"column_offsets": [-9.2, 0.0, 9.2],
				"column_height": 4.5,
				"shafts": [
					{"right_offset": -5.4},
					{"right_offset": 5.4}
				],
				"extra_boxes": [
					{"size_x": 2.1, "size_y": 0.55, "size_z": 64.0, "right_offset": 4.2, "forward_offset": -62.0, "up_offset": -2.15, "yaw_deg": 26.0, "color": "514c46"}
				],
				"headhouses": [
					{"right_offset": -5.4, "forward_offset": 10.0, "base_x": 6.8, "base_y": 4.2, "base_z": 5.8, "roof_x": 8.0, "roof_y": 0.8, "roof_z": 7.0},
					{"right_offset": 5.4, "forward_offset": 10.0, "base_x": 6.8, "base_y": 4.2, "base_z": 5.8, "roof_x": 8.0, "roof_y": 0.8, "roof_z": 7.0}
				]
			}
		"Park Street":
			return {
				"tracks": 4,
				"layout": "custom",
				"length": 236.0,
				"width": 44.0,
				"platform_width": 6.6,
				"track_offsets": [-12.2, -4.1, 4.1, 12.2],
				"platforms": [
					{"offset": -8.15, "width": 6.6, "length": 228.0},
					{"offset": 8.15, "width": 6.6, "length": 228.0},
					{"offset": 17.8, "width": 4.0, "length": 94.0, "forward_offset": 58.0, "edge_right": false}
				],
				"mezzanines": [
					{"width": 32.0, "height": 0.45, "length": 188.0, "up_offset": 2.25},
					{"width": 22.0, "height": 0.2, "length": 152.0, "up_offset": 1.95},
					{"width": 12.0, "height": 0.35, "length": 46.0, "up_offset": 2.65, "right_offset": 17.6, "forward_offset": 58.0, "orient_right": true}
				],
				"column_offsets": [-15.7, -8.15, 8.15, 15.7],
				"column_height": 4.7,
				"shafts": [
					{"right_offset": -9.5},
					{"right_offset": 9.5},
					{"right_offset": 18.0, "forward_offset": 58.0, "length": 4.2, "steps": 4, "run": 2.4}
				],
				"extra_boxes": [
					{"size_x": 4.0, "size_y": 2.2, "size_z": 22.0, "right_offset": 21.2, "forward_offset": 58.0, "up_offset": 1.4, "orient_right": true, "color": "b9ae98"},
					{"size_x": 1.1, "size_y": 4.4, "size_z": 34.0, "right_offset": 14.6, "forward_offset": -86.0, "up_offset": 0.15, "color": "80776b"}
				],
				"headhouses": [
					{"right_offset": -7.5, "forward_offset": 20.0, "base_x": 8.0, "base_y": 4.6, "base_z": 7.0, "roof_x": 9.2, "roof_y": 0.8, "roof_z": 8.2},
					{"right_offset": 7.5, "forward_offset": 20.0, "base_x": 8.0, "base_y": 4.6, "base_z": 7.0, "roof_x": 9.2, "roof_y": 0.8, "roof_z": 8.2},
					{"right_offset": 18.0, "forward_offset": 58.0, "base_x": 7.0, "base_y": 4.2, "base_z": 6.0, "roof_x": 8.0, "roof_y": 0.8, "roof_z": 7.0}
				],
				"surface_boxes": [
					{"size_x": 9.0, "size_y": 1.0, "size_z": 14.0, "forward_offset": -6.0, "up_offset": 0.5, "color": "544437"}
				],
				"label_height": 8.0
			}
		"Boylston":
			return {
				"tracks": 4,
				"layout": "custom",
				"length": 156.0,
				"width": 34.0,
				"platform_width": 5.6,
				"track_offsets": [-11.4, -4.1, 4.1, 11.4],
				"platforms": [
					{"offset": -7.75, "width": 5.6, "length": 134.0},
					{"offset": 7.75, "width": 5.6, "length": 134.0}
				],
				"mezzanines": [
					{"width": 18.0, "height": 0.45, "length": 74.0, "up_offset": 2.2},
					{"width": 11.0, "height": 0.2, "length": 52.0, "up_offset": 1.92}
				],
				"column_offsets": [-11.4, -7.75, 7.75, 11.4],
				"column_height": 4.5,
				"shafts": [
					{"right_offset": -7.8},
					{"right_offset": 7.8}
				],
				"extra_boxes": [
					{"size_x": 2.1, "size_y": 0.55, "size_z": 78.0, "right_offset": -11.4, "forward_offset": 54.0, "up_offset": -2.15, "yaw_deg": -32.0, "color": "514c46"},
					{"size_x": 0.9, "size_y": 4.2, "size_z": 78.0, "right_offset": -6.8, "forward_offset": 54.0, "yaw_deg": -32.0, "color": "80796e"},
					{"size_x": 2.1, "size_y": 0.55, "size_z": 28.0, "right_offset": 11.4, "forward_offset": -56.0, "up_offset": -2.15, "color": "514c46"}
				],
				"headhouses": [
					{"right_offset": -6.0, "forward_offset": -18.0, "base_x": 6.8, "base_y": 4.2, "base_z": 5.8, "roof_x": 8.0, "roof_y": 0.8, "roof_z": 7.0},
					{"right_offset": 6.0, "forward_offset": -18.0, "base_x": 6.8, "base_y": 4.2, "base_z": 5.8, "roof_x": 8.0, "roof_y": 0.8, "roof_z": 7.0}
				]
			}
		"Arlington":
			return {
				"tracks": 2,
				"layout": "custom",
				"length": 158.0,
				"width": 26.0,
				"platform_width": 5.4,
				"track_offsets": [-3.2, 3.2],
				"platforms": [
					{"offset": -8.0, "width": 5.4, "length": 150.0},
					{"offset": 8.0, "width": 5.4, "length": 150.0}
				],
				"mezzanines": [
					{"width": 18.0, "height": 0.45, "length": 46.0, "forward_offset": -38.0, "up_offset": 2.2},
					{"width": 12.0, "height": 0.35, "length": 18.0, "forward_offset": 46.0, "up_offset": 2.2}
				],
				"shafts": [
					{"right_offset": -8.0, "forward_offset": -38.0},
					{"right_offset": 8.0, "forward_offset": -38.0},
					{"forward_offset": 46.0, "length": 4.0}
				],
				"extra_boxes": [
					{"size_x": 10.0, "size_y": 2.5, "size_z": 18.0, "forward_offset": 46.0, "up_offset": 1.1, "orient_right": true, "color": "b8ae99"}
				],
				"headhouses": [
					{"right_offset": -7.5, "forward_offset": -26.0, "base_x": 7.0, "base_y": 4.2, "base_z": 6.0, "roof_x": 8.2, "roof_y": 0.8, "roof_z": 7.0},
					{"right_offset": 7.5, "forward_offset": -26.0, "base_x": 7.0, "base_y": 4.2, "base_z": 6.0, "roof_x": 8.2, "roof_y": 0.8, "roof_z": 7.0},
					{"forward_offset": 48.0, "base_x": 6.2, "base_y": 4.0, "base_z": 5.4, "roof_x": 7.2, "roof_y": 0.8, "roof_z": 6.4}
				]
			}
		"Copley":
			return {
				"tracks": 2,
				"layout": "custom",
				"length": 164.0,
				"width": 28.0,
				"platform_width": 5.8,
				"track_offsets": [-3.3, 3.3],
				"platforms": [
					{"offset": -8.6, "width": 5.8, "length": 122.0, "forward_offset": -18.0},
					{"offset": 8.6, "width": 5.8, "length": 122.0, "forward_offset": 18.0}
				],
				"mezzanines": [
					{"width": 11.5, "height": 0.35, "length": 30.0, "right_offset": -8.6, "forward_offset": -46.0, "up_offset": 2.2},
					{"width": 11.5, "height": 0.35, "length": 30.0, "right_offset": 8.6, "forward_offset": 46.0, "up_offset": 2.2}
				],
				"shafts": [
					{"right_offset": -8.6, "forward_offset": -46.0},
					{"right_offset": 8.6, "forward_offset": 46.0}
				],
				"extra_boxes": [
					{"size_x": 2.1, "size_y": 0.55, "size_z": 72.0, "right_offset": 1.0, "forward_offset": -74.0, "up_offset": -2.15, "yaw_deg": 28.0, "color": "514c46"},
					{"size_x": 0.8, "size_y": 3.8, "size_z": 72.0, "right_offset": 5.6, "forward_offset": -74.0, "yaw_deg": 28.0, "color": "7f786f"}
				],
				"headhouses": [
					{"right_offset": -10.0, "forward_offset": -38.0, "base_x": 7.0, "base_y": 4.2, "base_z": 5.8, "roof_x": 8.2, "roof_y": 0.8, "roof_z": 6.8},
					{"right_offset": 10.0, "forward_offset": 38.0, "base_x": 7.0, "base_y": 4.2, "base_z": 5.8, "roof_x": 8.2, "roof_y": 0.8, "roof_z": 6.8}
				]
			}
		"Massachusetts Avenue", "Hynes", "Massachusetts":
			return {
				"tracks": 2,
				"layout": "custom",
				"length": 114.0,
				"width": 30.0,
				"platform_width": 5.8,
				"track_offsets": [-3.3, 3.3],
				"platforms": [
					{"offset": -9.2, "width": 5.8, "length": 104.0},
					{"offset": 9.2, "width": 5.8, "length": 104.0}
				],
				"mezzanines": [
					{"width": 24.0, "height": 0.45, "length": 34.0, "forward_offset": -22.0, "up_offset": 2.25},
					{"width": 15.0, "height": 0.35, "length": 18.0, "forward_offset": 30.0, "up_offset": 2.25}
				],
				"shafts": [
					{"right_offset": -9.2, "forward_offset": -20.0},
					{"right_offset": 9.2, "forward_offset": -20.0},
					{"forward_offset": 30.0}
				],
				"extra_boxes": [
					{"size_x": 5.0, "size_y": 2.8, "size_z": 42.0, "right_offset": 16.5, "forward_offset": -4.0, "up_offset": 1.2, "orient_right": true, "color": "b8ae99"}
				],
				"headhouses": [
					{"forward_offset": -22.0, "base_x": 12.0, "base_y": 5.0, "base_z": 8.0, "roof_x": 13.0, "roof_y": 0.8, "roof_z": 9.0},
					{"right_offset": 16.0, "forward_offset": 6.0, "base_x": 6.5, "base_y": 4.0, "base_z": 6.0, "roof_x": 7.6, "roof_y": 0.8, "roof_z": 7.2, "orient_right": true}
				],
				"surface_boxes": [
					{"size_x": 12.0, "size_y": 4.0, "size_z": 28.0, "right_offset": 19.0, "forward_offset": -2.0, "up_offset": 4.2, "orient_right": true, "color": "7f5c44"},
					{"size_x": 20.0, "size_y": 14.0, "size_z": 16.0, "forward_offset": -22.0, "up_offset": 12.0, "color": "8b745f"}
				]
			}
		"Kenmore":
			return {
				"tracks": 4,
				"layout": "custom",
				"length": 246.0,
				"width": 44.0,
				"platform_width": 6.8,
				"track_offsets": [-12.4, -4.2, 4.2, 12.4],
				"platforms": [
					{"offset": -8.3, "width": 6.8, "length": 234.0},
					{"offset": 8.3, "width": 6.8, "length": 234.0}
				],
				"mezzanines": [
					{"width": 32.0, "height": 0.45, "length": 92.0, "up_offset": 2.3},
					{"width": 22.0, "height": 0.2, "length": 66.0, "up_offset": 2.0}
				],
				"column_offsets": [-15.8, -8.3, 8.3, 15.8],
				"column_height": 4.8,
				"shafts": [
					{"right_offset": -9.0},
					{"right_offset": 9.0},
					{"forward_offset": 18.0}
				],
				"extra_boxes": [
					{"size_x": 2.1, "size_y": 0.55, "size_z": 96.0, "right_offset": 12.4, "forward_offset": -88.0, "up_offset": -2.15, "yaw_deg": 24.0, "color": "514c46"},
					{"size_x": 0.9, "size_y": 4.0, "size_z": 96.0, "right_offset": 17.0, "forward_offset": -88.0, "yaw_deg": 24.0, "color": "867d72"},
					{"size_x": 18.0, "size_y": 2.6, "size_z": 20.0, "forward_offset": 74.0, "up_offset": 1.6, "color": "b8ae99"}
				],
				"headhouses": [
					{"right_offset": -10.0, "forward_offset": 8.0, "base_x": 8.5, "base_y": 4.8, "base_z": 7.2, "roof_x": 9.8, "roof_y": 0.8, "roof_z": 8.4},
					{"right_offset": 10.0, "forward_offset": 8.0, "base_x": 8.5, "base_y": 4.8, "base_z": 7.2, "roof_x": 9.8, "roof_y": 0.8, "roof_z": 8.4}
				],
				"surface_boxes": [
					{"size_x": 24.0, "size_y": 1.0, "size_z": 16.0, "forward_offset": 10.0, "up_offset": 0.5, "color": "544437"},
					{"size_x": 16.0, "size_y": 4.2, "size_z": 34.0, "right_offset": -18.0, "forward_offset": 22.0, "up_offset": 3.6, "orient_right": true, "color": "7f5c44"}
				],
				"label_height": 8.0
			}
		"Bowdoin":
			return {
				"display_name": "Bowdoin",
				"tracks": 2,
				"layout": "side",
				"length": 118.0,
				"width": 22.0,
				"platform_width": 5.2
			}
		"Government Center":
			return {
				"display_name": "Government Center",
				"tracks": 2,
				"layout": "custom",
				"length": 144.0,
				"width": 25.0,
				"platform_width": 6.0,
				"track_offsets": [-3.2, 3.2],
				"platforms": [
					{"offset": 0.0, "width": 6.0, "length": 134.0}
				]
			}
		"Aquarium":
			return {
				"display_name": "Aquarium",
				"tracks": 2,
				"layout": "side",
				"length": 138.0,
				"width": 24.0,
				"platform_width": 5.8
			}
		"Maverick":
			return {
				"display_name": "Maverick",
				"tracks": 2,
				"layout": "side",
				"length": 150.0,
				"width": 26.0,
				"platform_width": 6.0
			}
		"Airport":
			return {
				"display_name": "Airport",
				"tracks": 2,
				"layout": "side",
				"length": 132.0,
				"width": 24.0,
				"platform_width": 5.6
			}
		"Wood Island":
			return {
				"display_name": "Wood Island",
				"tracks": 2,
				"layout": "side",
				"length": 126.0,
				"width": 24.0,
				"platform_width": 5.4
			}
		"Orient Heights":
			return {
				"display_name": "Orient Heights",
				"tracks": 2,
				"layout": "side",
				"length": 132.0,
				"width": 24.0,
				"platform_width": 5.6
			}
		"Suffolk Downs":
			return {
				"display_name": "Suffolk Downs",
				"tracks": 2,
				"layout": "side",
				"length": 128.0,
				"width": 24.0,
				"platform_width": 5.4
			}
		"Beachmont":
			return {
				"display_name": "Beachmont",
				"tracks": 2,
				"layout": "side",
				"length": 126.0,
				"width": 24.0,
				"platform_width": 5.4
			}
		"Revere Beach":
			return {
				"display_name": "Revere Beach",
				"tracks": 2,
				"layout": "side",
				"length": 130.0,
				"width": 24.0,
				"platform_width": 5.4
			}
		"Wonderland":
			return {
				"display_name": "Wonderland",
				"tracks": 2,
				"layout": "side",
				"length": 144.0,
				"width": 26.0,
				"platform_width": 5.8
			}
		"Lynn":
			return {
				"display_name": "Lynn",
				"tracks": 2,
				"layout": "side",
				"length": 154.0,
				"width": 28.0,
				"platform_width": 6.0
			}
		"Salem":
			return {
				"display_name": "Salem",
				"tracks": 2,
				"layout": "side",
				"length": 160.0,
				"width": 28.0,
				"platform_width": 6.0
			}
		"Scollay Under":
			return {
				"tracks": 2,
				"layout": "custom",
				"length": 132.0,
				"width": 25.0,
				"platform_width": 6.2,
				"track_offsets": [-3.3, 3.3],
				"platforms": [
					{"offset": 0.0, "width": 6.2, "length": 122.0}
				],
				"mezzanines": [
					{"width": 16.0, "height": 0.45, "length": 28.0, "up_offset": 2.2}
				],
				"column_offsets": [-8.6, 0.0, 8.6],
				"column_height": 4.4,
				"headhouses": [
					{"base_x": 7.0, "base_y": 4.2, "base_z": 5.8, "roof_x": 8.0, "roof_y": 0.8, "roof_z": 6.8}
				]
			}
		"Court Street Under":
			return {
				"tracks": 2,
				"layout": "custom",
				"length": 124.0,
				"width": 23.0,
				"platform_width": 5.8,
				"track_offsets": [-3.2, 3.2],
				"platforms": [
					{"offset": 0.0, "width": 5.8, "length": 114.0}
				],
				"mezzanines": [
					{"width": 14.0, "height": 0.45, "length": 24.0, "up_offset": 2.15}
				],
				"column_offsets": [-8.0, 0.0, 8.0],
				"column_height": 4.2,
				"headhouses": [
					{"base_x": 6.2, "base_y": 4.0, "base_z": 5.2, "roof_x": 7.4, "roof_y": 0.8, "roof_z": 6.2}
				]
			}
		"State":
			return {
				"tracks": 2,
				"layout": "custom",
				"length": 144.0,
				"width": 25.0,
				"platform_width": 6.0,
				"track_offsets": [-3.3, 3.3],
				"platforms": [
					{"offset": -8.0, "width": 6.0, "length": 132.0},
					{"offset": 8.0, "width": 6.0, "length": 132.0}
				],
				"mezzanines": [
					{"width": 18.0, "height": 0.45, "length": 32.0, "up_offset": 2.2}
				],
				"column_offsets": [-8.8, 8.8],
				"column_height": 4.4,
				"headhouses": [
					{"right_offset": -7.0, "base_x": 6.4, "base_y": 4.0, "base_z": 5.4, "roof_x": 7.4, "roof_y": 0.8, "roof_z": 6.4},
					{"right_offset": 7.0, "base_x": 6.4, "base_y": 4.0, "base_z": 5.4, "roof_x": 7.4, "roof_y": 0.8, "roof_z": 6.4}
				]
			}
		"Atlantic":
			return {
				"tracks": 2,
				"layout": "custom",
				"length": 138.0,
				"width": 24.0,
				"platform_width": 6.0,
				"track_offsets": [-3.2, 3.2],
				"platforms": [
					{"offset": -7.4, "width": 6.0, "length": 126.0},
					{"offset": 7.4, "width": 6.0, "length": 126.0}
				],
				"mezzanines": [
					{"width": 16.0, "height": 0.45, "length": 28.0, "up_offset": 2.2}
				],
				"column_offsets": [-8.4, 8.4],
				"column_height": 4.3,
				"headhouses": [
					{"right_offset": -6.5, "base_x": 6.0, "base_y": 4.0, "base_z": 5.2, "roof_x": 7.0, "roof_y": 0.8, "roof_z": 6.2},
					{"right_offset": 6.5, "base_x": 6.0, "base_y": 4.0, "base_z": 5.2, "roof_x": 7.0, "roof_y": 0.8, "roof_z": 6.2}
				]
			}
		"North Station (Atlantic)":
			return {
				"display_name": "North Station",
				"tracks": 2,
				"layout": "side",
				"length": 132.0,
				"width": 24.0,
				"platform_width": 5.8,
				"headhouses": [
					{"right_offset": 8.0, "forward_offset": 8.0, "base_x": 6.6, "base_y": 4.0, "base_z": 5.4, "roof_x": 7.6, "roof_y": 0.7, "roof_z": 6.4}
				]
			}
		"Battery":
			return {
				"display_name": "Battery",
				"tracks": 2,
				"layout": "side",
				"length": 116.0,
				"width": 22.0,
				"platform_width": 5.2,
				"headhouses": [
					{"right_offset": 7.0, "base_x": 6.0, "base_y": 3.8, "base_z": 5.0, "roof_x": 7.0, "roof_y": 0.7, "roof_z": 6.0}
				]
			}
		"State (Atlantic)":
			return {
				"display_name": "State",
				"tracks": 2,
				"layout": "side",
				"length": 122.0,
				"width": 23.0,
				"platform_width": 5.4,
				"headhouses": [
					{"right_offset": -7.0, "base_x": 6.4, "base_y": 3.8, "base_z": 5.2, "roof_x": 7.4, "roof_y": 0.7, "roof_z": 6.2},
					{"right_offset": 7.0, "base_x": 6.4, "base_y": 3.8, "base_z": 5.2, "roof_x": 7.4, "roof_y": 0.7, "roof_z": 6.2}
				]
			}
		"Rowes Wharf":
			return {
				"display_name": "Rowes Wharf",
				"tracks": 2,
				"layout": "side",
				"length": 116.0,
				"width": 22.0,
				"platform_width": 5.2,
				"headhouses": [
					{"right_offset": 7.0, "base_x": 6.0, "base_y": 3.8, "base_z": 5.0, "roof_x": 7.0, "roof_y": 0.7, "roof_z": 6.0}
				]
			}
		"South Station (Atlantic)":
			return {
				"display_name": "South Station",
				"tracks": 2,
				"layout": "side",
				"length": 126.0,
				"width": 24.0,
				"platform_width": 5.8,
				"headhouses": [
					{"right_offset": -7.8, "forward_offset": -8.0, "base_x": 6.8, "base_y": 4.0, "base_z": 5.6, "roof_x": 7.8, "roof_y": 0.7, "roof_z": 6.6}
				]
			}
		"Beach":
			return {
				"display_name": "Beach",
				"tracks": 2,
				"layout": "side",
				"length": 110.0,
				"width": 22.0,
				"platform_width": 5.0,
				"headhouses": [
					{"right_offset": 6.8, "base_x": 5.8, "base_y": 3.8, "base_z": 4.8, "roof_x": 6.8, "roof_y": 0.7, "roof_z": 5.8}
				]
			}
		"Haymarket (Wash)":
			return {
				"display_name": "Haymarket",
				"tracks": 2,
				"layout": "split_side",
				"length": 128.0,
				"width": 24.0,
				"platform_width": 5.4,
				"stagger": 16.0,
				"headhouses": [
					{"right_offset": -5.6, "base_x": 5.8, "base_y": 3.8, "base_z": 5.2, "roof_x": 6.8, "roof_y": 0.7, "roof_z": 6.2},
					{"right_offset": 5.6, "base_x": 5.8, "base_y": 3.8, "base_z": 5.2, "roof_x": 6.8, "roof_y": 0.7, "roof_z": 6.2}
				]
			}
		"State (Wash)":
			return {
				"display_name": "State",
				"tracks": 2,
				"layout": "split_side",
				"length": 144.0,
				"width": 26.0,
				"platform_width": 5.6,
				"stagger": 22.0,
				"headhouses": [
					{"right_offset": -6.0, "base_x": 6.0, "base_y": 3.8, "base_z": 5.2, "roof_x": 7.0, "roof_y": 0.7, "roof_z": 6.2},
					{"right_offset": 6.0, "base_x": 6.0, "base_y": 3.8, "base_z": 5.2, "roof_x": 7.0, "roof_y": 0.7, "roof_z": 6.2}
				]
			}
		"Summer":
			return {
				"display_name": "Summer",
				"tracks": 2,
				"layout": "split_side",
				"length": 138.0,
				"width": 24.0,
				"platform_width": 5.4,
				"stagger": 18.0,
				"headhouses": [
					{"right_offset": -5.8, "base_x": 5.8, "base_y": 3.8, "base_z": 5.0, "roof_x": 6.8, "roof_y": 0.7, "roof_z": 6.0},
					{"right_offset": 5.8, "base_x": 5.8, "base_y": 3.8, "base_z": 5.0, "roof_x": 6.8, "roof_y": 0.7, "roof_z": 6.0}
				]
			}
		"Essex":
			return {
				"display_name": "Essex",
				"tracks": 2,
				"layout": "split_side",
				"length": 134.0,
				"width": 24.0,
				"platform_width": 5.4,
				"stagger": 16.0,
				"headhouses": [
					{"right_offset": -5.6, "base_x": 5.8, "base_y": 3.8, "base_z": 5.0, "roof_x": 6.8, "roof_y": 0.7, "roof_z": 6.0},
					{"right_offset": 5.6, "base_x": 5.8, "base_y": 3.8, "base_z": 5.0, "roof_x": 6.8, "roof_y": 0.7, "roof_z": 6.0}
				]
			}
		"Dover":
			return {
				"display_name": "Dover",
				"tracks": 2,
				"layout": "split_side",
				"length": 128.0,
				"width": 24.0,
				"platform_width": 5.2,
				"stagger": 16.0,
				"headhouses": [
					{"right_offset": -5.4, "base_x": 5.6, "base_y": 3.8, "base_z": 4.8, "roof_x": 6.6, "roof_y": 0.7, "roof_z": 5.8},
					{"right_offset": 5.4, "base_x": 5.6, "base_y": 3.8, "base_z": 4.8, "roof_x": 6.6, "roof_y": 0.7, "roof_z": 5.8}
				]
			}
		"Harvard":
			return {
				"display_name": "Harvard",
				"tracks": 2,
				"layout": "side",
				"length": 160.0,
				"width": 28.0,
				"platform_width": 6.2,
				"headhouses": [
					{"forward_offset": -18.0, "base_x": 9.0, "base_y": 4.6, "base_z": 7.0, "roof_x": 10.0, "roof_y": 0.8, "roof_z": 8.0}
				]
			}
		"Central":
			return {
				"display_name": "Central",
				"tracks": 2,
				"layout": "side",
				"length": 150.0,
				"width": 27.0,
				"platform_width": 6.0
			}
		"Kendall":
			return {
				"display_name": "Kendall",
				"tracks": 2,
				"layout": "side",
				"length": 146.0,
				"width": 27.0,
				"platform_width": 6.0
			}
		"Charles":
			return {
				"display_name": "Charles",
				"tracks": 2,
				"layout": "side",
				"length": 144.0,
				"width": 28.0,
				"platform_width": 5.8
			}
		"Park Street Under":
			return {
				"display_name": "Park Street Under",
				"tracks": 2,
				"layout": "custom",
				"length": 176.0,
				"width": 28.0,
				"platform_width": 7.2,
				"track_offsets": [-4.0, 4.0],
				"platforms": [
					{"offset": 0.0, "width": 7.2, "length": 162.0}
				],
				"column_offsets": [-9.6, 0.0, 9.6],
				"column_height": 4.8
			}
		"Washington":
			return {
				"display_name": "Washington",
				"tracks": 2,
				"layout": "custom",
				"length": 156.0,
				"width": 30.0,
				"platform_width": 6.8,
				"track_offsets": [-4.0, 4.0],
				"platforms": [
					{"offset": 0.0, "width": 6.8, "length": 144.0}
				],
				"column_offsets": [-10.2, 0.0, 10.2],
				"column_height": 4.8
			}
		"South Station Under":
			return {
				"display_name": "South Station Under",
				"tracks": 2,
				"layout": "custom",
				"length": 168.0,
				"width": 30.0,
				"platform_width": 7.0,
				"track_offsets": [-4.1, 4.1],
				"platforms": [
					{"offset": 0.0, "width": 7.0, "length": 156.0}
				],
				"column_offsets": [-10.4, 0.0, 10.4],
				"column_height": 4.8
			}
		"Broadway":
			return {
				"display_name": "Broadway",
				"tracks": 2,
				"layout": "custom",
				"length": 152.0,
				"width": 29.0,
				"platform_width": 6.8,
				"track_offsets": [-4.0, 4.0],
				"platforms": [
					{"offset": 0.0, "width": 6.8, "length": 140.0}
				],
				"column_offsets": [-9.8, 0.0, 9.8],
				"column_height": 4.7
			}
		"Andrew":
			return {
				"display_name": "Andrew",
				"tracks": 2,
				"layout": "custom",
				"length": 154.0,
				"width": 29.0,
				"platform_width": 6.8,
				"track_offsets": [-4.0, 4.0],
				"platforms": [
					{"offset": 0.0, "width": 6.8, "length": 142.0}
				],
				"column_offsets": [-9.8, 0.0, 9.8],
				"column_height": 4.7
			}
		"Columbia":
			return {
				"display_name": "Columbia",
				"tracks": 2,
				"layout": "side",
				"length": 146.0,
				"width": 28.0,
				"platform_width": 6.0
			}
		"Savin Hill":
			return {
				"display_name": "Savin Hill",
				"tracks": 2,
				"layout": "side",
				"length": 142.0,
				"width": 27.0,
				"platform_width": 5.8
			}
		"Fields Corner":
			return {
				"display_name": "Fields Corner",
				"tracks": 2,
				"layout": "side",
				"length": 148.0,
				"width": 27.0,
				"platform_width": 5.8
			}
		"Shawmut":
			return {
				"display_name": "Shawmut",
				"tracks": 2,
				"layout": "side",
				"length": 138.0,
				"width": 26.0,
				"platform_width": 5.6
			}
		"Ashmont":
			return {
				"display_name": "Ashmont",
				"tracks": 2,
				"layout": "side",
				"length": 154.0,
				"width": 28.0,
				"platform_width": 6.0,
				"headhouses": [
					{"forward_offset": 10.0, "base_x": 8.0, "base_y": 4.4, "base_z": 6.6, "roof_x": 9.2, "roof_y": 0.8, "roof_z": 7.8}
				]
			}
	return {"tracks": 2, "layout": "side", "length": 140.0, "width": 22.0, "platform_width": 6.0, "mezzanine_length": 72.0}

func _add_station_mezzanines(parent: Node3D, center: Vector3, forward: Vector3, right: Vector3, width: float, mezzanine_length: float, spec: Dictionary) -> void:
	var mezzanines: Array = spec.get("mezzanines", [])
	if mezzanines.is_empty():
		_add_box(parent, Vector3(width * 0.72, 0.45, mezzanine_length), center + Vector3(0.0, 2.2, 0.0), forward, Color("b7ad98"))
		_add_box(parent, Vector3(width * 0.42, 0.2, mezzanine_length * 0.84), center + Vector3(0.0, 1.92, 0.0), forward, Color("7e7468"))
		return
	for entry_variant in mezzanines:
		var entry: Dictionary = entry_variant
		var deck_width := float(entry.get("width", width * 0.72))
		var deck_height := float(entry.get("height", 0.45))
		var deck_length := float(entry.get("length", mezzanine_length))
		var right_offset := float(entry.get("right_offset", 0.0))
		var forward_offset := float(entry.get("forward_offset", 0.0))
		var up_offset := float(entry.get("up_offset", 2.2))
		var orient := right if bool(entry.get("orient_right", false)) else forward
		var deck_center := center + right * right_offset + forward * forward_offset + Vector3(0.0, up_offset, 0.0)
		_add_box(parent, Vector3(deck_width, deck_height, deck_length), deck_center, orient, Color(String(entry.get("color", "b7ad98"))))
		if bool(entry.get("add_cap", true)):
			var cap_width := float(entry.get("cap_width", deck_width * 0.62))
			var cap_height := float(entry.get("cap_height", 0.2))
			var cap_length := float(entry.get("cap_length", deck_length * float(entry.get("cap_scale", 0.84))))
			var cap_up_offset := float(entry.get("cap_up_offset", up_offset - 0.28))
			var cap_center := center + right * right_offset + forward * forward_offset + Vector3(0.0, cap_up_offset, 0.0)
			_add_box(parent, Vector3(cap_width, cap_height, cap_length), cap_center, orient, Color(String(entry.get("cap_color", "7e7468"))))

func _track_offsets_for_spec(spec: Dictionary, tracks: int) -> Array[float]:
	var offsets: Array[float] = []
	var raw_offsets = spec.get("track_offsets", [])
	if raw_offsets is Array and not raw_offsets.is_empty():
		for value in raw_offsets:
			offsets.append(float(value))
		return offsets
	return _track_offsets(tracks)

func _station_track_half_extent(spec: Dictionary, tracks: int) -> float:
	var half_extent := 0.0
	for offset in _track_offsets_for_spec(spec, tracks):
		half_extent = maxf(half_extent, absf(offset) + 1.45)
	return half_extent

func _resolved_station_width(spec: Dictionary, requested_width: float, tracks: int) -> float:
	var wall_clearance := 2.0
	var required_half_width := _station_track_half_extent(spec, tracks) + wall_clearance + subway_wall_thickness
	return maxf(requested_width, required_half_width * 2.0)

func _station_portal_opening_width(width: float, spec: Dictionary, tracks: int) -> float:
	var portal_clearance := 1.25
	var minimum_opening := _station_track_half_extent(spec, tracks) * 2.0 + portal_clearance * 2.0
	var maximum_opening := maxf(8.0, width - (subway_wall_thickness + 0.35) * 2.0)
	return clampf(maxf(8.0, minimum_opening), 8.0, maximum_opening)

func run_station_clearance_smoke_test() -> Dictionary:
	var checked := 0
	var failures: Array[String] = []
	var seen: Dictionary = {}
	var station_lists: Array = [
		subway_station_names,
		north_subway_station_names,
		washington_street_station_names,
		cambridge_dorchester_station_names,
		blue_line_station_names
	]
	for list_variant in station_lists:
		var station_list: PackedStringArray = list_variant
		for station_name in station_list:
			if seen.has(station_name):
				continue
			seen[station_name] = true
			var spec := _station_spec(station_name)
			var tracks := int(spec.get("tracks", 2))
			var requested_width := float(spec.get("width", 22.0))
			var resolved_width := _resolved_station_width(spec, requested_width, tracks)
			var track_half_extent := _station_track_half_extent(spec, tracks)
			var wall_clearance := resolved_width * 0.5 - subway_wall_thickness - track_half_extent
			var portal_clearance := _station_portal_opening_width(resolved_width, spec, tracks) * 0.5 - track_half_extent
			checked += 1
			if wall_clearance < 2.0 or portal_clearance < 1.25:
				failures.append("%s failed clearance smoke test (wall %.2fm, portal %.2fm)." % [station_name, wall_clearance, portal_clearance])
	return {
		"ok": failures.is_empty(),
		"checked": checked,
		"failures": failures
	}

func _add_station_platforms(parent: Node3D, center: Vector3, forward: Vector3, right: Vector3, width: float, length: float, platform_width: float, spec: Dictionary, layout: String, style_id: String = "tremont") -> void:
	var theme := _corridor_theme(style_id)
	var platform_material := _ensure_period_material(String(theme.get("platform_material", "tile")))
	var line_color: Color = theme.get("line_color", Color("2d8f45"))
	var edge_color := line_color.lightened(0.28)
	var platform_defs: Array = spec.get("platforms", [])
	if not platform_defs.is_empty():
		for entry_variant in platform_defs:
			var entry: Dictionary = entry_variant
			var plat_width := float(entry.get("width", platform_width))
			var plat_length := float(entry.get("length", length))
			var edge_inset := float(entry.get("edge_inset", plat_width * 0.4))
			var right_offset := float(entry.get("offset", 0.0))
			var forward_offset := float(entry.get("forward_offset", 0.0))
			var orient := right if bool(entry.get("orient_right", false)) else forward
			var deck_center := center + right * right_offset + forward * forward_offset + Vector3(0.0, -1.35, 0.0)
			_add_box(parent, Vector3(plat_width, 0.7, plat_length), deck_center, orient, Color("d6c8a9"))
			_add_box_with_material(parent, Vector3(plat_width - 0.18, 0.08, plat_length - 0.4), deck_center + Vector3(0.0, 0.34, 0.0), orient, platform_material)
			if bool(entry.get("edge_left", true)):
				_add_box(parent, Vector3(0.45, 0.14, plat_length), center + right * (right_offset - edge_inset) + forward * forward_offset + Vector3(0.0, -0.88, 0.0), orient, edge_color)
			if bool(entry.get("edge_right", true)):
				_add_box(parent, Vector3(0.45, 0.14, plat_length), center + right * (right_offset + edge_inset) + forward * forward_offset + Vector3(0.0, -0.88, 0.0), orient, edge_color)
			_add_platform_canopy(parent, deck_center, orient, plat_width, plat_length, style_id)
			_add_platform_furniture(parent, deck_center, orient, plat_width, plat_length)
		_add_station_columns_from_spec(parent, center, forward, right, length, width, layout, spec)
		return

	match layout:
		"dual_island":
			for island_offset in [-5.2, 5.2]:
				var deck_center: Vector3 = center + right * island_offset + Vector3(0.0, -1.35, 0.0)
				_add_box(parent, Vector3(platform_width, 0.7, length), deck_center, forward, Color("d6c8a9"))
				_add_box_with_material(parent, Vector3(platform_width - 0.18, 0.08, length - 0.4), deck_center + Vector3(0.0, 0.34, 0.0), forward, platform_material)
				_add_box(parent, Vector3(0.45, 0.14, length), center + right * (island_offset - platform_width * 0.4) + Vector3(0.0, -0.88, 0.0), forward, edge_color)
				_add_box(parent, Vector3(0.45, 0.14, length), center + right * (island_offset + platform_width * 0.4) + Vector3(0.0, -0.88, 0.0), forward, edge_color)
				_add_platform_canopy(parent, deck_center, forward, platform_width, length, style_id)
				_add_platform_furniture(parent, deck_center, forward, platform_width, length)
		"split_side":
			var stagger: float = float(spec.get("stagger", 18.0))
			var left_offset := width * 0.5 - platform_width * 0.5 - 1.8
			var left_center: Vector3 = center - right * left_offset - forward * stagger + Vector3(0.0, -1.35, 0.0)
			var right_center: Vector3 = center + right * left_offset + forward * stagger + Vector3(0.0, -1.35, 0.0)
			_add_box(parent, Vector3(platform_width, 0.7, length * 0.82), left_center, forward, Color("d6c8a9"))
			_add_box(parent, Vector3(platform_width, 0.7, length * 0.82), right_center, forward, Color("d6c8a9"))
			_add_box_with_material(parent, Vector3(platform_width - 0.18, 0.08, length * 0.82 - 0.4), left_center + Vector3(0.0, 0.34, 0.0), forward, platform_material)
			_add_box_with_material(parent, Vector3(platform_width - 0.18, 0.08, length * 0.82 - 0.4), right_center + Vector3(0.0, 0.34, 0.0), forward, platform_material)
			_add_box(parent, Vector3(0.45, 0.14, length * 0.82), center - right * (left_offset - platform_width * 0.4) - forward * stagger + Vector3(0.0, -0.88, 0.0), forward, edge_color)
			_add_box(parent, Vector3(0.45, 0.14, length * 0.82), center + right * (left_offset - platform_width * 0.4) + forward * stagger + Vector3(0.0, -0.88, 0.0), forward, edge_color)
			_add_platform_canopy(parent, left_center, forward, platform_width, length * 0.82, style_id)
			_add_platform_canopy(parent, right_center, forward, platform_width, length * 0.82, style_id)
			_add_platform_furniture(parent, left_center, forward, platform_width, length * 0.82)
			_add_platform_furniture(parent, right_center, forward, platform_width, length * 0.82)
		_:
			var side_offset := width * 0.5 - platform_width * 0.5 - 1.8
			var left_platform_center: Vector3 = center - right * side_offset + Vector3(0.0, -1.35, 0.0)
			var right_platform_center: Vector3 = center + right * side_offset + Vector3(0.0, -1.35, 0.0)
			_add_box(parent, Vector3(platform_width, 0.7, length), left_platform_center, forward, Color("d6c8a9"))
			_add_box(parent, Vector3(platform_width, 0.7, length), right_platform_center, forward, Color("d6c8a9"))
			_add_box_with_material(parent, Vector3(platform_width - 0.18, 0.08, length - 0.4), left_platform_center + Vector3(0.0, 0.34, 0.0), forward, platform_material)
			_add_box_with_material(parent, Vector3(platform_width - 0.18, 0.08, length - 0.4), right_platform_center + Vector3(0.0, 0.34, 0.0), forward, platform_material)
			_add_box(parent, Vector3(0.45, 0.14, length), center - right * (side_offset - platform_width * 0.4) + Vector3(0.0, -0.88, 0.0), forward, edge_color)
			_add_box(parent, Vector3(0.45, 0.14, length), center + right * (side_offset - platform_width * 0.4) + Vector3(0.0, -0.88, 0.0), forward, edge_color)
			_add_platform_canopy(parent, left_platform_center, forward, platform_width, length, style_id)
			_add_platform_canopy(parent, right_platform_center, forward, platform_width, length, style_id)
			_add_platform_furniture(parent, left_platform_center, forward, platform_width, length)
			_add_platform_furniture(parent, right_platform_center, forward, platform_width, length)

	_add_station_columns_from_spec(parent, center, forward, right, length, width, layout, spec)

func _add_station_columns_from_spec(parent: Node3D, center: Vector3, forward: Vector3, right: Vector3, length: float, width: float, layout: String, spec: Dictionary) -> void:
	var column_offsets: Array[float] = []
	var raw_offsets = spec.get("column_offsets", [])
	if raw_offsets is Array:
		for value in raw_offsets:
			column_offsets.append(float(value))
	var column_length := length * float(spec.get("column_length_scale", 1.0))
	var column_height := float(spec.get("column_height", 4.8))
	if column_offsets.is_empty():
		match layout:
			"dual_island":
				column_offsets = [-11.4, -5.2, 5.2, 11.4]
				if not spec.has("column_height"):
					column_height = 4.6
			"split_side":
				column_offsets = [-width * 0.28, width * 0.28]
				if not spec.has("column_length_scale"):
					column_length = length * 0.78
			_:
				column_offsets = [-width * 0.26, width * 0.26]
	_add_station_columns(parent, center + forward * float(spec.get("column_forward_offset", 0.0)), forward, right, column_length, column_offsets, column_height)

func _add_station_extra_boxes(parent: Node3D, center: Vector3, forward: Vector3, right: Vector3, spec: Dictionary) -> void:
	var boxes: Array = spec.get("extra_boxes", [])
	for entry_variant in boxes:
		var entry: Dictionary = entry_variant
		var size := Vector3(float(entry.get("size_x", 1.0)), float(entry.get("size_y", 1.0)), float(entry.get("size_z", 1.0)))
		var orient := right if bool(entry.get("orient_right", false)) else forward
		var yaw_deg := float(entry.get("yaw_deg", 0.0))
		if absf(yaw_deg) > 0.01:
			orient = orient.rotated(Vector3.UP, deg_to_rad(yaw_deg)).normalized()
		var pos := center + right * float(entry.get("right_offset", 0.0)) + forward * float(entry.get("forward_offset", 0.0)) + Vector3(0.0, float(entry.get("up_offset", 0.0)), 0.0)
		var is_junction_wall := absf(yaw_deg) >= 8.0 and size.y >= subway_tunnel_height * 0.55 and size.x <= 1.5 and size.z >= 18.0
		if is_junction_wall:
			pos = _push_box_outward_from_center(center, pos, orient, subway_junction_wall_push)
			size.z = maxf(8.0, size.z - subway_segment_end_open_length)
		_add_box(parent, size, pos, orient, Color(String(entry.get("color", "b8ae99"))))

func _add_station_surface_boxes(parent: Node3D, station_center: Vector3, forward: Vector3, right: Vector3, spec: Dictionary, style_id: String = "tremont") -> void:
	var above := station_center - Vector3(0.0, subway_depth, 0.0)
	var theme := _corridor_theme(style_id)
	var surface_material := _ensure_period_material(String(theme.get("surface_material", "cobble")))
	var boxes: Array = spec.get("surface_boxes", [])
	for entry_variant in boxes:
		var entry: Dictionary = entry_variant
		var size := Vector3(float(entry.get("size_x", 1.0)), float(entry.get("size_y", 1.0)), float(entry.get("size_z", 1.0)))
		var orient := right if bool(entry.get("orient_right", false)) else forward
		var pos := above + right * float(entry.get("right_offset", 0.0)) + forward * float(entry.get("forward_offset", 0.0)) + Vector3(0.0, float(entry.get("up_offset", size.y * 0.5)), 0.0)
		_add_box_with_material(parent, size, pos, orient, surface_material)

func _add_platform_canopy(parent: Node3D, deck_center: Vector3, orient: Vector3, plat_width: float, plat_length: float, style_id: String = "tremont") -> void:
	var theme := _corridor_theme(style_id)
	var steel_color: Color = theme.get("steel_color", Color("5b544b"))
	var roof_material := _ensure_period_material(String(theme.get("roof_material", "steel_dark")), steel_color)
	var canopy_center := deck_center + Vector3(0.0, subway_platform_canopy_height, 0.0)
	var canopy_width := minf(subway_platform_canopy_width, plat_width * 0.88)
	_add_box_with_material(parent, Vector3(canopy_width, 0.16, plat_length * 0.86), canopy_center, orient, _ensure_period_material("tile"))
	_add_box_with_material(parent, Vector3(canopy_width * 0.88, 0.12, plat_length * 0.82), canopy_center + Vector3(0.0, 0.18, 0.0), orient, roof_material)
	var cross := Vector3(-orient.z, 0.0, orient.x).normalized()
	var post_count := maxi(2, int(round(plat_length / 42.0)))
	for i in range(post_count):
		var t := 0.0 if post_count <= 1 else float(i) / float(post_count - 1)
		var longitudinal := -plat_length * 0.33 + plat_length * 0.66 * t
		for side in [-1.0, 1.0]:
			var post_pos: Vector3 = deck_center + orient * longitudinal + cross * side * (canopy_width * 0.34) + Vector3(0.0, 0.62, 0.0)
			_add_box_with_material(parent, Vector3(0.18, subway_platform_canopy_height + 0.05, 0.18), post_pos, orient, roof_material)

func _add_platform_furniture(parent: Node3D, deck_center: Vector3, orient: Vector3, plat_width: float, plat_length: float) -> void:
	var bench_span := minf(subway_bench_length, plat_length * 0.2)
	for longitudinal in [-plat_length * 0.22, plat_length * 0.22]:
		_add_box(parent, Vector3(1.2, 0.45, bench_span), deck_center + orient * longitudinal + Vector3(0.0, -0.84, 0.0), orient, Color("6c543d"))
		_add_box(parent, Vector3(0.9, 0.2, bench_span), deck_center + orient * longitudinal + Vector3(0.0, -0.56, 0.0), orient, Color("8f734d"))
	var kiosk_depth := minf(6.0, plat_length * 0.08)
	_add_box(parent, Vector3(maxf(1.2, plat_width * 0.22), 2.0, kiosk_depth), deck_center + orient * (plat_length * 0.32) + Vector3(0.0, -0.35, 0.0), orient, Color("8d7a61"))
	_add_box(parent, Vector3(maxf(0.9, plat_width * 0.18), 0.16, kiosk_depth * 0.84), deck_center + orient * (plat_length * 0.32) + Vector3(0.0, 0.78, 0.0), orient, Color("d8ccb4"))

func _add_station_name_boards(parent: Node3D, center: Vector3, forward: Vector3, right: Vector3, width: float, length: float, station_name: String, style_id: String = "tremont") -> void:
	var theme := _corridor_theme(style_id)
	var sign_bg: Color = theme.get("sign_bg", Color("efe4c3"))
	var sign_material := _ensure_period_material("tile", sign_bg)
	var line_color: Color = theme.get("line_color", Color("2d8f45"))
	var sign_text_color: Color = theme.get("sign_text", Color("231b14"))
	var display_name := _station_display_name(station_name)
	for side in [-1.0, 1.0]:
		for longitudinal in [-length * 0.22, length * 0.22]:
			var board_pos: Vector3 = center + right * side * (width * 0.5 - 0.42) + forward * longitudinal + Vector3(0.0, 0.42, 0.0)
			_add_box_with_material(parent, Vector3(0.12, 1.0, 8.5), board_pos, forward, sign_material)
			_add_box(parent, Vector3(0.14, 0.12, 8.3), board_pos + Vector3(0.0, 0.38, 0.0), forward, line_color)
			_add_box(parent, Vector3(0.14, 0.12, 8.3), board_pos + Vector3(0.0, -0.38, 0.0), forward, line_color)
			var label := Label3D.new()
			label.text = display_name
			label.font_size = 22
			label.modulate = sign_text_color
			label.position = board_pos + right * side * -0.08
			label.rotation = Vector3(0.0, -PI * 0.5 * side, 0.0)
			parent.add_child(label)

func _add_station_wall_finish(parent: Node3D, center: Vector3, forward: Vector3, right: Vector3, width: float, length: float, style_id: String = "tremont") -> void:
	var theme := _corridor_theme(style_id)
	var wall_material := _ensure_period_material(String(theme.get("wall_material", "plaster")))
	var sign_bg: Color = theme.get("sign_bg", Color("efe4c3"))
	var tile_material := _ensure_period_material(String(theme.get("tile_material", "tile")), sign_bg)
	var trim_color: Color = theme.get("trim_color", Color("6c5845"))
	for side in [-1.0, 1.0]:
		_add_box_with_material(parent, Vector3(0.12, 4.3, length - 0.8), center + right * side * (width * 0.5 - subway_wall_thickness - 0.08) + Vector3(0.0, -0.05, 0.0), forward, wall_material)
		_add_box_with_material(parent, Vector3(0.18, subway_tile_band_height, length), center + right * side * (width * 0.5 - subway_wall_thickness - 0.11) + Vector3(0.0, 0.05, 0.0), forward, tile_material)
		_add_box(parent, Vector3(0.22, 0.18, length), center + right * side * (width * 0.5 - subway_wall_thickness - 0.14) + Vector3(0.0, 1.24, 0.0), forward, trim_color)
		_add_box(parent, Vector3(0.22, 0.18, length), center + right * side * (width * 0.5 - subway_wall_thickness - 0.14) + Vector3(0.0, -0.92, 0.0), forward, trim_color)
	var bay_count := maxi(2, int(round(length / 34.0)))
	for i in range(bay_count):
		var t := float(i + 1) / float(bay_count + 1)
		var pier_center := center - forward * (length * 0.5) + forward * (length * t)
		for side in [-1.0, 1.0]:
			_add_box_with_material(parent, Vector3(0.42, 4.4, 0.58), pier_center + right * side * (width * 0.5 - subway_wall_thickness - 0.32) + Vector3(0.0, 0.02, 0.0), forward, tile_material)

func _add_tunnel_ceiling_layers(parent: Node3D, center: Vector3, forward: Vector3, right: Vector3, inner_width: float, length: float, roof_offset_y: float, twin_bore_hint: bool) -> void:
	_add_box(parent, Vector3(inner_width, 0.18, length), center + Vector3(0.0, roof_offset_y - 0.08, 0.0), forward, Color("756e65"))
	_add_box(parent, Vector3(inner_width * 0.78, 0.16, length), center + Vector3(0.0, roof_offset_y - 0.48, 0.0), forward, Color("847b70"))
	if twin_bore_hint:
		for side in [-1.0, 1.0]:
			_add_box(parent, Vector3(inner_width * 0.42, 0.16, length), center + right * side * (inner_width * 0.24) + Vector3(0.0, roof_offset_y - 0.82, 0.0), forward, Color("8c8377"))
	else:
		_add_box(parent, Vector3(inner_width * 0.54, 0.14, length), center + Vector3(0.0, roof_offset_y - 0.92, 0.0), forward, Color("8c8377"))

func _add_tunnel_track_details(parent: Node3D, center: Vector3, forward: Vector3, right: Vector3, track_offsets: Array[float], length: float) -> void:
	for offset in track_offsets:
		var wire_y := subway_wire_height
		_add_box(parent, Vector3(0.08, 0.08, length), center + right * offset + Vector3(0.0, wire_y, 0.0), forward, Color("2a2622"))
		var hanger_count := maxi(2, int(round(length / 24.0)))
		for i in range(hanger_count):
			var t := float(i + 1) / float(hanger_count + 1)
			var hanger_pos := center - forward * (length * 0.5) + forward * (length * t) + right * offset + Vector3(0.0, wire_y + 0.42, 0.0)
			_add_box(parent, Vector3(0.06, 0.84, 0.06), hanger_pos, forward, Color("3c352f"))
		_add_rail_box(parent, Vector3(0.26, 0.12, length), center + right * offset + Vector3(0.0, -1.62, 0.0), forward)
	var drain_count := maxi(2, int(round(length / 22.0)))
	for i in range(drain_count):
		var t := float(i + 1) / float(drain_count + 1)
		var drain_pos := center - forward * (length * 0.5) + forward * (length * t) + Vector3(0.0, -1.98, 0.0)
		_add_box(parent, Vector3(0.44, 0.08, 0.9), drain_pos, forward, Color("696159"))

func _track_offsets(tracks: int) -> Array[float]:
	if tracks >= 4:
		return [-9.0, -3.0, 3.0, 9.0]
	return [-2.9, 2.9]

func _station_forward(points: PackedVector3Array, idx: int) -> Vector3:
	var prev_idx := maxi(0, idx - 1)
	var next_idx := mini(points.size() - 1, idx + 1)
	var forward := (points[next_idx] - points[prev_idx]).normalized()
	if forward.length() < 0.01:
		return Vector3.RIGHT
	return forward

func _average_points(points: PackedVector3Array) -> Vector3:
	var sum := Vector3.ZERO
	for point in points:
		sum += point
	return sum / float(points.size())

func _segment_end_open_length(length: float, is_junction: bool) -> float:
	var desired := subway_segment_end_open_length
	if is_junction:
		desired += subway_junction_extra_open_length
	return minf(desired, maxf(0.0, length * 0.35))

func _trimmed_segment_span(center: Vector3, forward: Vector3, length: float, start_open: float, end_open: float) -> Dictionary:
	var clamped_start := clampf(start_open, 0.0, maxf(0.0, length - 2.0))
	var clamped_end := clampf(end_open, 0.0, maxf(0.0, length - clamped_start - 2.0))
	var span_length := maxf(2.0, length - clamped_start - clamped_end)
	var span_center := center + forward * ((clamped_start - clamped_end) * 0.5)
	return {
		"center": span_center,
		"length": span_length
	}

func _station_has_junction_geometry(spec: Dictionary) -> bool:
	if bool(spec.get("spur", false)) or bool(spec.get("corridor", false)):
		return true
	if int(spec.get("tracks", 2)) >= 4:
		return true
	var boxes: Array = spec.get("extra_boxes", [])
	for entry_variant in boxes:
		var entry: Dictionary = entry_variant
		if absf(float(entry.get("yaw_deg", 0.0))) >= 8.0:
			return true
	return false

func _station_display_name(station_name: String) -> String:
	var spec := _station_spec(station_name)
	return String(spec.get("display_name", station_name))

func _corridor_theme(style_id: String) -> Dictionary:
	match style_id:
		"washington":
			return {
				"line_color": Color("c86d2c"),
				"sign_bg": Color("eee2c5"),
				"sign_text": Color("30251d"),
				"surface_material": "cobble",
				"wall_material": "plaster",
				"tile_material": "tile",
				"platform_material": "tile",
				"headhouse_material": "brick",
				"roof_material": "steel_dark",
				"trim_color": Color("5c4838"),
				"steel_color": Color("61574d")
			}
		"cambridge":
			return {
				"line_color": Color("b32033"),
				"sign_bg": Color("f0e6d4"),
				"sign_text": Color("281f19"),
				"surface_material": "asphalt",
				"wall_material": "plaster",
				"tile_material": "tile",
				"platform_material": "tile",
				"headhouse_material": "brick",
				"roof_material": "steel_dark",
				"trim_color": Color("7a2d2a"),
				"steel_color": Color("686058")
			}
		"blue":
			return {
				"line_color": Color("3a7dbf"),
				"sign_bg": Color("edf1f6"),
				"sign_text": Color("1f2833"),
				"surface_material": "asphalt",
				"wall_material": "plaster",
				"tile_material": "tile",
				"platform_material": "tile",
				"headhouse_material": "brick",
				"roof_material": "steel_dark",
				"trim_color": Color("38618c"),
				"steel_color": Color("5c646c")
			}
		"mattapan":
			return {
				"line_color": Color("d04b41"),
				"sign_bg": Color("f3ead8"),
				"sign_text": Color("2b2019"),
				"surface_material": "asphalt",
				"wall_material": "plaster",
				"tile_material": "tile",
				"platform_material": "timber",
				"headhouse_material": "brick",
				"roof_material": "steel_dark",
				"trim_color": Color("7f3b2f"),
				"steel_color": Color("5d554c")
			}
		"atlantic_elevated":
			return {
				"line_color": Color("d96a16"),
				"sign_bg": Color("1e1b18"),
				"sign_text": Color("f0a44f"),
				"surface_material": "timber",
				"wall_material": "steel_dark",
				"tile_material": "timber",
				"platform_material": "timber",
				"headhouse_material": "brick",
				"roof_material": "steel_dark",
				"trim_color": Color("d96a16"),
				"steel_color": Color("1f1d1a")
			}
		_:
			return {
				"line_color": Color("2d8f45"),
				"sign_bg": Color("efe4c3"),
				"sign_text": Color("231b14"),
				"surface_material": "cobble",
				"wall_material": "plaster",
				"tile_material": "tile",
				"platform_material": "tile",
				"headhouse_material": "brick",
				"roof_material": "steel_dark",
				"trim_color": Color("5f4c3b"),
				"steel_color": Color("5b544b")
			}

func _ensure_period_material(material_key: String, tint: Color = Color.WHITE) -> StandardMaterial3D:
	var cache_key := "%s_%d_%d_%d_%d" % [
		material_key,
		int(round(tint.r * 255.0)),
		int(round(tint.g * 255.0)),
		int(round(tint.b * 255.0)),
		int(round(tint.a * 255.0))
	]
	if _pbr_material_cache.has(cache_key):
		return _pbr_material_cache[cache_key]
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tint
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	match material_key:
		"brick":
			mat.albedo_texture = _load_runtime_texture(BrickAlbedoPath)
			mat.roughness_texture = _load_runtime_texture(BrickRoughnessPath)
			mat.normal_texture = _load_runtime_texture(BrickNormalPath)
			mat.roughness = 0.95
		"plaster":
			mat.albedo_texture = _load_runtime_texture(PlasterAlbedoPath)
			mat.roughness_texture = _load_runtime_texture(PlasterRoughnessPath)
			mat.normal_texture = _load_runtime_texture(PlasterNormalPath)
			mat.roughness = 0.9
		"tile":
			mat.albedo_texture = _load_runtime_texture(TileAlbedoPath)
			mat.roughness_texture = _load_runtime_texture(TileRoughnessPath)
			mat.normal_texture = _load_runtime_texture(TileNormalPath)
			mat.roughness = 0.8
		"cobble":
			mat.albedo_texture = _load_runtime_texture(CobbleAlbedoPath)
			mat.roughness_texture = _load_runtime_texture(CobbleRoughnessPath)
			mat.normal_texture = _load_runtime_texture(CobbleNormalPath)
			mat.roughness = 1.0
		"asphalt":
			mat.albedo_texture = _load_runtime_texture(AsphaltAlbedoPath)
			mat.roughness_texture = _load_runtime_texture(AsphaltRoughnessPath)
			mat.normal_texture = _load_runtime_texture(AsphaltNormalPath)
			mat.roughness = 1.0
		"timber":
			mat.albedo_texture = _load_runtime_texture(SleeperAlbedoPath)
			mat.roughness_texture = _load_runtime_texture(SleeperRoughnessPath)
			mat.roughness = 0.95
		"steel_dark":
			mat.albedo_texture = _load_runtime_texture(RailAlbedoPath)
			mat.roughness_texture = _load_runtime_texture(RailRoughnessPath)
			mat.roughness = 0.32
			mat.metallic = 0.82
		_:
			mat.roughness = 0.85
	_pbr_material_cache[cache_key] = mat
	return mat

func _add_box_with_material(parent: Node3D, size: Vector3, position: Vector3, forward: Vector3, material: Material) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.set_surface_override_material(0, material)
	_add_box_instance(parent, instance, position, forward)

func _push_box_outward_from_center(center: Vector3, position: Vector3, forward: Vector3, amount: float) -> Vector3:
	var cross := Vector3(-forward.z, 0.0, forward.x).normalized()
	if cross.length() < 0.01:
		return position
	if cross.dot(position - center) < 0.0:
		cross = -cross
	return position + cross * amount

func _add_tunnel_shell(parent: Node3D, center: Vector3, forward: Vector3, right: Vector3, width: float, length: float, tracks: int, include_center_divider: bool = true, style_id: String = "tremont") -> void:
	var clear_height := subway_tunnel_height
	var floor_y := center.y - 2.25
	var roof_y := floor_y + clear_height
	_add_cut_and_cover(parent, center, forward, right, width, length, roof_y, clear_height + 1.6)
	_add_box(parent, Vector3(width, subway_floor_thickness, length), Vector3(center.x, floor_y - subway_floor_thickness * 0.5, center.z), forward, Color("47433f"))
	_add_box(parent, Vector3(subway_wall_thickness, clear_height, length), center + right * (width * 0.5 - subway_wall_thickness * 0.5) + Vector3(0.0, floor_y + clear_height * 0.5 - center.y, 0.0), forward, Color("7f786f"))
	_add_box(parent, Vector3(subway_wall_thickness, clear_height, length), center - right * (width * 0.5 - subway_wall_thickness * 0.5) + Vector3(0.0, floor_y + clear_height * 0.5 - center.y, 0.0), forward, Color("7f786f"))
	_add_box(parent, Vector3(width, subway_roof_thickness, length), Vector3(center.x, roof_y + subway_roof_thickness * 0.5, center.z), forward, Color("5f5a54"))
	var inner_width := width - subway_wall_thickness * 2.0
	_add_tunnel_ceiling_layers(parent, center, forward, right, inner_width, length, roof_y - center.y, tracks <= 2)
	_add_box(parent, Vector3(inner_width, 0.18, length), center + Vector3(0.0, roof_y - center.y - 0.42, 0.0), forward, Color("6f6860"))
	for side in [-1.0, 1.0]:
		_add_box(parent, Vector3(subway_service_walkway_width, 0.18, length), center + right * side * (width * 0.5 - subway_wall_thickness - subway_service_walkway_width * 0.5) + Vector3(0.0, -1.4, 0.0), forward, Color("686157"))
		_add_box(parent, Vector3(0.45, 0.62, length), center + right * side * (width * 0.5 - subway_wall_thickness - subway_service_walkway_width - 0.24) + Vector3(0.0, -1.03, 0.0), forward, Color("5f584f"))
		_add_box(parent, Vector3(0.24, 0.24, length), center + right * side * (width * 0.5 - subway_wall_thickness - 0.32) + Vector3(0.0, 1.45, 0.0), forward, Color("82796f"))
	var rib_count := maxi(1, int(round(length / subway_ring_spacing)))
	for i in range(rib_count):
		var t := float(i + 1) / float(rib_count + 1)
		var rib_center := center - forward * (length * 0.5) + forward * (length * t)
		_add_box(parent, Vector3(width - 0.8, 0.22, 0.85), rib_center + Vector3(0.0, roof_y - center.y - 0.2, 0.0), forward, Color("6e665d"))
	if include_center_divider and tracks >= 4:
		_add_box(parent, Vector3(0.75, clear_height - 0.6, length), center + Vector3(0.0, floor_y + (clear_height - 0.6) * 0.5 - center.y + 0.2, 0.0), forward, Color("6f6961"))
	elif include_center_divider and tracks == 2:
		_add_box(parent, Vector3(0.95, clear_height - 0.8, length), center + Vector3(0.0, floor_y + (clear_height - 0.8) * 0.5 - center.y + 0.12, 0.0), forward, Color("625a52"))
		_add_box(parent, Vector3(subway_bore_inner_width, 0.18, length), center + right * (width * 0.24) + Vector3(0.0, roof_y - center.y - 0.82, 0.0), forward, Color("756d63"))
		_add_box(parent, Vector3(subway_bore_inner_width, 0.18, length), center - right * (width * 0.24) + Vector3(0.0, roof_y - center.y - 0.82, 0.0), forward, Color("756d63"))
	var theme := _corridor_theme(style_id)
	var wall_material := _ensure_period_material(String(theme.get("wall_material", "plaster")))
	var trim_color: Color = theme.get("trim_color", Color("5f4c3b"))
	for side in [-1.0, 1.0]:
		_add_box_with_material(parent, Vector3(0.14, clear_height - 0.6, length - 0.8), center + right * side * (width * 0.5 - subway_wall_thickness - 0.07) + Vector3(0.0, 0.1, 0.0), forward, wall_material)
		_add_box(parent, Vector3(0.16, 0.14, length - 1.0), center + right * side * (width * 0.5 - subway_wall_thickness - 0.09) + Vector3(0.0, 1.26, 0.0), forward, trim_color)

func _add_station_shell(parent: Node3D, center: Vector3, forward: Vector3, right: Vector3, width: float, length: float, style_id: String = "tremont", _station_name: String = "") -> void:
	var clear_height := subway_tunnel_height + 1.0
	var floor_y := center.y - 2.35
	var roof_y := floor_y + clear_height
	_add_cut_and_cover(parent, center, forward, right, width, length, roof_y, clear_height + 2.2)
	_add_box(parent, Vector3(width, subway_floor_thickness, length), Vector3(center.x, floor_y - subway_floor_thickness * 0.5, center.z), forward, Color("504a44"))
	_add_box(parent, Vector3(subway_wall_thickness, clear_height, length), center + right * (width * 0.5 - subway_wall_thickness * 0.5) + Vector3(0.0, floor_y + clear_height * 0.5 - center.y, 0.0), forward, Color("91897d"))
	_add_box(parent, Vector3(subway_wall_thickness, clear_height, length), center - right * (width * 0.5 - subway_wall_thickness * 0.5) + Vector3(0.0, floor_y + clear_height * 0.5 - center.y, 0.0), forward, Color("91897d"))
	_add_box(parent, Vector3(width, subway_roof_thickness, length), Vector3(center.x, roof_y + subway_roof_thickness * 0.5, center.z), forward, Color("6e685f"))
	_add_tunnel_ceiling_layers(parent, center, forward, right, width - 1.4, length, roof_y - center.y - 0.16, false)
	_add_box(parent, Vector3(width - 1.4, 0.22, length), center + Vector3(0.0, roof_y - center.y - 0.58, 0.0), forward, Color("827b70"))
	_add_station_wall_finish(parent, center, forward, right, width, length, style_id)
	_add_station_end_portal(parent, center, forward, right, width, floor_y, clear_height, -(length * 0.5 - 0.5))
	_add_station_end_portal(parent, center, forward, right, width, floor_y, clear_height, length * 0.5 - 0.5)

func _add_station_end_portal(parent: Node3D, center: Vector3, forward: Vector3, right: Vector3, width: float, floor_y: float, clear_height: float, forward_offset: float) -> void:
	var opening_width := maxf(8.0, width - 4.4)
	var pier_width := maxf(subway_wall_thickness + 0.35, (width - opening_width) * 0.5)
	var lintel_height := 0.9
	var end_center := center + forward * forward_offset
	var wall_mid_y := floor_y + clear_height * 0.5 - center.y
	for side in [-1.0, 1.0]:
		var pier_center: Vector3 = end_center + right * side * (opening_width * 0.5 + pier_width * 0.5) + Vector3(0.0, wall_mid_y, 0.0)
		_add_box(parent, Vector3(pier_width, clear_height, 1.0), pier_center, forward, Color("837b70"))
	var lintel_center: Vector3 = end_center + Vector3(0.0, floor_y + clear_height - lintel_height * 0.5 - center.y, 0.0)
	_add_box(parent, Vector3(opening_width, lintel_height, 1.0), lintel_center, forward, Color("837b70"))

func _add_tunnel_lights(parent: Node3D, center: Vector3, forward: Vector3, length: float) -> void:
	var count := maxi(2, int(round(length / subway_light_spacing)))
	for i in range(count):
		var t := float(i + 1) / float(count + 1)
		var light := OmniLight3D.new()
		light.omni_range = 16.0
		light.light_energy = 0.22
		light.light_color = Color(1.0, 0.95, 0.86)
		light.position = center - forward * (length * 0.5) + forward * (length * t) + Vector3(0.0, 1.2, 0.0)
		parent.add_child(light)

func _add_station_lights(parent: Node3D, center: Vector3, forward: Vector3, right: Vector3, length: float, width: float) -> void:
	var count := maxi(3, int(round(length / 38.0)))
	for i in range(count):
		var t := float(i + 1) / float(count + 1)
		for lateral in [-width * 0.18, width * 0.18]:
			var anchor: Vector3 = center - forward * (length * 0.5) + forward * (length * t) + right * lateral
			_add_box(parent, Vector3(1.4, 0.12, 0.6), anchor + Vector3(0.0, 2.18, 0.0), forward, Color("d1c6ae"))
			var light := OmniLight3D.new()
			light.omni_range = 20.0
			light.light_energy = 0.35
			light.light_color = Color(1.0, 0.96, 0.9)
			light.position = anchor + Vector3(0.0, 1.8, 0.0)
			parent.add_child(light)

func _build_portal(parent: Node3D, surface_parent: Node3D, stop_points: PackedVector3Array) -> void:
	var station_indices := _subway_station_indices()
	if station_indices.is_empty():
		return
	var kenmore_idx := station_indices[station_indices.size() - 1]
	if kenmore_idx + 1 >= stop_points.size():
		return
	var kenmore := stop_points[kenmore_idx]
	var brookline := stop_points[kenmore_idx + 1]
	var forward := (brookline - kenmore).normalized()
	if forward.length() < 0.01:
		return
	var right := Vector3(-forward.z, 0.0, forward.x).normalized()
	var p1 := kenmore.lerp(brookline, portal_fraction_1) + Vector3(0.0, subway_depth, 0.0)
	var p2 := kenmore.lerp(brookline, portal_fraction_2) + Vector3(0.0, subway_depth * 0.55, 0.0)
	var p3 := kenmore.lerp(brookline, portal_fraction_3) + Vector3(0.0, subway_depth * 0.15, 0.0)
	var portal_surface := kenmore.lerp(brookline, min(0.84, portal_fraction_3 + 0.1))
	_add_surface_alignment(surface_parent, kenmore, portal_surface, 11.0, Color("7a6249"))
	var portal_root := _make_subway_section(parent, "PortalRamp")
	_add_portal_section(portal_root, _subway_track_point(kenmore), p1, 14.0, 5.8, true)
	_add_portal_section(portal_root, p1, p2, 14.0, 5.2, true)
	_add_portal_section(portal_root, p2, p3, 14.4, 4.4, false)
	_add_portal_section(portal_root, p3, portal_surface, 15.4, 3.6, false)
	_add_box(portal_root, Vector3(13.0, 5.6, 1.4), portal_surface + Vector3(0.0, 1.3, 0.0), forward, Color("8b8375"))
	_add_box(portal_root, Vector3(13.8, 0.7, 4.0), portal_surface - forward * 1.7 + Vector3(0.0, 3.8, 0.0), forward, Color("3d352e"))
	_add_box(portal_root, Vector3(20.0, 0.16, 18.0), portal_surface + forward * 2.0 + Vector3(0.0, 0.08, 0.0), forward, Color("8b7f6c"))
	for side in [-1.0, 1.0]:
		var lamp := OmniLight3D.new()
		lamp.omni_range = 18.0
		lamp.light_energy = 0.4
		lamp.light_color = Color(1.0, 0.95, 0.88)
		lamp.position = portal_surface + right * side * 5.2 + Vector3(0.0, 3.0, -1.2)
		portal_root.add_child(lamp)

func _build_causeway_portal(parent: Node3D, surface_parent: Node3D, haymarket_surface: Vector3, causeway_surface: Vector3) -> void:
	var forward := (causeway_surface - haymarket_surface).normalized()
	if forward.length() < 0.01:
		return
	var right := Vector3(-forward.z, 0.0, forward.x).normalized()
	var tunnel_start := _subway_track_point(haymarket_surface)
	var p1 := _portal_blend(haymarket_surface, causeway_surface, 0.24, subway_depth * 0.72)
	var p2 := _portal_blend(haymarket_surface, causeway_surface, 0.52, subway_depth * 0.18)
	var p3 := _portal_blend(haymarket_surface, causeway_surface, 0.78, elevated_deck_height * 0.42)
	var portal_top := causeway_surface + Vector3(0.0, elevated_deck_height, 0.0)
	_add_surface_alignment(surface_parent, haymarket_surface, causeway_surface, 11.4, Color("725c48"))
	var portal_root := _make_subway_section(parent, "PortalRamp")
	_add_portal_section(portal_root, tunnel_start, p1, 13.8, 5.6, true)
	_add_portal_section(portal_root, p1, p2, 14.0, 4.8, true)
	_add_portal_section(portal_root, p2, p3, 14.4, 4.1, false)
	_add_portal_section(portal_root, p3, portal_top, 15.2, 3.6, false)
	_add_box(portal_root, Vector3(14.0, 5.4, 1.5), portal_top - forward * 2.4 + Vector3(0.0, 1.4, 0.0), forward, Color("8b8375"))
	_add_box(portal_root, Vector3(14.8, 0.7, 4.4), portal_top - forward * 4.2 + Vector3(0.0, 3.9, 0.0), forward, Color("3d352e"))
	_add_box(portal_root, Vector3(22.0, 0.16, 18.0), portal_top + forward * 2.0 + Vector3(0.0, 0.08, 0.0), forward, Color("8b7f6c"))
	for side in [-1.0, 1.0]:
		var lamp := OmniLight3D.new()
		lamp.omni_range = 18.0
		lamp.light_energy = 0.36
		lamp.light_color = Color(1.0, 0.95, 0.88)
		lamp.position = portal_top + right * side * 5.6 + Vector3(0.0, 2.8, -1.0)
		portal_root.add_child(lamp)

func _add_surface_alignment(parent: Node3D, a: Vector3, b: Vector3, width: float, color: Color, style_id: String = "") -> void:
	var length := a.distance_to(b)
	if length < 1.0:
		return
	var forward := (b - a).normalized()
	var center := (a + b) * 0.5 + Vector3(0.0, 0.06, 0.0)
	if style_id == "":
		_add_box(parent, Vector3(width, 0.12, length), center, forward, color)
		return
	var theme := _corridor_theme(style_id)
	var surface_material := _ensure_period_material(String(theme.get("surface_material", "asphalt")))
	_add_box_with_material(parent, Vector3(width, 0.12, length), center, forward, surface_material)

func _add_station_columns(parent: Node3D, center: Vector3, forward: Vector3, right: Vector3, length: float, offsets: Array[float], height: float) -> void:
	var count := maxi(2, int(round(length / subway_column_spacing)))
	for i in range(count):
		var t := float(i + 1) / float(count + 1)
		var column_center := center - forward * (length * 0.5) + forward * (length * t)
		for offset in offsets:
			_add_box(parent, Vector3(0.65, height, 0.65), column_center + right * offset + Vector3(0.0, 0.15, 0.0), forward, Color("a79f92"))

func _add_station_access_shafts(parent: Node3D, center: Vector3, forward: Vector3, right: Vector3, width: float, station_name: String, spec: Dictionary = {}) -> void:
	var shaft_height := absf(subway_depth) + 2.8
	var shaft_entries: Array = spec.get("shafts", [])
	if shaft_entries.is_empty():
		var shaft_offsets: Array[float] = [0.0]
		if station_name == "Park Street" or station_name == "Kenmore":
			shaft_offsets = [-width * 0.16, width * 0.16]
		for offset in shaft_offsets:
			shaft_entries.append({"right_offset": offset})
	for entry_variant in shaft_entries:
		var entry: Dictionary = entry_variant
		var shaft_width_local := float(entry.get("width", subway_shaft_width))
		var shaft_length_local := float(entry.get("length", subway_shaft_length))
		var shaft_height_local := float(entry.get("height", shaft_height))
		var right_offset := float(entry.get("right_offset", 0.0))
		var forward_offset := float(entry.get("forward_offset", 0.0))
		var shaft_center := center + right * right_offset + forward * forward_offset + Vector3(0.0, shaft_height_local * 0.5 - 0.3 + float(entry.get("up_offset", 0.0)), 0.0)
		_add_box(parent, Vector3(shaft_width_local, shaft_height_local, shaft_length_local), shaft_center, forward, Color("948a7b"))
		var steps := maxi(2, int(entry.get("steps", 5)))
		var run := float(entry.get("run", 3.2))
		var landing_offset := float(entry.get("landing_forward_offset", -1.4))
		for step in range(steps):
			var step_t := 0.0 if steps <= 1 else float(step) / float(steps - 1)
			var landing_pos := center + right * right_offset + forward * (forward_offset + landing_offset + step_t * run) + Vector3(0.0, 1.5 + step_t * 5.3, 0.0)
			_add_box(parent, Vector3(shaft_width_local - 0.8, 0.18, 1.0), landing_pos, forward, Color("c8bda6"))

func _add_cut_and_cover(parent: Node3D, center: Vector3, forward: Vector3, right: Vector3, width: float, length: float, roof_y: float, side_height: float) -> void:
	var outer_width := width + subway_cover_margin * 2.0
	var cover_top_y := -0.18
	var retaining_height := maxf(1.2, cover_top_y - roof_y)
	_add_box(parent, Vector3(outer_width, subway_cover_thickness, length), Vector3(center.x, cover_top_y - subway_cover_thickness * 0.5, center.z), forward, Color("5d5348"))
	_add_box(parent, Vector3(outer_width - 1.0, 0.14, length), Vector3(center.x, cover_top_y + 0.03, center.z), forward, Color("7e6e59"))
	for side in [-1.0, 1.0]:
		_add_box(parent, Vector3(1.1, retaining_height + side_height * 0.15, length), center + right * side * (outer_width * 0.5 - 0.55) + Vector3(0.0, roof_y + retaining_height * 0.5 - center.y, 0.0), forward, Color("7b6f61"))

func _add_portal_section(parent: Node3D, a: Vector3, b: Vector3, width: float, wall_height: float, roofed: bool) -> void:
	var forward := (b - a).normalized()
	var length := a.distance_to(b)
	if forward.length() < 0.01 or length < 0.5:
		return
	var right := Vector3(-forward.z, 0.0, forward.x).normalized()
	var center := (a + b) * 0.5
	var floor_center := center + Vector3(0.0, -2.25, 0.0)
	_add_box(parent, Vector3(width, subway_floor_thickness, length), floor_center, forward, Color("514b44"))
	_add_box(parent, Vector3(width - 0.8, 0.4, length), floor_center + Vector3(0.0, 0.28, 0.0), forward, Color("5c554d"))
	for side in [-1.0, 1.0]:
		_add_box(parent, Vector3(0.9, wall_height, length), center + right * side * (width * 0.5 - 0.45) + Vector3(0.0, wall_height * 0.5 - 0.15, 0.0), forward, Color("867d72"))
	if roofed:
		_add_box(parent, Vector3(width, 0.7, length), center + Vector3(0.0, wall_height - 0.25, 0.0), forward, Color("5f5a53"))
		var light := OmniLight3D.new()
		light.omni_range = 18.0
		light.light_energy = 0.28
		light.light_color = Color(1.0, 0.95, 0.88)
		light.position = center + Vector3(0.0, wall_height - 0.8, 0.0)
		parent.add_child(light)
	else:
		for side in [-1.0, 1.0]:
			_add_box(parent, Vector3(0.55, 0.18, length), center + right * side * (width * 0.5 - 0.3) + Vector3(0.0, wall_height - 0.1, 0.0), forward, Color("b3a38b"))

func _add_box(parent: Node3D, size: Vector3, position: Vector3, forward: Vector3, color: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	mat.metallic = 0.05
	instance.set_surface_override_material(0, mat)
	_add_box_instance(parent, instance, position, forward)

func _add_track_surface_box(parent: Node3D, size: Vector3, position: Vector3, forward: Vector3) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.set_surface_override_material(0, _ensure_track_surface_material())
	_add_box_instance(parent, instance, position, forward)

func _add_rail_box(parent: Node3D, size: Vector3, position: Vector3, forward: Vector3) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.set_surface_override_material(0, _ensure_track_rail_material())
	_add_box_instance(parent, instance, position, forward)

func _add_box_instance(parent: Node3D, instance: MeshInstance3D, position: Vector3, forward: Vector3) -> void:
	parent.add_child(instance)
	instance.global_position = position
	var z_axis := forward.normalized()
	if z_axis.length() < 0.01:
		z_axis = Vector3.FORWARD
	var x_axis := Vector3.UP.cross(z_axis).normalized()
	if x_axis.length() < 0.01:
		x_axis = Vector3.RIGHT
	var y_axis := z_axis.cross(x_axis).normalized()
	instance.global_basis = Basis(x_axis, y_axis, z_axis).orthonormalized()

func _ensure_track_surface_material() -> ShaderMaterial:
	if _track_surface_material != null:
		return _track_surface_material
	_track_surface_material = ShaderMaterial.new()
	_track_surface_material.shader = TrackBlendShader
	_track_surface_material.set_shader_parameter("ballast_albedo", _load_runtime_texture(BallastAlbedoPath))
	_track_surface_material.set_shader_parameter("ballast_roughness", _load_runtime_texture(BallastRoughnessPath))
	_track_surface_material.set_shader_parameter("sleeper_albedo", _load_runtime_texture(SleeperAlbedoPath))
	_track_surface_material.set_shader_parameter("sleeper_roughness", _load_runtime_texture(SleeperRoughnessPath))
	_track_surface_material.set_shader_parameter("rail_albedo", _load_runtime_texture(RailAlbedoPath))
	_track_surface_material.set_shader_parameter("rail_roughness", _load_runtime_texture(RailRoughnessPath))
	_track_surface_material.set_shader_parameter("side_color", Vector3(0.31, 0.29, 0.27))
	_track_surface_material.set_shader_parameter("paint_rails", 0.0)
	_track_surface_material.set_shader_parameter("ballast_scale_x", 1.8)
	_track_surface_material.set_shader_parameter("ballast_scale_y", 8.0)
	_track_surface_material.set_shader_parameter("sleeper_repeat", 14.0)
	return _track_surface_material

func _ensure_track_rail_material() -> StandardMaterial3D:
	if _track_rail_material != null:
		return _track_rail_material
	_track_rail_material = StandardMaterial3D.new()
	_track_rail_material.albedo_texture = _load_runtime_texture(RailAlbedoPath)
	_track_rail_material.roughness_texture = _load_runtime_texture(RailRoughnessPath)
	_track_rail_material.albedo_color = Color(0.86, 0.86, 0.84, 1.0)
	_track_rail_material.roughness = 0.28
	_track_rail_material.metallic = 0.78
	return _track_rail_material

func _load_runtime_texture(resource_path: String) -> Texture2D:
	if resource_path == "":
		return null
	var absolute_path := ProjectSettings.globalize_path(resource_path)
	if not FileAccess.file_exists(absolute_path):
		return null
	var image := Image.new()
	var err := image.load(absolute_path)
	if err != OK:
		return null
	return ImageTexture.create_from_image(image)

func _map_bounds(points: PackedVector3Array) -> Dictionary:
	if points.is_empty():
		return {"min": Vector3.ZERO, "max": Vector3.ONE}
	var min_point := points[0]
	var max_point := points[0]
	for point in points:
		min_point.x = minf(min_point.x, point.x)
		min_point.y = minf(min_point.y, point.y)
		min_point.z = minf(min_point.z, point.z)
		max_point.x = maxf(max_point.x, point.x)
		max_point.y = maxf(max_point.y, point.y)
		max_point.z = maxf(max_point.z, point.z)
	for entry in _driver_route_stops:
		var stop_pos: Vector3 = entry.get("position", Vector3.ZERO)
		min_point.x = minf(min_point.x, stop_pos.x)
		min_point.z = minf(min_point.z, stop_pos.z)
		max_point.x = maxf(max_point.x, stop_pos.x)
		max_point.z = maxf(max_point.z, stop_pos.z)
	for trolley in _fleet:
		if trolley == null or not is_instance_valid(trolley):
			continue
		var pos := trolley.global_position
		min_point.x = minf(min_point.x, pos.x)
		min_point.z = minf(min_point.z, pos.z)
		max_point.x = maxf(max_point.x, pos.x)
		max_point.z = maxf(max_point.z, pos.z)
	var pad_x := maxf(1200.0, (max_point.x - min_point.x) * 0.05)
	var pad_z := maxf(1200.0, (max_point.z - min_point.z) * 0.08)
	min_point.x -= pad_x
	max_point.x += pad_x
	min_point.z -= pad_z
	max_point.z += pad_z
	return {"min": min_point, "max": max_point}

func _make_subway_section(parent: Node3D, section_name: String) -> Node3D:
	var node := Node3D.new()
	node.name = section_name
	parent.add_child(node)
	return node

func _section_name(value: String) -> String:
	return value.replace(" ", "_").replace("/", "_").replace("-", "_")

func _get_town_manager() -> Node:
	if town_manager_path == NodePath(""):
		return null
	return get_node(town_manager_path) as Node

func _seed_initial_towns(town_manager: Node) -> void:
	if town_manager == null:
		return
	if town_manager.has_method("SpawnSuburbsForAllStops"):
		town_manager.call_deferred("SpawnSuburbsForAllStops")

func _get_track_builder() -> Node:
	if track_builder_path == NodePath(""):
		return null
	return get_node(track_builder_path) as Node

func _mainline_stop_points() -> PackedVector3Array:
	if use_geo_path and _geo_points_ready():
		return _build_points_from_geo()

	var points := PackedVector3Array()
	var dir := direction.normalized()
	if dir.length() < 0.01:
		dir = Vector3.RIGHT
	var span := total_length_m
	var use_mileposts := mainline_mileposts.size() == mainline_towns.size()
	if use_mileposts:
		var last_miles := mainline_mileposts[mainline_mileposts.size() - 1]
		span = max(span, last_miles * METERS_PER_MILE)
	var step := span / float(mainline_towns.size() - 1)
	var start := 0.0 if anchor_at_first_stop else -span * 0.5
	for i in range(mainline_towns.size()):
		var distance := start + step * float(i)
		if use_mileposts:
			distance = mainline_mileposts[i] * METERS_PER_MILE
			if not anchor_at_first_stop:
				distance -= span * 0.5
		var pos := origin + dir * distance
		points.append(pos)
	return points

func _route_points(stop_points: PackedVector3Array) -> PackedVector3Array:
	var westbound := _westbound_route_points(stop_points)
	if not build_north_terminal_extension:
		return westbound
	var north_terminal := _north_terminal_route_points()
	if north_terminal.is_empty():
		return westbound
	var route := PackedVector3Array()
	for point in north_terminal:
		route.append(point)
	for i in range(1, westbound.size()):
		route.append(westbound[i])
	return route

func _westbound_route_points(stop_points: PackedVector3Array) -> PackedVector3Array:
	if stop_points.is_empty():
		return PackedVector3Array()
	var route := PackedVector3Array()
	var last_subway_idx := _last_subway_station_index()
	for i in range(stop_points.size()):
		if i <= last_subway_idx:
			route.append(_subway_track_point(stop_points[i]))
			if i == last_subway_idx and i + 1 < stop_points.size():
				var next_surface := stop_points[i + 1]
				route.append(stop_points[i].lerp(next_surface, portal_fraction_1) + Vector3(0.0, subway_depth, 0.0))
				route.append(stop_points[i].lerp(next_surface, portal_fraction_2) + Vector3(0.0, subway_depth * 0.55, 0.0))
				route.append(stop_points[i].lerp(next_surface, portal_fraction_3) + Vector3(0.0, subway_depth * 0.15, 0.0))
			continue
		route.append(stop_points[i])
	return route

func _north_terminal_route_points() -> PackedVector3Array:
	var subway_surface := _north_subway_surface_points()
	var elevated_surface := _elevated_surface_points()
	if subway_surface.size() < 2 or elevated_surface.size() < 2:
		return PackedVector3Array()
	var route := PackedVector3Array()
	var lechmere_surface := elevated_surface[0]
	var causeway_surface := elevated_surface[1]
	var haymarket_surface := subway_surface[subway_surface.size() - 1]
	var tail_surface := _lechmere_turnback_surface_point(elevated_surface)
	route.append(tail_surface + Vector3(0.0, elevated_deck_height, 0.0))
	route.append(lechmere_surface + Vector3(0.0, elevated_deck_height, 0.0))
	route.append(causeway_surface + Vector3(0.0, elevated_deck_height, 0.0))
	route.append(_portal_blend(causeway_surface, haymarket_surface, 0.28, elevated_deck_height * 0.78))
	route.append(_portal_blend(causeway_surface, haymarket_surface, 0.54, 2.4))
	route.append(_portal_blend(causeway_surface, haymarket_surface, 0.76, subway_depth * 0.42))
	route.append(_subway_track_point(haymarket_surface))
	for i in range(subway_surface.size() - 2, -1, -1):
		route.append(_subway_track_point(subway_surface[i]))
	return route

func _north_subway_surface_points() -> PackedVector3Array:
	return _project_geo_points(north_subway_geo)

func _elevated_surface_points() -> PackedVector3Array:
	return _project_geo_points(elevated_geo)

func _lechmere_turnback_surface_point(elevated_surface: PackedVector3Array = PackedVector3Array()) -> Vector3:
	var points := elevated_surface
	if points.is_empty():
		points = _elevated_surface_points()
	if points.size() < 2:
		return Vector3.ZERO
	var tail_dir := (points[0] - points[1]).normalized()
	if tail_dir.length() < 0.01:
		tail_dir = Vector3.LEFT
	return points[0] + tail_dir * lechmere_turnback_tail_m

func _portal_blend(a_surface: Vector3, b_surface: Vector3, t: float, height: float) -> Vector3:
	return a_surface.lerp(b_surface, t) + Vector3(0.0, height, 0.0)

func _build_points_from_geo() -> PackedVector3Array:
	var pts := PackedVector3Array()
	var b = _geo_bounds()
	if b == null:
		return pts
	for i in range(min(mainline_geo.size(), mainline_towns.size())):
		var ll := mainline_geo[i]
		var pos := GeoProjectorScript.lon_lat_to_world(ll.x, ll.y, b, world_size_m)
		pts.append(pos)
	if pts.size() > 1:
		total_length_m = _path_length(pts)
	return pts

func _geo_points_ready() -> bool:
	return (bounds != null) or ResourceLoader.exists("res://data/ma_bounds.tres")

func _geo_bounds():
	var resolved := {
		"min_lat": 41.2,
		"max_lat": 42.9,
		"min_lon": -73.6,
		"max_lon": -69.9
	}
	var raw_bounds: Variant = bounds
	if raw_bounds is Dictionary:
		for key in resolved.keys():
			if raw_bounds.has(key):
				resolved[key] = float(raw_bounds[key])
		return resolved
	var bounds_path := "res://data/ma_bounds.tres"
	if raw_bounds is Resource and String(raw_bounds.resource_path) != "":
		bounds_path = String(raw_bounds.resource_path)
	_read_bounds_file(bounds_path, resolved)
	return resolved

func _read_bounds_file(path: String, target: Dictionary) -> void:
	if not ResourceLoader.exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty() or line.begins_with("[") or not line.contains("="):
			continue
		var parts := line.split("=", false, 1)
		if parts.size() != 2:
			continue
		var key := parts[0].strip_edges()
		if not target.has(key):
			continue
		var raw_value := parts[1].strip_edges()
		target[key] = float(raw_value)

func _path_length(points: PackedVector3Array) -> float:
	var length := 0.0
	for i in range(points.size() - 1):
		length += points[i].distance_to(points[i + 1])
	return length
