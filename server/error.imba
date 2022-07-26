import type { Request, Response } from 'express'
import { AxiosError } from 'axios'

export class InvalidProvider < Error
	constructor actual\string, expected\string
		super "Invalid provider, expected {expected} but got {actual}"
	
	static def assert actual\string, expected\string
		unless actual === expected
			throw new InvalidProvider actual, expected

export class UnsupportedImageType < Error
	constructor got\string
		super "Unsupported image type: {got} file cannot be uploaded to imgur.com"

export class ImageTooLarge < Error
	constructor filename\string, filesize\number, limit\number
		super "Image too large - {filename} cannot be uploaded to imgur.com because it is {filesize} bytes, but the limit is {limit} bytes"
	
	static def assert filename\string, filesize\number, limit\number
		unless filesize <= limit
			throw new ImageTooLarge filename, filesize, limit

export def handle-error req\Request, res\Response, err\Error
	if err isa InvalidProvider
		res.status(400).json { type: "error", message: err.message }
	elif err isa UnsupportedImageType
		res.status(400).json { type: "error", message: err.message }
	elif err isa ImageTooLarge
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
