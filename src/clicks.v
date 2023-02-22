module main

import ui
import gx
import clipboard

fn (mut app App) on_checkbox_click(mut cb ui.CheckBox) {
	for check in app.checkbox_row.children {
		mut checkbox := app.window.get_or_panic[ui.CheckBox](check.id)
		checkbox.checked = false
	}
	cb.checked = true
	app.set_result_text_by_checkbox()
}

fn (mut app App) minus_btn_click(b &ui.Button) {
	mut parent := app.window.get_or_panic[ui.Stack]('${b.parent.id}')
	mut grand_parent := app.window.get_or_panic[ui.Stack]('${parent.parent.id}')
	for i, mut c in grand_parent.children {
		//println('---> ${c.id}')
		if b.parent.id == c.id {
			grand_parent.remove(at: i)
			//println('${c.id} removed')
		}
		// child := app.window.get_or_panic[ui.Stack]('${c.id}')
		// for cc in child.children {
		// 	println('|- ${cc.id}')
		// }
	}
}

fn (mut app App) on_qp_plus_click(b &ui.Button) {
	app.parameter_row.add(
		// at:0
		child: app.make_name_value_row()
		heights: ui.fit
		widths: ui.fit
		spacing: 5
	)
}

fn (mut app App) on_request_click(b &ui.Button) {
	if app.request_type.selected_index == -1 {
		app.request_type.style.border_color = gx.red
		return
	}

	app.fetch_request_result()
}

fn (mut app App) on_mouse_click(window &ui.Window, e ui.MouseEvent) {
	if e.button == .right {
		if e.y < app.url_box.y + app.url_box.height && e.y > app.url_box.y { // right click - paste to url box
			println('mouse paste')
			if !app.url_box.is_sel_active() {
				mut c := clipboard.new()
				app.url_box.set_text(c.get_text())
				c.destroy()
			}
		}
	}
}
