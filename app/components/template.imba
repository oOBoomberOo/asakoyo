tag twitter-card
	prop tweet\string
	prop author\string
	prop attachment\string

	css self
		$roundness: 25px
		$avatar-size: 40px
		$primary-color: #0084b4
		$secondary-color: #fafafa
		$surface-color: #fafafa
		$link-color: #0084b4
		$on-surface-color: warm8

		bg: $surface-color
		c: $on-surface-color

		ff: "Helvetica Neue", Helvetica, Arial, sans-serif
		fs: 14px
		lh: 1.5

		d: grid
		rd: $roundness
		gta: "heading" "content" "attachment"
		gtc: minmax(300px, min-content)
		g: 5px
		p: 15px

		w: fit-content

		shadow: 0px 0px 10px -5px black
	
	css h3, h4
		fs: 14px
		m: 0
	
	css header
		d: grid
		gta: "avatar author" "avatar username"
		gtc: min-content auto
		ai: center
		cg: 5px

	css .avatar
		ga: avatar
		size: $avatar-size
		rd: 50%
		bg: warm4
		aspect-ratio: 1 / 1

	css .author
		ga: author

	css .username
		ga: username
		fw: normal
		c: warmer4
	
	css .hashtag
		c: $link-color
		td: none @hover: underline
	
	css section
		ga: content
		fs: 18px
	
	css figure
		ga: attachment
		rd: $roundness
		bd: 1px solid $secondary-color
		of: hidden
		w: fit-content
		h: fit-content
		m: 0
	
	def extract-content
		let matcher = /#(\w+)/g
		let matches = tweet.matchAll matcher

		let result = []
		let lastIndex = 0

		<>
			for match of matches
				<> "{tweet.slice lastIndex, match.index}"

				let whole-word = match[0]
				let topic = match[1]

				<a.hashtag target="_blank" href="https://twitter.com/hashtag/{topic}"> whole-word
				lastIndex = match.index + whole-word.length
		
	<self>
		<header>
			<.avatar>
			<h3.author> author
			<h4.username> "@{author}"
		<section> extract-content!
		<figure>
			<img src=attachment>
