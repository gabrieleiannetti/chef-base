# Cookbook Name:: base
# Recipe:: package
#
# Author:: Victor Penso
#
# Copyright:: 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

%w(
  yum_repository
  package
  group
  user
  directory
  file
  link
  service
  systemd_unit
  route
  mount
).each do |resource|

  next unless node.has_key? resource
  next if node[resource].empty?

  if resource.eql? 'package' and node[resource].is_a? Array
    package node[resource]
    next
  end

  node[resource].each do |name,conf|

    public_send(resource, name) do
      conf.each do |key,value|
        case key
        when 'content'

          if resource.eql? 'file'
            value = "
              #
              # DO NOT CHANGE THIS FILE MANUALLY!
              #
              # This file is managed by the Chef configuration management system
              #
            #{value}
            "
          end

          value = value.gsub(/^ */,'')
          value = value.split("\n")
          value = value[1..-1] if value[0] =~ /^$/
          value = value.join("\n") << "\n"
          send(key,value)

        when 'notifies'

          send(key, *value)

        else

          send(key,value)

        end
      end
    end
  end

end