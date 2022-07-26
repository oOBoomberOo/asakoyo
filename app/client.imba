import './components/news'
import './components/credentials'
import './components/publication'
import * as api from './api'
import { store, logged-in, has-publications } from './store'

global css @root
	$primary-color: orange5
	$button-color: teal4
	$background-color: warm1
	$on-primary-color: warm1
	$on-button-color: warm1
	$on-background-color: warm6

global css html, body
	ff: sans
	bg: $background-color
	c: $on-background-color

tag app
	css self
		p: 15px clamp(50px, 25%, 200px)
	
	def mount
		store.user = await api.me()
		store.subreddits = await api.subreddits()
		store.publications = await api.publications()
	
	<self>
		<credentials>
		<hr>
		<news-form>
		<hr>
		
		if logged-in()
			<publication-list>

imba.mount <app>