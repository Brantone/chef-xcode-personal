#
# Cookbook Name:: chef-xcode
# Recipe:: editor
#
# Copyright (C) 2016 Disney Consumer Products Interactive
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'ark'

xcode_versions = data_bag(node['xcode']['databag'])

xcode_versions.each do |version|
  xcode = data_bag_item(node['xcode']['databag'], version)

  xcode_app xcode['id'] do
    app xcode['app']
    url xcode['url']
    checksum xcode['checksum']
    force xcode['force'] unless xcode['force'].nil?
    action xcode['action']
  end
end

