# The root module for Puppet Strings.
module PuppetStrings
  # The glob patterns used to search for files to document.
  DEFAULT_SEARCH_PATTERNS = %w(
    manifests/**/*.pp
    functions/**/*.pp
    types/**/*.pp
    lib/**/*.rb
  ).freeze

  # Generates documentation.
  # @param [Array<String>] search_patterns The search patterns (e.g. manifests/**/*.pp) to look for files.
  # @param [Hash] options The options hash.
  # @option options [Boolean] :debug Enable YARD debug output.
  # @option options [Boolean] :backtrace Enable YARD backtraces.
  # @option options [String] :markup The YARD markup format to use (defaults to 'markdown').
  # @option options [String] :json Enables JSON output to the given file. If the file is nil, STDOUT is used.
  # @option options [Array<String>] :yard_args The arguments to pass to yard.
  # @return [void]
  def self.generate(search_patterns = DEFAULT_SEARCH_PATTERNS, options = {})
    require 'puppet-strings/yard'
    PuppetStrings::Yard.setup!

    # Format the arguments to YARD
    args = ['doc']
    args << '--debug'     if options[:debug]
    args << '--backtrace' if options[:backtrace]
    args << "-m#{options[:markup] || 'markdown'}"

    render_as_json = options.key? :json
    json_file = nil
    if render_as_json
      json_file = options[:json]
      # Disable output and prevent stats/progress when writing to STDOUT
      args << '-n'
      args << '-q' unless json_file
      args << '--no-stats' unless json_file
      args << '--no-progress' unless json_file
    end

    yard_args = options[:yard_args]
    args += yard_args if yard_args
    args += search_patterns

    # Run YARD
    YARD::CLI::Yardoc.run(*args)

    # If outputting JSON, render the output
    if render_as_json
      require 'puppet-strings/json'
      PuppetStrings::Json.render(json_file)
    end
  end

  # Runs the YARD documentation server.
  # @param [Array<String>] args The arguments to YARD.
  def self.run_server(*args)
    require 'puppet-strings/yard'
    PuppetStrings::Yard.setup!

    YARD::CLI::Server.run(*args)
  end
end
