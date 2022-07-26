import type { Provider } from "@prisma/client"
import axios from 'axios'
import { IMGUR_CLIENT_ID } from "./env.imba"
import { ImgurClient } from "imgur"
import sharp from 'sharp'
import ffmpeg from 'fluent-ffmpeg'
import fs from 'fs'
import { UnsupportedImageType } from './error'
import tempfile from 'tempfile'

export class Imgur
	constructor client\ImgurClient
		#client = client

	
	static provider-name = "imgur"

	static def fromEnv
		let client = new ImgurClient
			clientId: IMGUR_CLIENT_ID

		new Imgur client

	# TODO: handle GIFs	
	def preprocessor file\(Express.Multer.File)
		if file.mimetype === "image/webp" || file.mimetype === "image/jpeg"
			let buffer = await sharp(file.buffer)
				.png()
				.toBuffer()
			{ ...file, buffer }
		elif file.mimetype === "image/png"
			{ ...file }
		else
			throw new UnsupportedImageType(file.mimetype)
	
	def create-album files\(Express.Multer.File[])
		let ids = []

		let buffers = await Promise.all files.map do(file)
			await preprocessor(file)
		
		for file in buffers
			let img = await #client.upload
				image: file.buffer
				name: file.originalname
			
			console.log "Uploaded image {img.data.id} / {img.data.link}"

			if img.success
				ids.push img.data.deletehash
			else
				console.log img.data
		
		let params =
			deletehashes: ids
		
		let response = await axios.post 'https://api.imgur.com/3/album', params, {
			headers:
				Authorization: `Client-ID {IMGUR_CLIENT_ID}`
		}

		let album = response.data.data
		console.log "Created album {album.id}"

		return album
