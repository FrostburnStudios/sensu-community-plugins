#! /usr/bin/env ruby
#
#
# DESCRIPTION:
#
# OUTPUT:
#   plain-text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# #YELLOW
# needs usage
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

# !/usr/bin/hbase org.jruby.Main
#
# HBase status plugin
# ===
#
# This plugin checks if any of the regionservers are down
#
# Copyright 2011 Runa Inc
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'java'
require 'pp'

include Java
include_class('java.lang.Integer') { |_package, name| "J#{name}" }
include_class('java.lang.Long')    { |_package, name| "J#{name}" }
include_class('java.lang.Boolean') { |_package, name| "J#{name}" }

import org.apache.hadoop.hbase.client.HBaseAdmin
import org.apache.hadoop.hbase.client.HTable
import org.apache.hadoop.hbase.HBaseConfiguration
import org.apache.hadoop.hbase.util.Bytes
import org.apache.log4j.Logger

packages = ['org.apache.zookeeper', 'org.apache.hadoop', 'org.apache.hadoop.hbase']

packages.each do |package|
  logger = org.apache.log4j.Logger.getLogger(package)
  logger.setLevel(org.apache.log4j.Level::ERROR)
end

module SensuUtils
  # Copied from sensu-plugin

  EXIT_CODES = {
    'OK' => 0,
    'WARNING' => 1,
    'CRITICAL' => 2,
    'UNKNOWN' => 3
  }

  def output(fn, *args)
    puts "#{fn.upcase}: #{args}"
  end

  EXIT_CODES.each do |status, code|
    define_method(status.downcase) do |*args|
      output(status, *args)
      exit(code)
    end
  end
end

include SensuUtils

def check_hbase_status
  conf  = HBaseConfiguration.new
  admin = HBaseAdmin.new(conf)

  status = admin.getClusterStatus
  dead_servers = status.getDeadServerNames

  count = dead_servers.length

  if count == 0
    ok 'Alive'
  else
    critical "Dead: #{dead_servers.join(' ')}"
  end

  unknown 'No output from plugin'
end

check_hbase_status
