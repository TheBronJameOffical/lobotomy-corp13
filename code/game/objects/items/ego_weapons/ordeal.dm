// Cycles through all 4 damage tpyes, ability based off the pillars attacks.
/obj/item/ego_weapon/god_delusion
	name = "delusionist's end"
	desc = "We saw their faces, their invisible hands choking our minds. \
	They spoke of their impossibility, they decreed their inexistence. \
	It was unacceptable, it was fruitless, no answer would have satisfied us."
	special = "This weapon changes its damage type every 2 minutes. Use in hand to open a portal in front of you releasing a RED damage claw."
	icon_state = "delusion_red"
	force = 60
	damtype = RED_DAMAGE
	attack_verb_continuous = list("bashes", "crushes")
	attack_verb_simple = list("bash", "crush")
	hitsound = 'sound/weapons/ego/hammer.ogg'
	attribute_requirements = list(
							FORTITUDE_ATTRIBUTE = 100,
							PRUDENCE_ATTRIBUTE = 100,
							TEMPERANCE_ATTRIBUTE = 100,
							JUSTICE_ATTRIBUTE = 100
							)
	var/form = "red"
	var/index = 1
	var/special_attack = FALSE
	var/list/weapon_list = list(
		"red" = list(60, RED_DAMAGE, "This weapon changes its damage type every 2 minutes. Use in hand to open a portal in front of you releasing a RED damage claw.", 240),
		"white" = list(60, WHITE_DAMAGE, "This weapon changes its damage type every 2 minutes. Use in hand to open a portal at your location releasing a WHITE damage tentacle.", 240),
		"black" = list(60, BLACK_DAMAGE, "This weapon changes its damage type every 2 minutes. Use in hand to open multiple portals around you which unleashes a BLACK spike in a 5x5 aoe.", 180),
		"pale" = list(50, PALE_DAMAGE, "This weapon changes its damage type every 2 minutes. Use in hand to summon a stationary pulsing PALE damage eye.", 60)
		)
	var/special_cooldown
	var/special_cooldown_time = 30 SECONDS
	var/special_checks_faction = TRUE
	var/special_damage = 240
	var/switch_cooldown_time = 2 MINUTES // Workshop this value.
	var/pulse_range = 5
	var/list/intrusive_thoughts = list(
		"They could never be understood, we ignored their warnings and warped our minds.",
		"The idea of Love and Compassion was alien to them, all they could give was the cold reality.",
		"We built shrines and scribed their languages in their image, they ignored our pleas and left nothing.",
		"We damned the consequences, and spiraled into insanity."
	)

/obj/item/ego_weapon/god_delusion/Initialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	addtimer(CALLBACK(src, .proc/Transform), switch_cooldown_time) // Kicks off the changing

/obj/item/ego_weapon/god_delusion/attack_self(mob/user)
	. = ..()
	if(!CanUseEgo(user))
		return
	if(special_cooldown > world.time)
		to_chat(user, "<span class='warning'>Your ability is on cooldown!</span>")
		return
	switch(form)
		if("red")
			special_attack = !special_attack
			if(special_attack)
				to_chat(user, "<span class='notice'>You prepare your portal.</span>")
			else
				to_chat(user, "<span class='notice'>You decide to not use the red claw.</span>")
		if("white")
			special_attack = !special_attack
			if(special_attack)
				to_chat(user, "<span class='notice'>You prepare your portal.</span>")
			else
				to_chat(user, "<span class='notice'>You decide to not use the white tentacle.</span>")
		if("black")
			for(var/turf/L in view(2, user))
				new /obj/effect/temp_visual/cult/sparks(L)
			playsound(user, 'sound/effects/ordeals/violet/midnight_portal_on.ogg', 50, FALSE)
			if(!do_after(user, 1 SECONDS, src))
				to_chat(user, "<span class='notice'>You diffuse the portals.</span>")
				return
			special_cooldown = world.time + special_cooldown_time
			playsound(user, 'sound/effects/ordeals/violet/midnight_black_attack1.ogg', 50, FALSE)
			for(var/turf/open/T in view(2, user))
				new /obj/effect/temp_visual/small_smoke/halfsecond(T)
			for(var/mob/living/L in view(2, user))
				if(L.z != user.z)
					continue
				var/modified_damage = (special_damage * force_multiplier)
				if(L == user || ishuman(L))
					continue
				L.apply_damage(modified_damage, BLACK_DAMAGE, null, L.run_armor_check(null, BLACK_DAMAGE), spread_damage = TRUE)
				to_chat(L, "<span class='userdanger'>You are stabbed by a spike!</span>")
		if("pale")
			playsound(user, 'sound/effects/ordeals/violet/midnight_pale_move.ogg', 50, TRUE)
			var/obj/effect/pale_eye/eye = new(get_turf(user))
			eye.alpha = 0
			animate(eye, alpha = 200, time = (1 SECONDS))
			to_chat(user, "<span class='notice'>You call upon the Pale Deity.</span>")
			if(!do_after(user, 2 SECONDS, src))
				to_chat(user, "<span class='notice'>You decide not to summon the eye now.</span>")
				qdel(eye)
				return
			special_cooldown = world.time + special_cooldown_time
			var/turf/eye_loc = get_turf(user)
			for(var/i = 1 to 3)
				pale_pulse(eye_loc, user)
				sleep(10)
			animate(eye, alpha = 1, time = (1 SECONDS))
			playsound(eye_loc, 'sound/effects/ordeals/violet/midnight_pale_move.ogg', 50, TRUE, 8)
			sleep(10)
			qdel(eye)

