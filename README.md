# AWS Stack Deploy Demo

This project demonstrates deploying a simple microservices app.  The app is
deployed using Terraform.  The various components are scheduled using Nomad,
and Consul is used for service discovery by those components.  This is a basic
demonstration.  Best practices were not used, and there is room for improvement
in a number of areas.

# Detail

The application stack is comprised of four Ubuntu 16.04 servers.  One of the
servers runs both the Consul and Nomad server processes.  Only a single server
is used for the purposes of this demo.  In production you would need three or
five Consul and Nomad servers or data loss is inevitable.  

Of the three remaining servers one hosts a locally installed Mongodb database.  
The other two only have Docker installed locally.  All three servers will host
a simple Node.js application running in a container.  That application uses
Consul to find the database server, and writes a record to the database each
time the default route is visited.

This configuration is intended to demonstrate how containerized microservices
could theoretically consume an existing shared resource such as a database.  Using Nomad we can register this existing service (Mongodb in our case) making
it available to our new microservice apps while remaining accessible to legacy
applications that rely upon it.

There is also a job defined to run Mongodb in a container to demonstrate how one
might spin up short lived dev environments.  Whichever strategy is used our
microservice apps can still communicate with the DB thanks to the service
discovery provided by Consul.

# Usage

```
git clone https://github.com/luddyte/aws_stack_deploy_demo.git
cd aws_stack_deploy_demo/deploy/
terraform plan
terraform apply
```

The Terraform code is contained in the 'deploy' directory.  The code assumes
you have configured your .aws/credentials file, and are using ssh-agent.  
Simply run 'terraform apply' from within that directory.  Once the app is
deployed you can connect to application_address output value ('terraform output')
to verify the app is functioning.  Please note that it may take a few minutes for
the DNS record to propagate, and the page to become available using the ELB URL.

When you are done with the resoures run 'terraform destroy' to clean up.
