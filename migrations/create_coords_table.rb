#!/usr/bin/env ruby

require '../db.rb'

ActiveRecord::Schema.define do
	create_table :coords do |table|
		table.column :x, :integer
		table.column :y, :integer
		table.column :time, :date
		table.column :sent, :boolean
	end
end