/obj/item/ego_weapon/god_delusion/afterattack(atom/target, mob/living/user, proximity_flag, params)
	if(!special_attack)
		return
	switch(form)
		if("red")
			var/turf/target_turf = get_ranged_target_turf_direct(user, target, 4)
			var/list/turfs_to_hit = getline(user, target_turf)
			for(var/turf/T in turfs_to_hit)
				if(T.density)
					break
				var/obj/effect/temp_visual/sparkles/S = new(T)
				S.color = "#a50d1c"
			var/obj/effect/violet_portal/red/R = new(get_turf(user))
			QDEL_IN(R, (10.2))
			playsound(user, 'sound/effects/ordeals/violet/midnight_portal_on.ogg', 75)
			special_cooldown = world.time + special_cooldown_time
			if(!do_after(user, 7, src))
				return
			playsound(user, 'sound/effects/ordeals/violet/midnight_red_attack.ogg', 75)
			var/turf/MT = get_turf(user)
			MT.Beam(target_turf, "blood_beam", time=5)
			var/modified_damage = (special_damage * force_multiplier)
			for(var/turf/T in turfs_to_hit)
				if(T.density)
					break
				for(var/mob/living/L in T)
					if(special_checks_faction && user.faction_check_mob(L))
						if(ishuman(L))
							var/mob/living/carbon/human/H = L
							if(!H.sanity_lost)
								continue
						else
							continue
					L.apply_damage(modified_damage, RED_DAMAGE, null, L.run_armor_check(null, RED_DAMAGE), spread_damage = TRUE)
					new /obj/effect/temp_visual/dir_setting/bloodsplatter(get_turf(L), pick(GLOB.alldirs))
			special_attack = FALSE
		if("white")
			playsound(user, 'sound/effects/ordeals/violet/midnight_portal_on.ogg', 75)
			to_chat(user, "<span class='warning'>Not done</span>")
			if(!do_after(user, 7, src))
				return
			special_attack = FALSE

/obj/item/ego_weapon/god_delusion/proc/pale_pulse(turf/eye, mob/living/user)
	for(var/turf/T in range(pulse_range, eye))
		new /obj/effect/temp_visual/pale_eye_attack(T)
	for(var/mob/living/L in range(pulse_range, eye))
		if(L == user)
			continue
		if(faction_check(user.faction, L.faction))
			continue
		if(L.status_flags & GODMODE)
			continue
		if(L.stat == DEAD)
			continue
		L.apply_damage(special_damage, PALE_DAMAGE, null, L.run_armor_check(null, PALE_DAMAGE))
	var/obj/effect/pale_eye/D = new(eye) // The Decoy
	animate(D, alpha = 0, transform = matrix()*1.25, time = 4)
	QDEL_IN(D, 5)
	playsound(eye, 'sound/effects/ordeals/violet/midnight_pale_attack.ogg', 75, TRUE, 8)

/obj/item/ego_weapon/god_delusion/attack(mob/living/M, mob/living/user)
	..()
	if(prob(8))
		to_chat(user, span_info("[pick(intrusive_thoughts)]"), MESSAGE_TYPE_LOCALCHAT)

/obj/item/ego_weapon/god_delusion/proc/Transform()
	if(!istype(src)) // Check if item exists
		return
	var/L = src.loc
	addtimer(CALLBACK(src, .proc/Transform), switch_cooldown_time) // Restarts the timer
	index = index + 1
	if(index >= 5) // Cap
		index = 1
	special_attack = FALSE
	form = weapon_list[index]
	icon_state = "delusion_[form]"
	update_icon_state()
	to_chat(L,"<span class='notice'>[src] changes its deity!</span>")
	playsound(L, 'sound/effects/ordeals/violet/midnight_portal_off.ogg', 50, FALSE)
	force = weapon_list[form][1]
	damtype = weapon_list[form][2]
	special = weapon_list[form][3]
	special_damage = weapon_list[form][4]

// Fast RED gauntlet, combo system, heals/gib on kill, burrowing special ability
/obj/item/ego_weapon/eternal_feast
	name = "Endless Feast"
	desc = "They were ruthless, it was never enough. \
	They fought for the right to eat, they killed for the chance to be killed. \
	It didnt matter, it never mattered. Not for them and not for us."
	special = "This weapon comes with a combo system. It will also heal the user slightly on kill. \
	\nUse this weapon to burrow beneath the floor, re-emerging a short time after dealing an aoe of RED damage."
	icon_state = "feast"
	force = 36
	damtype = RED_DAMAGE
	attack_verb_continuous = list("crunches", "punches")
	attack_verb_simple = list("crunch", "punch")
	hitsound = 'sound/weapons/fixer/generic/fist2.ogg'
	actions_types = list(/datum/action/item_action/toggle_combo)
	attribute_requirements = list(
							FORTITUDE_ATTRIBUTE = 100,
							PRUDENCE_ATTRIBUTE = 100,
							TEMPERANCE_ATTRIBUTE = 100,
							JUSTICE_ATTRIBUTE = 100
							)
	var/combo = 0
	var/combo_time
	var/combo_wait = 10
	var/combo_on = TRUE
	var/special_cooldown
	var/special_cooldown_time = 30 SECONDS
	var/special_damage = 240
	var/list/intrusive_thoughts = list(
		"It was inevitable until our tastes accustomed to our meals. Could we ever go back?",
		"They were greedy weren't they? They deserved this didnt they?",
		"We are no different, consuming all in our path. What decided that they should die instead of us?",
		"Our hunger was born out of necessity, they would eat the same without a second thought."
	)

