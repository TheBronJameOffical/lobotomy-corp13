/obj/item/clothing/under/rank/civilian/curator
	name = "sensible suit"
	desc = "It's very... sensible."
	icon = 'icons/obj/clothing/under/suits.dmi'
	icon_state = "red_suit"
	inhand_icon_state = "red_suit"
	worn_icon = 'icons/mob/clothing/under/suits.dmi'
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/curator/skirt
	name = "sensible suitskirt"
	desc = "It's very... sensible."
	icon = 'icons/obj/clothing/under/suits.dmi'
	icon_state = "red_suit_skirt"
	inhand_icon_state = "red_suit"
	worn_icon = 'icons/mob/clothing/under/suits.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/rank/civilian/curator/zwei_shield
	name = "zwei association uniform"
	desc = "A rugged uniform suitable for a professional mercenary."
	icon = 'icons/obj/clothing/under/civilian.dmi'
	icon_state = "curator"
	inhand_icon_state = "curator"
	worn_icon = 'icons/mob/clothing/under/civilian.dmi'

/obj/item/clothing/under/rank/civilian/curator/nasa
	name = "\improper NASA jumpsuit"
	desc = "It has a NASA logo on it and is made of space-proofed materials."
	icon = 'icons/obj/clothing/under/color.dmi'
	icon_state = "black"
	inhand_icon_state = "bl_suit"
	worn_icon = 'icons/mob/clothing/under/color.dmi'
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST | GROIN | LEGS | ARMS //Needs gloves and shoes with cold protection to be fully protected.
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	can_adjust = FALSE
	resistance_flags = NONE
