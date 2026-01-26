extends Node


const ICON_PATH = "res://Textures/Items/Upgrades/"
const WEAPON_PATH = "res://Textures/Items/Weapons/"
const UPGRADES = {
	"icespear1": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Ice Spear",
		"details": "A spear of ice is thrown at a random enemy",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"icespear2": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Ice Spear",
		"details": "An addition Ice Spear is thrown",
		"level": "Level: 2",
		"prerequisite": ["icespear1"],
		"type": "weapon"
	},
	"icespear3": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Ice Spear",
		"details": "Ice Spears now pass through another enemy and do + 3 damage",
		"level": "Level: 3",
		"prerequisite": ["icespear2"],
		"type": "weapon"
	},
	"icespear4": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Ice Spear",
		"details": "An additional 2 Ice Spears are thrown",
		"level": "Level: 4",
		"prerequisite": ["icespear3"],
		"type": "weapon"
	},
	"javelin1": {
		"icon": WEAPON_PATH + "javelin_3_new_attack.png",
		"displayname": "Javelin",
		"details": "A magical javelin will follow you attacking enemies in a straight line",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"javelin2": {
		"icon": WEAPON_PATH + "javelin_3_new_attack.png",
		"displayname": "Javelin",
		"details": "The javelin will now attack an additional enemy per attack",
		"level": "Level: 2",
		"prerequisite": ["javelin1"],
		"type": "weapon"
	},
	"javelin3": {
		"icon": WEAPON_PATH + "javelin_3_new_attack.png",
		"displayname": "Javelin",
		"details": "The javelin will attack another additional enemy per attack",
		"level": "Level: 3",
		"prerequisite": ["javelin2"],
		"type": "weapon"
	},
	"javelin4": {
		"icon": WEAPON_PATH + "javelin_3_new_attack.png",
		"displayname": "Javelin",
		"details": "The javelin now does + 5 damage per attack and causes 20% additional knockback",
		"level": "Level: 4",
		"prerequisite": ["javelin3"],
		"type": "weapon"
	},
	"tornado1": {
		"icon": WEAPON_PATH + "tornado.png",
		"displayname": "Tornado",
		"details": "A tornado is created and random heads somewhere in the players direction",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"tornado2": {
		"icon": WEAPON_PATH + "tornado.png",
		"displayname": "Tornado",
		"details": "An additional Tornado is created",
		"level": "Level: 2",
		"prerequisite": ["tornado1"],
		"type": "weapon"
	},
	"tornado3": {
		"icon": WEAPON_PATH + "tornado.png",
		"displayname": "Tornado",
		"details": "The Tornado cooldown is reduced by 0.5 seconds",
		"level": "Level: 3",
		"prerequisite": ["tornado2"],
		"type": "weapon"
	},
	"tornado4": {
		"icon": WEAPON_PATH + "tornado.png",
		"displayname": "Tornado",
		"details": "An additional tornado is created and the knockback is increased by 25%",
		"level": "Level: 4",
		"prerequisite": ["tornado3"],
		"type": "weapon"
	},
	"armor1": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By 1 point",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"armor2": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 2",
		"prerequisite": ["armor1"],
		"type": "upgrade"
	},
	"armor3": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 3",
		"prerequisite": ["armor2"],
		"type": "upgrade"
	},
	"armor4": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 4",
		"prerequisite": ["armor3"],
		"type": "upgrade"
	},
	"speed1": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by 50% of base speed",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"speed2": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 2",
		"prerequisite": ["speed1"],
		"type": "upgrade"
	},
	"speed3": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 3",
		"prerequisite": ["speed2"],
		"type": "upgrade"
	},
	"speed4": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased an additional 50% of base speed",
		"level": "Level: 4",
		"prerequisite": ["speed3"],
		"type": "upgrade"
	},
	"tome1": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"tome2": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 2",
		"prerequisite": ["tome1"],
		"type": "upgrade"
	},
	"tome3": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 3",
		"prerequisite": ["tome2"],
		"type": "upgrade"
	},
	"tome4": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 4",
		"prerequisite": ["tome3"],
		"type": "upgrade"
	},
	"scroll1": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"scroll2": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 2",
		"prerequisite": ["scroll1"],
		"type": "upgrade"
	},
	"scroll3": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 3",
		"prerequisite": ["scroll2"],
		"type": "upgrade"
	},
	"scroll4": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 4",
		"prerequisite": ["scroll3"],
		"type": "upgrade"
	},
	"ring1": {
		"icon": ICON_PATH + "urand_mage.png",
		"displayname": "Ring",
		"details": "Your spells now spawn 1 more additional attack",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"ring2": {
		"icon": ICON_PATH + "urand_mage.png",
		"displayname": "Ring",
		"details": "Your spells now spawn an additional attack",
		"level": "Level: 2",
		"prerequisite": ["ring1"],
		"type": "upgrade"
	},
	"food": {
		"icon": ICON_PATH + "chunk.png",
		"displayname": "Food",
		"details": "Heals you for 20 health",
		"level": "N/A",
		"prerequisite": [],
		"type": "item"
	},
	"speedboost1": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed Boost",
		"details": "Movement Speed Increased by 20%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"rotatingsword1": {
		"icon": WEAPON_PATH + "sword.png",
		"displayname": "Rotating Sword",
		"details": "A sword rotates around the player, damaging enemies",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"rotatingsword2": {
		"icon": WEAPON_PATH + "sword.png",
		"displayname": "Rotating Sword",
		"details": "An additional sword is added",
		"level": "Level: 2",
		"prerequisite": ["rotatingsword1"],
		"type": "weapon"
	},
	"rotatingsword3": {
		"icon": WEAPON_PATH + "sword.png",
		"displayname": "Rotating Sword",
		"details": "Swords rotate faster and deal more damage",
		"level": "Level: 3",
		"prerequisite": ["rotatingsword2"],
		"type": "weapon"
	},
	"rotatingsword4": {
		"icon": WEAPON_PATH + "sword.png",
		"displayname": "Rotating Sword",
		"details": "An additional sword and increased radius",
		"level": "Level: 4",
		"prerequisite": ["rotatingsword3"],
		"type": "weapon"
	},
	"fireball1": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Fireball",
		"details": "A fireball is thrown at a random enemy, explodes on impact",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"fireball2": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Fireball",
		"details": "An additional fireball is thrown",
		"level": "Level: 2",
		"prerequisite": ["fireball1"],
		"type": "weapon"
	},
	"fireball3": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Fireball",
		"details": "Fireballs now explode in a larger area",
		"level": "Level: 3",
		"prerequisite": ["fireball2"],
		"type": "weapon"
	},
	"fireball4": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Fireball",
		"details": "An additional 2 fireballs are thrown",
		"level": "Level: 4",
		"prerequisite": ["fireball3"],
		"type": "weapon"
	},
	"lootradius1": {
		"icon": ICON_PATH + "urand_mage.png",
		"displayname": "Loot Radius",
		"details": "Increases loot collection radius by 20%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"lightning1": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Lightning Bolt",
		"details": "A lightning bolt strikes enemies in a chain",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"lightning2": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Lightning Bolt",
		"details": "Lightning chains to one more enemy and deals more damage",
		"level": "Level: 2",
		"prerequisite": ["lightning1"],
		"type": "weapon"
	},
	"lightning3": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Lightning Bolt",
		"details": "Increased chain range and damage",
		"level": "Level: 3",
		"prerequisite": ["lightning2"],
		"type": "weapon"
	},
	"lightning4": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Lightning Bolt",
		"details": "Chains to even more enemies with increased range",
		"level": "Level: 4",
		"prerequisite": ["lightning3"],
		"type": "weapon"
	},
	"shuriken1": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Shuriken",
		"details": "A throwing star that returns to you, hitting enemies on the way back",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"shuriken2": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Shuriken",
		"details": "An additional shuriken and increased damage",
		"level": "Level: 2",
		"prerequisite": ["shuriken1"],
		"type": "weapon"
	},
	"shuriken3": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Shuriken",
		"details": "Increased range and speed",
		"level": "Level: 3",
		"prerequisite": ["shuriken2"],
		"type": "weapon"
	},
	"shuriken4": {
		"icon": WEAPON_PATH + "ice_spear.png",
		"displayname": "Shuriken",
		"details": "An additional shuriken with maximum range and damage",
		"level": "Level: 4",
		"prerequisite": ["shuriken3"],
		"type": "weapon"
	}
}

