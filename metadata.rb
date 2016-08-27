name 'chef-xcode'
maintainer '#DI DevOps Engineers'
maintainer_email 'DIDevOpsEngineers@disney.com'
license 'All rights reserved'
description 'Installs/Configures Xcode'
long_description 'Installs/Configures Xcode'
version '1.0.0'

%w(mac_os_x).each do |os|
  supports os
end

depends 'dmg'
depends 'ark'
