module main

import gx
import ui
import rand
import x.json2

fn (mut app App) set_result_text_by_checkbox() {
	for checkbox in app.checkbox_row.children {
		cb := app.window.get_or_panic[ui.CheckBox](checkbox.id)
		if cb.checked {
			mut text := app.response.str()
			match cb.id {
				'checkbox_body' {
					if app.response.header.str().contains('application/json') {
						r := json2.raw_decode(app.response.body) or { return }
						text = '${r.prettify_json_str()}'
					} else {
						text = app.response.body
					}
				}
				'checkbox_headers' {
					text = app.response.header.str()
				}
				else {}
			}
			app.response_box.set_text(text)
			break
		}
	}
}

fn (mut app App) make_name_value_row() &ui.Stack {
	index := rand.u32()
	mut minus_btn := ui.button(
		height: 16
		width: 16
		text: '-'
		on_click: app.minus_btn_click
		on_mouse_enter: fn (mut b ui.Button, e &ui.MouseMoveEvent) {
			b.style.bg_color = gx.rgb(252, 252, 252)
		}
		on_mouse_leave: fn (mut b ui.Button, e &ui.MouseMoveEvent) {
			b.style.bg_color = gx.rgb(255, 255, 255)
		}
	)
	minus_btn.style_params.radius = 0.0
	row := ui.row(
		id: 'row_${index}'
		// bg_color: gx.rgb(230, 230, 230)
		// heights: ui.stretch
		children: [
			ui.label(
				height: 20
				text: 'name:'
				text_vertical_align: .top
				text_color: gx.gray
			),
			ui.textbox(
				mode: .line_numbers
				z_index: 1
				id: 'name_${index}'
				width: 100
				height: 20
				line_height_factor: 20.0
				fitted_height: true
				text_size: 16
				bg_color: gx.rgb(250, 250, 250)
				clipping: true
			),
			ui.label(
				height: 20
				text: ' value:'
				text_vertical_align: .top
				text_color: gx.gray
			),
			ui.textbox(
				mode: .line_numbers
				z_index: 2
				id: 'value_${index}'
				width: 100
				height: 20
				line_height_factor: 20.0
				fitted_height: true
				text_size: 16
				bg_color: gx.rgb(250, 250, 250)
				clipping: true
			),
			minus_btn,
		]
	)

	return row
}