/datum/action/item_action/toggle_combo
	name = "Toggle Combo"
	desc = "Toggles your combo for the current weapon."
	icon_icon = 'icons/obj/ego_weapons.dmi'
	button_icon_state = "feast"

/datum/action/item_action/toggle_combo/Trigger()
	var/obj/item/ego_weapon/eternal_feast/H = target
	if(istype(H))
		H.toggle_combo(owner)

/obj/item/ego_weapon/eternal_feast/proc/toggle_combo(mob/living/user)
	if(combo_on)
		combo_on = FALSE
		to_chat(user,"<span class='warning'>You hold back the gauntlets hunger, no longer performing a combo.</span>")
	else
		combo_on = TRUE
		to_chat(user,"<span class='warning'>You let loose the gauntlets hunger, letting you perofrm a combo.</span>")

/obj/item/ego_weapon/eternal_feast/attack_self(mob/user)
	..()
	if(!CanUseEgo(user))
		return
	if(special_cooldown > world.time)
		to_chat(user, "<span class='warning'>You can't burrow yet!</span>")
		return
	if(do_after(user, 5, src))
		// Anim and prep for burrow attack
		animate(user, alpha = 0,pixel_x = 0, pixel_z = -16, time = 0.1 SECONDS)
		user.pixel_z = -16
		special_cooldown = world.time + special_cooldown_time
		var/obj/effect/temp_visual/target_field/underminer = new /obj/effect/temp_visual/target_field(user.loc) // Make some other effect for it
		underminer.orbit(user, 0)
		user.density = FALSE
		addtimer(CALLBACK(src, .proc/burrow_attack, user), 3 SECONDS) //3 secs of burrowing

// 4 Hit combo, if kills heal a bit of health.
/obj/item/ego_weapon/eternal_feast/attack(mob/living/M, mob/living/user)
	if(!CanUseEgo(user))
		return
	if(world.time > combo_time || !combo_on)
		combo = 0
	combo_time = world.time + combo_wait
	if(combo==4)
		combo = 0
		user.changeNext_move(CLICK_CD_MELEE * 2)
		force *= 3	// workshop this value
		playsound(src, 'sound/effects/ordeals/amber/dusk_attack.ogg', 75, FALSE, 9)
		to_chat(user,"<span class='warning'>It feasts, you take a moment to recollect your stance.</span>")
	else
		user.changeNext_move(CLICK_CD_MELEE * 0.4)
	..()
	combo += 1
	if(prob(4))
		to_chat(user, "<span class='controlradio'>[pick(intrusive_thoughts)]</span>", MESSAGE_TYPE_LOCALCHAT)
	force = initial(force)
	if(M.stat == DEAD)
		to_chat(user, "<span class='controlradio'>Another meal to our masses. Are you finally fulfilled?</span>", MESSAGE_TYPE_LOCALCHAT)
		M.gib()
		user.adjustBruteLoss(-user.maxHealth*0.10) // 10% heal, super small.

/obj/item/ego_weapon/eternal_feast/proc/burrow_attack(mob/user)
	playsound(src, 'sound/effects/ordeals/amber/midnight_out.ogg', 50, FALSE, 9)
	to_chat(user, "<span class='warning'>You emerge from the ground!</span>")
	animate(user, alpha = 255,pixel_x = 0, pixel_z = -16, time = 0.1 SECONDS)
	user.pixel_z = 0
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(get_turf(user), user) //Temporary, make a new effect for it
	animate(D, alpha = 0, transform = matrix()*2, time = 5)
	user.density = TRUE
	for(var/turf/open/T in view(1, user))
		new /obj/effect/temp_visual/small_smoke/halfsecond(T)
	for(var/mob/living/L in livinginrange(1, user))
		if(L.z != user.z)
			continue
		var/modified_damage = (special_damage * force_multiplier)
		if(L == user || ishuman(L))
			continue
		L.apply_damage(modified_damage, RED_DAMAGE, null, L.run_armor_check(null, RED_DAMAGE), spread_damage = TRUE)
		to_chat(L, "<span class='userdanger'>You are crunched by [src]!</span>")
		if(L.health < 0)
			L.gib()

