module main

import ui
import gx
import net.http

[heap]
struct App {
mut:
	window           &ui.Window  = unsafe { nil }
	url_box          &ui.TextBox = unsafe { nil }
	request_btn      &ui.Button  = unsafe { nil }
	response_box     &ui.TextBox = unsafe { nil }
	result_label     &ui.Label   = unsafe { nil }
	status_msg_label &ui.Label   = unsafe { nil }

	request_type  &ui.Dropdown = unsafe { nil }
	parameter_row &ui.Stack    = unsafe { nil }
	checkbox_row  &ui.Stack    = unsafe { nil }
	history_row	  &ui.Stack    = unsafe { nil }
	response      http.Response
}

const (
	request_methods = [
		http.Method.get,
		http.Method.post,
		http.Method.put,
		http.Method.head,
		http.Method.delete,
		http.Method.options,
		http.Method.trace,
		http.Method.connect,
		http.Method.patch,
	]
	win_width       = 800
	win_height      = 600
)

fn (mut app App) create_window() {
	app.request_type = ui.dropdown(
		def_text: 'Request method'
		z_index: 100000
		text_color: gx.black
		text_size: 20
		bg_color: gx.light_gray
		width: 145
		on_selection_changed: fn (mut dd ui.Dropdown) {
			dd.style.border_color = gx.light_gray
		}
	)
	for m in request_methods {
		app.request_type.items << ui.DropdownItem{
			text: m.str()
		}
	}

	app.url_box = ui.textbox(
		mode: .line_numbers
		id: 'url_box'
		placeholder: 'https://api.url...'
		width: 645
		text_size: 18
		bg_color: gx.rgb(250, 250, 250)
	)

	app.request_btn = ui.button(
		id: 'request_btn'
		text: 'Send Request'
		height: 50
		width: 500
		bg_color: gx.rgb(255, 255, 255)
		on_mouse_enter: fn (mut b ui.Button, e &ui.MouseMoveEvent) {
			b.style.bg_color = gx.rgb(252, 252, 252)
		}
		on_mouse_leave: fn (mut b ui.Button, e &ui.MouseMoveEvent) {
			b.style.bg_color = gx.rgb(255, 255, 255)
		}
	)
	app.request_btn.style_params.radius = 0.0
	app.request_btn.on_click = app.on_request_click

	app.result_label = ui.label(
		height: 16
		text: ''
		text_vertical_align: .top
	)
	app.status_msg_label = ui.label(
		height: 16
		text: ''
		text_vertical_align: .top
		text_align: .center
	)

	app.response_box = ui.textbox(
		mode: .multiline
		id: 'response_box'
		height: win_height / 2 - 100
		text_size: 20
		bg_color: gx.rgb(240, 240, 240)
	)
	app.response_box.has_scrollview = true

	app.parameter_row = ui.column(
		// heights: 1.0
		// widths: ui.compact
		// heights: ui.compact
		children: [
			// app.make_name_value_row(0)
		]
	)

	mut qp_plus_btn := ui.button(
		id: 'qp_plus_btn'
		height: 16
		width: 15
		text: '+'
		on_click: app.on_qp_plus_click
		on_mouse_enter: fn (mut b ui.Button, e &ui.MouseMoveEvent) {
			b.style.bg_color = gx.rgb(252, 252, 252)
		}
		on_mouse_leave: fn (mut b ui.Button, e &ui.MouseMoveEvent) {
			b.style.bg_color = gx.rgb(255, 255, 255)
		}
	)
	qp_plus_btn.style_params.radius = 0.0

	app.checkbox_row = ui.row(
		children: [
			ui.checkbox(
				id: 'checkbox_full'
				text: 'Full Response '
				checked: true
				on_check_changed: app.on_checkbox_click
			),
			ui.checkbox(
				id: 'checkbox_body'
				text: 'Body '
				on_check_changed: app.on_checkbox_click
			),
			ui.checkbox(
				id: 'checkbox_headers'
				text: 'Headers '
				on_check_changed: app.on_checkbox_click
			),
		]
	)
	app.history_row = ui.column(
		margin_: 0
		children:[
			//ui.label(text:'hello')
		]
	)
	app.window = ui.window(
		width: win_width
		height: win_height
		title: 'V API Tester'
		resizable: true
		children: [
			ui.column(
				margin: ui.Margin{0, 0, 10, 0}
				bg_color: gx.rgb(255, 255, 255)
				widths: 0.99
				heights: 0.33
				children: [
					ui.column(
						margin_: 5
						bg_color: gx.rgb(255, 255, 255)
						// widths: ui.fit
						children: [
							ui.row(
								// margin_: 5
								bg_color: gx.rgb(255, 255, 255)
								// widths: 0.3
								children: [
									app.request_type,
									app.url_box,
								]
							),
							ui.label(
								id: 'empty_space_label'
								height: 5
								text: ''
								text_vertical_align: .top
							),
							ui.row(
								children: [
									ui.label(
										height: 20
										text: 'Query Parameters'
										text_size: 18
										text_vertical_align: .top
									),
									qp_plus_btn,
								]
							),
							ui.label(
								id: 'empty_space_label'
								height: 5
								text: ''
								text_vertical_align: .top
							),
							app.parameter_row,
							ui.label(
								id: 'empty_space_label'
								height: 10
								text: ''
								text_vertical_align: .top
							),
							app.checkbox_row,
							ui.label(
								id: 'empty_space_label'
								height: 5
								text: ''
								text_vertical_align: .top
							),
							app.request_btn,
							ui.row(
								margin_: ui.compact
								children: [
									app.result_label,
									app.status_msg_label,
								]
							),
							app.response_box,
							ui.label(
								id: 'empty_space_label'
								height: 5
								text: ''
								text_vertical_align: .top
							),
							ui.column(
								children: [
									app.history_row,
								]
							)
						]
					),
				]
			),
		]
		on_mouse_down: app.on_mouse_click
		on_resize: app.on_window_resize
	)
}

fn (mut app App) on_window_resize(window &ui.Window, w int, h int) {
	// println('${w} ${h}')
	app.response_box.height = h / 2 - 100
	app.url_box.width = w - 155
}

fn (mut app App) run() {
	ui.run(app.window)
}
