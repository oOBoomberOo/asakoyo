import * as api from '../api'
import { store, fetching } from '../store'

tag credentials
	get twitter
		store.user..providers..twitter
	
	get reddit
		store.user..providers..reddit
	
	def state
		if twitter and reddit
			<>
				<p[ta: center]> "You are now logged in!"
		elif twitter
			<>
				<p> "Next, grant this app the ability to post to your reddit account"
				<p> "Press {<social-login provider="Reddit">} to grant access."
		elif !fetching()
			<>
				<p> "Welcome to AsaKoyo, a simple news publication site for Holonews."
				<p> "Press {<social-login provider="Twitter">} to get started."
		else
			<p[ta: center]> "Authenticating..."

	<self>
		state()

	
css .disabled
	$button-color: warm6
	$primary-color: warm7
	$on-button-color: warm3
	$on-primary-color: warm3

tag social-login < a
	css self
		d: inline-block
		bg: $button-color @hover: $primary-color
		c: $on-button-color @hover: $on-primary-color
		rd: 5px
		p: 5px 10px
		td: none
		
	prop provider = "Unknown"
	prop checked = false

	get url
		"/auth/{provider.toLowerCase!}"
	
	get content
		if checked
			"✓"
		else
			"Sign-in with {provider}"

	<self .disabled=checked href=url @click.if(checked).prevent> content
