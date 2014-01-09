using build::BuildPod

class Build : BuildPod {

	new make() {
		podName = "afBounce"
		summary = "A library for testing Bed applications!"
		version = Version("0.0.1")

		meta	= [	"org.name"		: "Alien-Factory",
					"org.uri"		: "http://www.alienfactory.co.uk/",
					"vcs.uri"		: "https://bitbucket.org/Alien-Factory/afbounce",
					"proj.name"		: "Bounce",
					"license.name"	: "BSD 2-Clause License",	
					"repo.private"	: "true"

				]



		depends = ["sys 1.0", "afIoc 1.4+", "afBedSheet 1.0+", "util 1.0"]
		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true

	}
}
