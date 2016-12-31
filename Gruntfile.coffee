module.exports = (grunt) ->
	grunt.initConfig
		coffee:
			compile:
				files: [
					expand: true
					cwd: 'src/'
					src: ['**/*.coffee']
					dest: '.'
					ext: '.js'
				]

	grunt.loadNpmTasks 'grunt-contrib-coffee'

	grunt.registerTask 'default', ['coffee']