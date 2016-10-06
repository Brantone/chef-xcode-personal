#
# Cookbook Name:: chef-xcode
# Attribute:: default
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

default['xcode']['databag'] = 'xcode_versions'
default['xcode']['app']['install_root'] = '/Applications'
default['xcode']['app']['link_id'] = 'v731'
default['xcode']['app']['last_gm_license'] = 'EA1327'
default['xcode']['app']['version_gm_license'] = '7.3.1'