/obj/item/ego_weapon/meaningless_march // Look at Soulmate code, per hit charge a little bit.
	name = "Meaningless March"
	desc = "What purpose were our efforts without a sacrafice? \
	We marched the red line into the jaws of death, and returned with an ever-burning resolve. \
	No matter the cost we met, no matter the price we paid. In the end it won't matter."
	special = "This weapon builds up charge on hit. The projectiles fired from the hat are chosen from 5 projectiles."
	icon_state = "march"
	force = 70
	damtype = RED_DAMAGE
	attack_verb_continuous = list("crunches", "punches")
	attack_verb_simple = list("crunch", "punch")
	hitsound = 'sound/effects/ordeals/crimson/ball.ogg'
	attribute_requirements = list(
							FORTITUDE_ATTRIBUTE = 100,
							PRUDENCE_ATTRIBUTE = 100,
							TEMPERANCE_ATTRIBUTE = 100,
							JUSTICE_ATTRIBUTE = 100
							)
	var/gun_cooldown
	var/gun_cooldown_time = 1 SECONDS
	var/gun_charge
	var/gun_charge_cost = 2
	var/projectiles = list(
	/obj/projectile/ego_bullet/gunblade
	)
	var/list/intrusive_thoughts = list(
		"Join us into one body, cast away your flesh for new unity.",
		"One day our voices will be heard, and when it echos through the halls we will march down in triumph.",
		"We joined in an endless harmony, and only wished to share it with the world.",
		"The candles we lit will be snuffed out, so let us burn more radiant than ever."
	)

/obj/item/ego_weapon/meaningless_march/examine(mob/user)
	. = ..()
	. += "Spend [gun_charge]/[gun_charge_cost] charge to fire a random projectile from the hat."

/obj/item/ego_weapon/meaningless_march/attack(mob/living/M, mob/living/user)
	if(!CanUseEgo(user))
		return
	if(!((M.health<=M.maxHealth *0.1 || M.stat == DEAD) && !(GODMODE in M.status_flags)))
		gun_charge+=1
	..()
	if(prob(8))
		to_chat(user, "<span class='redteamradio'>[pick(intrusive_thoughts)]</span>", MESSAGE_TYPE_LOCALCHAT)
	if(M.stat == DEAD)
		to_chat(user, "<span class='controlradio'>Another meal to our masses. Are you finally fulfilled?</span>", MESSAGE_TYPE_LOCALCHAT)
		M.gib()
		user.adjustBruteLoss(-user.maxHealth*0.10) // 10% heal, super small.

/obj/item/ego_weapon/meaningless_march/afterattack(atom/target, mob/living/user, proximity_flag, clickparams)
	if(!CanUseEgo(user))
		return
	if(!(gun_charge>=gun_charge_cost))
		to_chat(user, "<span class='warning'>You don't have enough charge!</span>")
		return
	if(!proximity_flag && gun_cooldown <= world.time)
		gun_charge -= gun_charge_cost
		var/turf/proj_turf = user.loc
		if(!isturf(proj_turf))
			return
		var/obj/projectile/ego_bullet/gunblade/G = new /obj/projectile/ego_bullet/gunblade(proj_turf) // Use pick() to get the projectile type and intilaize it.
		// var/pick(projectiles)/G = new pick(projectiles)(proj_turf)
		playsound(user, 'sound/weapons/plasma_cutter.ogg', 100, TRUE)
		G.firer = user
		G.preparePixelProjectile(target, user, clickparams)
		G.fire()
		G.damage *= force_multiplier
		gun_cooldown = world.time + gun_cooldown_time
		return

/obj/item/gun/ego_gun/painful_purpose
	name = "Painful Purpose"
	desc = "To suffer the burden of life is to exist in this world peacefully. \
	We would not accept this peace, rather we would take it by the hands. \
	The tower we built to finally see, to hold our very lives in our hands. \
	It crumbled, it brought ruin, it only intensified our pain, and our suffering forevermore."
	icon_state = "purpose"
	inhand_icon_state = "purpose"
	special = "This weapon ramps up its fire rate as you continue to fire. At a certain point it will charge a massive indiscriminate BLACK damage 3x3 laser that pierces walls."
	ammo_type = /obj/item/ammo_casing/caseless/ego_magicbullet
	weapon_weight = WEAPON_HEAVY
	fire_sound = 'sound/abnormalities/freischutz/shoot.ogg'
	fire_delay = 18
	attribute_requirements = list(
							FORTITUDE_ATTRIBUTE = 100,
							PRUDENCE_ATTRIBUTE = 100,
							TEMPERANCE_ATTRIBUTE = 100,
							JUSTICE_ATTRIBUTE = 100
							)

/obj/item/ego_weapon/familial_strength
	name = "Familial Strength"
	desc = "When the night came, the sweepers followed. \
	They cleaned the streets clean, they left nothing in their wake. \
	Such is life in the city, a life we so desperately tried to change."
	special = "On hit recover 10% of damage dealt as both SP and HP. \nThis weapon will gib on kill, healing 20% of max SP and HP.. \nUse this weapon to prepare a series of rapid gashes to be performed upon your enemy."
	icon_state = "familial"
	force = 20
	attack_speed = 0.3
	damtype = BLACK_DAMAGE
	attack_verb_continuous = list("slashes", "gashes")
	attack_verb_simple = list("slash", "gash")
	hitsound = 'sound/effects/ordeals/indigo/stab_1.ogg'
	attribute_requirements = list(
							FORTITUDE_ATTRIBUTE = 100,
							PRUDENCE_ATTRIBUTE = 100,
							TEMPERANCE_ATTRIBUTE = 100,
							JUSTICE_ATTRIBUTE = 100
							)
	var/special_attack = FALSE
	var/special_cooldown
	var/special_cooldown_time = 30 SECONDS
	var/list/intrusive_thoughts = list(
		"For them family was everything, perhaps they were more human than we thought.",
		"We shielded the weak from their claws, yet would they be better being fluid for the sweepers?",
		"Those piercing red eyes, their gleaming red claws, there was nothing we could do.",
		"Such cruelty every night yet needed to keep the streets clean, disgusting."
	)

