#!/usr/bin/env ruby

require '../db.rb'

ActiveRecord::Schema.define do
	create_table :coords do |table|
		table.column :from, :string
		table.column :n, :integer
		table.column :x, :integer
		table.column :y, :integer
		table.column :value, :boolean
        table.column :time, :datetime
		table.column :ms, :integer
		table.column :sent, :boolean
        table.column :check, :boolean
    end
end
