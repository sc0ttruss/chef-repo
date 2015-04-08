require 'chef/provisioning/aws_driver'
with_driver 'aws'

name = "amanly"

# declare security groups
aws_security_group "#{name}-ssh" do
  inbound_rules [{:ports => 22, :protocol => :tcp, :sources => ['0.0.0.0/0'] }]
end

aws_security_group "#{name}-http" do
  inbound_rules [{:ports => 80, :protocol => :tcp, :sources => ['0.0.0.0/0'] }]
end

# specify what's needed to create a machine
with_machine_options({
  :bootstrap_options => {
    :instance_type => "t1.micro",
    :key_name => "amanly",
    :security_groups => [ "#{name}-ssh","#{name}-http"]
  },
  :ssh_username => "root",
  :image_id => "ami-b6bdde86"
})

# declare a machine to act as our web server
elb_instances = []

machine_batch do
  1.upto(3) do |n|
    instance = "#{name}-webserver-#{n}"
    machine instance do
      recipe "webserver"
      tag "my-webserver"
      converge true
    end
    elb_instances << instance
  end
end

load_balancer "#{name}-webserver-lb" do
  load_balancer_options({
    :availability_zones => ["us-west-2a", "us-west-2b", "us-west-2c"],
    :listeners => [{:port => 80, :protocol => :http, :instance_port => 80, :instance_protocol => :http }],
    :security_group_name => "#{name}-http"
  })
  machines elb_instances
end
