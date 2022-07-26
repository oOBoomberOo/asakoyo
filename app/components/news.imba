import './template'
import { DateTime } from 'luxon'
import * as api from '../api'
import { store, has-subreddits } from '../store'

let langs = {
	EN: 'English'
	JP: 'Japanese'
	CN: 'Chinese'
	KR: 'Korean'
	FR: 'French'
	IT: 'Italian'
}

def files-input disabled
	<label[ga: file] htmlFor="files"> "Files"
		<input type='file'
				id='files'
				name='files'
				required
				multiple
				disabled=disabled
				accept='image/*'>

def week-input disabled, current-week
	<label[ga: week] htmlFor='week'> "Week"
		<input type='week' name='week' defaultValue=current-week required disabled=disabled>

def lang-input disabled
	<label[ga: lang] htmlFor='language'> "Language"
		<select name='language' required disabled=disabled>
			for own key,lang of langs
				<option value=key> lang

def subreddit-input disabled
	<label[ga: subreddit] htmlFor='subreddit'> "Subreddit"
		<select name='subreddit' disabled=(not has-subreddits!) required disabled=disabled>
			<option value="" disabled> "Select Subreddit"
			for subreddit of store.subreddits
				<option value=subreddit> "{subreddit}"

def hashtag-input disabled, defaultValue
	<label[ga: hashtag] htmlFor='hashtag'> "Hashtags"
		<input type='text' name='hashtag' defaultValue=defaultValue required disabled=disabled>

def submit-button disabled
	<button[ga: submit] disabled=disabled> "Submit"

global css input, select
	d: block
	w: 100%

tag news-form
	css self
		pos: relative

	css form
		d: grid
		p: 15px
		g: 15px
		gt: "file week lang" "hashtag hashtag hashtag" "subreddit subreddit submit"
		
	css .error-box
		d: block
		p: 0 5px
		c: red7
		bg: red2
		bd: 1px solid red6
		rd: 5px
		ta: center
	
	css .loader
		d: flex
		fld: column
		c: $on-background-color
		p: 15px
		ta: center
		jc: center
		ai: center
		$primary-color: warm4
	
	css @keyframes spin
		0% transform: rotate(0deg)
		100% transform: rotate(360deg)

	css .spinner
		w: 64px
		h: 64px
		bd: 8px solid transparent
		bcb: $primary-color
		rd: 50%
		animation: spin 1s linear infinite
	
	prop data = {
		language: "en"
		hashtag: "#HolonewsDev"
	}

	prop loading = false
	prop error = null

	get current-week
		let date = DateTime.now()
		let weekNumber = "{date.weekNumber}".padStart(2, '0')
		"{date.weekYear}-W{weekNumber}"
	
	get disabled
		(not store.user) or loading

	def handle event
		let form = new FormData(event.target)

		try
			loading = true
			error = null
			await api.publish-news form
			window.location.reload()
		catch err
			error = err.response.data
		finally
			loading = false
	
	<self>
		if error
			<div.error-box>
				<p> "{<span[fw: bold]> "Error:"} {error.message}"

		if loading
			<div.loader>
				<p> "Your publication is being queued, this will take a while. you may close this window."
				<div.spinner>
		else
			<form @submit.prevent.if(not disabled)=handle>
				files-input(disabled)
				week-input(disabled, current-week)
				lang-input(disabled)
				hashtag-input(disabled, data.hashtag)
				subreddit-input(disabled)
				submit-button(disabled)