/obj/item/ego_weapon/familial_strength/attack(mob/living/target, mob/living/carbon/human/user)
	if(!CanUseEgo(user))
		return
	if(!istype(user))
		return
	if(!(target.status_flags & GODMODE) && target.stat != DEAD)
		var/heal_amt = force*0.10
		if(isanimal(target))
			var/mob/living/simple_animal/S = target
			if(S.damage_coeff.getCoeff(damtype) > 0)
				heal_amt *= S.damage_coeff.getCoeff(damtype)
			else
				heal_amt = 0
		user.adjustBruteLoss(-heal_amt)
		user.adjustSanityLoss(-heal_amt)
	..()
	if(prob(2))
		to_chat(user, "<span class='scienceradio'>[pick(intrusive_thoughts)]</span>", MESSAGE_TYPE_LOCALCHAT)
	if(target.stat == DEAD)
		target.gib()
		user.adjustBruteLoss(-user.maxHealth*0.15) // Enjoy
		user.adjustSanityLoss(-user.maxSanity*0.15) // Enjoy

/obj/item/ego_weapon/familial_strength/attack_self(mob/user)
	if(!CanUseEgo(user))
		return
	if(special_cooldown > world.time)
		to_chat(user, "<span class='warning'>Your gashes are not ready!</span>")
		return
	if(special_attack)
		special_attack = FALSE
		to_chat(user,"<span class='notice'>You hold back your claws.</span>")
	else
		special_attack = TRUE
		to_chat(user,"<span class='notice'>You prepare to dispose of the trash.</span>")

/obj/item/ego_weapon/familial_strength/afterattack(atom/target, mob/living/user, proximity_flag, clickparams)
	if(!CanUseEgo(user))
		return
	if(!special_attack)
		return
	if(!isliving(target))
		return
	special_cooldown = world.time + special_cooldown_time
	var/obj/effect/temp_visual/target_field/you = new /obj/effect/temp_visual/target_field(target.loc) // Temporary, if you can move to an overlay that would be great
	you.orbit(target, 0)
	QDEL_IN(you, 10)
	to_chat(user,"<span class='notice'>You've found your target.</span>")
	// Add some sounds
	if(!do_after(user, 1 SECONDS, src))
		to_chat(user,"<span class='scienceradio'>Not this one.</span>")
		special_attack = FALSE
		return
	trash_disposal(user, target)

/obj/item/ego_weapon/familial_strength/proc/trash_disposal(mob/living/user, mob/living/target)
	var/turf/tp_loc= get_step(target.loc, pick(GetSafeDir(get_turf(target))))
	ADD_TRAIT(src, TRAIT_NODROP, STICKY_NODROP)
	user.Stun(5 SECONDS, ignore_canstun = TRUE)
	target.Stun(5 SECONDS, ignore_canstun = TRUE)
	// Some movement effect here
	user.forceMove(tp_loc)
	for(var/i = 1 to 4)
		src.attack(target, user)
		if(target.stat == DEAD)
			break
		sleep(2)
	user.AdjustStun(-5 SECONDS, ignore_canstun = TRUE)
	target.AdjustStun(-5 SECONDS, ignore_canstun = TRUE)
	REMOVE_TRAIT(src, TRAIT_NODROP, STICKY_NODROP)
	to_chat(user,span_info("For family."))
	special_attack = FALSE

// FOR ADMIN USE ONLY, SHOULD NEVER BE OBTAINED IN GAME
// Weapon dps is 142.9 at 0 just, 220.9 at 130.
/obj/item/ego_weapon/the_claw
	name = "The Claw"
	desc = "A large metal arm with a claw for a hand. Used by the Executioners of the Claw."
	special = "This weapon can not be removed once equipped by any normal means. Use in hand to inject the selected serum with a cooldown of 30 Seconds. \
	\nEach serum changes the damage type of the weapon."
	icon_state = "claw"
	force = 60
	attack_speed = 0.6
	damtype = RED_DAMAGE
	slot_flags = null
	attack_verb_continuous = list("slashes", "eviscerates", "tears")
	attack_verb_simple = list("slash", "eviscerate", "tear")
	hitsound = 'ModularTegustation/Tegusounds/claw/attack.ogg'
	actions_types = list(/datum/action/item_action/switch_serum)
	attribute_requirements = list(
							FORTITUDE_ATTRIBUTE = 130,
							PRUDENCE_ATTRIBUTE = 130,
							TEMPERANCE_ATTRIBUTE = 130,
							JUSTICE_ATTRIBUTE = 130
							)
	var/serum = "K"
	var/special_attack = FALSE
	var/special_cooldown
	var/special_cooldown_time = 30 SECONDS
	var/dash_charges = 3
	var/dash_limit = 3
	var/dash_range = 8
	var/justicemod
	var/dash_ignore_walls = FALSE
	var/serum_desc = "This serum heals you by 25% of max health after injecting for 2 seconds."

