module.exports = (grunt) ->
	grunt.initConfig
		apidoc:
			nexrad:
				src: 'src/'
				dest: 'docs/'
		'string-replace':
			nexrad:
				files:
					'README.md': 'api.md'
				options:
					replacements: [
						{
							pattern: /[^}]\n(```)(\n.)/ig
							replacement: '\n$1json$2'
						}
						{
							pattern: /<p>|<\/p>/ig
							replacement: ''
						}
					]
		clean:
			docs:
				'api.md'
		coffee:
			compile:
				files: [
					expand: true
					cwd: 'src/'
					src: ['**/*.coffee']
					dest: '.'
					ext: '.js'
				]

	grunt.loadNpmTasks 'grunt-apidoc'
	grunt.loadNpmTasks 'grunt-string-replace'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-clean'

	grunt.registerTask 'default', ['apidoc', 'string-replace', 'clean', 'coffee']