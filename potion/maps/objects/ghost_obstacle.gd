extends Obstacle

func activate():
	activated.emit()
	
	var tables = get_tree().get_nodes_in_group(Table.GROUP).filter(func(t): return t.has_item())
	if tables.is_empty(): return
	
	var table = tables.pick_random() as Table
	if not table: return
	
	table.start_floating()
	if await table.floating_finished:
		table.remove_item()
	
	finished.emit()
