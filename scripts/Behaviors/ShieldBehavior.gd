extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	BehaviorEvents.connect("OnObjTurn", self, "OnObjTurn_Callback")
	BehaviorEvents.connect("OnMountAdded", self, "OnMountAdded_Callback")
	
func OnObjTurn_Callback(obj):
	var shield_name = obj.get_attrib("mounts.shield")
	if shield_name == null or shield_name == "":
		return
	
	var shield_data = Globals.LevelLoaderRef.LoadJSON(shield_name)
	var max_hp = shield_data.shielding.max_hp
	var cur_hp = obj.get_attrib("shield.current_hp")
	if cur_hp == null:
		obj.set_attrib("shield.current_hp", max_hp)
		return
		
	if cur_hp < max_hp:
		_process_healing(obj, max_hp, cur_hp, shield_data)
		
	obj.set_attrib("shield.last_turn_update", Globals.total_turn)
		
		
func _process_healing(obj, max_hp, cur_hp, shield_data):
	var last_update = obj.get_attrib("shield.last_turn_update", Globals.total_turn)
	var heal = shield_data.shielding.hp_regen_per_ap * (Globals.total_turn - last_update)
	var energy = shield_data.shielding.energy_cost_per_hp * (Globals.total_turn - last_update)
	
	var new_hp = min(cur_hp + heal, max_hp)
	obj.set_attrib("shield.current_hp", new_hp)
	BehaviorEvents.emit_signal("OnUseEnergy", obj, energy)
	
func OnMountAdded_Callback(obj, slot, src):
	if slot != "shield" or src == null or src.empty():
		return
		
	var data = Globals.LevelLoaderRef.LoadJSON(src)
	obj.set_attrib("shield.last_turn_update", Globals.total_turn)
	