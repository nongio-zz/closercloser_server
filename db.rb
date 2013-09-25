#!/usr/bin/env ruby

require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3', # or 'postgresql' or 'sqlite3'
  database: 'closercloser_test.db'
)

class Coords < ActiveRecord::Base
	
end