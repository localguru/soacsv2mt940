#!/usr/bin/env ruby
# encoding: UTF-8

# require 'debug'

require 'logger'
require 'date'
require 'optparse'

require_relative 'soacsv2mt940/version'
require_relative 'soacsv2mt940/soacsv'
require_relative 'soacsv2mt940/soamt940'

# Namespace SOACSV2MT940 -- wraps everything together
module SOACSV2MT940
  LOGGER = Logger.new(STDOUT)
  LOGGER.level = Logger::DEBUG
end
