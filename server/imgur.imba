import type { Provider } from "@prisma/client"
import axios from 'axios'
import { IMGUR_CLIENT_ID } from "./env.imba"
import { ImgurClient } from "imgur"
import sharp from 'sharp'

export class Imgur
	constructor client\ImgurClient
		#client = client
	
	static provider-name = "imgur"

	static def fromEnv
		let client = new ImgurClient
			clientId: IMGUR_CLIENT_ID

		new Imgur client
	
	def preprocessor file\(Express.Multer.File)
		if file.mimetype === "image/webp" || file.mimetype === "image/jpeg"
			await sharp(file.buffer)
				.png()
				.toBuffer()
		else
			throw new Error("Unsupported image type")
	
	def create-album files\(Express.Multer.File[])
		let ids = []
		
		for file in files
			let img = await #client.upload
				image: await preprocessor(file)
				title: file.originalname
			
			console.log "Uploaded image", img

			if img.success
				ids.push img.data.deletehash
		
		let params =
			deletehashes: ids
		
		let response = await axios.post 'https://api.imgur.com/3/album', params, {
			headers:
				Authorization: `Client-ID {IMGUR_CLIENT_ID}`
		}

		let album = response.data.data
		console.log "Created album {album.id}"

		return album
