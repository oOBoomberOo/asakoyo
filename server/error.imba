import type { Request, Response } from 'express'
import { AxiosError } from 'axios'

export class InvalidProvider < Error
	constructor actual\string, expected\string
		super "Invalid provider, expected {expected} but got {actual}"
	
	static def assert actual\string, expected\string
		unless actual === expected
			throw new InvalidProvider actual, expected

export def handle-error req\Request, res\Response, err\Error
	if err isa InvalidProvider
		res.status(400).json { type: "error", message: err.message }
	elif err isa AxiosError
		def from obj\object, fields
			unless obj
				return obj

			let entries = Object.entries(obj).filter do([key, value])
				fields.includes key
			Object.fromEntries entries
		
		let request = from err.request, ['_header']
		let response = from err.response, ['headers', "status", "statusText", "config"]

		console.error "Unexpected error during OAuth2 callback:"
		console.error "Request:", request
		console.error "Response:", response
		console.error "Data:", response.data
		res.status(500).json { type: "error", message: "Internal server error" }
	elif err isa Error
		console.error err
		res.status(500).json { type: "error", message: "Internal server error" }
