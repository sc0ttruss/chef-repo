# declare a machine to act as our web server
require "chef/provisioning/aws_driver"
with_driver "aws"

name = "amanly"

# specify what's needed to destroy a machine
with_machine_options({
  :bootstrap_options => {
    :key_name => "#{name}",
  },
  :ssh_username => "root",
})

# declare a machine to act as our web server
1.upto(3) do |n|
  instance = "#{name}-webserver-#{n}"
  machine instance do
    action :destroy
  end
end

load_balancer "#{name}-webserver-elb" do
  action :destroy
end

# aws_security_group "#{name}-ssh" do
#  action :delete
#  vpc_id "vpc-abd534ce"
# end

# aws_security_group "#{name}-http" do
#  action :delete
#  vpc_id "vpc-abd534ce"
# end

