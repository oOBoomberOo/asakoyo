export tag SocialLogin
	css self
		bg: $button-color @hover: $primary-color
		color: $on-button-color @hover: $on-primary-color
		p: 5px 15px

	css a
		td: none
		c: inherit
	
	prop provider = "Unknown"

	<self>
		<a.social href="/auth/{provider.toLowerCase!}"> "Sign-in with {provider}"