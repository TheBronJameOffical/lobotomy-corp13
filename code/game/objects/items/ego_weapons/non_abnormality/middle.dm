// Middle stuff comes with a 3 hit combo system, can choose to two hand each weapon increasing force by 15%
// Deals RED because the numbers could get quite... high
// No combo toggle btw, suffer you will punch them in quick succession
/obj/item/ego_weapon/city/middle
	name = "little sibling chains"
	desc = "A set of chains meant to be wrapped arounds ones fist. This ones lighter to be used by little siblings."
	special = "Use in hand to wield in both hands, increasing your damage by 15% This weapon also has a combo system."
	icon_state = "kbatong" // Placeholder
	inhand_icon_state = "kbatong"
	force = 23 // Tweak these values in the future
	attack_verb_continuous = list("smacks", "crushes", "punches")
	attack_verb_simple = list("smack", "crush", "punch")
	hitsound = 'sound/weapons/fixer/generic/middle1.ogg'
	attribute_requirements = list(
							FORTITUDE_ATTRIBUTE = 60,
							PRUDENCE_ATTRIBUTE = 60,
							TEMPERANCE_ATTRIBUTE = 60,
							JUSTICE_ATTRIBUTE = 60
							)
	var/combo = 0
	var/combo_time
	var/combo_wait = 10
	var/wielded = FALSE
	var/force_wielded = 26

/obj/item/ego_weapon/city/middle/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/OnWield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)

/obj/item/ego_weapon/city/middle/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=23, force_wielded=26) // Var this and connect it to the weapon, since its a component in theory it should be able to draw from this no?

/obj/item/ego_weapon/city/middle/proc/OnWield(obj/item/source, mob/user)
	SIGNAL_HANDLER
	wielded = TRUE

/obj/item/ego_weapon/city/middle/proc/on_unwield(obj/item/source, mob/user)
	SIGNAL_HANDLER
	wielded = FALSE

/obj/item/ego_weapon/city/middle/attack(mob/living/M, mob/living/user)
	if(!CanUseEgo(user))
		return
	combo_time = world.time + combo_wait
	if(combo==3)
		combo = 0
		user.changeNext_move(CLICK_CD_MELEE * 2)
		force *= 4	// It may be a bit weaker? you're wielding it anyways most likely
		playsound(src, 'sound/weapons/fixer/generic/middle_end.ogg', 300, FALSE, 9) // Fluff
		to_chat(user, span_warning("You are offbalance, you take a moment to reset your stance."))
	else
		user.changeNext_move(CLICK_CD_MELEE * 0.4)
	..()
	combo += 1
	if(wielded)
		force = force_wielded
		return
	force = initial(force)

/obj/item/ego_weapon/city/middle/big // The ricardos
	name = "big sibling chains"
	desc = "A set of chains meant to be wrapped arounds ones fist. Its way heavier, clearly meant for the Big Siblings of the Middle."
	icon_state = "kbatong" // Placeholder
	inhand_icon_state = "kbatong"
	force = 35
	attribute_requirements = list(
							FORTITUDE_ATTRIBUTE = 80,
							PRUDENCE_ATTRIBUTE = 80,
							TEMPERANCE_ATTRIBUTE = 80,
							JUSTICE_ATTRIBUTE = 80
							)
	force_wielded = 40

/obj/item/ego_weapon/city/middle/big/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=35, force_wielded=40)

/obj/item/ego_weapon/city/middle/great // The allegeded Great sibling line
	name = "great sibling chains"
	desc = "A set of chains meant to be wrapped arounds ones fist. You aren't sure how to even carry this around, only a Great Sibling could use this much weight."
	icon_state = "kbatong" // Placeholder
	inhand_icon_state = "kbatong"
	force = 60
	attribute_requirements = list(
							FORTITUDE_ATTRIBUTE = 100,
							PRUDENCE_ATTRIBUTE = 100,
							TEMPERANCE_ATTRIBUTE = 100,
							JUSTICE_ATTRIBUTE = 100
							)
	force_wielded = 70

/obj/item/ego_weapon/city/middle/big/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=35, force_wielded=40)
