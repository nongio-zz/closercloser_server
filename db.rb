#!/usr/bin/env ruby
require 'rubygems'
require 'active_record'
require 'mysql'

ActiveRecord::Base.establish_connection(
  adapter:  'mysql', # or 'postgresql' or 'sqlite3'
  database: 'closercloser',
  username: "riccardo"
)

class Coords < ActiveRecord::Base
	
end