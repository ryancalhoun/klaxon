require 'artii'
require 'colorize'
require 'securerandom'
require 'terminfo'

# Insert a programmable interactive warning prompt for developers
# before taking dangerous or destructive action.
#
# Example:
#   Klaxon.alert banner: 'Delete', description: 'About to delete files!' do
#     system "rm -rf"
#   end
#
#   # prints to STDERR...
#    _____       _      _       
#   |  __ \     | |    | |      
#   | |  | | ___| | ___| |_ ___ 
#   | |  | |/ _ \ |/ _ \ __/ _ \
#   | |__| |  __/ |  __/ |_  __/
#   |_____/ \___|_|\___|\__\___|
#                                 
#
#   About to delete files!
#   To continue, press ENTER. To abort, press Ctrl+C...
module Klaxon

  YESNO = :yesno
  ENTER = :enter
  RANDOM = :random

  # Issues the alert prompt, unless running in a CI environment. The prompt is always
  # to STDERR.
  #
  # When run with a block, denying the prompt will simply not call the block. When
  # run without a block, denying will cause a system exit.
  #
  # * +:banner:+ - A large block banner displayed figlet-style
  # * +:description:+ - Paragraph text for the prompt, with line feeds preserved
  # * +:color:+ - A symbol like :red or :yellow which will color the whole prompt
  # * +:type:+ - Either :enter (the default), :yesno, :random, or literal text
  # * +:ci:+ - If nil, auto-detect a CI environment from the ENV; if true, behave like a CI environment; if false, halt if it is a CI environment
  #
  def self.alert(banner: nil, description: nil, color: nil, type: nil, ci: nil, &dangerous)
    execute = proc do
      if dangerous
        return dangerous.call
      else
        return true
      end
    end

    halt = proc do
      if dangerous
        STDERR.puts "\nSkipping.".colorize color
        return false
      else
        STDERR.puts "\nExiting."
        exit 1
      end
    end

    prompt = proc do |msg,&ok|
      STDERR.print msg
      begin
        if ok[STDIN.gets.chomp.downcase]
          execute.call
        end
      rescue Interrupt
      end

      halt.call
    end

    if ci == true
      execute.call
    elsif !STDIN.isatty && (ENV['CI'] || ENV['JENKINS_URL'])
      if ci != false
        execute.call
      else
        halt.call
      end
    end

    if banner
      STDERR.puts
      STDERR.puts Artii::Base.new.asciify(banner).each_line.map {|line| "    " + line[0..TermInfo.screen_width-4] }.join.colorize color
      STDERR.puts
    end

    if description
      STDERR.puts description.colorize color
    end

    case type
    when ENTER, nil
      prompt.call "To continue, press ENTER. To abort, press Ctrl+C..." do
        true
      end
    when YESNO
      prompt.call "Continue? [y/N]: " do |val|
        ['y', 'yes'].include?(val)
      end
    when RANDOM
      digits = SecureRandom.hex(2)
      prompt.call "To continue, type #{digits.upcase.split(//).join(" ")}\n> " do |val|
        val.gsub(/\s+/, '') == digits
      end
    else
      prompt.call "To continue, type \"#{type}\"\n> " do |val|
        val == type
      end
    end
  end
end