/obj/item/ego_weapon/the_claw/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, STICKY_NODROP) //You may not drop this, it is your arm, do you think baral can take off his claw?

/obj/item/ego_weapon/the_claw/examine(mob/user)
	. = ..()
	. += span_notice("Current Serum: Serum [serum]")
	. += span_notice("[serum_desc]")

/obj/item/ego_weapon/the_claw/equipped(mob/living/user)
	. = ..()
	to_chat(user, span_warning("[src] attaches itself to your body!"))
	var/userjust = (get_modified_attribute_level(user, JUSTICE_ATTRIBUTE))
	justicemod = 1 + userjust/100

/obj/item/ego_weapon/the_claw/dropped()
	src.visible_message(span_warning("The claw arm disappears, you've violated a crucial law of physics."))
	playsound(src, 'ModularTegustation/Tegusounds/claw/death.ogg', 50, TRUE)
	qdel(src)
	return ..()

/datum/action/item_action/switch_serum
	name = "Swap Serum"
	desc = "Swaps your currently selected serum."
	icon_icon = 'icons/obj/ego_weapons.dmi'
	button_icon_state = "claw"

/datum/action/item_action/switch_serum/Trigger()
	var/obj/item/ego_weapon/the_claw/H = target
	if(istype(H))
		H.SwitchSerum(owner)

/obj/item/ego_weapon/the_claw/proc/SwitchSerum(mob/living/user)
	switch(serum)
		if("K")
			serum = "R"
			serum_desc = "This serum prepares [dash_charges] deadly dashes to the location you choose, dealing massive RED damage to all that stand in your way. This serum's charge time is halved."
			damtype = RED_DAMAGE
		if("R")
			serum = "W"
			serum_desc = "This serum locks on to one target of your choosing, and teleports them through multiple locations dealing massive BLACK damage at the end."
			damtype = BLACK_DAMAGE
			dash_charges = dash_limit
		if("W")
			serum = "Tri"
			serum_desc = "Will inject all 3 serums at once, providing a heal fo 15% of your max HP and prepares a mass slash attack to all enemies within a 12 tile radius. This however overclocks the injection systems and double the cooldown."
			damtype = PALE_DAMAGE
			force = 40
		if("Tri")
			serum = "K"
			serum_desc = "This serum heals you by 50% of max health after injecting for 2 seconds."
			damtype = WHITE_DAMAGE
			force = initial(force)
	special_attack = FALSE
	to_chat(user, span_notice("You prime your serum [serum]."))
	playsound(src, 'ModularTegustation/Tegusounds/claw/error.ogg', 50, TRUE)

/obj/item/ego_weapon/the_claw/attack_self(mob/living/user)
	..()
	if(!CanUseEgo(user))
		return
	if(special_cooldown > world.time)
		to_chat(user, span_warning("Your serum is not ready!"))
		return
	switch(serum)
		if("K")
			to_chat(user, span_notice("You inject the serum K."))
			playsound(src, 'ModularTegustation/Tegusounds/claw/prepare.ogg', 50, TRUE)
			var/obj/effect/serum_energy/heals = new /obj/effect/serum_energy(user.loc)
			heals.color = "#51e715"
			if(!do_after(user, 2 SECONDS, src))
				qdel(heals)
				return
			animate(heals, alpha = 0, transform = matrix()*2, time = 5)
			to_chat(user, span_notice("The injection is complete, you feel much better."))
			user.adjustBruteLoss(-user.maxHealth*0.50) // Heals 50% of max HP, powerful because its admin only.
			special_cooldown = world.time + special_cooldown_time
			QDEL_IN(heals, 5)
		if("R")
			to_chat(user, span_notice("You prepare the serum R."))
			playsound(src, 'ModularTegustation/Tegusounds/claw/r_prep.ogg', 50, TRUE)
			special_attack = TRUE
			var/obj/effect/serum_energy/dash = new /obj/effect/serum_energy(user.loc)
			dash.color = "#c8720c"
			dash.orbit(user, 0)
			QDEL_IN(dash, 10)
		if("W")
			to_chat(user, span_notice("You prepare the serum W."))
			playsound(src, 'ModularTegustation/Tegusounds/claw/prepare.ogg', 50, TRUE)
			special_attack = TRUE
			var/obj/effect/serum_energy/death = new /obj/effect/serum_energy(user.loc)
			death.color = "#288ad3"
			death.orbit(user, 0)
			QDEL_IN(death, 10)
		if("Tri")
			to_chat(user, span_notice("You prepare all 3 serums"))
			playsound(src, 'ModularTegustation/Tegusounds/claw/prepare.ogg', 50, TRUE)
			var/obj/effect/serum_energy/omega_death = new /obj/effect/serum_energy(user.loc)
			omega_death.orbit(user, 0)
			QDEL_IN(omega_death, 10)
			if(!do_after(user, 2 SECONDS, src))
				to_chat(user, span_notice("You disengage the injection sequence."))
				return
			special_cooldown = world.time + special_cooldown_time
			TriSerum(user)

