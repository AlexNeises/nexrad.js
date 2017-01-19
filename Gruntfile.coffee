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
			docs: [
				'api.md'
			]
		coffee:
			server:
				files: [
					expand: true
					cwd: 'src/server/'
					src: ['**/*.coffee']
					dest: '.'
					ext: '.js'
				]
			client:
				files: [
					expand: true
					cwd: 'src/client/'
					src: ['**/*.coffee']
					dest: './static/'
					ext: '.js'
				]

	grunt.loadNpmTasks 'grunt-apidoc'
	grunt.loadNpmTasks 'grunt-string-replace'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-clean'

	grunt.registerTask 'default', ['string-replace', 'clean', 'coffee']
	grunt.registerTask 'gendocs', ['apidoc']
	grunt.registerTask 'develop', ['coffee']