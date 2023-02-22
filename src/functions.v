module main

import gx
import ui
import rand
import x.json2
import net.http
import time

fn (mut app App) fetch_request_result() {
	method := get_method_by_index(app.request_type.selected_index)
	url_text := app.url_box.text

	// get query parameters
	mut params := map[string]string{}
	for pp in app.parameter_row.children {
		id := pp.id.split('_').last().u32()
		name := app.window.get_or_panic[ui.TextBox]('name_${id}')
		value := app.window.get_or_panic[ui.TextBox]('value_${id}')
		params[*name.text] = *value.text
	}

	fetch_config := http.FetchConfig{
		url: url_text
		method: method
		params: params
	}
	mut bm := time.ticks()
	response := http.fetch(fetch_config) or {
		app.result_label.text_styles.current.color = gx.rgb(150, 0, 0)
		app.status_msg_label.set_text('')
		app.result_label.set_text('Request Error:')
		app.response_box.set_text('${err}')
		return
	}
	bm = time.ticks() - bm
	if response.status_code == 200 {
		app.result_label.text_styles.current.color = gx.rgb(0, 150, 0)
	} else if response.status_code >= 300 {
		app.result_label.text_styles.current.color = gx.rgb(250, 150, 0)
	}
	app.result_label.set_text('Status code: ${response.status_code}')
	app.status_msg_label.set_text('${response.status_msg}')
	app.response = response
	app.set_result_text_by_checkbox()
	

	mut history_tb := ui.textbox(
		mode: .line_numbers | .read_only
		z_index: 1
		width: 250
		height: 16
		text_size: 16
		bg_color: gx.white
		borderless: true
	)
	history_tb.set_text('${time.now()} [${response.status_code}] ${method} ${bm}ms ${response.status_msg} ${*url_text}')
	app.history_row.add(
		at:0
		child: history_tb
	)

}

fn get_method_by_index(index int) http.Method {
	if index >= request_methods.len || index < 0 {
		return http.Method.get
	}
	return request_methods[index]
}

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
	// println('${index} created')
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
				width: 150
				height: 20
				text_size: 16
				bg_color: gx.rgb(250, 250, 250)
				// clipping: true
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
				width: 150
				height: 20
				text_size: 16
				bg_color: gx.rgb(250, 250, 250)
				// clipping: true
			),
			minus_btn,
		]
	)

	return row
}
