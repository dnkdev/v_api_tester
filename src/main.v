module main

fn main() {
	mut app := App{}
	app.create_window()
	// test 
	// https://api.telegram.org/bot5401623750:AAFWXZWx8V-SZIDQUI62AT7agCMs55aLIdU/getMe
	// https://api.ipify.org
	app.url_box.set_text('https://api.ipify.org')

	app.run()
}
