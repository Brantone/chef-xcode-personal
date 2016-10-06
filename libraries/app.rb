#
# Cookbook Name:: chef-xcode
# Library:: app
#
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/resource'
require 'chef/provider'

module Xcode
  module Resources
    module XcodeApp
      # A 'xcode_app' resource to install and uninstall Xcode components.

      class Resource < Chef::Resource::LWRPBase
        self.resource_name = :xcode_app
        provides(:xcode_app)
        actions(:install, :uninstall)
        default_action(:install)

        attribute(:version, kind_of: String, name_attribute: true)
        attribute(:url, kind_of: String, required: true)
        attribute(:checksum, kind_of: String, required: true)
        attribute(:app, kind_of: String, required: true)
        attribute(:install_root, kind_of: String, default: '/Applications')
        attribute(:force, kind_of: [TrueClass, FalseClass], default: false)
      end

      class Provider < Chef::Provider::LWRPBase
        provides(:xcode_app)
        use_inline_resources

        action :install do
          return if exists?
          case Chef.node.platform_family
            when 'mac_os_x'
              install_app
            else
              raise "Xcode App LWRP only support OSX"
          end
        end

        action :uninstall do
          if exists?
            directory install_dir do
              recursive true
              action :delete
            end
          end
        end

        def install_app
          # Remove folder if it exists and we force the install.
          directory install_dir do
            recursive true
            action :delete
          end if new_resource.force && exists?

          temp_pkg_dir = ::File.join(Chef::Config[:file_cache_path], "Xcode_#{new_resource.version}")
          temp_pkg_file = ::File.join(temp_pkg_dir, ::File.basename(new_resource.url))

          directory temp_pkg_dir do
            recursive true
          end

          if new_resource.url.end_with?('dmg')

            dmg_package "Xcode" do
              app new_resource.app
              source new_resource.url
              checksum new_resource.checksum
              dmg_name ::File.basename(new_resource.url, '.dmg')
              owner 'root'
              type 'app'
              destination temp_pkg_dir
              action :install
            end

            # Because DMG just contains the .app, it's unpacked to cache, 
            # then moved /Applications/ so multiple installs can be available
            execute "mv -f #{temp_pkg_dir}/Xcode.app #{install_dir}" do
              only_if { Dir.exist?("#{temp_pkg_dir}/Xcode.app") }
            end

          elsif new_resource.url.end_with?('xip')
=begin For some reason this doesn't work with some XIPs, Apple?
            remote_file "Xcode" do
              source new_resource.url
              checksum new_resource.checksum
              path temp_pkg_file
              action :create
            end

            bash 'Extracting xip using xar' do
              user 'root'
              cwd temp_pkg_dir
              code <<-EOH
                #!/bin/sh
                xar -xf #{temp_pkg_file}
              EOH
            end

            ark "Xcode" do
              name 'Content'
              url "file://#{temp_pkg_dir}/Content"
              extension 'tar.gz'
              path '/Applications'
              action :put
            end
=end
          else
            # Need to log error unsupported extension
          end

          # clean up installer file but check if the install dir moved 1st
          if exists?
            delete_installer_file(temp_pkg_file)
          end
          directory temp_pkg_dir do
            recursive true
            action :delete
            only_if { Dir.exists?(temp_pkg_dir) }
          end

        end

        def install_dir
          ::File.join(new_resource.install_root, "Xcode_#{new_resource.version}.app")
        end

        def exists?
          new_resource.force ? false : Dir.exists?(install_dir)
        end

        # remove the installer file from chef cache dir
        # this help save some storage space
        def delete_installer_file(pkg_file)
          file pkg_file do
            action :delete
            only_if { ::File.exist?(pkg_file) }
          end
        end
      end
    end
  end
end
