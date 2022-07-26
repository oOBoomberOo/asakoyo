export class InvalidProvider < Error
	constructor actual\string, expected\string
		super "Invalid provider, expected {expected} but got {actual}"
	
	static def assert actual\string, expected\string
		unless actual === expected
			throw new InvalidProvider actual, expected