/obj/item/ego_weapon/the_claw/afterattack(atom/A, mob/living/user, proximity_flag, params)
	if(!CanUseEgo(user))
		return
	if(!special_attack)
		return
	switch(serum)
		if("R") // Thanks helper
			var/turf/target_turf = get_turf(user)
			var/list/line_turfs = list(target_turf)
			var/list/mobs_to_hit = list()
			for(var/turf/T in getline(user, get_ranged_target_turf_direct(user, A , dash_range)))
				if(!dash_ignore_walls && T.density)
					break
				target_turf = T
				line_turfs += T
			user.forceMove(target_turf)
			// "Movement" effect
			for(var/i = 1 to line_turfs.len)
				var/turf/T = line_turfs[i]
				if(!istype(T))
					continue
				for(var/mob/living/L in view(1, T))
					mobs_to_hit |= L
				var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(T, user)
				D.alpha = min(150 + i*15, 255)
				animate(D, alpha = 0, time = 2 + i*2)
				for(var/turf/TT in range(T, 1))
					new /obj/effect/temp_visual/small_smoke/halfsecond(TT)
				playsound(user, 'ModularTegustation/Tegusounds/claw/move.ogg', 50, 1)
				for(var/obj/machinery/door/MD in T.contents) // Hiding behind a door mortal?
					if(MD.density)
						addtimer(CALLBACK (MD, .obj/machinery/door/proc/open))
			// Damage
			for(var/mob/living/L in mobs_to_hit)
				if(user.faction_check_mob(L))
					continue
				if(L.status_flags & GODMODE)
					continue
				visible_message(span_boldwarning("[user] claws through [L]!"))
				playsound(L, 'ModularTegustation/Tegusounds/claw/stab.ogg', 25, 1)
				new /obj/effect/temp_visual/cleave(get_turf(L))
				L.apply_damage(justicemod*60, RED_DAMAGE, null, L.run_armor_check(null, RED_DAMAGE))
			dash_charges--
			if(dash_charges == 0)
				special_attack = FALSE
				special_cooldown = world.time + (special_cooldown_time * 0.5)
				dash_charges = dash_limit
				to_chat(user, span_warning("Your dashes have run out."))
		if("W")
			if(!isliving(A))
				return
			var/obj/effect/temp_visual/target_field/uhoh = new /obj/effect/temp_visual/target_field(A.loc)
			uhoh.orbit(A, 0)
			playsound(A, 'ModularTegustation/Tegusounds/claw/eviscerate1.ogg', 100, 1)
			to_chat(A, span_warning("[user] stares you down, running won't help you."))
			if(!do_after(user, 1 SECONDS, src))
				to_chat(user, span_notice("Whats this, mercy?"))
				qdel(uhoh)
				return
			special_attack = FALSE
			special_cooldown = world.time + special_cooldown_time
			qdel(uhoh)
			SerumW(user, A)

