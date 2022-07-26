import type { User, Publication } from '@prisma/client'
import axios from 'axios'

export def me
	let response = await axios.get '/me'
	return response.data\User

export def subreddits
	let response = await axios.get '/subreddits'
	return response.data\string[]

export def publish-news form-data
	let response = await axios.post '/publications', form-data, {
		headers:
			'Content-Type': 'multipart/form-data'
	}

	return response.data\Publication

export def publications
	let response = await axios.get '/publications'
	return response.data\Publication[]

export def remove-publication\Promise<void> id
	await axios.delete "/publications/{id}"
