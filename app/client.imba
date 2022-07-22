import { SocialLogin } from './components/credentials'

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
	
	css .container
		d: flex
		fld: row
		ai: center
		jc: center
		g: 15px

	<self>
		<div.container>
			<SocialLogin provider="Twitter">
			<SocialLogin provider="Reddit">

imba.mount <app>