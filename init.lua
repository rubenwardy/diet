diet = {
	players = {}
}

function diet.item_eat(max)	
	return function(itemstack, user, pointed_thing)	
		-- Process player data
		local name = user:get_player_name()
		local player = diet.__player(name)
		local item = itemstack:get_name()
		
		-- Get type
		local ftype = ""
		if (minetest.registered_items[item] and minetest.registered_items[item].groups) then
			local groups = minetest.registered_items[item].groups
			if groups.food_type_meal then
				ftype = "meal"
			elseif groups.food_type_snack then
				ftype = "snack"
			elseif groups.food_type_dessert then
				ftype = "dessert"
			elseif groups.food_type_drink then
				ftype = "drink"
			end
		end
		
		-- Calculate points
		local points = max
		if (#player.eaten>0) then
			local same_food = 0
			local same_type = 0
			for _,v in pairs(player.eaten) do
				if v[1] == item then
					same_food = same_food + 1
				end
				if v[2] == ftype then
					same_type = same_type + 1
				end
			end
			local mult = same_food/10
			points = points * 1-mult
			
			if (mult > 0.9) then
				local desc = item
				if (minetest.registered_items[item] and minetest.registered_items[item].description) then
					desc = minetest.registered_items[item].description
				end
				minetest.chat_send_player(name,"Your stomach hates "..desc)
			elseif (mult > 0.4) then
				minetest.chat_send_player(name,"Your stomach could do with a change.")
			end
			if points > max then
				error("[DIET] This shouldn't happen! points > max")
				return
			end
		end
		
		-- Increase health
		local hp = user:get_hp()		
		if (hp+points > 20) then
			hp = 20
		else
			hp = hp + points
		end		
		user:set_hp(hp)
		
		-- Register
		diet.__register_eat(player,item,ftype)
		
		-- Remove item
		itemstack:take_item()
		return itemstack
	end
end

function diet.__player(name)
	if name == "" then
		return nil
	end
	if diet.players[name] then
		return diet.players[name]
	end
	
	diet.players[name] = {
		name = name,
		eaten = {}
	}
	return diet.players[name]
end

function diet.__register_eat(player,food,type)
	table.insert(player.eaten,{food,type})
	
	while (#player.eaten > 10) do
		table.remove(player.eaten,1)
	end
end
