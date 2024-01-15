function has_train_equipment(train,equipment)
	for _,locomotive in pairs(train.locomotives.front_movers) do
        if locomotive.grid.count(equipment)>0 then
            return true
        end
    end
	for _,locomotive in pairs(train.locomotives.back_movers) do
        if locomotive.grid.count(equipment)>0 then
            return true
        end
    end
end

