require 'mkmf'

command = "sudo ln -nfs #{File.expand_path("../qor_test", __FILE__)} /usr/bin/"
puts command
system command

create_makefile('qor_test/qor_test')