/obj/item/ego_weapon/the_claw/proc/SerumW(mob/living/user, mob/living/target) // It wasn't nice meeting you, farewell.
	var/turf/tp_loc = get_step(target, pick(GLOB.alldirs))
	user.forceMove(tp_loc)
	user.face_atom(target)
	new /obj/effect/temp_visual/emp/pulse(tp_loc)
	playsound(tp_loc, 'ModularTegustation/Tegusounds/claw/move.ogg', 100, 1)
	user.Stun(60 SECONDS, ignore_canstun = TRUE) // Here we go.
	target.Stun(60 SECONDS, ignore_canstun = TRUE)
	to_chat(user, span_notice("You grab [target] by the neck."))
	to_chat(target, span_warning("Your neck is grabbed by [user]!."))
	playsound(user, 'ModularTegustation/Tegusounds/claw/w_portal.ogg', 50, 1)
	new /obj/effect/temp_visual/serum_w(target.loc)
	target.face_atom(user)
	animate(target, pixel_x = 0, pixel_z = 8, time = 5) // The gripping
	sleep(10) // Dramatic effect
	target.visible_message(
		span_warning("[user] disappears, taking [target] with them!"),
		span_userdanger("[user] teleports you with them!")
	)
	animate(target, pixel_x = 0, pixel_z = 0, time = 1)
	var/list/teleport_turfs = list()
	var/list/alt = list("rcorp", "wcorp", "city")
	if(SSmaptype.maptype in alt)
		for(var/turf/T in range(12, user))
			if(!IsSafeTurf(T))
				continue
			teleport_turfs += T
	else
		for(var/turf/T in shuffle(GLOB.department_centers))
			if(T in range(12, user))
				continue
			teleport_turfs += T
	for(var/i = 1 to 5) // Thanks egor
		if(!LAZYLEN(teleport_turfs))
			break
		var/turf/target_turf = pick(teleport_turfs)
		playsound(tp_loc, 'ModularTegustation/Tegusounds/claw/eviscerate2.ogg', 100, 1)
		tp_loc.Beam(target_turf, "nzcrentrs_power", time=15)
		playsound(target_turf, 'ModularTegustation/Tegusounds/claw/eviscerate2.ogg', 100, 1)
		user.forceMove(target_turf)
		new /obj/effect/temp_visual/emp/pulse(target_turf)
		for(var/mob/living/AA in range(1, target_turf))
			if(faction_check(user.faction, AA.faction))
				continue
			if(AA == target)
				continue
			to_chat(AA, span_userdanger("[user] slashes you!"))
			AA.apply_damage(justicemod*50, BLACK_DAMAGE, null, AA.run_armor_check(null, BLACK_DAMAGE))
			new /obj/effect/temp_visual/cleave(get_turf(AA))
		for(var/obj/item/I in get_turf(target))
			if(I.anchored)
				continue
			I.forceMove(tp_loc)
		tp_loc= get_step(user.loc, pick(GetSafeDir(get_turf(user))))
		target.forceMove(tp_loc)
		new /obj/effect/temp_visual/emp/pulse(tp_loc)
		user.face_atom(target)
		sleep(4)
	playsound(user, 'ModularTegustation/Tegusounds/claw/w_slashes.ogg', 75, 1)
	user.face_atom(target)
	target.visible_message(
		span_warning("Slashes appear around [target], its unwise to stick around.")
	)
	for(var/turf/T in range(2, target))
		if(prob(25))
			new /obj/effect/temp_visual/justitia_effect(T)
	sleep(20)
	for(var/mob/living/AA in range(2, target))
		if(faction_check(user.faction, AA.faction))
			continue
		if(AA == target)
			continue
		to_chat(AA, span_userdanger("You start gushing blood!"))
		AA.apply_damage(justicemod*60, BLACK_DAMAGE, null, AA.run_armor_check(null, BLACK_DAMAGE)) // Shouldn't have gotten close.
		new /obj/effect/temp_visual/cleave(get_turf(AA))
	user.AdjustStun(-60 SECONDS, ignore_canstun = TRUE)
	target.AdjustStun(-60 SECONDS, ignore_canstun = TRUE)
	playsound(user, 'ModularTegustation/Tegusounds/claw/w_fin.ogg', 75, 1)
	target.visible_message(
		span_warning("[target] suddenly gushes blood!"),
		span_userdanger("As [user] lets go, you start gushing blood!")
	)
	target.apply_damage(justicemod*150, BLACK_DAMAGE, null, target.run_armor_check(null, BLACK_DAMAGE)) // 150 so that it can scale form justice to about 300
	for(var/turf/T in range(1, target))
		if(prob(35))
			var/obj/effect/decal/cleanable/blood/B = new /obj/effect/decal/cleanable/blood(get_turf(target))
			B.bloodiness = 100
	if(target.health <= 0)
		target.gib()

/obj/item/ego_weapon/the_claw/proc/TriSerum(mob/living/user) // from PT, which was from Blue reverb
	var/list/targets = list()
	for(var/mob/living/L in livinginrange(12, user))
		if(L == src)
			continue
		if(faction_check(user.faction, L.faction))
			continue
		if(L.status_flags & GODMODE)
			continue
		if(L.stat == DEAD)
			continue
		targets += L
		var/obj/effect/temp_visual/target_field/blue/oh_dear = new /obj/effect/temp_visual/target_field/blue(L.loc)
		oh_dear.orbit(L, 0)
		playsound(L, 'ModularTegustation/Tegusounds/claw/eviscerate1.ogg', 25, 1)
		to_chat(L, span_warning("You're being hunted down by [user]!."))
		QDEL_IN(oh_dear, 10)
	if(!LAZYLEN(targets))
		to_chat(user, span_warning("There are no enemies nearby!"))
		return
	new /obj/effect/temp_visual/serum_w(user.loc)
	playsound(user, 'ModularTegustation/Tegusounds/claw/w_portal.ogg', 50, 1)
	sleep(1 SECONDS) // Dramatic effect
	for(var/mob/living/L in targets)
		var/turf/prev_loc = get_turf(user)
		var/turf/tp_loc= get_step(L.loc, pick(GetSafeDir(get_turf(L))))
		user.forceMove(tp_loc)
		to_chat(L, span_userdanger("[user] decimates you!"))
		playsound(L, 'ModularTegustation/Tegusounds/claw/eviscerate2.ogg', 100, 1)
		L.apply_damage(justicemod*60, PALE_DAMAGE, null, L.run_armor_check(null, BLACK_DAMAGE))
		prev_loc.Beam(tp_loc, "bsa_beam", time=25)
		new /obj/effect/temp_visual/cleave(get_turf(L))
		sleep(3)

/obj/effect/serum_energy
	name = "serum energies"
	icon = 'ModularTegustation/Teguicons/tegu_effects.dmi'
	icon_state = "white_shield"
	layer = BYOND_LIGHTING_LAYER
	plane = BYOND_LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/temp_visual/serum_w
	name = "serum w portal"
	desc = "No... Not again..."
	icon = 'icons/effects/effects.dmi'
	icon_state = "blueshatter"
	randomdir = FALSE
	duration = 1 SECONDS
	layer = POINT_LAYER
